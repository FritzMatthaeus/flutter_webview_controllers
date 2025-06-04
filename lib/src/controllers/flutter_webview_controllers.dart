import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// Enum of all the available controllers.
enum FlutterWebviewControllers {
  /// The app state controller.
  ///
  /// {@macro app_state_controller}
  appState,

  /// The firebase controller.
  ///
  /// {@macro firebase_controller}
  firebase,

  /// The phone controller.
  ///
  /// {@macro phone_controller}
  phone,
}

/// Extension on [FlutterWebviewControllers] to get
/// the [BaseController] for the given enum value.
extension FlutterWebviewControllersExtension on FlutterWebviewControllers {
  /// Returns the [BaseController] for the given [FlutterWebviewControllers]
  /// enum value.
  ///
  /// provide the [webViewController] and [platformInterface] to the controller.
  BaseController getController(
    InAppWebViewController webViewController,
    String platformInterface,
  ) => switch (this) {
    FlutterWebviewControllers.appState => AppStateController(
      webViewController: webViewController,
      webviewInterface: platformInterface,
    ),
    FlutterWebviewControllers.firebase => FirebaseController(
      webViewController: webViewController,
      webviewInterface: platformInterface,
    ),
    FlutterWebviewControllers.phone => PhoneController(
      webViewController: webViewController,
      webviewInterface: platformInterface,
    ),
  };
}
