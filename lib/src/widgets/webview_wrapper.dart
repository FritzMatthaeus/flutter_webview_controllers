import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_controllers/src/src.dart';

/// A wrapper for the webview.
///
/// This widget is used to wrap the webview and provide a
/// [Scaffold] with a [AppBar] and a body that contains the webview.
///
/// The [WebviewWrapper] is a [StatefulWidget] that contains the
/// [WebviewSetup] instance and the [InAppWebView] widget.
class WebviewWrapper extends StatefulWidget {
  /// Requires a [backgroundColor] to be provided.
  ///
  /// you can override the [systemOverlayStyle],
  /// [extendBodyBehindAppBar] and [appBarBackgroundColor] to customize the
  /// webview.
  const WebviewWrapper({
    required this.backgroundColor,
    super.key,
    this.appBarBackgroundColor = Colors.transparent,
    this.systemOverlayStyle = SystemUiOverlayStyle.light,
    this.extendBodyBehindAppBar = true,
  });

  /// The background color of the webview.
  final Color backgroundColor;

  /// The system overlay style of the webview.
  ///
  /// Defaults to [SystemUiOverlayStyle.light]
  final SystemUiOverlayStyle systemOverlayStyle;

  /// Whether to extend the body behind the app bar.
  ///
  /// Defaults to true
  final bool extendBodyBehindAppBar;

  /// The background color of the app bar.
  ///
  /// Defaults to [Colors.transparent]
  final Color appBarBackgroundColor;

  @override
  State<WebviewWrapper> createState() => _WebviewWrapperState();
}

class _WebviewWrapperState extends State<WebviewWrapper> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        WebviewSetup.instance.onGoBack();
      },
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        appBar: AppBar(
          systemOverlayStyle: widget.systemOverlayStyle,
          backgroundColor: widget.appBarBackgroundColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: InAppWebView(
                key: WebviewSetup.instance.webviewKey,
                initialSettings: WebviewSetup.instance.webviewSettings,
                initialUrlRequest: URLRequest(
                  url: WebUri(WebviewSetup.instance.baseUrl),
                ),
                onWebViewCreated: _onWebViewCreated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    CustomLogger.instance.d('Disposing webview wrapper');
    WebviewSetup.instance.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    CustomLogger.instance.d('Initializing webview wrapper');
  }

  /// Called when the webview is created.
  ///
  /// Register any JavaScript handlers here.
  void _onWebViewCreated(InAppWebViewController controller) {
    WebviewSetup.instance.onWebViewCreated(inAppWebViewController: controller);
  }
}
