//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.example.flutter_ai_assistant"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//        applicationId = "com.example.flutter_ai_assistant"
//        // You can update the following values to match your application needs.
//        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}


import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// #region agent log
fun debugLog(
    hypothesisId: String,
    location: String,
    message: String,
    data: String
) {
    val logFile = File("/Users/dushiling/StudioProjects/flutter_ai_soulpen/.cursor/debug-7c5bda.log")
    logFile.parentFile?.mkdirs()
    val escapedMessage = message.replace("\"", "\\\"")
    val line =
        """{"sessionId":"7c5bda","runId":"pre-fix","hypothesisId":"$hypothesisId","location":"$location","message":"$escapedMessage","data":$data,"timestamp":${System.currentTimeMillis()}}""" + "\n"
    logFile.appendText(line)
}
// #endregion

// #region agent log
debugLog(
    hypothesisId = "H1",
    location = "android/build.gradle.kts:root",
    message = "root build script evaluated",
    data = """{"gradleVersion":"${gradle.gradleVersion}","javaVersion":"${System.getProperty("java.version")}","javaVendor":"${System.getProperty("java.vendor")}"}"""
)
// #endregion

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        if (plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
                kotlinOptions {
                    jvmTarget = JavaVersion.VERSION_17.toString()
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// #region agent log
subprojects {
    beforeEvaluate {
        debugLog(
            hypothesisId = "H2",
            location = "android/build.gradle.kts:beforeEvaluate",
            message = "subproject beforeEvaluate",
            data = """{"project":"$path","name":"$name"}"""
        )
    }
    afterEvaluate {
        val hasAndroidApp = plugins.hasPlugin("com.android.application")
        val hasAndroidLib = plugins.hasPlugin("com.android.library")
        if (hasAndroidApp || hasAndroidLib) {
            val androidExt = extensions.findByName("android")
            val compileSdkValue = try {
                androidExt?.javaClass?.methods?.firstOrNull { it.name == "getCompileSdk" }?.invoke(androidExt)
                    ?.toString()
            } catch (_: Exception) {
                "ERR"
            } ?: "NULL"
            val namespaceValue = try {
                androidExt?.javaClass?.methods?.firstOrNull { it.name == "getNamespace" }?.invoke(androidExt)
                    ?.toString()
            } catch (_: Exception) {
                "ERR"
            } ?: "NULL"
            debugLog(
                hypothesisId = "H3",
                location = "android/build.gradle.kts:afterEvaluate",
                message = "android project evaluated",
                data = """{"project":"$path","isApp":$hasAndroidApp,"isLibrary":$hasAndroidLib,"compileSdk":"$compileSdkValue","namespace":"$namespaceValue"}"""
            )
        }
    }
}
// #endregion

// #region agent log
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android")
        val getNamespace = androidExt?.javaClass?.methods?.firstOrNull { it.name == "getNamespace" }
        val setNamespace = androidExt?.javaClass?.methods?.firstOrNull { it.name == "setNamespace" }
        val current = try {
            getNamespace?.invoke(androidExt)?.toString()
        } catch (_: Exception) {
            null
        }
        debugLog(
            hypothesisId = "H5",
            location = "android/build.gradle.kts:withPluginLibrary",
            message = "library plugin applied",
            data = """{"project":"$path","namespace":"${current ?: "NULL"}"}"""
        )

        if (current.isNullOrBlank()) {
            val manifestFile = file("src/main/AndroidManifest.xml")
            val pkg = if (manifestFile.exists()) {
                Regex("""package\s*=\s*"([^"]+)"""")
                    .find(manifestFile.readText())
                    ?.groupValues
                    ?.getOrNull(1)
            } else {
                null
            }
            if (!pkg.isNullOrBlank() && setNamespace != null) {
                try {
                    setNamespace.invoke(androidExt, pkg)
                    debugLog(
                        hypothesisId = "FIX2",
                        location = "android/build.gradle.kts:withPluginLibrary",
                        message = "namespace injected from manifest package",
                        data = """{"project":"$path","namespace":"$pkg"}"""
                    )
                } catch (e: Exception) {
                    debugLog(
                        hypothesisId = "FIX2",
                        location = "android/build.gradle.kts:withPluginLibrary",
                        message = "namespace injection failed",
                        data = """{"project":"$path","error":"${e.javaClass.simpleName}"}"""
                    )
                }
            } else {
                debugLog(
                    hypothesisId = "H6",
                    location = "android/build.gradle.kts:withPluginLibrary",
                    message = "namespace missing and manifest package unresolved",
                    data = """{"project":"$path","manifestExists":${manifestFile.exists()}}"""
                )
            }
        }
    }
}
// #endregion
