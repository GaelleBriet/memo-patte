import 'dart:developer' as developer;

/// Log structuré minimal — `dart:developer.log` plutôt qu'un package
/// dédié (`package:logging`...) : suffisant pour le besoin actuel (garder
/// une trace consultable après coup — DevTools, `adb logcat` — des
/// erreurs jusqu'ici seulement affichées à l'écran puis perdues), pas de
/// nouvelle dépendance pour ça (audit du 2026-08-19, issue #71 point
/// 3.2).
class AppLogger {
  AppLogger._();

  /// [name] : origine du log (typiquement l'écran ou le provider
  /// concerné), pour filtrer facilement parmi tous les logs de l'app —
  /// préfixé `memo_patte.` pour rester repérable au milieu des logs du
  /// moteur Flutter/des plugins natifs.
  static void error(
    String name,
    Object error, {
    StackTrace? stackTrace,
    String? message,
  }) {
    developer.log(
      message ?? error.toString(),
      name: 'memo_patte.$name',
      error: error,
      stackTrace: stackTrace,
      // 1000 = SEVERE sur l'échelle de `package:logging`, reprise ici
      // comme référence même sans en dépendre — permet de filtrer sur
      // la sévérité dans DevTools.
      level: 1000,
    );
  }
}
