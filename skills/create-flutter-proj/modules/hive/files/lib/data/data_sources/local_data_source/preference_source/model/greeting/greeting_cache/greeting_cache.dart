import 'package:freezed_annotation/freezed_annotation.dart';

part 'greeting_cache.freezed.dart';

/// Cache models: suffix `Cache`, freezed with JSON off (hive_ce generates the
/// binary adapter). Register in `hive/hive_adapters.dart`. Convert with a
/// mapper in `data/mapper/<feature>/<name>_cache_mapper.dart`.
@Freezed(copyWith: false, toJson: false, fromJson: false)
abstract class GreetingCache with _$GreetingCache {
  const factory GreetingCache({required String message, required int count}) =
      _GreetingCache;
}
