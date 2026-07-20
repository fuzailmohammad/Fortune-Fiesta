#!/bin/bash

set -e

ANDROID_APP_ID="1:976683485159:android:525c7edf0bf0f6b69b9f42"
IOS_APP_ID="1:976683485159:ios:76817e91316715fa9b9f42"
GROUP="qa-testers"

flutter pub get

echo "Building Android..."
flutter build appbundle --release

firebase appdistribution:distribute \
build/app/outputs/bundle/release/app-release.aab \
--app "$ANDROID_APP_ID" \
--groups "$GROUP"

echo "Building iOS..."
flutter build ipa --release

firebase appdistribution:distribute \
build/ios/ipa/Runner.ipa \
--app "$IOS_APP_ID" \
--groups "$GROUP"

echo "Done!"