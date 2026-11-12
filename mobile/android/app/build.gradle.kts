import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
// Sem arquivo real, debug compila e o app informa a falta de configuração.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
val signingFile = rootProject.file("key.properties")
val signingProperties = Properties()
if (signingFile.exists()) FileInputStream(signingFile).use { signingProperties.load(it) }
val releaseRequested = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
if (releaseRequested) {
    require(file("google-services.json").exists()) {
        "Configure o Firebase: mobile/android/app/google-services.json está ausente. Consulte docs/CONFIGURACAO_FIREBASE.md."
    }
    require(signingFile.exists() && listOf("storeFile", "storePassword", "keyAlias", "keyPassword").all { !signingProperties.getProperty(it).isNullOrBlank() }) {
        "Configure a assinatura release em mobile/android/key.properties. Consulte docs/DISTRIBUICAO_APK.md."
    }
}
android {
    namespace = "circuito.descobertas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    defaultConfig {
        applicationId = "circuito.descobertas"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        if (signingFile.exists()) create("release") {
            keyAlias = signingProperties.getProperty("keyAlias")
            keyPassword = signingProperties.getProperty("keyPassword")
            storeFile = signingProperties.getProperty("storeFile")?.let { rootProject.file(it) }
            storePassword = signingProperties.getProperty("storePassword")
        }
    }
    buildTypes {
        release {
            if (signingFile.exists()) signingConfig = signingConfigs.getByName("release")
        }
    }
}
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
flutter { source = "../.." }
