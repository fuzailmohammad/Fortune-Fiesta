# Firebase Setup Guide

This document provides a comprehensive guide to the Firebase setup for Fortune Fiesta Flutter app including Analytics, Crashlytics, and FCM (Firebase Cloud Messaging).

## 📱 What's Included

1. **Firebase Analytics** - Track user behavior and app metrics
2. **Firebase Crashlytics** - Real-time crash reporting
3. **Firebase Cloud Messaging (FCM)** - Push notifications for both Android and iOS
   - Foreground notification handling
   - Background notification handling
   - Terminated state notification handling

## 📦 Dependencies Added

- `firebase_core: ^3.7.0` - Core Firebase library
- `firebase_analytics: ^11.3.0` - Analytics SDK
- `firebase_crashlytics: ^4.2.0` - Crashlytics SDK
- `firebase_messaging: ^15.1.3` - Cloud Messaging SDK

## 🔧 Android Setup

### 1. Build Configuration (Already Done)
- Updated `android/build.gradle` with Firebase and Crashlytics classpath
- Updated `android/app/build.gradle` with Google Services and Crashlytics plugins
- Added FCM permissions to `android/app/src/main/AndroidManifest.xml`

### 2. Google Services JSON
The `google-services.json` file is already present in `android/app/`.

### 3. AndroidManifest.xml Configuration
Required permissions have been added:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 4. Build and Sync
Run the following commands:
```bash
cd /Users/mohdfuzail/AndroidStudioProjects/Fortune-Fiesta
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🍎 iOS Setup

### 1. GoogleService-Info.plist
The `ios/Runner/GoogleService-Info.plist` file is already present.

### 2. Pod Installation
Run the following commands:
```bash
cd ios
pod install --repo-update
cd ..
```

### 3. iOS Capabilities
You need to enable the following capabilities in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project → Runner target
3. Go to "Signing & Capabilities"
4. Add the following capabilities:
   - **Push Notifications**
   - **Background Modes** (enable "Remote notifications")
   - **Apple Sign In** (optional, if using)

### 4. APNs Certificate Setup
To enable push notifications on iOS, you need to:
1. Create an APNs (Apple Push Notification service) certificate in Apple Developer Account
2. Upload it to Firebase Console → Project Settings → Cloud Messaging → iOS APNs Certificates
3. Instructions: https://firebase.google.com/docs/cloud-messaging/ios/certs

## 🚀 Dart/Flutter Setup (Already Done)

### 1. New Files Created

#### `lib/utils/services/firebase_service.dart`
- Initializes Firebase Core, Analytics, and Crashlytics
- Provides methods for:
  - Setting user ID
  - Logging events
  - Logging screen views
  - Recording errors
  - Setting custom keys in Crashlytics

#### `lib/utils/services/notification_service.dart`
- Initializes Firebase Messaging
- Handles notifications in all states:
  - **Foreground**: Shows snackbar notification
  - **Background**: Handles when user taps notification
  - **Terminated**: Handles initial message when app launches
- Provides methods for:
  - Topic subscription/unsubscription
  - Getting FCM token
  - Getting permission status
  - Notification history management

### 2. Main.dart Updated
- Imports Firebase services
- Initializes Firebase before creating app
- Sets up background message handler
- Initializes notification service

## 📊 Usage Examples

### Analytics

```dart
import 'package:fortune_fiesta/utils/services/firebase_service.dart';

final firebaseService = FirebaseService();

// Log custom event
await firebaseService.logEvent(
  name: 'spin_wheel',
  parameters: {
    'amount': 100,
    'currency': 'USD',
  },
);

// Log screen view
await firebaseService.logScreenView('home_screen');

// Set user ID
await firebaseService.setUserId('user_123');
```

### Crashlytics

```dart
// Record error
try {
  // Some code that might throw
} catch (e, st) {
  await firebaseService.recordError(e, st, reason: 'Spin failed');
}

// Set custom key
await firebaseService.setCustomKey('user_level', 5);

// Log message
firebaseService.logMessage('User started game session');
```

### Notifications

```dart
import 'package:fortune_fiesta/utils/services/notification_service.dart';

final notificationService = NotificationService();

