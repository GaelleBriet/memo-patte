# Règles R8/ProGuard — audit du 2026-08-19, issue #71 point 3.11
# ("vérifier que les plugins notifications/Drift ne sont pas strippés en
# release").
#
# État actuel : la minification (`isMinifyEnabled`) n'est PAS activée
# pour le build `release` (voir `build.gradle.kts`) — ce fichier ne fait
# donc rien tant qu'elle ne l'est pas. Préparé à l'avance pour que
# l'activer plus tard (réduction de taille d'APK avant publication Play
# Store) ne casse pas les notifications au runtime sans que ça se voie
# avant un test sur appareil réel.
#
# flutter_local_notifications : ses deux `<receiver>` dans
# AndroidManifest.xml (`ScheduledNotificationReceiver`,
# `ScheduledNotificationBootReceiver`) sont référencés uniquement par
# leur nom de classe en chaîne XML — R8 ne voit aucun appel Java/Kotlin
# direct vers elles et pourrait les renommer/supprimer comme "code
# mort", faisant planter la programmation/le redémarrage des rappels
# au premier lancement en release. Le plugin sérialise aussi les
# détails de notification programmée via Gson pour survivre à un
# redémarrage (`ScheduledNotificationBootReceiver`) — même risque côté
# (dé)sérialisation par réflexion. Règles reprises de la doc officielle
# du plugin (README, section ProGuard).
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.dexterous.flutterlocalnotifications.**

# Drift / sqlite3 : PAS de règle nécessaire ici — le package `sqlite3`
# (utilisé par Drift pour parler à SQLite) passe par `dart:ffi` pour
# appeler directement `libsqlite3.so`, sans passer par des classes
# Java/Kotlin côté Android. R8 ne shrinke que le bytecode JVM/Dex ; un
# appel FFI direct depuis Dart n'a rien côté Java à stripper. Documenté
# ici pour que ça ne ressemble pas à un oubli.
