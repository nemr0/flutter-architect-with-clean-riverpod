import 'dart:io';

import 'package:dio/dio.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/base/error_response.dart';
import 'package:__APP__/data/util/error/app_error.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';

/// The only place that knows Dio's error shape. Called from
/// `AppError.fromException`.
AppError appErrorFromDio(DioException e, StackTrace? trace) {
  AppError err(String message, AppErrorType type, {String? error}) =>
      AppError(message: message, error: error, type: type, trace: trace);
  final ex = t.commonExceptions;

  switch (e.type) {
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
      return switch (e.error) {
        SocketException() => err(ex.networkConnectionFailed, .network),
        HandshakeException() => err(ex.sslHandshakeFailed, .network),
        FormatException() => err(ex.invalidRequestFormat, .network),
        OSError() => err(ex.networkError, .network),
        _ => err(ex.unexpectedError, .unknown),
      };
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return err(ex.requestTimeout, .timeout);
    case DioExceptionType.sendTimeout:
      return err(ex.sendTimeout, .network);
    case DioExceptionType.cancel:
      return err(ex.requestCancelled, .cancel);
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      final type = switch (status) {
        HttpStatus.badRequest => AppErrorType.badRequest,
        HttpStatus.unauthorized => AppErrorType.unauthorized,
        HttpStatus.internalServerError ||
        HttpStatus.badGateway ||
        HttpStatus.serviceUnavailable ||
        HttpStatus.gatewayTimeout => AppErrorType.server,
        _ => AppErrorType.unknown,
      };
      var message = switch (type) {
        .badRequest => ex.badRequest,
        .unauthorized => ex.unauthorized,
        .server => ex.serverError,
        _ => ex.anErrorOccurred,
      };
      String? error;
      // Prefer the backend's own message when it sent one.
      final data = e.response?.data;
      try {
        if (data is Map<String, dynamic>) {
          final body = ErrorResponse.fromJson(data);
          message = body.error ?? body.message ?? message;
          error = body.error;
        } else if (data is String && data.isNotEmpty && !data.contains('<html')) {
          message = data;
        }
      } catch (_) {}
      return err(message, type, error: error);
    case DioExceptionType.badCertificate:
      return err(ex.sslHandshakeFailed, .network);
  }
}
