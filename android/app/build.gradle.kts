import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.localtransport.app.dev"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    val dartDefines: Map<String, String> = run {
        val definesProperty = project.findProperty("dart-defines") as String?
        if (definesProperty.isNullOrBlank()) {
            emptyMap()
        } else {
            definesProperty.split(",")
                .mapNotNull { encoded ->
                    val decoded = String(Base64.getDecoder().decode(encoded))
                    val separatorIndex = decoded.indexOf("=")
                    if (separatorIndex <= 0) {
                        null
                    } else {
                        decoded.substring(0, separatorIndex) to
                            decoded.substring(separatorIndex + 1)
                    }
                }
                .toMap()
        }
    }

    val localProperties: Map<String, String> = run {
        val propertiesFile = rootProject.file("local.properties")
        if (!propertiesFile.exists()) {
            emptyMap()
        } else {
            val properties = Properties()
            propertiesFile.inputStream().use { properties.load(it) }
            properties.stringPropertyNames().associateWith { key ->
                properties.getProperty(key).orEmpty()
            }
        }
    }

    val googleMapsApiKey: String =
        (project.findProperty("GOOGLE_MAPS_API_KEY") as String?)
            ?: System.getenv("GOOGLE_MAPS_API_KEY")
            ?: localProperties["GOOGLE_MAPS_API_KEY"]
            ?: dartDefines["GOOGLE_MAPS_API_KEY"]
            ?: "AIzaSyCfYetXZeDG082fWzLTgT8Mzldo6e7i6HE"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.localtransport.app.dev"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "google_maps_api_key", googleMapsApiKey)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
