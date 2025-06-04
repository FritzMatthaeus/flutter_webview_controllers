# Phone Controller Setup Guide

To enable phone dialing functionality in your Flutter app using the [Phone Controller](./phone_controller.dart), follow these steps for iOS.

## 1. iOS Setup

- Open `ios/Runner/Info.plist`.
- Add the following inside the `<dict>` tag:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

- No additional permissions are required for dialing.

## 2. Dependencies

This Controller depends on [flutter_phone_direct_caller](https://pub.dev/packages/flutter_phone_direct_caller)
