import 'package:flutter/foundation.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
// @imports

enum AppErrorType {
  network,
  badRequest,
  unauthorized,
  cancel,
  timeout,
  server,
  unknown,
}

/// The one error type that reaches view models and UI.
///
/// Everything thrown below the view model is normalised into this by
/// [AppError.fromException] — via `guard` in `build()` and `runLoad` in
/// actions — so nothing above the data layer catches SDK exceptions.
/// Add an `if (error is XException)` branch per SDK you pull in; that branch
/// is the only place that SDK's error shape is known. `message` is already
/// localized, so UI shows it as-is.
class AppError implements Exception {
  AppError({
    required this.message,
    required this.error,
    required this.type,
    this.trace,
  });

  final String message;
  final String? error;
  final AppErrorType type;
  final StackTrace? trace;

  factory AppError.fromException(Object? error, {StackTrace? trace}) {
    if (error is AppError) return error;
    if (error == null) {
      return AppError(
        message: t.commonExceptions.unknownError,
        error: null,
        type: AppErrorType.unknown,
        trace: trace,
      );
    }
    // @error-mappers
    debugPrint(
      'Unhandled exception type in AppError.fromException: '
      '${error.runtimeType}, error: $error',
    );
    return AppError(
      message: t.commonExceptions.somethingWentWrong,
      error: error.toString(),
      type: AppErrorType.unknown,
      trace: trace,
    );
  }

  @override
  String toString() => 'AppError($type): $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError && other.message == message && other.type == type;

  @override
  int get hashCode => message.hashCode ^ type.hashCode;
}
