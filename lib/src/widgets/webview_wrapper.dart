import 'package:flutter/material.dart';
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

  const WebviewWrapper({required this.backgroundColor, super.key});

  /// The background color of the webview.
  final Color backgroundColor;

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
        extendBody: true,

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
