import 'package:shared_preferences/shared_preferences.dart';

mixin CacheManager {
  String? getCachedAppUserId();

  Future<void> setCachedAppUserId(String? value);
}

class SharedPreferencesCacheManager with CacheManager {
  final SharedPreferences _storage;

  SharedPreferencesCacheManager._(this._storage);

  static Future<CacheManager> create() async {
    final storage = await SharedPreferences.getInstance();
    return SharedPreferencesCacheManager._(storage);
  }

  final _appUserIdKey = 'appUserID';

  @override
  String? getCachedAppUserId() => _storage.getString(_appUserIdKey);

  @override
  Future<void> setCachedAppUserId(String? value) async => value == null ? await _storage.remove(_appUserIdKey) : await _storage.setString(_appUserIdKey, value);
}
