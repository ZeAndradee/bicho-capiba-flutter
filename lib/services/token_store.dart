import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _key = 'auth_cookie';

  String? _cached;
  bool _loaded = false;

  Future<String?> read() async {
    if (_loaded) return _cached;
    final prefs = await SharedPreferences.getInstance();
    _cached = prefs.getString(_key);
    _loaded = true;
    return _cached;
  }

  Future<void> write(String cookie) async {
    _cached = cookie;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, cookie);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
