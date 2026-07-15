# Firebase Setup Completion Checklist

Complete this checklist to finish setting up Firebase for your Fortune Fiesta app.

## ✅ Step 1: Install Dependencies (2 minutes)

```bash
cd /Users/mohdfuzail/AndroidStudioProjects/Fortune-Fiesta
flutter pub get
```

**Verify**: Should see all packages downloading

---

## ✅ Step 2: Android Configuration (5 minutes)

### 2.1 Clean Gradle
```bash
cd android
./gradlew clean
cd ..
```

### 2.2 Verify Configuration
- [ ] `google-services.json` exists in `android/app/`
- [ ] `android/build.gradle` has Firebase classpath
- [ ] `android/app/build.gradle` has Google Services plugin
- [ ] `android/app/src/main/AndroidManifest.xml` has FCM permissions

**Verify Android Build**:
```bash
cd android
./gradlew assembleDebug
cd ..
```

---

## ✅ Step 3: iOS Configuration (15 minutes)

### 3.1 Install Pods
```bash
cd ios
pod install --repo-update
cd ..
```

**If this fails**:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### 3.2 Open Xcode Project
```bash
open ios/Runner.xcworkspace
```

**IMPORTANT**: Always open `.xcworkspace`, NOT `.xcodeproj`

### 3.3 Add Push Notifications Capability

1. In Xcode, select **Runner** project (left sidebar)
2. Select **Runner** target
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"** button
5. Search for **"Push Notifications"**
6. Select and add it

### 3.4 Add Background Modes Capability

1. Click **"+ Capability"** button again
2. Search for **"Background Modes"**
3. Select and add it
4. Check ✅ **"Remote notifications"**
5. Optionally check ✅ **"Background fetch"**

### 3.5 Verify Configuration
- [ ] `GoogleService-Info.plist` exists in `ios/Runner/`
- [ ] Push Notifications capability added
- [ ] Background Modes capability added
- [ ] Remote notifications enabled

---

## ✅ Step 4: APNs Certificate Setup (20 minutes) - iOS Only

This step is required for iOS push notifications.

### 4.1 Create APNs Certificate

