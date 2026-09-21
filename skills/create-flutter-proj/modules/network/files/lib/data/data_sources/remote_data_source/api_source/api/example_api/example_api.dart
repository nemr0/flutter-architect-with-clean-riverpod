import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/base/base_response.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/example/response/greeting_response/greeting_response.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/providers/app_dio.dart';
import 'package:retrofit/retrofit.dart';

part 'example_api.g.dart';

/// Reference API — copy its shape, then delete it. Endpoint paths are
/// top-level consts (interceptors match on them); every method returns
/// `BaseResponse<T>`; the provider is a plain `Provider` built from a Ref.
const greetingEndpoint = '/greeting';

final exampleApiProvider = Provider(ExampleApi.new);

@RestApi()
abstract class ExampleApi {
  factory ExampleApi(Ref ref) => _ExampleApi(ref.read(appDioProvider));

  @GET(greetingEndpoint)
  Future<BaseResponse<GreetingResponse>> getGreeting();
}
