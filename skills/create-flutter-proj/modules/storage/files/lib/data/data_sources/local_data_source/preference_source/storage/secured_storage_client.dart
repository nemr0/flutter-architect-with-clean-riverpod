import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/key_value_storage.dart';

/// Keychain / EncryptedSharedPreferences. Tokens and secrets only.
final securedStorageClientProvider = Provider<KeyValueStorage>(
  (_) => SecuredStorageClient(),
);

class SecuredStorageClient implements KeyValueStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> setBool(String key, bool value) =>
      setString(key, value.toString());

  @override
  Future<void> setInt(String key, int value) => setString(key, '$value');

  @override
  Future<String?> getString(String key) => _storage.read(key: key);

  @override
  Future<bool?> getBool(String key) async {
    final v = await getString(key);
    return v == null ? null : v == 'true';
  }

  @override
  Future<int?> getInt(String key) async {
    final v = await getString(key);
    return v == null ? null : int.tryParse(v);
  }

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
  Future<void> deleteData(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAllData() => _storage.deleteAll();
}
