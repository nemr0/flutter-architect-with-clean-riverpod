import 'package:__APP__/data/data_sources/local_data_source/preference_source/model/auth/token/token.dart';
import 'package:__APP__/data/data_sources/remote_data_source/api_source/model/auth/response/token_response/token_response.dart';

extension TokenResponseMapper on TokenResponse {
  Token toToken() => Token(access: accessToken, refresh: refreshToken);
}
