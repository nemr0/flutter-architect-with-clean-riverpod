/// One interface over both stores so session/cache code doesn't care which it
/// got: [SharedPreferencesClient] for plain prefs, [SecuredStorageClient] for
/// tokens and secrets.
abstract class KeyValueStorage {
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<String?> getString(String key);
  Future<bool?> getBool(String key);
  Future<int?> getInt(String key);
  Future<void> setObject(String key, Object? value);
  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  );
  Future<void> deleteData(String key);
  Future<void> deleteAllData();
}
