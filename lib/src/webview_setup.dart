import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// A singleton class that manages the WebView setup and controllers.
///
/// This class is responsible for:
/// * Managing the WebView controllers
/// * Handling the communication between Flutter and the WebView
/// * Providing a base URL for the WebView
/// * Managing the platform interface name
///
/// You can either run the webview from the [localhostServer]
/// or from a custom [baseUrl].
///
/// **NOTE**: Your webview must provide a class with the name
///  of the [platformInterface]
///
/// Example:
/// ```dart
/// // Initialize with custom settings
/// // this will load the webview from the provided baseUrl
/// // and it will register 2 controllers:
/// // - [FlutterWebviewControllers.firebase]
/// // - [FlutterWebviewControllers.phone]
/// final webviewSetup = WebviewSetup(
///   baseUrl: 'https://example.com',
///   platformInterface: 'myPlatformInterface',
///   controllers: {
///     FlutterWebviewControllers.firebase,
///     FlutterWebviewControllers.phone,
///   },
/// );
///
/// // this will load the webview from the localhost server
/// // and it will register 2 controllers:
/// // - [FlutterWebviewControllers.firebase]
/// // - [FlutterWebviewControllers.phone]
/// final webviewSetup = WebviewSetup(
///   platformInterface: 'myPlatformInterface',
///   controllers: {
///     FlutterWebviewControllers.firebase,
///     FlutterWebviewControllers.phone,
///   },
/// );
///
/// // start the localhost server and provide the document root
/// // where the webview is located.
/// webviewSetup.startLocalhostServer('assets/webview');
///
/// // Access the singleton instance
/// final instance = WebviewSetup.instance;
///
/// // Call this method when the webview is created.
/// WebviewSetup.instance.onWebViewCreated(
///   inAppWebViewController: inAppWebViewController,
/// );
///
/// // now the registered controllers are instantiated.
///
/// // dispose the webviewSetup when the webview is disposed.
/// webviewSetup.dispose();
/// ```
///
/// The WebView setup can be accessed from anywhere in the app using the
/// singleton instance. The controllers can be used to communicate with the
/// WebView and handle platform-specific functionality.
///
/// The [onWebViewCreated] method should be called when the WebView is created,
/// typically in the [onWebViewCreated] callback of the [InAppWebView] widget.
/// This method initializes the controllers and sets up the communication
/// between Flutter and the WebView.
///
/// The [dispose] method should be called when the WebView is disposed,
/// typically in the [dispose] method of the widget that contains the WebView.
/// This method cleans up the controllers and releases any resources.

final class WebviewSetup {
  /// Returns the singleton instance of [WebviewSetup].
  ///
  /// Provide a [Set] of [FlutterWebviewControllers] to register
  /// the controllers you want to use.
  ///
  /// If no controllers are provided, the [AppStateController] will be registered
  /// by default.
  ///
  /// Provide a [baseUrl] if you do not want to run the
  /// WebView from the [localhostServer]
  ///
  /// Override the [platformInterface] if you want to use a different
  /// interface name inside the WebApp. It defines the name of the class
  /// that will be called when communicating with the WebApp.
  ///
  /// Provide a [webviewSettings] if you want to override the default settings.
  ///
  /// Provide a [webviewKey] if you want to use a specific [Key]
  /// for the webview.
  ///
  /// set [enableLogging] to true if you want to enable the logging.
  ///
  /// Default is 'platformInterface'
  ///
  /// Example:
  /// ```dart
  /// FlutterWebviewControllers(platformInterface: 'myPlatformInterface');
  /// ```
  ///
  /// Any calls to the WebView will be made to this class.
  /// ```js
  /// myPlatformInterface.getPlatform();
  /// ```
  factory WebviewSetup({
    String? baseUrl,
    Set<FlutterWebviewControllers> controllers = const {},
    String platformInterface = 'platformInterface',
    InAppWebViewSettings? webviewSettings,
    bool enableLogging = false,
    Key? webviewKey,
  }) {
    if (_instance == null) {
      _instance ??= WebviewSetup._(
        baseUrl: baseUrl,
        platformInterface: platformInterface,
        controllers: controllers,
      );
      _instance!.webviewSettings = webviewSettings ?? defaultWebviewSettings;
      _instance!.webviewKey = webviewKey ?? GlobalKey();
      if (enableLogging) {
        CustomLogger.instance.enable();
      }
    }
    return _instance!;
  }

  /// Private constructor to prevent multiple instances.
  WebviewSetup._({
    required String platformInterface,
    String? baseUrl,
    Set<FlutterWebviewControllers> controllers = const {},
  }) : _baseUrl = baseUrl,
       _platformInterface = platformInterface,
       _controllers = {...controllers, FlutterWebviewControllers.appState};

