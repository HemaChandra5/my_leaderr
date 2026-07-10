plugins {
    id("com.android.application")
    id("com.google.gms.google-services")   // ✅ ADD THIS
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_leaderr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.my_leaderr"
        minSdk = flutter.minSdkVersion   // ✅ Firebase requires at least 21 (23 recommended)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
