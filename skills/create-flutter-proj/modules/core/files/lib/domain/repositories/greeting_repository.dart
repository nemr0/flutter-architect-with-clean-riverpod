import 'package:__APP__/domain/model/greeting/greeting.dart';

/// The data/domain boundary: plain abstract class, `Future`-returning, domain
/// types only. The impl + its provider live in `data/repositories/`.
abstract class GreetingRepository {
  Future<Greeting> getGreeting();
}
