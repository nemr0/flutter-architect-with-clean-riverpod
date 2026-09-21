import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/key_value_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A FutureProvider because SharedPreferences loads asynchronously; consumers
/// hold the `Future` (`ref.watch(sharedPreferencesClientProvider.future)`)
/// and await it per call, so nothing blocks app start.
final sharedPreferencesClientProvider = FutureProvider<KeyValueStorage>(
  (ref) async => SharedPreferencesClient(await SharedPreferences.getInstance()),
);

class SharedPreferencesClient implements KeyValueStorage {
  SharedPreferencesClient(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> setObject(String key, Object? value) =>
      setString(key, jsonEncode(value));

  @override
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await getString(key);
    return raw == null ? null : fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteData(String key) => _prefs.remove(key);

  @override
  Future<void> deleteAllData() => _prefs.clear();
}
