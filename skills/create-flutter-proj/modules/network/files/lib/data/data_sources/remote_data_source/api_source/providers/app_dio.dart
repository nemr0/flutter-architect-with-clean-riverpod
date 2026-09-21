import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// @imports

/// Base URL comes from `--dart-define=NETWORK_BASE_URL=...` (the flavors
/// module feeds it from `.env.<flavor>`). Never a literal in code.
const networkBaseUrl = String.fromEnvironment(
  'NETWORK_BASE_URL',
  defaultValue: 'https://api.example.com',
);

/// Plain `Provider`, not `@riverpod`: one Dio for the app's life, and
/// interceptors hold a `Ref` that must stay mounted.
final appDioProvider = Provider(AppDio.new);

class AppDio with DioMixin implements Dio {
  AppDio(this.ref) {
    options = BaseOptions(
      baseUrl: networkBaseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
    interceptors.addAll([
      // @interceptors
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
    httpClientAdapter = HttpClientAdapter();
  }

  final Ref ref;
}
