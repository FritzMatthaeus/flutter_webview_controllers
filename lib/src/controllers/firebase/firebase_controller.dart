import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// {@template firebase_controller}
/// A controller class that handles Firebase Cloud Messaging (FCM)
/// functionality.
/// This class provides methods to initialize FCM, request permissions, and
/// retrieve FCM tokens.
///
/// Example in Dart:
/// ```dart
/// // Initialize Firebase Messaging
/// await FirebaseController.initialize();
/// final instance = FirebaseController(
///   webViewController: webViewController,
///   webviewInterface: 'platformInterface',
/// );
///
/// // Get FCM token - might be null if not available
/// final token = await instance.getToken();
/// print('FCM Token: $token');
///
/// // Disposing the instance will remove the handler from the webview
/// instance.dispose();
/// ```
///
/// Example in JavaScript:
/// ```javascript
/// // Get FCM token - might be null if not available
/// const token = await window.flutter_inappwebview.callHandler('getFirebaseToken');
/// console.log('FCM Token:', token);
/// ```
/// {@endtemplate}
class FirebaseController extends BaseController {
  /// Creates a new instance of [FirebaseController].
  ///
  /// [webViewController] is the [InAppWebViewController] to use.
  /// [webviewInterface] is the interface name to use.
  FirebaseController({
    required this.webViewController,
    required this.webviewInterface,
  }) {
    webViewController.addJavaScriptHandler(
      handlerName: getFirebaseTokenHandlerName,
      callback: _handleFirebaseTokenCallBack,
    );
    FirebaseMessaging.instance.requestPermission();
  }

  /// Use this value to get the FCM token from the webview.
  static const getFirebaseTokenHandlerName = 'getFirebaseToken';

  @override
  final InAppWebViewController webViewController;

  @override
  final String webviewInterface;

  @override
  void dispose() {
    webViewController.removeJavaScriptHandler(
      handlerName: getFirebaseTokenHandlerName,
    );
  }

  /// Retrieves the Firebase Cloud Messaging token.
  /// For iOS devices, it first checks for an APNS token.
  /// Returns the FCM token as a string or null if not available.
  Future<String?> getToken() async {
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        CustomLogger.instance.d('No APNS token found - returning null');
        return null;
      }
    }

    final token = await FirebaseMessaging.instance.getToken();
    CustomLogger.instance.d('FCM token: $token');
    return token;
  }

  /// Handles the callback from JavaScript to retrieve the Firebase token.
  /// Returns the FCM token as a string or null if not available.
  Future<String?> _handleFirebaseTokenCallBack(List<dynamic> data) async {
    return getToken();
  }
}
