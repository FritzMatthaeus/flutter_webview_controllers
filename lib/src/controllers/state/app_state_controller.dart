import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// {@template app_state_controller}
/// A controller class that handles app state functionality for
/// javascript interface calls to the WebApp.
///
/// add as callback to [AppLifecycleListener] to notify
/// the webapp about the app state.
///
/// Example in Dart:
/// ```dart
/// appLifecycleListener = AppLifecycleListener(
///   onResume: appStateController?.onResume,
///   onPause: appStateController?.onPause,
/// );
/// ```
///
/// Example in JavaScript:
/// ```javascript
/// // Listen for the app state events
/// window.addEventListener('onGoBack', () => {
///   // handle the event
/// });
///
/// // Notify the WebApp that the App has been paused
/// window.addEventListener('onPause', () => {
///   // handle the event
/// });
///
/// // Notify the WebApp that the App has been resumed
/// window.addEventListener('onResume', () => {
///   // handle the event
/// });
/// ```
/// {@endtemplate}
final class AppStateController extends BaseController {
  /// Creates a new instance of [AppStateController].
  ///
  /// [webViewController] is the [InAppWebViewController] to use.
  /// [webviewInterface] is the interface name for the WebApp.
  AppStateController({
    required this.webViewController,
    required this.webviewInterface,
  }) {
    webViewController.addJavaScriptHandler(
      handlerName: getPlatformHandlerName,
      callback: _getPlatform,
    );
  }

  /// The name of the JavaScript handler for getting the platform.
  static const getPlatformHandlerName = 'getPlatform';

  /// The [InAppWebViewController] to use.
  @override
  final InAppWebViewController webViewController;

  /// The interface name for the WebApp.
  @override
  final String webviewInterface;

  @override
  void dispose() {
    webViewController.removeJavaScriptHandler(
      handlerName: getPlatformHandlerName,
    );
  }

  /// Call this method to inform the WebApp that the user wants to go back.
  void onGoBack() => callOnWebView(method: 'onGoBack', data: '');

  /// Call this method to inform the WebApp that the App has been paused.
  void onPause() => callOnWebView(method: 'onPause', data: '');

  /// Call this method to inform the WebApp that the App has been resumed.
  void onResume() => callOnWebView(method: 'onResume', data: '');

  String _getPlatform(List<dynamic> data) {
    return Platform.operatingSystem;
  }
}