1. Go to [Apple Developer Account](https://developer.apple.com/account/)
2. Go to **Certificates, Identifiers & Profiles**
3. Click **Certificates** → Click **"+"**
4. Select **"Apple Push Notification service SSL (Sandbox & Production)"**
5. Click **Continue**
6. Select App ID: **com.fuzail.fortunefiesta**
7. Click **Continue**
8. Create CSR (Certificate Signing Request):
   - Open Keychain Access
   - Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
   - Fill your email and name, check "Save to disk"
   - Save CSR file
9. Upload CSR file
10. Download certificate (.cer file)
11. Double-click .cer to install in Keychain

### 4.2 Export Certificate

1. Open Keychain Access
2. Find "Apple Push Services: com.fuzail.fortunefiesta"
3. Right-click → Export
4. Save as `.p12` or `.p8`
5. Note the password (or use blank)

### 4.3 Upload to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project **fortune-fiesta2**
3. Go to **Project Settings** (gear icon)
4. Click **Cloud Messaging** tab
5. Scroll to **iOS APNs Certificates**
6. Click **Upload Certificate**
7. Upload your certificate file
8. If prompted, enter password
9. Click **Upload**

**Verify**: Should show certificate with checkmark ✓

---

## ✅ Step 5: Build and Run (10 minutes)

### 5.1 Clean Everything
```bash
flutter clean
flutter pub get
```

### 5.2 Build Android
```bash
flutter run -v
```

**Verify**: App launches without Firebase errors. Look for:
```
✅ Firebase initialized successfully
✅ Notification service initialized
📱 FCM Token: XXXXX...
```

### 5.3 Build iOS

In Xcode:
1. Select `Runner` → `Runner` target
2. Build: Cmd + B
3. Run: Cmd + R

**Verify**: Same logs as Android

---

## ✅ Step 6: Test Notifications (10 minutes)

### 6.1 Get FCM Token

1. Run app on device
2. Look in console output for: `📱 FCM Token: XXXXX...`
3. Copy the token

### 6.2 Send Test Notification - Android

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **fortune-fiesta2** project
3. Go to **Cloud Messaging**
4. Click **"Send your first message"** or **"New campaign"**
5. Fill notification:
   - Title: "Test Android"
   - Body: "Hello from Firebase"
6. Click **"Send test message"**
7. Select **"Send to a device"**
8. Paste your Android FCM token
9. Click **Send**

**Verify**: 
- Notification appears on device
- App can be closed (terminated state) and still receive it
- Tapping notification opens app

### 6.3 Send Test Notification - iOS

1. Go to Firebase Console
2. Go to **Cloud Messaging**
3. Create new campaign
4. Fill notification:
   - Title: "Test iOS"
   - Body: "Hello from Firebase"
5. Click **"Send test message"**
6. Select **"Send to a device"**
7. Paste your iOS FCM token
8. Click **Send**

**Verify**:
- Notification appears on device
- App can be closed and still receive it
- Tapping notification opens app

---

## ✅ Step 7: Verify All Features

### 7.1 Analytics
- [ ] Go to Firebase Console → Analytics
- [ ] Wait 24-48 hours for data to appear
- [ ] Check for user events

### 7.2 Crashlytics
- [ ] Go to Firebase Console → Crashlytics
- [ ] Should show "No crashes yet"
- [ ] This is good! (means no crashes)

### 7.3 Cloud Messaging
- [ ] Go to Firebase Console → Cloud Messaging
- [ ] Should see your test messages in history

---

## ✅ Step 8: Integrate into Your Game Code

### 8.1 Add Analytics to Game Events

In your game screen/controller:

```dart
import 'package:fortune_fiesta/utils/services/index.dart';

// When user spins
await FirebaseIntegrationHelper.logSpinEvent(
  betAmount: 100,
  result: 'win',
  winAmount: 500,
);

// When user completes level
await FirebaseIntegrationHelper.logLevelComplete(
  level: 5,
  timeSpent: 300,
  success: true,
);

// When user makes purchase
await FirebaseIntegrationHelper.logPurchaseEvent(
  productId: 'coins_100',
  price: 0.99,
  currency: 'USD',
);
```

### 8.2 Subscribe to Topics

```dart
// In your app initialization or user login:
await FirebaseIntegrationHelper.initializeUserAnalytics('user_123');
await FirebaseIntegrationHelper.subscribeToPromotions();
await FirebaseIntegrationHelper.notificationService.subscribeToTopic('all_users');
```

### 8.3 Handle Notification Taps

```dart
// Watch for notifications
FirebaseIntegrationHelper.watchCurrentNotification().listen((notification) {
  if (notification != null) {
    print('Notification tapped: ${notification.title}');
    // Handle navigation based on notification data
  }
});
```

---

## ✅ Step 9: Test All Three Notification States

### 9.1 Foreground (App Open)
1. App must be open
2. Send notification from Firebase Console
3. Should see snackbar notification
4. Tap it to handle

### 9.2 Background (App in Background)
1. Open app then press home button
2. Send notification from Firebase Console
3. System notification appears on lock screen
4. Tap notification - app opens and handles it

### 9.3 Terminated (App Closed)
1. Close app completely
2. Send notification from Firebase Console
3. System notification appears
4. Tap notification - app launches and handles it

**All three working?** ✅ You're done!

---

## ✅ Step 10: Monitor and Maintain

### 10.1 Daily Checks
- Check Firebase Console for crashes
- Monitor analytics for user engagement
- Review notification delivery rates

### 10.2 Regular Tasks
- Keep dependencies updated: `flutter pub upgrade`
- Renew APNs certificate before expiration
- Update topics based on user segments
- Test notifications monthly

### 10.3 Before Production Release
- [ ] All three notification states tested
- [ ] Analytics events logged correctly
- [ ] Crashlytics ready
- [ ] APNs certificate valid and uploaded
- [ ] App signed with release certificate
- [ ] Tested on real devices (not simulator/emulator)
- [ ] Privacy policy mentions Firebase
- [ ] No sensitive data in analytics

---

## 📊 Verification Logs

Watch for these messages in your console:

```
✅ Firebase initialized successfully
✅ Notification service initialized  
📱 FCM Token: <your-token-here>
✅ Subscribed to topic: all_users
✅ Subscribed to topic: promotions
```

If you don't see these, review the setup steps.

---

## 🆘 Troubleshooting

### Issue: "Flutter build failed"
- Run: `flutter clean && flutter pub get`
- For iOS: `cd ios && pod install --repo-update && cd ..`
- Try again

### Issue: "FCM Token not showing"
- Check Firebase is initialized
- Check `firebase_options.dart` exists
- Check `google-services.json` in `android/app/`
- Check `GoogleService-Info.plist` in `ios/Runner/`

### Issue: "Notifications not received"
- Verify FCM token obtained
- Verify permissions granted
- For iOS: APNs certificate must be uploaded
- Check notification permission is enabled

### Issue: "Analytics not showing"
- Wait 24-48 hours
- Data appears with some delay
- Check Firebase Console → Analytics dashboard

---

## 📚 Documentation Files

If you need more details:
- **FIREBASE_QUICK_START.md** - Overview
- **FIREBASE_SETUP.md** - Complete guide
- **ANDROID_FIREBASE_SETUP.md** - Android details
- **iOS_FIREBASE_SETUP.md** - iOS details
- **firebase_example_controller.dart** - Code example

---

## ✨ You're All Set!

Once you've completed all steps, your Fortune Fiesta app will have:
- ✅ Analytics tracking
- ✅ Crash reporting
- ✅ Push notifications (all 3 states)
- ✅ User engagement tracking

**Time to celebrate!** 🎉

---

**Questions?** Review the relevant documentation file or check Firebase console logs.

