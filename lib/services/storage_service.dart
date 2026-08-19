import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Envoltura fina sobre shared_preferences para leer/escribir JSON por
/// clave. ponytail: sin migración de esquema ni validación con paquetes
/// externos — si el valor guardado no parsea, cae al fallback; se versiona
/// la clave (ej. "sh.progress.v2") cuando cambie la forma del dato
/// (docs/PLAN.md §9).
class StorageService {
  final SharedPreferences _prefs;

  const StorageService(this._prefs);

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  T getJson<T>(String key, T fallback, T Function(dynamic decoded) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return fallback;
    try {
      return fromJson(jsonDecode(raw));
    } catch (_) {
      return fallback;
    }
  }

  Future<void> setJson(String key, Object value) =>
      _prefs.setString(key, jsonEncode(value));

  // --- Player name (plain string, no JSON wrapping) ---

  static const _kPlayerName = 'sh.playerName';

  String? get playerName => _prefs.getString(_kPlayerName);

  Future<void> setPlayerName(String? name) async {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _prefs.remove(_kPlayerName);
    } else {
      await _prefs.setString(_kPlayerName, trimmed);
    }
  }
}
