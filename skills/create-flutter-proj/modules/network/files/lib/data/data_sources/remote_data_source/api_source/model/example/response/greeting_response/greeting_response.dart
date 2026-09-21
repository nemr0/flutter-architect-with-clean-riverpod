import 'package:freezed_annotation/freezed_annotation.dart';

part 'greeting_response.freezed.dart';
part 'greeting_response.g.dart';

/// DTOs: freezed + json_serializable, one directory each under
/// `api_source/model/<feature>/{body,response}/<name>/`. Rename backend
/// fields with `@JsonKey(name:)` so they don't leak into Dart.
@freezed
abstract class GreetingResponse with _$GreetingResponse {
  const factory GreetingResponse({
    @JsonKey(name: 'text') required String message,
    required int count,
  }) = _GreetingResponse;

  factory GreetingResponse.fromJson(Map<String, dynamic> json) =>
      _$GreetingResponseFromJson(json);
}
