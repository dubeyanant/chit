import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, ADR-098. The keystore and its passwords are the owner's and
// are never committed; key.properties beside this file supplies them. Without
// it a release build still works and is signed with the debug key, which is
// what `flutter run --release` needs — so the absence is announced rather than
// assumed, an APK that installs and can never be updated being the failure
// this guards.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
val signedForRelease = keyPropertiesFile.exists()

if (signedForRelease) {
    FileInputStream(keyPropertiesFile).use { keyProperties.load(it) }
} else {
    println(
        "chitta: android/key.properties is missing, so the release build is " +
            "signed with the DEBUG key. It will install, and no properly " +
            "signed build can ever update it. See docs/PACKAGES.md."
    )
}

android {
    namespace = "com.infiniteants.chitt"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.infiniteants.chitt"
        // record_android requires 24; it is the highest floor of any plugin in
        // PACKAGES.md. path_provider asks 21, just_audio 16.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (signedForRelease) {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (signedForRelease) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
