import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/body/refresh_token_body/refresh_token_body.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/response/token_response/token_response.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/base/base_response.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/providers/app_dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

// TODO: match your backend.
const loginEndpoint = '/auth/login';
const refreshTokenEndpoint = '/auth/refresh';

/// Endpoints that must not carry the access token.
const unauthenticatedEndpoints = {loginEndpoint, refreshTokenEndpoint};

final authApiProvider = Provider(AuthApi.new);

@RestApi()
abstract class AuthApi {
  factory AuthApi(Ref ref) => _AuthApi(ref.read(appDioProvider));

  @POST(refreshTokenEndpoint)
  Future<BaseResponse<TokenResponse>> refreshToken(
    @Body() RefreshTokenBody body,
  );
}
