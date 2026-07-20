# Firebase Setup - Quick Start Guide

Complete Firebase integration including Analytics, Crashlytics, and FCM for Fortune Fiesta.

## ✨ What's Been Done

Your Flutter app is now equipped with:

✅ **Firebase Analytics** - Track user behavior and engagement  
✅ **Firebase Crashlytics** - Real-time crash reporting  
✅ **Firebase Cloud Messaging (FCM)** - Push notifications for Android & iOS  
✅ **Notification Handling** - Foreground, background, and terminated states  
✅ **Integration Helper** - Easy-to-use wrapper functions  

## 📦 Installation

### 1. Get Dependencies

```bash
flutter pub get
```

### 2. Android Setup (5 minutes)

```bash
cd android
./gradlew clean
cd ..
```

✓ `google-services.json` is already in place  
✓ Gradle plugins are configured  
✓ Permissions are added to AndroidManifest.xml  

### 3. iOS Setup (10 minutes)

```bash
cd ios
pod install --repo-update
cd ..
```

✓ `GoogleService-Info.plist` is already in place  
✓ Firebase pods will be installed  

**⚠️ Additional iOS Setup Required:**
- Open `ios/Runner.xcworkspace` in Xcode
- Add "Push Notifications" capability
- Add "Background Modes" capability (enable "Remote notifications")
- Upload APNs certificate to Firebase Console

See detailed instructions in `iOS_FIREBASE_SETUP.md`

### 4. Build & Run

```bash
flutter clean
flutter pub get
flutter run -v
```

## 🚀 Using Firebase in Your App

### Basic Usage

```dart
import 'package:fortune_fiesta/utils/services/firebase_integration_helper.dart';

// Log an event
await FirebaseIntegrationHelper.logGameEvent(
  eventName: 'spin_wheel',
  amount: 100,
);

// Log screen view
await FirebaseIntegrationHelper.firebaseService.logScreenView('game_screen');

// Set user ID
await FirebaseIntegrationHelper.initializeUserAnalytics('user_123');
```

### In Your Game Logic

```dart
// Log spin result
await FirebaseIntegrationHelper.logSpinEvent(
  betAmount: 50,
  result: 'win',
  winAmount: 250,
);

// Log level completion
await FirebaseIntegrationHelper.logLevelComplete(
  level: 5,
  timeSpent: 300, // seconds
  success: true,
);

// Log purchase
await FirebaseIntegrationHelper.logPurchaseEvent(
  productId: 'coins_100',
  price: 0.99,
  currency: 'USD',
);
```

### Getting Notifications

```dart
// Get FCM token to send notifications to this device
String? token = await FirebaseIntegrationHelper.getDeviceFCMToken();

// Subscribe to topics
await FirebaseIntegrationHelper.subscribeToPromotions();
await FirebaseIntegrationHelper.notificationService.subscribeToTopic('level_10');

// Listen to notifications
FirebaseIntegrationHelper.watchCurrentNotification().listen((notification) {
  if (notification != null) {
    print('Notification: ${notification.title}');
    // Handle notification tap
  }
});
```

## 📝 Example: Complete Controller

See `lib/utils/services/firebase_example_controller.dart` for a complete example controller showing:
- Analytics tracking
- Event logging
- Notification listening
- Error reporting

## 🧪 Testing

### Test on Android

1. Run app on Android device/emulator
2. In Logcat, look for "FCM Token: xxxx..."
3. Go to Firebase Console → Cloud Messaging
4. Send test notification using that token
5. Verify notification appears

### Test on iOS

