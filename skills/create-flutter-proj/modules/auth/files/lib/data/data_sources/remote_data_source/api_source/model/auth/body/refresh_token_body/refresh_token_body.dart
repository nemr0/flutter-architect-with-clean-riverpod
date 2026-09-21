import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_body.freezed.dart';
part 'refresh_token_body.g.dart';

@freezed
abstract class RefreshTokenBody with _$RefreshTokenBody {
  const factory RefreshTokenBody({required String refreshToken}) =
      _RefreshTokenBody;

  factory RefreshTokenBody.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenBodyFromJson(json);
}
