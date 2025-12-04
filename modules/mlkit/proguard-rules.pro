# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.mlkit.**

# Keep ML Kit ContentProvider
-keep class com.google.mlkit.common.internal.MlKitInitProvider { *; }
