import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Identifiant et libellés du canal de notification Android utilisé pour
/// tous les rappels de l'app (vaccins, vermifuges...).
///
/// Un seul canal suffit en v1 : le scope actuel (`06-mvp-scope.md`) ne
/// distingue pas les rappels par type. Le nom/la description sont visibles
/// par l'utilisatrice ou l'utilisateur dans les réglages système Android.
const String _androidChannelId = 'reminders';
const String _androidChannelName = 'Rappels';
const String _androidChannelDescription =
    'Rappels de vaccins et de vermifuges/antiparasitaires';

/// Wrapper autour de `flutter_local_notifications`.
///
/// Porte le différenciant n°1 ("rappels fiables, y compris hors-ligne") de
/// `04-differenciation.md`. Se limite volontairement à ce que couvre le
/// ticket 2.1 : initialisation, demande de permission et
/// programmation/annulation d'une notification par identifiant. L'écran de
/// "priming" (ticket 2.2) et le bandeau de statut si la permission est
/// refusée (ticket 2.3) sont des tickets séparés qui consomment ce
/// service, pas son contenu.
///
/// Important : [init] ne déclenche jamais la popup système de permission.
/// La décision actée le 2026-08-14 dans `decisions-log.md` veut qu'un
/// écran d'explication soit montré *avant* la vraie demande OS — c'est
/// pour ça que les `request*Permission` de [DarwinInitializationSettings]
/// sont à `false` ci-dessous. La permission n'est demandée qu'en appelant
/// explicitement [requestPermission] (depuis l'écran de priming, au
/// ticket 2.2).
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  /// Initialise le plugin ainsi que le fuseau horaire local (nécessaire à
  /// [scheduleNotification], qui raisonne en `TZDateTime` et non en
  /// `DateTime` local — voir la doc de `zonedSchedule` dans le package).
  ///
  /// Idempotent et sûr à appeler plusieurs fois : les autres méthodes de
  /// cette classe l'appellent systématiquement en premier, pour ne pas
  /// imposer un ordre d'appel précis à l'appelant.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // Permissions à `false` : voir la doc de la classe, demandées
    // explicitement via [requestPermission], jamais au lancement à froid.
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _androidChannelId,
            _androidChannelName,
            description: _androidChannelDescription,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  /// Déclenche la vraie demande de permission côté OS et retourne si elle a
  /// été accordée.
  ///
  /// Android 13+ (API 33) : permission `POST_NOTIFICATIONS`, à demander
  /// explicitement au runtime (elle est déclarée automatiquement par le
  /// plugin dans son propre manifest, pas besoin de la redéclarer dans
  /// celui de l'app). Avant Android 13, les notifications sont autorisées
  /// par défaut et cette méthode retourne `true` sans rien demander.
  ///
  /// iOS : alerte + son + badge, seule popup système possible pour les
  /// notifications locales.
  ///
  /// `false` sur les autres plateformes (desktop, web) : hors scope v1
  /// (`01-architecture.md` : Android + iOS uniquement).
  Future<bool> requestPermission() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return false;
  }

  /// Programme une notification locale à [scheduledDate], identifiée par
  /// [id] (le même identifiant sert à l'annuler ou la reprogrammer via
  /// [cancelNotification] — c'est aux repositories `vaccinations` et
  /// `treatments`, aux tickets 3.4/4.4, de décider quel identifiant
  /// utiliser, typiquement l'id de la ligne Drift correspondante).
  ///
  /// **Schéma d'ids, vue d'ensemble** (audit du 2026-08-19, issue #71,
  /// section sécurité "Schéma d'IDs de notification" — documenté ici
  /// plutôt qu'éclaté entre les trois repositories, pour avoir la vue
  /// d'ensemble à un seul endroit) : chaque famille dérive son id de
  /// celui de la ligne Drift correspondante, avec un décalage propre
  /// pour ne jamais se chevaucher entre familles :
  /// - Vaccin : `VaccinationRepository.notificationIdFor` — `id * 10 + 1`.
  /// - Traitement, cycle long : `TreatmentRepository.notificationIdFor` —
  ///   `id * 10 + 2`.
  /// - Traitement, heure(s) fixe(s) (une notification récurrente par
  ///   heure choisie) : `TreatmentRepository.notificationIdForSlot` —
  ///   `id * 1000 + slot * 10 + 2`, `slot` étant l'index (0, 1, 2...) de
  ///   l'heure parmi celles du traitement.
  ///
  /// `flutter_local_notifications` transmet cet id à la plateforme sous
  /// forme d'entier 32 bits signé côté Android (`Integer`, max
  /// 2 147 483 647) — la formule la plus contraignante des trois
  /// (`id * 1000 + ...`) reste donc sûre jusqu'à environ 2,1 millions de
  /// lignes de traitement, très au-delà de ce qu'une app locale
  /// mono-utilisatrice atteindra jamais en pratique. Non vérifié à
  /// l'exécution (pas de garde-fou actif) : une limite purement
  /// théorique, documentée ici pour un futur mainteneur plutôt que
  /// bloquée par du code mort.
  ///
  /// Non-collision entre les trois formules testée dans
  /// `treatment_repository_test.dart` (groupe `createTreatment`, test
  /// "l'identifiant de notification ne collisionne pas...").
  ///
  /// [scheduledDate] est une date/heure "wall clock" dans le fuseau local
  /// de l'appareil (ex. celle saisie par l'utilisateur dans un formulaire) ;
  /// elle est convertie en [tz.TZDateTime] avec le fuseau détecté par
  /// [init].
  ///
  /// Mode de programmation Android par défaut :
  /// [AndroidScheduleMode.inexactAllowWhileIdle] — se déclenche même en
  /// mode veille profonde (Doze), mais peut être retardée de quelques
  /// minutes par le système. Suffisant pour un rappel de vaccin/vermifuge
  /// (granularité du jour, pas de la minute) et ça évite de dépendre de la
  /// permission spéciale `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`, non
  /// demandée dans ce ticket. À revoir si un futur besoin exige une
  /// précision à la minute près.
  ///
  /// [matchDateTimeComponents] : `null` (défaut) programme une
  /// notification ponctuelle, à [scheduledDate] et une seule fois — c'est
  /// le cas des vaccins et des traitements à cycle long (repris à chaque
  /// échéance dépassée par `VaccinationRepository`/`TreatmentRepository`,
  /// pas de vraie récurrence côté OS). Passer
  /// `DateTimeComponents.time` (ajouté le 2026-08-17 pour les traitements
  /// à heure(s) de rappel fixe(s), `TreatmentFrequency.daily`/
  /// `severalTimesDaily`) programme au contraire une notification qui se
  /// répète nativement tous les jours à la même heure — l'OS s'occupe de
  /// la répétition, pas besoin de reprogrammer à chaque ouverture de
  /// l'app comme pour les cycles longs.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.inexactAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await init();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      payload: payload,
      androidScheduleMode: androidScheduleMode,
      matchDateTimeComponents: matchDateTimeComponents,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Indique si l'app peut programmer des alarmes exactes (Android
  /// uniquement) — audit du 2026-08-19, issue #71 point 3.4. Consommée
  /// par `TreatmentRepository._scheduleReminderTimes` pour choisir entre
  /// [AndroidScheduleMode.exactAllowWhileIdle] (traitements à heure(s)
  /// de rappel fixe(s), où l'heure précise compte réellement — prendre
  /// un médicament "vers 8h" plutôt qu'à 8h pile n'a pas le même sens
  /// que pour un vaccin dans un mois) et
  /// [AndroidScheduleMode.inexactAllowWhileIdle] (repli si la
  /// permission n'est pas accordée).
  ///
  /// Ne déclenche jamais de demande — c'est le rôle de
  /// [requestExactAlarmPermission]. `true` par défaut sur les
  /// plateformes/versions Android où l'exactitude n'est pas restreinte
  /// (avant Android 12, ou hors Android où la question ne se pose pas
  /// pour ce plugin) : c'est ce que retourne déjà
  /// `canScheduleExactNotifications` du plugin dans ces cas.
  Future<bool> canScheduleExactAlarms() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final allowed = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.canScheduleExactNotifications();
      return allowed ?? false;
    }

    return true;
  }

  /// Déclenche la vraie demande de permission d'alarmes exactes — sur
  /// Android 12+, ouvre l'écran système dédié (pas une popup in-app
  /// classique). Contrairement aux notifications elles-mêmes
  /// ([requestPermission]), pas de "priming" avant : cette permission
  /// n'est demandée qu'au moment de créer/modifier un traitement à
  /// heure(s) fixe(s), un contexte déjà explicite pour qui la déclenche.
  ///
  /// `false` sur les plateformes hors Android (rien à demander).
  Future<bool> requestExactAlarmPermission() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
      return granted ?? false;
    }

    return false;
  }

  /// Annule la notification programmée sous l'identifiant [id]. Ne fait
  /// rien si aucune notification n'est programmée sous cet identifiant.
  Future<void> cancelNotification(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }

  /// Indique si la permission de notifications est accordée *sans*
  /// déclencher de demande — contrairement à [requestPermission]. Consommé
  /// par le bandeau de statut (ticket 2.3) pour savoir s'il doit
  /// s'afficher, et par l'écran de priming (ticket 2.2) pour éviter de
  /// re-proposer la demande si elle a déjà été accordée.
  ///
  /// `false` sur les plateformes hors scope v1 (desktop, web), comme
  /// [requestPermission].
  Future<bool> arePermissionsGranted() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return status?.isEnabled ?? false;
    }

    return false;
  }

  /// Ouvre l'écran des réglages système de notifications de l'app —
  /// utilisé par le lien du bandeau de statut (ticket 2.3) quand la
  /// permission a été refusée. Sur iOS, une fois la permission refusée, une
  /// redirection vers les réglages est le seul moyen d'y revenir (pas de
  /// reprompt possible via [requestPermission]) ; Android le permet aussi
  /// en théorie mais on garde le même chemin sur les deux OS pour un
  /// comportement cohérent.
  ///
  /// Retourne si l'écran a pu être ouvert.
  Future<bool> openNotificationSettings() async {
    await init();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final opened = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.openAppNotificationSettings();
      return opened ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final opened = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.openAppNotificationSettings();
      return opened ?? false;
    }

    return false;
  }
}
