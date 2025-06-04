import 'package:flutter/material.dart';
import 'package:flutter_webview_controllers/flutter_webview_controllers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final webviewSetup = WebviewSetup(
    controllers: {
      FlutterWebviewControllers.appState,
      FlutterWebviewControllers.firebase,
      FlutterWebviewControllers.phone,
    },
    enableLogging: true,
  );
  await webviewSetup.startLocalhostServer('assets/webview');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WebviewWrapper(backgroundColor: Colors.white),
    );
  }
}
