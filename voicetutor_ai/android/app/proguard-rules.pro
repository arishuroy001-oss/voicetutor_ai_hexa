# Hive
-keep class ** extends com.google.flatbuffers.Table { *; }
-keep class * implements com.hive.** { *; }

# Porcupine / Picovoice
-keep class ai.picovoice.** { *; }
-keepclassmembers class ai.picovoice.** { *; }

# Google Generative AI
-keep class com.google.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
