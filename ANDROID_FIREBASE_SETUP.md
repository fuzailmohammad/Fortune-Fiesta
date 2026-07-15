# Android Firebase & FCM Setup Guide

This guide provides step-by-step instructions for setting up Firebase, Crashlytics, and FCM on Android.

## 📋 Prerequisites

- Android SDK 24 or higher (minSdk is already set)
- Firebase project configured (should already be done)
- google-services.json file (already in `android/app/`)
- Android Studio or command line tools

## 🔧 Setup Steps

### Step 1: Verify google-services.json

The `google-services.json` file should already be in:
```
android/app/google-services.json
```

Verify it contains your project credentials.

### Step 2: Build Configuration (Already Done)

The following have been configured:

**`android/build.gradle`**:
```groovy
classpath 'com.google.gms:google-services:4.4.2'
classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.2'
```

**`android/app/build.gradle`**:
```groovy
plugins {
    id 'com.google.gms.google-services'
    id 'com.google.firebase.crashlytics'
}
```

**`android/app/src/main/AndroidManifest.xml`**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Step 3: Build the Project

```bash
cd /Users/mohdfuzail/AndroidStudioProjects/Fortune-Fiesta
flutter clean
flutter pub get
flutter run -v
```

If you encounter Gradle errors:
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### Step 4: Request Notification Permission (Runtime)

For Android 13 (API 33+), POST_NOTIFICATIONS permission must be requested at runtime.

This is handled in your `notification_service.dart`:
```dart
// Request user permission for iOS (Android handles it automatically for Firebase)
if (Platform.isIOS) {
  await _requestIOSPermission();
}
```

For Android, you can request manually:
```dart
import 'package:permission_handler/permission_handler.dart';

// Add to pubspec.yaml if needed:
// permission_handler: ^11.4.4

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
}
```

## 🧪 Testing Notifications

### Get Device FCM Token

In your app, after Firebase initialization:

```dart
import 'package:fortune_fiesta/utils/services/notification_service.dart';

final token = await NotificationService().getFCMToken();
print('Device FCM Token: $token');
```

Copy this token.

### Send Test Notification

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (fortune-fiesta2)
3. Go to **Cloud Messaging** in the left menu
4. Click **"Send your first message"** or **"New campaign"**
5. Fill notification details:
   - Title: "Test Notification"
   - Body: "This is a test"
6. Click **"Send test message"**
7. Choose **"Send to a device"**
8. Paste your FCM token
9. Click **Send**

The notification should appear on your Android device!

## 📱 Notification Behavior

### Foreground (App Running)
- Notification appears as a snackbar
- User can tap to open app

### Background (App in Background)
- System notification appears
- Tapping notification opens app with message handler triggered
- Message data is available in `_handleBackgroundMessage()`

### Terminated (App Closed)
- System notification appears
- Initial message is fetched on app launch
- Message handler triggered in `_handleTerminatedMessage()`

## 🔔 Android Notification Channel

Firebase automatically creates a notification channel for your app. You can customize it in your app:

### In Flutter (Optional Enhancement):

```dart
// Add to your notification_service.dart if you want custom channel behavior
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _createNotificationChannel() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );
  
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
```

Then add to pubspec.yaml:
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
```

## 🔐 Android Security

### Enable ProGuard/R8 Obfuscation

For release builds, Firebase will work with obfuscated code. Ensure your `android/app/build.gradle` includes:

```groovy
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### API Key Security

Your google-services.json contains API keys. It's safe to include in source control because:
- It's Android-restricted
- API keys are only valid for your app's package name and signing certificate
- Never hardcode keys in code

## 🐛 Troubleshooting Android

### Notifications Not Received

1. **Check Gradle sync**: Make sure Gradle synced successfully in Android Studio
2. **Verify FCM token**: Print and verify the token is obtained
3. **Check topic subscription**: Ensure subscriptions are working
4. **Review Logcat**: Check Android logs for errors:
   ```bash
   flutter logs
   ```

