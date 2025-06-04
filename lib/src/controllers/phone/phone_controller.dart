import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// {@template phone_controller}
/// A controller class that handles phone dialer functionality for the WebApp.
/// This class provides methods to launch the device's phone dialer with
/// a specified phone number.
///
/// Example in Dart:
/// ```dart
/// final instance = PhoneController(
///   webViewController: webViewController,
///   webviewInterface: 'platformInterface',
/// );
///
/// // The phone dialer can be triggered from JavaScript
/// // Disposing the instance will remove the handler from the webview
/// instance.dispose();
/// ```
///
/// Example in JavaScript:
/// ```javascript
/// // Launch phone dialer with a phone number
/// await window.flutter_inappwebview.callHandler('openPhone', '+1234567890');
/// ```
/// {@endtemplate}
final class PhoneController extends BaseController {
  /// Creates a new instance of [PhoneController].
  ///
  /// The [webViewController] is used to handle JavaScript callbacks,
  /// and [webviewInterface] specifies the interface name for the WebApp.
  PhoneController({
    required this.webViewController,
    required this.webviewInterface,
  }) {
    webViewController.addJavaScriptHandler(
      handlerName: openPhoneHandlerName,
      callback: _launchPhoneDialer,
    );
  }

  /// The name of the JavaScript handler for opening the phone dialer
  static const openPhoneHandlerName = 'openPhone';

  @override
  final InAppWebViewController webViewController;

  @override
  final String webviewInterface;

  @override
  void dispose() {
    webViewController.removeJavaScriptHandler(
      handlerName: openPhoneHandlerName,
    );
  }

  /// Launch the phone dialer with a phone number.
  ///
  /// This method will remove any non-digit characters from the phone number
  /// and then launch the phone dialer with the cleaned number.
  ///
  /// If the phone dialer cannot be launched, an error will be logged.
  Future<void> _launchPhoneDialer(List<dynamic> data) async {
    try {
      final phoneNumber = data.first as String;

      // Remove any non-digit characters from the phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      CustomLogger.instance.d(
        'Launching phone dialer with number: $cleanNumber',
      );

      await FlutterPhoneDirectCaller.callNumber(cleanNumber);
    } catch (e) {
      CustomLogger.instance.e('Error launching phone dialer: $e');
    }
  }
}
