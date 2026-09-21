import 'package:__APP__/domain/model/greeting/greeting.dart';
import 'package:__APP__/domain/repositories/greeting_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'greeting_repository_impl.g.dart';

@riverpod
GreetingRepository greetingRepository(Ref ref) => GreetingRepositoryImpl();

// Holds resolved dependencies rather than a Ref: callers reach this class via
// `ref.read`, so its own provider is disposed the moment the read returns and
// any later `ref.read` on a stored Ref would throw UnmountedRefException.
// Replace the body with real api/cache calls + a mapper.
//
// Corollary: impls are stateless. The provider is auto-dispose, so each
// `ref.read` builds a fresh impl — an instance field would reset every call.
// State lives in the backend, a cache, or a keepAlive provider.
class GreetingRepositoryImpl implements GreetingRepository {
  /// Stands in for the backend.
  static int _fakeServerCount = 0;

  @override
  Future<Greeting> getGreeting() async =>
      Greeting(message: 'Hello from __APP_TITLE__', count: ++_fakeServerCount);
}
