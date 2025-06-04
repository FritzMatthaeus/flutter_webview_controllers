# Flutter WebView Controllers

A Flutter package that simplifies WebView integration with native functionality through a structured controller system.

## Features

- Seamless communication between Flutter and JavaScript in WebViews
- Pre-built controllers for common use cases:
  - Firebase Cloud Messaging integration
  - Phone dialer access
  - App state management
- Customizable platform interface naming
- Supports both local and remote WebView content sources
- Built on top of `flutter_inappwebview`

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_webview_controllers:
    git:
      url: https://github.com/FritzMatthaeus/flutter_webview_controllers.git
```

Run `flutter pub get` to install the package.

## Basic Usage

### 1. Initialize WebView Setup

```dart
void main() async {
    // Initialize with controllers you need
    final webviewSetup = WebviewSetup(
        platformInterface: 'myPlatformInterface',
        controllers: {
            FlutterWebviewControllers.firebase,
            FlutterWebviewControllers.phone,
        },
        baseUrl: "https://example.com",
        enableDebugging: true
    );

    // If you're loading from assets
    // start the localhost server
    // **NOTE** this will override the provided baseUrl
    await webviewSetup.startLocalhostServer('assets/webview');
}

```

### 2. Use the WebView Wrapper

The [WebvieWrapper](./lib/src/widgets/webview_wrapper.dart) provides a Scaffold with an InAppWebView to be shown in FullScreen Mode.
A `backgroundColor` must be provided.

```dart
class MyWebViewPage extends StatelessWidget {
  const MyWebViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WebviewWrapper(
      backgroundColor: Colors.white,
    );
  }
}
```

In case you want to implement the `InAppWebView` yourself, you can do this. Checkout the [WebvieWrapper](./lib/src/widgets/webview_wrapper.dart) on
how to use the [WebvieSetup](./lib/src/webview_setup.dart) to set up your webview.

### 3. Set up JavaScript Interface

In your web application, define the JavaScript interface with the same name as specified in `platformInterface`.
Here is an example implementation:

```javascript
const PlatformEvents = {
  ON_GO_BACK: "goBack",
  ON_RESUME: "onResume",
  ON_PAUSE: "onPause",
};

class PlatformInterface {
  /**
   * @type {boolean}
   */
  isInitalized = false;

  /**
   * @type {CustomEventEmitter}
   */
  listen = new CustomEventEmitter();

  /**
   * An array of functions that have been called
   * before the Flutter Interface is initialized
   *
   * they are stacked and executed when the Flutter Interface is initialized
   * @type {Array<Function>}
   */
  stackedCalls = [];

  constructor() {
    this.isInitalized = true;
  }

  async isAndroid() {
    return (await this.getPlatform()) == "android" ? true : false;
  }

  async isIOS() {
    return (await this.getPlatform()) == "ios" ? true : false;
  }

  async isWeb() {
    return (await this.getPlatform()) == "web" ? true : false;
  }

  /**
   * returns the platform of the device from Flutter
   * @return {Promise<string>}
   * @memberof PlatformInterface
   */
  async getPlatform() {
    return "web";
  }

  /**
   * emits NativeEvents.ON_RESUME
   * is fired when App comes from background
   * [Android, iOS]
   * @memberof PlatformInterface
   */
  onResume() {
    console.log("onResume");
    this.listen.emit(PlatformEvents.ON_RESUME);
  }

  /**
   * emits NativeEvents.ON_PAUSE
   * is fired when App goes to background
   * [Android, iOS]
   * @memberof PlatformInterface
   */
  onPause() {
    console.log("onPause");
    this.listen.emit(PlatformEvents.ON_PAUSE);
  }

  /**
   * emits NativeEvents.GO_BACK
   * is fired when Android Back Button is tapped
   * [Android]
   * @memberof PlatformInterface
   */
  onGoBack() {
    console.log("goBack");
    this.listen.emit(PlatformEvents.ON_GO_BACK);
  }

  /**
   * await this method to get the FirebaseToken
   * returns "dummyToken" if not called on Flutter Interface
   * and is resolved on success
   * @return {Promise<string>}
   * @memberof PlatformInterface
   */
  async getFirebaseToken() {
    return new Promise((resolve) => resolve("dummyToken"));
  }

