# Flutter ProGuard 규칙
# Flutter 및 Mission100 앱 최적화를 위한 ProGuard 설정

# Flutter 관련 유지
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core Split APK (R8 오류 해결)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.** { *; }

# Flutter Split APK 관련 클래스 무시 (현재 사용하지 않음)
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Google Mobile Ads 최적화
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.ads.** { *; }

# SQLite 최적화
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# 알림 서비스 유지
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.app.Application

# Mission100 앱 특정 클래스 유지
-keep class com.chadteam.mission100_chad_pushup.** { *; }

# 리플렉션 사용 클래스 유지
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 성능 최적화
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# 디버그 정보 제거 (릴리스용)
-printmapping mapping.txt
-printseeds seeds.txt
-printusage usage.txt

# 경고 억제
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.*

# 🚀 Mission: 100 ProGuard 설정

# Google Mobile Ads 보존
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Firebase 보존 (향후 추가 시)
-keep class com.google.firebase.** { *; }

# JSON 직렬화 보존
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 앱 특정 모델 클래스 보존
-keep class com.reaf.misson100.models.** { *; }

# 네이티브 라이브러리 보존
-keep class com.reaf.misson100.** { *; }

# 일반적인 Android 컴포넌트 보존
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# 로그 제거 (릴리즈 빌드에서)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 기본 최적화 설정
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/* 