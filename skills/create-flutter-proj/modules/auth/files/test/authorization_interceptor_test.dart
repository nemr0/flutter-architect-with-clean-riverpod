import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/model/auth/token/token.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/providers/session_provider.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/api/auth_api/auth_api.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/interceptors/authorization_interceptor.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/body/refresh_token_body/refresh_token_body.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/response/token_response/token_response.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/base/base_response.dart';
import 'package:__APP__/domain/event/event_bus.dart';
import 'package:__APP__/domain/event/session_event.dart';

class _MockApi extends Mock implements AuthApi {}

class _MemorySession implements ISessionProvider {
  Token? token = const Token(access: 'a0', refresh: 'r0');
  bool cleared = false;
  @override
  Future<Token?> getToken() async => token;
  @override
  Future<void> updateToken(Token t) async => token = t;
  @override
  Future<void> clearSession() async => cleared = true;
}

void main() {
  setUpAll(() => registerFallbackValue(const RefreshTokenBody(refreshToken: '')));

  late _MockApi api;
  late _MemorySession session;
  late AuthorizationInterceptor interceptor;

  setUp(() {
    api = _MockApi();
    session = _MemorySession();
    final container = ProviderContainer(
      overrides: [
        authApiProvider.overrideWithValue(api),
        sessionProvider.overrideWithValue(session),
      ],
    );
    addTearDown(container.dispose);
    interceptor = container.read(authorizationInterceptorProvider);
  });

  test('concurrent 401s refresh the token exactly once', () async {
    when(() => api.refreshToken(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return const BaseResponse(
        message: null,
        data: TokenResponse(accessToken: 'a1', refreshToken: 'r1'),
      );
    });

    await Future.wait([for (var i = 0; i < 3; i++) interceptor.refreshToken()]);

    verify(() => api.refreshToken(any())).called(1);
    expect(session.token, const Token(access: 'a1', refresh: 'r1'));
  });

  test('a failed refresh clears the session and fires forceLogout once', () async {
    when(() => api.refreshToken(any())).thenThrow(StateError('401'));
    final events = <SessionEvent>[];
    final sub = eventBus.on<SessionEvent>().listen(events.add);
    addTearDown(sub.cancel);

    await expectLater(interceptor.refreshToken(), throwsStateError);
    await Future<void>.delayed(Duration.zero);

    expect(session.cleared, isTrue);
    expect(events.single.type, SessionEventType.forceLogout);
  });
}