// Subscribe to topic
await notificationService.subscribeToTopic('promotions');

// Get FCM token
String? token = await notificationService.getFCMToken();

// Get notification permission status
AuthorizationStatus status = await notificationService.getNotificationPermissionStatus();

// Access current notification
var notification = notificationService.currentNotification.value;

// View notification history
int count = notificationService.getNotificationCount();
```

## 🔔 Notification Topics

You can subscribe users to topics for targeted notifications:

```dart
// Subscribe to topics
await notificationService.subscribeToTopic('all_users');
await notificationService.subscribeToTopic('promotions');
await notificationService.subscribeToTopic('new_features');
await notificationService.subscribeToTopic('level_${userLevel}');

// Unsubscribe from topic
await notificationService.unsubscribeFromTopic('promotions');
```

## 📤 Sending Notifications (From Backend)

### Using Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Create a new campaign
3. Select target (All, Topic, Condition)
4. Set notification content
5. Schedule and send

### Using Firebase Admin SDK (Node.js Example)
```javascript
const admin = require('firebase-admin');
admin.initializeApp();

const message = {
  notification: {
    title: 'Special Offer!',
    body: 'You have a new reward',
  },
  data: {
    screen: 'rewards',
    action: 'show_reward',
    reward_id: '12345',
  },
  topic: 'promotions',
};

admin.messaging().send(message);
```

## 🐛 Debugging & Testing

### Test Notifications
1. Get your device FCM token:
```dart
String? token = await NotificationService().getFCMToken();
print('My FCM token: $token');
```

2. Send test notification via Firebase Console:
   - Go to Cloud Messaging
   - Click "Send your first message"
   - Enter notification details
   - Select "Send to a device"
   - Paste the FCM token
   - Click "Send"

### Monitor Crashes
1. Go to Firebase Console → Crashlytics
2. View all crashes in real-time
3. Check stack traces and custom keys for debugging

### View Analytics
1. Go to Firebase Console → Analytics
2. View user engagement, events, and funnels
3. Create custom reports

## ⚙️ Configuration Tips

### Crash Collection in Debug Mode
By default, Crashlytics collection is enabled in debug mode. To disable:
```dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
```

### Custom Error Handling
The app already integrates Crashlytics with Flutter's error handling:
```dart
FlutterError.onError = _crashlytics.recordFlutterError;
```

This automatically reports all Flutter errors to Crashlytics.

### Topics Strategy
Consider implementing topics for:
- User segments (free_users, premium_users)
- Game levels (beginner, intermediate, expert)
- Promotions (daily_bonus, seasonal_event)
- Feature updates

## 🔐 Security Best Practices

1. **FCM Token Management**
   - Store tokens securely
   - Refresh tokens regularly
   - Send new tokens to backend on app update

2. **Notification Validation**
   - Validate notification data on receipt
   - Sanitize any user-provided data
   - Ignore notifications from unexpected sources

3. **Analytics**
   - Don't send sensitive data in custom events
   - Use event parameter limits (25 parameters max)
   - Avoid logging PII (Personally Identifiable Information)

4. **Crashlytics**
   - Set user identifiers carefully (use user IDs, not emails)
   - Don't log sensitive information in custom keys
   - Review crashes regularly

## 📝 Next Steps

1. Run `flutter pub get` to install dependencies
2. For iOS: Run `cd ios && pod install && cd ..`
3. Build and run on devices
4. Verify Firebase initialization logs
5. Test notifications from Firebase Console
6. Set up backend to send notifications
7. Monitor Analytics and Crashlytics dashboards

## 🆘 Troubleshooting

### Build Failures
```bash
# Clean Flutter build
flutter clean

# Rebuild
flutter pub get
flutter run -v
```

### iOS Pod Issues
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### Notifications Not Received
1. Verify FCM token is obtained
2. Check topic subscriptions
3. Ensure notification permissions granted (especially iOS)
4. Check Firebase rules (if using Firestore for restrictions)
5. Verify message was sent to correct topic/device

### Analytics Not Appearing
1. Wait 24-48 hours for initial events to appear
2. Ensure DEBUG builds - analytics may be delayed
3. Check Firebase Console for data validation errors

## 📚 References

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire](https://firebase.flutter.dev/)

