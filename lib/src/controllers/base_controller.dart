import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class BaseController {
  /// The webview controller.
  InAppWebViewController get webViewController;

  /// The javascript interface class name.
  String get webviewInterface;

  /// This method will call the provided [method] on the
  /// javascript interface class [webviewInterface]
  /// with the provided [data] via the [webViewController] instance.
  ///
  /// Example:
  /// ```dart
  /// callOnWebView(method: 'getFirebaseToken', data: 'data');
  ///
  /// // In the WebApp this will be executed as
  /// platformInterface.getFirebaseToken("data");
  ///
  /// ```
  void callOnWebView({required String method, required String data}) {
    webViewController.evaluateJavascript(
      source: '$webviewInterface.$method("$data")',
    );
  }

  /// override this method to dispose any resources
  void dispose();
}
