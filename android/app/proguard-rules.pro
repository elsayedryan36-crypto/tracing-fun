# R8 rules for the release build.
# Flutter's own rules are added automatically by the Flutter Gradle plugin.
# google_mobile_ads and the other plugins ship their own consumer rules.

# Keep annotations and generic signatures that plugins read at runtime.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations

# Rive ships native code (JNI); its Java classes must keep their names.
-keep class app.rive.** { *; }

# in_app_review talks to Google Play Core classes that may be absent.
-keep class com.google.android.play.review.** { *; }
-dontwarn com.google.android.play.core.**
