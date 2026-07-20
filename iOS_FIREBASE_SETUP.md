# iOS Firebase & FCM Setup Guide

This guide provides step-by-step instructions for setting up Firebase, Crashlytics, and FCM on iOS.

## 📋 Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later (deployment target)
- Firebase project configured (should already be done)
- GoogleService-Info.plist file (already in `ios/Runner/`)

## 🔧 Setup Steps

### Step 1: Install CocoaPods Dependencies

The Podfile is already configured. Just run:

```bash
cd ios
pod install --repo-update
cd ..
```

If you encounter any issues:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### Step 2: Configure Xcode Project

1. Open the project in Xcode:
```bash
open ios/Runner.xcworkspace
```

**Important**: Always open `.xcworkspace` (not `.xcodeproj`) when you have pods.

2. Select the **Runner** project in the left sidebar
3. Select the **Runner** target
4. Go to the **"Signing & Capabilities"** tab

### Step 3: Enable Push Notifications Capability

1. Click **"+ Capability"** button (top left in Signing & Capabilities)
2. Search for and select **"Push Notifications"**

This should add an entitlements file if not already present.

### Step 4: Enable Background Modes

1. Click **"+ Capability"** button again
2. Search for and select **"Background Modes"**
3. In Background Modes, check:
   - ✅ Remote notifications
   - ✅ Background fetch (optional but recommended)

### Step 5: Set Up APNs Certificate

To receive push notifications on iOS devices, you need to configure Apple Push Notification service (APNs):

#### Create APNs Certificate in Apple Developer Account:

1. Go to [Apple Developer Account](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Certificates** in the left sidebar
4. Click **"+"** to create a new certificate
5. Select **"Apple Push Notification service SSL (Sandbox & Production)"**
6. Click **Continue**
7. Select your App ID (com.fuzail.fortunefiesta)
8. Click **Continue**
9. Follow the instructions to create a Certificate Signing Request (CSR):
   - Open Keychain Access on your Mac
   - Go to **Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority**
   - Fill in your email and name, select "Saved to disk"
   - Save the CSR file
10. Upload the CSR file and create the certificate
11. Download the certificate (`.cer` file)
12. Double-click to install it in Keychain

#### Upload to Firebase:

1. Open the `.cer` file in Keychain Access
2. Right-click and select **Export**
3. Save as `.p8` or `.p12` format (choose p8 for modern setup)
4. Go to [Firebase Console](https://console.firebase.google.com/)
5. Select your project (fortune-fiesta2)
6. Go to **Project Settings → Cloud Messaging → iOS APNs Certificates**
7. Click **Upload Certificate**
8. Upload your certificate and enter the password if prompted
9. Click **Upload**

### Step 6: Build and Run

```bash
cd ios
pod install --repo-update
cd ..

flutter clean
flutter pub get
flutter run -v
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
2. Select your project
3. Go to **Cloud Messaging**
4. Click **"Send your first message"** or **"New campaign"**
5. Fill in notification details:
   - Title: "Test Notification"
   - Body: "This is a test"
6. Click **"Send test message"**
7. Select **"Add an APNs token"**
8. Paste the device FCM token you copied
9. Click **Send**

The notification should appear on your device!

## 🔍 Troubleshooting iOS

### Notifications Not Appearing

1. **Check permissions**: Go to Settings → [Your App] → Notifications → Make sure "Allow Notifications" is ON
2. **Verify APNs certificate**: Make sure it's properly uploaded to Firebase
3. **Check build settings**: Ensure all capabilities are enabled
4. **Review logs**: Run your app with verbose logging:
   ```bash
   flutter run -v
   ```

### Pod Installation Issues

```bash
# Update pods
cd ios
pod repo update
pod install
cd ..

# If still failing, try:
cd ios
rm -rf Pods
rm Podfile.lock
pod deintegrate
pod install
cd ..
```

### Xcode Build Failures

1. Clean Xcode build folder: `Cmd + Shift + K`
2. Clean Flutter build: `flutter clean`
3. Get pub packages: `flutter pub get`
4. Try running again: `flutter run`

### Capabilities Not Available

Make sure you're working with:
- The correct team ID (linked to your Apple Developer account)
- The correct bundle identifier (com.fuzail.fortunefiesta)
- A valid provisioning profile

## 📱 Handling Notifications in Code

### Foreground Notifications (App is open)

These are automatically handled by the notification_service.dart and will show a snackbar.

### Background Notifications (App in background, user taps)

When user taps the notification while app is in background, the notification_service will handle it in `_handleBackgroundMessage()`.

### Terminated State (App closed, user taps)

When user taps the notification with app completely closed, the initial message is fetched and handled in `_handleTerminatedMessage()`.

## 🔗 Deep Linking (Optional)

If you want notifications to navigate to specific screens:

1. Add deep link data to notification:
```json
{
  "screen": "/game/level_5",
  "action": "start_game"
}
```

2. Handle in notification_service.dart `_handleNotificationNavigation()` method:
```dart
if (screen != null) {
  Get.toNamed(screen, arguments: payload.data);
}
```

## 📊 Monitor Push Notifications

In Firebase Console:
1. Go to **Cloud Messaging** tab
2. Click **Recent** to see notification history
3. Check **Delivery** stats for success rates

## 🔐 Security Notes

1. **APNs Certificate**: Keep your certificate secure and don't share it
2. **FCM Token**: Treat tokens like passwords - don't log them in production
3. **Notification Content**: Don't send sensitive data in notifications
4. **Signature**: Always sign your iOS app properly before distribution

## 📞 Getting Help

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [FCM iOS Implementation](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs Certificate Setup](https://firebase.google.com/docs/cloud-messaging/ios/certs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## ✅ Verification Checklist

- [ ] Pods installed successfully
- [ ] GoogleService-Info.plist is in Runner project
- [ ] Push Notifications capability enabled
- [ ] Background Modes capability enabled
- [ ] APNs certificate uploaded to Firebase
- [ ] App builds successfully in Xcode
- [ ] App launches without Firebase errors
- [ ] Test notification received on device
- [ ] Notification tap is handled correctly

