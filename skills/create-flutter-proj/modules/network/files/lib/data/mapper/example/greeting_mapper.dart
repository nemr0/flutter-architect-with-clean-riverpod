import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/example/response/greeting_response/greeting_response.dart';
import 'package:__APP__/domain/model/greeting/greeting.dart';

/// DTO → domain conversion lives in a mapper extension, never in the
/// repository body or the view model.
extension GreetingResponseMapper on GreetingResponse {
  Greeting toGreeting() => Greeting(message: message, count: count);
}
