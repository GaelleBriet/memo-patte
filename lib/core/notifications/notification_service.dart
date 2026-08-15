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
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.inexactAllowWhileIdle,
  }) async {
    await init();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      payload: payload,
      androidScheduleMode: androidScheduleMode,
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
