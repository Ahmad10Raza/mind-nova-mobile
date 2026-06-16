# ═══════════════════════════════════════════════════════════
# MindNova Proguard Rules — Jitsi Meet + WebRTC + Audio
# ═══════════════════════════════════════════════════════════

# --- Jitsi Meet SDK ---
-keep class org.jitsi.** { *; }
-keep class org.jitsi.meet.** { *; }
-keep class org.jitsi.meet.sdk.** { *; }
-keep class org.jitsi.meet.sdk.JitsiMeetService { *; }

# --- React Native (Jitsi dependency) ---
-keep class com.facebook.react.** { *; }
-keep class com.facebook.soloader.** { *; }
-keep class com.facebook.hermes.** { *; }
-keep class com.facebook.jni.** { *; }

# --- WebRTC ---
-keep class org.webrtc.** { *; }

# --- OkHttp / Okio (network layer) ---
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep interface okhttp3.** { *; }

# --- Duktape JS engine ---
-keep class com.squareup.duktape.** { *; }

# --- Suppress warnings ---
-dontwarn org.jitsi.**
-dontwarn com.facebook.react.**
-dontwarn com.facebook.soloader.**
-dontwarn com.facebook.hermes.**
-dontwarn com.facebook.jni.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.squareup.duktape.**
-dontwarn org.webrtc.**

# --- Do NOT optimize/obfuscate (prevents Jitsi native crashes) ---
-dontoptimize
-dontobfuscate

# --- Android 14+ Foreground Services ---
-keepclassmembers class * extends android.app.Service { *; }

# --- Keep native methods for JNI ---
-keepclasseswithmembernames class * {
    native <methods>;
}

# --- Socket.IO / WebSocket client classes ---
-keep class io.socket.** { *; }
-dontwarn io.socket.**