  /// The default webview settings.
  ///
  /// will be applied if no [webviewSettings] are provided by the user.
  static final defaultWebviewSettings = InAppWebViewSettings(
    allowFileAccessFromFileURLs: true,
    disableLongPressContextMenuOnLinks: true,
    horizontalScrollBarEnabled: false,
    isInspectable: true,
    javaScriptCanOpenWindowsAutomatically: true,
    safeBrowsingEnabled: false,
    transparentBackground: true,
    underPageBackgroundColor: Colors.transparent,
    disableContextMenu: true,
  );

  /// Singleton instance of [WebviewSetup].
  static WebviewSetup? _instance;

  /// Returns the singleton instance of [WebviewSetup].
  ///
  /// You must have called the [WebviewSetup] factory constructor
  /// at least once before accessing this getter.
  ///
  /// If no instance exists, it will throw an exception.
  static WebviewSetup get instance =>
      _instance ?? (throw Exception('WebviewSetup not initialized'));

  /// The key to be used for the webview.
  ///
  /// If no [webviewKey] is provided by the user,
  /// a new [GlobalKey] will be created.
  late final Key webviewKey;

  /// Settings to be used for the webview.
  ///
  /// If no [webviewSettings] are provided by the user,
  /// the [defaultWebviewSettings] will be used.
  late final InAppWebViewSettings webviewSettings;

  /// The controllers to register.
  final Set<FlutterWebviewControllers> _controllers;

  final String _platformInterface;

  /// The base URL of the webview.
  final String? _baseUrl;

  InAppLocalhostServer? _localhostServer;

  Set<BaseController> _registeredControllers = {};

  /// The base URL of the webview.
  ///
  /// If no other baseUrl is provided, on instantiation,
  /// it will default to the localhost server:
  /// 'http://localhost:${_localhostServer?.port}'
  String get baseUrl =>
      _baseUrl ?? 'http://localhost:${_localhostServer?.port}';

  /// Instance of [InAppLocalhostServer] to serve the localhost server.
  InAppLocalhostServer? get localhostServer => _localhostServer;

  /// The platform interface name.
  ///
  /// Defaults to 'platformInterface'
  ///
  /// The webview must provide a class with this name.
  String get platformInterface => _platformInterface;

  /// Call this method when the webview is disposed.
  ///
  /// It will dispose all the registered controllers.
  void dispose() {
    for (final e in _registeredControllers) {
      CustomLogger.instance.d('Disposing controller: ${e.runtimeType}');
      e.dispose();
    }
    _localhostServer?.close();
  }

  /// Call this method when the user presses the back button.
  ///
  /// It will call the [onGoBack] method of the [AppStateController]
  /// if it is registered.
  void onGoBack() {
    for (final e in _registeredControllers) {
      if (e is AppStateController) {
        CustomLogger.instance.d('Calling onGoBack');
        e.onGoBack();
      }
    }
  }

  /// Call this method when the webview is created.
  ///
  /// Provide the [inAppWebViewController] and then
  /// all the [FlutterWebviewControllers] that have been registered
  /// will be instantiated.
  ///
  /// Example:
  /// ```dart
  /// // Instantiate the WebviewSetup with 2 controllers
  /// final webviewSetup = WebviewSetup(
  ///   controllers: {
  ///     FlutterWebviewControllers.appState,
  ///     FlutterWebviewControllers.firebase,
  ///   },
  /// );
  ///
  /// // Call this method when the webview is created.
  /// WebviewSetup.instance.onWebViewCreated(
  ///   inAppWebViewController: inAppWebViewController,
  /// );
  ///
  /// // now the registered controllers are instantiated.
  ///
  /// // dispose the webviewSetup when the webview is disposed.
  /// webviewSetup.dispose();
  /// ```
  ///
  /// **NOTE**: Do not forget to call [dispose] when the webview is disposed.
  void onWebViewCreated({
    required InAppWebViewController inAppWebViewController,
  }) {
    CustomLogger.instance.d('registering controllers: $_controllers');
    _registeredControllers = _controllers
        .map((e) => e.getController(inAppWebViewController, platformInterface))
        .toSet();
  }

  /// Starts the localhost server
  ///
  /// it will load the webview from the [documentRoot]
  ///
  /// If the server is started, it will be used to serve the webview.
  /// and ignore any other url that has been provided.
  ///
  /// Example:
  /// ```dart
  /// WebviewSetup.instance.startLocalhostServer('assets/webview');
  /// ```
  Future<void> startLocalhostServer(String documentRoot) async {
    _localhostServer = InAppLocalhostServer(documentRoot: documentRoot);
    await _localhostServer?.start();
    CustomLogger.instance.d(
      'localhost server started on port: ${_localhostServer?.port}',
    );
  }
}