  /**
   * opens the phone app with the given phone number
   * does nothing if not called on Flutter Interface
   * [Android, iOS]
   * @param {string} phoneNumber
   * @memberof PlatformInterface
   */
  openPhone(phoneNumber) {
    console.log("openPhone: " + phoneNumber);
  }
}

class FlutterInterface extends PlatformInterface {
  constructor() {
    super();
    this.isInitalized = false;
    window.addEventListener("flutterInAppWebViewPlatformReady", async () => {
      this.isInitalized = true;
      console.log("FlutterInterface initialized");
      // this.platform = await this.getPlatform();
      this.stackedCalls.forEach((call) => call());
      this.stackedCalls = [];
    });
  }

  /**
   * @override
   */
  async getPlatform() {
    return window.flutter_inappwebview.callHandler("getPlatform");
  }

  /**
   * @override
   */
  openPhone(phoneNumber) {
    if (this.isInitalized) {
      window.flutter_inappwebview.callHandler("openPhone", phoneNumber);
    } else {
      this.stackedCalls.push(() => this.openPhone(phoneNumber));
    }
  }

  /**
   * @override
   */
  async getFirebaseToken() {
    if (this.isInitalized) {
      return window.flutter_inappwebview.callHandler("getFirebaseToken");
    } else {
      return new Promise((resolve) =>
        this.stackedCalls.push(() => resolve(this.getFirebaseToken()))
      );
    }
  }
}

/**
 * @type {PlatformInterface}
 */
var platformInterface = null;

if (typeof window.flutter_inappwebview != "undefined") {
  console.log("Instantiating FlutterInterface");
  platformInterface = new FlutterInterface();
} else {
  console.log("Instantiating PlatformInterface");
  platformInterface = new PlatformInterface();
}
```

the package provides an example for the javascript implementation [here](./js/platformInterface.js);

You can also checkout the [Example](./example/assets/webview/) on how this is implemented

## Available Controllers

### AppStateController

Communicates app lifecycle events to the WebView.

```dart
// Dart usage
// Automatically registered by default

// JavaScript usage
window.addEventListener('onGoBack', () => {
  // Handle back navigation
});

window.addEventListener('onPause', () => {
  // App went to background
});

window.addEventListener('onResume', () => {
  // App came to foreground
});
```

## Advanced Configuration

### Custom WebView Settings

The `WebviewWrapper` depends on `InAppWebView`. There are default settings of `InAppWebViewSettings` set in
[WebviewSetup](./lib/src/webview_setup.dart).
In case you need to override them, provide your custom `InAppWebViewSettings` on instantiating `WebviewSetup`:

```dart
final webviewSetup = WebviewSetup(
  webviewSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    // Other InAppWebView settings
  ),
  enableLogging: true, // Enable debug logging
);
```

### Handle Back Navigation

```dart
// In your Flutter widget
@override
void initState() {
  super.initState();
  // Listen for WillPopScope or use PopScope widget
  // WebviewSetup.instance.onGoBack() is called automatically in WebviewWrapper
}
```

## Notes

- Your web application must define a JavaScript class with the name matching `platformInterface` (default) or your custom name.
- Always call `WebviewSetup.instance.dispose()` when you're done with the WebView to release resources.
- For iOS, ensure you have the appropriate permissions set up in your Info.plist for features like Firebase messaging.

## Example

A complete example demonstrating all features:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_webview_controllers/flutter_webview_controllers.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Controllers Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  Future<void> _setupWebView() async {
    // Initialize with all available controllers
    final webviewSetup = WebviewSetup(
      platformInterface: 'platformInterface',
      controllers: {
        FlutterWebviewControllers.firebase,
        FlutterWebviewControllers.phone,
        FlutterWebviewControllers.appState,
      },
      enableLogging: true,
    );

    // Use local assets for the web content
    await webviewSetup.startLocalhostServer('assets/webview');
  }

  @override
  Widget build(BuildContext context) {
    return const WebviewWrapper(
      backgroundColor: Colors.white,
    );
  }
}
```
