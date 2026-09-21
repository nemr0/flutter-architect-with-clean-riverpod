import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/providers/session_provider.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/api/auth_api/auth_api.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/body/refresh_token_body/refresh_token_body.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/providers/app_dio.dart';
import 'package:__APP__/data/mapper/auth/auth_mapper.dart';
import 'package:__APP__/domain/event/event_bus.dart';
import 'package:__APP__/domain/event/session_event.dart';

final authorizationInterceptorProvider = Provider(AuthorizationInterceptor.new);

/// Adds the bearer token, and on a 401 refreshes once and retries.
class AuthorizationInterceptor extends Interceptor {
  AuthorizationInterceptor(this.ref);

  final Ref ref;

  // Read on demand rather than cached: this interceptor outlives any single
  // provider instance it depends on.
  ISessionProvider get _session => ref.read(sessionProvider);

  /// The in-flight token refresh, or null when none is running.
  Future<void>? _refresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _session.getToken();
    final path = options.path;
    if (token != null && path == refreshTokenEndpoint) {
      options.headers['Authorization'] = 'Bearer ${token.refresh}';
    } else if (token != null && !unauthenticatedEndpoints.contains(path)) {
      options.headers['Authorization'] = 'Bearer ${token.access}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != HttpStatus.unauthorized ||
        request.path == refreshTokenEndpoint ||
        request.extra['_retried'] == true) {
      return handler.next(err);
    }

    try {
      await refreshToken();
    } catch (_) {
      // The shared refresh already logged out; this request just fails.
      return handler.reject(err);
    }

    try {
      final token = await _session.getToken();
      request.extra['_retried'] = true;
      request.headers['Authorization'] = 'Bearer ${token?.access}';
      // FormData is a single-use stream; clone it for the retry.
      if (request.data is FormData) {
        request.data = (request.data as FormData).clone();
      }
      handler.resolve(await ref.read(appDioProvider).fetch<dynamic>(request));
    } catch (e) {
      handler.reject(DioException(requestOptions: request, error: e));
    }
  }

  /// Single-flight: the first 401 starts the refresh and every concurrent 401
  /// awaits that same future, so the token is refreshed once no matter how
  /// many requests fail together. Cleared on completion.
  Future<void> refreshToken() =>
      _refresh ??= _refreshToken().whenComplete(() => _refresh = null);

  Future<void> _refreshToken() async {
    try {
      final token = await _session.getToken();
      final response = await ref
          .read(authApiProvider)
          .refreshToken(RefreshTokenBody(refreshToken: token?.refresh ?? ''));
      final data = response.data;
      if (data == null) throw StateError('refresh returned no token');
      await _session.updateToken(data.toToken());
    } catch (_) {
      // Runs once per refresh, so logout + event fire once too.
      await _session.clearSession();
      eventBus.fire(const SessionEvent(type: SessionEventType.forceLogout));
      rethrow;
    }
  }
}
