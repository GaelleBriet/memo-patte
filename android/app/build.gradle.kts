import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Signature de release (audit du 2026-08-19, issue #71 point 1.5 —
// "release signée avec les clés debug", bloquant Play Store). Lu depuis
// `android/key.properties`, jamais commité (déjà dans `.gitignore` /
// `android/.gitignore`) — voir `android/key.properties.example` pour le
// format attendu et comment générer le keystore. Pas de scaffolding
// pour le keystore lui-même : c'est un secret réel, à créer et garder
// en sécurité par Gaelle elle-même, pas par moi (règle du projet — voir
// CLAUDE.md, "Ne jamais exposer de secrets").
//
// Tant qu'`android/key.properties` n'existe pas, le comportement est
// strictement identique à avant (signature debug) — ce scaffold ne
// change rien tant qu'il n'est pas activé.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "fr.gaellebriet.memo_patte"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Requis par flutter_local_notifications (voir son AAR metadata).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "fr.gaellebriet.memo_patte"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Signature dédiée si `android/key.properties` existe
            // (voir plus haut), sinon repli sur les clés debug comme
            // avant — pour que `flutter run --release` continue de
            // fonctionner sans configuration tant que la vraie release
            // n'est pas encore préparée.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Règles prêtes pour flutter_local_notifications (voir
            // `proguard-rules.pro`) — `isMinifyEnabled` volontairement
            // pas activé ici (décision séparée, pas couverte par
            // l'audit du 2026-08-19 issue #71 point 3.11 : juste
            // "vérifier que les plugins ne seraient pas strippés" le
            // jour où la minification est activée, pas l'activer
            // maintenant).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Requis par flutter_local_notifications avec core library desugaring
    // activé ci-dessus (voir compileOptions).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
