import 'package:logger/logger.dart';

/// A singleton logger class that can be used to log messages.
///
/// call [enable] to enable the logger and [disable] to disable it.
///
/// call [d] to log a debug message.
///
/// call [e] to log an error message.
///
/// call [i] to log an info message.
final class CustomLogger {
  CustomLogger._();
  static const _tag = 'FlutterWebviewControllers';

  static final CustomLogger _instance = CustomLogger._();

  /// Returns the instance of the logger.
  static CustomLogger get instance => _instance;

  final Logger _logger = Logger(printer: PrettyPrinter());

  /// Whether the logger is enabled.
  ///
  /// Defaults to false.
  bool isEnabled = false;

  /// Logs a message.
  ///
  /// Provide a [error] to log and a [stackTrace] to log the stack trace.
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    if (isEnabled) {
      _logger.d('$_tag: $message', error: error, stackTrace: stackTrace);
    }
  }

  /// Disables the logger.
  void disable() {
    isEnabled = false;
  }

  /// Logs an error.
  ///
  /// Provide a [error] to log and a [stackTrace] to log the stack trace.
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (isEnabled) {
      _logger.e('$_tag: $message', error: error, stackTrace: stackTrace);
    }
  }

  /// Enables the logger.
  void enable() {
    isEnabled = true;
  }

  /// Logs an info message.
  ///
  /// Provide a [error] to log and a [stackTrace] to log the stack trace.
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    if (isEnabled) {
      _logger.i('$_tag: $message', error: error, stackTrace: stackTrace);
    }
  }

  /// Logs a warning message.
  ///
  /// Provide a [error] to log and a [stackTrace] to log the stack trace.
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    if (isEnabled) {
      _logger.w('$_tag: $message', error: error, stackTrace: stackTrace);
    }
  }
}