### Gradle Build Failures

```bash
# Clean build
cd android
./gradlew clean
cd ..

# Rebuild
flutter clean
flutter pub get
flutter run
```

### Permission Denied Errors

If you see `Permission denied` in logcat:
1. Ensure `google-services.json` is in the correct location
2. Verify your package name matches:
   - google-services.json: `com.fuzail.fortunefiesta`
   - build.gradle: `applicationId "com.fuzail.fortunefiesta"`

### Firebase Initialization Errors

If Firebase doesn't initialize:
```
E/Firebase: Could not inject required dependencies
```

1. Verify all dependencies in `pubspec.yaml`
2. Run `flutter pub get` again
3. Clean and rebuild

## 📊 Topics & Subscriptions

### Built-in Topics

The app automatically manages these topics:

```dart
// Default subscriptions
await notificationService.subscribeToTopic('all_users');     // All users
await notificationService.subscribeToTopic('promotions');    // Marketing
await notificationService.subscribeToTopic('level_${level}'); // Level-specific
```

### Custom Topics

Create topics for your app needs:

```dart
// Subscribe
await notificationService.subscribeToTopic('android_users');
await notificationService.subscribeToTopic('high_level_players');

// Unsubscribe
await notificationService.unsubscribeFromTopic('promotions');
```

### Sending to Topics (Backend)

Using Firebase Admin SDK (Node.js):
```javascript
const admin = require('firebase-admin');

const message = {
  notification: {
    title: 'New Challenge!',
    body: 'Level 10 is now available',
  },
  data: {
    screen: 'level_10',
    action: 'unlock_level',
  },
  topic: 'level_10',
};

admin.messaging().send(message)
  .then((response) => console.log('Message sent:', response))
  .catch((error) => console.log('Error:', error));
```

## 📈 Monitoring

### View in Firebase Console

1. **Cloud Messaging** tab shows:
   - Recent notifications sent
   - Delivery statistics
   - Engagement metrics

2. **Crashlytics** tab shows:
   - Crash reports in real-time
   - Stack traces
   - Affected users

3. **Analytics** tab shows:
   - User engagement
   - Event tracking
   - User properties

## 📋 Manifest Permissions Reference

Current permissions in `AndroidManifest.xml`:

```xml
<!-- Internet - Required for Firebase -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Post Notifications - Required for Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## ⚙️ Advanced Configuration

### Custom Notification Styling

To customize notification appearance, override notification channel in Android native code:

1. Create `android/app/src/main/java/com/fuzail/fortunefiesta/NotificationChannel.kt`
2. Configure notification appearance
3. Register in `MainActivity.kt`

### FCM Data-Only Messages

For silent notifications that update UI without showing notification:

```json
{
  "data": {
    "update_type": "daily_bonus",
    "bonus_amount": "500"
  },
  "android": {
    "priority": "high"
  },
  "topic": "all_users"
}
```

These require handling in `firebaseMessagingBackgroundHandler`.

## ✅ Verification Checklist

- [ ] google-services.json in android/app/
- [ ] Gradle plugins configured
- [ ] AndroidManifest.xml has permissions
- [ ] App builds without errors
- [ ] Firebase initializes on app start
- [ ] FCM token obtained successfully
- [ ] Topic subscriptions work
- [ ] Foreground notification appears
- [ ] Background notification works
- [ ] Terminated state notification works
- [ ] Analytics events logged
- [ ] Crashes reported to Crashlytics

## 📚 References

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [FCM Android Implementation](https://firebase.google.com/docs/cloud-messaging/android/client)
- [Firebase Crashlytics Android](https://firebase.google.com/docs/crashlytics/get-started?platform=android)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Android Notification Channels](https://developer.android.com/training/notify-user/channels)

## 🚀 Next Steps

1. Run the app on an Android device
2. Get the FCM token from logs
3. Send a test notification
4. Verify notifications work in all states
5. Monitor Crashlytics and Analytics dashboards
6. Set up backend to send notifications

