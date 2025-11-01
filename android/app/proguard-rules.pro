## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## flutter_foreground_task
-keep class com.pravera.flutter_foreground_task.** { *; }
-keep class androidx.work.** { *; }

## Prevent obfuscation of notification and foreground service classes
-keepclassmembers class * extends android.app.Service {
    *;
}

## Keep all native methods (JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}
