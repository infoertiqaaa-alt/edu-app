import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release-signing credentials from keystore.properties if present.
// This file is git-ignored and MUST NOT be committed. CI provides it by decoding
// GitHub Secrets; locally you can create it manually for signed builds.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Required keys of the release signing configuration.
val keystoreRequiredKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")

// True only when keystore.properties exists, is complete, and its storeFile
// points to an existing keystore file. This is the ONLY accepted source of
// release signing: production Release APKs are never signed with the Debug
// keystore.
fun releaseSigningConfigured(): Boolean {
    if (!keystorePropertiesFile.exists()) return false

    val keysComplete = keystoreRequiredKeys.all { key ->
        !keystoreProperties.getProperty(key).isNullOrBlank()
    }

    val storeFileRaw = keystoreProperties["storeFile"] as String?
    val storeFile = storeFileRaw?.let { file(it) }

    return keysComplete && storeFile != null && storeFile.isFile
}

android {
    namespace = "com.example.teacher"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.teacher"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Release builds MUST always use the Production signing configuration.
            // NEVER fall back to Debug signing: a Release APK signed with the
            // Debug keystore would conflict with production-signed installs
            // ("App not installed because the package conflicts...").
            // If the keystore is missing, packageRelease fails with a clear error.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Fail Release packaging with a clear message when the Production signing
// configuration is missing. Unlike the `buildTypes.release { }` block (which
// runs for every build type during configuration), this only triggers when a
// Release task actually runs, so `flutter build apk --debug` / `flutter run`
// still work without a keystore.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { task ->
        task.project == project && (
            task.name == "assembleRelease" ||
                task.name == "packageRelease" ||
                task.name == "bundleRelease"
            )
    }

    if (buildingRelease && !releaseSigningConfigured()) {
        throw GradleException(
            "Release build requires the Production signing keystore, but " +
                "android/keystore.properties is missing or incomplete " +
                "(storeFile, storePassword, keyAlias, keyPassword) or the " +
                "keystore file it points to does not exist. " +
                "Release APKs MUST be signed with the Production keystore and will " +
                "NOT fall back to Debug signing. In CI this file is created by " +
                "release.yml from the ANDROID_KEYSTORE_BASE64 secret. Locally, create " +
                "android/keystore.properties pointing at your Production keystore."
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.18.0"))
    implementation("com.google.firebase:firebase-analytics")
}
