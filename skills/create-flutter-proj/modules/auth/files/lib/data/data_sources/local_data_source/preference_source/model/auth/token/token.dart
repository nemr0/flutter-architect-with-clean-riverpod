import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';
part 'token.g.dart';

/// Stored model (secure storage, as JSON).
@Freezed(copyWith: false)
abstract class Token with _$Token {
  const factory Token({required String access, required String refresh}) =
      _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
