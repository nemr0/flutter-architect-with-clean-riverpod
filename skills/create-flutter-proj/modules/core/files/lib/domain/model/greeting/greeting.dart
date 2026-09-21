import 'package:freezed_annotation/freezed_annotation.dart';

part 'greeting.freezed.dart';

/// Domain models: freezed, serialization OFF (DTOs own JSON, mappers convert).
/// Turn a flag on only when something calls it.
@Freezed(
  copyWith: false,
  equal: true,
  toJson: false,
  fromJson: false,
  toStringOverride: true,
)
abstract class Greeting with _$Greeting {
  const factory Greeting({required String message, required int count}) =
      _Greeting;
}
