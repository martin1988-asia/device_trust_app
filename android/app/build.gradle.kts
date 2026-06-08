plugins {
    id("com.android.application")

    /// ✅ FIREBASE GOOGLE SERVICES ✅
    id("com.google.gms.google-services")

    /// ✅ FLUTTER PLUGIN (MUST BE LAST ✅)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.device_trust_app"

    /// 🔥 FIXED (FORCE API LEVEL ✅)
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.device_trust_app"

        minSdk = flutter.minSdkVersion

        /// 🔥 FIXED (FORCE TARGET ✅)
        targetSdk = 36

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
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

/// ✅ REQUIRED FOR FIREBASE ✅
dependencies {
    implementation("com.google.firebase:firebase-bom:32.7.0")
}
