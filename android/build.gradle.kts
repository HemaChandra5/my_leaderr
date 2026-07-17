buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        // Third-party plugins may still compile with source/target 8; suppress
        // the obsolete-options warning until those dependencies are updated.
        options.compilerArgs.add("-Xlint:-options")
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

fun forceAndroidSdk(project: org.gradle.api.Project) {
    val androidExt = project.extensions.findByName("android") ?: return

    runCatching {
        androidExt.javaClass
            .methods
            .firstOrNull { it.name == "setCompileSdk" && it.parameterTypes.size == 1 }
            ?.invoke(androidExt, 36)
    }

    runCatching {
        androidExt.javaClass
            .methods
            .firstOrNull { it.name == "compileSdkVersion" && it.parameterTypes.size == 1 }
            ?.invoke(androidExt, 36)
    }

    runCatching {
        val defaultConfig = androidExt.javaClass
            .methods
            .firstOrNull { it.name == "getDefaultConfig" }
            ?.invoke(androidExt)

        defaultConfig
            ?.javaClass
            ?.methods
            ?.firstOrNull { it.name == "setTargetSdk" && it.parameterTypes.size == 1 }
            ?.invoke(defaultConfig, 36)
    }
}

subprojects {
    plugins.withId("com.android.application") {
        forceAndroidSdk(this@subprojects)
    }
    plugins.withId("com.android.library") {
        forceAndroidSdk(this@subprojects)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