1. Ensure APNs certificate is uploaded to Firebase
2. Run app on iOS device (simulator won't receive real notifications)
3. In Xcode console, look for "FCM Token: xxxx..."
4. Go to Firebase Console → Cloud Messaging
5. Send test notification using that token
6. Verify notification appears

## 📊 Monitoring

### Firebase Console

Go to [Firebase Console](https://console.firebase.google.com/) and select **fortune-fiesta2**:

1. **Cloud Messaging**
   - Send test notifications
   - View delivery statistics
   
2. **Crashlytics**
   - Monitor app crashes in real-time
   - View stack traces
   - Create alerts
   
3. **Analytics**
   - View user engagement
   - Track events
   - Create custom reports

## 🔔 Notification Topics

Subscribe users to topics for targeted notifications:

```dart
// Subscribe
await notificationService.subscribeToTopic('all_users');
await notificationService.subscribeToTopic('promotions');
await notificationService.subscribeToTopic('vip_users');
await notificationService.subscribeToTopic('level_10');

// Later, unsubscribe
await notificationService.unsubscribeFromTopic('promotions');
```

Send notifications via Firebase Console → Cloud Messaging → New Campaign → Target → Topic

## 📱 Notification States

Your app handles notifications in all states:

### 1. Foreground (App Open)
```
App receives notification → Shows as snackbar → User can tap
```

### 2. Background (App in Background)
```
User receives system notification → Taps it → App opens → Message handled
```

### 3. Terminated (App Closed)
```
User receives system notification → Taps it → App launches → Message handled
```

## 🐛 Troubleshooting

### Notifications Not Received

1. Check FCM token is obtained:
   ```
   Look for "📱 FCM Token: xxx" in logs
   ```

2. Verify topic subscription:
   ```
   Look for "✅ Subscribed to topic: xxx" in logs
   ```

3. Check notification permission:
   ```
   For iOS: Add Push Notifications capability
   For Android: Grant notification permission when prompted
   ```

### Firebase Not Initializing

```
Look for "✅ Firebase initialized successfully" in logs
If not present, check:
- Dependencies installed (flutter pub get)
- google-services.json in android/app/
- GoogleService-Info.plist in ios/Runner/
- Pods installed (cd ios && pod install)
```

### Analytics Not Showing

- Wait 24-48 hours for initial data
- In debug builds, data is delayed
- Check Firebase Console for validation errors

## 📚 Detailed Documentation

- **`FIREBASE_SETUP.md`** - Complete Firebase setup guide
- **`ANDROID_FIREBASE_SETUP.md`** - Android-specific instructions
- **`iOS_FIREBASE_SETUP.md`** - iOS-specific instructions
- **`firebase_example_controller.dart`** - Example controller implementation
- **`firebase_integration_helper.dart`** - Helper functions
- **`firebase_service.dart`** - Firebase service
- **`notification_service.dart`** - Notification service

## 🔗 Useful Links

- [Firebase Docs](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [FCM Console](https://console.firebase.google.com/project/fortune-fiesta2/cloudmessaging)
- [APNs Setup](https://firebase.google.com/docs/cloud-messaging/ios/certs)

## ✅ Verification Checklist

Before deploying to production:

- [ ] Analytics events are logging correctly
- [ ] Crashlytics receives test crashes
- [ ] Notifications work on Android (foreground, background, terminated)
- [ ] Notifications work on iOS (foreground, background, terminated)
- [ ] Topics are set up correctly
- [ ] Firebase Console shows data
- [ ] No sensitive data in logs
- [ ] APNs certificate valid (iOS)
- [ ] App signed correctly for release
- [ ] Tested on real devices (not just simulator/emulator)

## 🚀 Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Run `cd ios && pod install --repo-update && cd ..`
3. ✅ Set up iOS capabilities (Push Notifications, Background Modes)
4. ✅ Upload APNs certificate (iOS)
5. ✅ Build and run on test device
6. ✅ Send test notification from Firebase Console
7. ✅ Integrate analytics calls in your game code
8. ✅ Monitor Firebase Console during testing
9. ✅ Set up backend to send notifications
10. ✅ Deploy to production

## 💡 Tips

- **User Tracking**: Call `setUserId()` when user logs in
- **Custom Events**: Use `logEvent()` for any game action
- **Error Reporting**: Errors are automatically reported via Crashlytics
- **Topic Strategy**: Use topics to segment users (free vs premium, level-based, etc.)
- **Notification Data**: Send structured data with notifications for in-app handling

## 🆘 Support

If you encounter issues:

1. Check the relevant setup guide (Android or iOS)
2. Review detailed documentation files
3. Check Flutter logs: `flutter logs`
4. Check Firebase Console for errors
5. Verify all dependencies are installed
6. Try clean build: `flutter clean && flutter pub get`

---

**Ready to go!** Your app now has enterprise-grade Firebase integration. 🎉

