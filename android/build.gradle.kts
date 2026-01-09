// 👇 YE BLOCK ADD KARNA BOHT ZAROORI HAI
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Ye line add karein Google Services ke liye:
        classpath("com.google.gms:google-services:4.3.15")
    }
}
// 👆 Yahan tak naya code hai

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}