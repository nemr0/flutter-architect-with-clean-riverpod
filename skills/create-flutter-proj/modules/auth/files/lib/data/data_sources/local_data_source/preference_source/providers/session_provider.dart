import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/model/auth/token/token.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/key_value_storage.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/secured_storage_client.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/shared_preferences_client.dart';
import 'package:__APP__/data/data_sources/local_data_source/preference_source/storage/util/shared_pref_keys.dart';

abstract class ISessionProvider {
  Future<Token?> getToken();
  Future<void> updateToken(Token token);
  Future<void> clearSession();
}

/// Plain non-auto-dispose Provider: the interceptor reads it for the app's
/// life.
final sessionProvider = Provider<ISessionProvider>(
  (ref) => SessionManager(
    ref.watch(sharedPreferencesClientProvider.future),
    ref.watch(securedStorageClientProvider),
  ),
);

class SessionManager implements ISessionProvider {
  SessionManager(this._prefs, this._secure);

  final Future<KeyValueStorage> _prefs;
  final KeyValueStorage _secure;

  @override
  Future<Token?> getToken() =>
      _secure.getObject(SharedPrefKeys.token, Token.fromJson);

  @override
  Future<void> updateToken(Token token) =>
      _secure.setObject(SharedPrefKeys.token, token);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _secure.deleteAllData(),
      (await _prefs).deleteAllData(),
    ]);
  }
}
