import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';
part 'error_response.g.dart';

/// The backend's error body; `dio_error_mapper` prefers its text over the
/// generic status-code message.
@freezed
abstract class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required String? message,
    required String? error,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
