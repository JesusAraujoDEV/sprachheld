import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

const _configKey = 'sh.config';

/// Config global chica (TTS, autoplay). ChangeNotifier estándar de Flutter
/// — ponytail: no justifica Riverpod/Bloc para dos flags persistidos
/// (docs/PLAN.md §9).
class ConfigNotifier extends ChangeNotifier {
  final StorageService _storage;
  bool ttsEnabled;
  bool autoPlayAudio;

  ConfigNotifier(
    this._storage, {
    this.ttsEnabled = true,
    this.autoPlayAudio = false,
  });

  factory ConfigNotifier.load(StorageService storage) {
    final json = storage.getJson<Map<String, dynamic>>(
      _configKey,
      const {'ttsEnabled': true, 'autoPlayAudio': false},
      (decoded) => Map<String, dynamic>.from(decoded as Map),
    );
    return ConfigNotifier(
      storage,
      ttsEnabled: json['ttsEnabled'] as bool? ?? true,
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
    );
  }

  void setTtsEnabled(bool value) {
    ttsEnabled = value;
    _persist();
    notifyListeners();
  }

  void setAutoPlayAudio(bool value) {
    autoPlayAudio = value;
    _persist();
    notifyListeners();
  }

  void _persist() {
    _storage.setJson(_configKey, {
      'ttsEnabled': ttsEnabled,
      'autoPlayAudio': autoPlayAudio,
    });
  }
}
