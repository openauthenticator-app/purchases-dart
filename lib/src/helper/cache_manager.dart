import 'package:shared_preferences/shared_preferences.dart';

mixin CacheManager {
  String? getCachedAppUserId();

  Future<void> setCachedAppUserId(String? value);
}

class SharedPreferencesCacheManager with CacheManager {
  final SharedPreferences _storage;

  SharedPreferencesCacheManager._(this._storage);

  static CacheManager? _instance;

  static Future<CacheManager> get instance async {
    if (_instance != null) return _instance!;
    final storage = await SharedPreferences.getInstance();
    _instance = SharedPreferencesCacheManager._(storage);
    return _instance!;
  }

  final _appUserIdKey = 'appUserID';

  @override
  String? getCachedAppUserId() => _storage.getString(_appUserIdKey);

  @override
  Future<void> setCachedAppUserId(String? value) async => value == null ? await _storage.remove(_appUserIdKey) : await _storage.setString(_appUserIdKey, value);
}
