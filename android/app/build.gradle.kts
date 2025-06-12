plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cryptosquare"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // 使用更具体的应用ID，避免与其他应用冲突
        applicationId = "org.cryptosquare.app"
        // 配置应用版本信息
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 250612002
        versionName = "2.0.0"
    }

    // 添加签名配置
    signingConfigs {
        // 使用已有的debug签名配置
        // release签名配置使用debug keystore，仅用于测试目的
        create("release") {
            storeFile = file("../key17.jks")
            storePassword = "123456"
            keyAlias = "key17"
            keyPassword = "123456"
        }
    }

    buildTypes {
        release {
            // 使用release签名配置
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 移除Play Core库依赖，代码中未使用
    // implementation("com.google.android.play:core-ktx:2.0.1")
}
