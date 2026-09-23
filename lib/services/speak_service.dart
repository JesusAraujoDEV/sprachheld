import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

import 'german_voice_stub.dart' if (dart.library.js_interop) 'german_voice_web.dart';

/// Envoltura mínima sobre flutter_tts — motor nativo de cada plataforma
/// (docs/PLAN.md §5). [speak] debe llamarse siempre dentro de un gesto de
/// usuario (onPressed), nunca en initState/build: obligatorio en iOS.
///
/// En web NO se usa flutter_tts: depende de las voces del sistema y sin voz
/// alemana habla en español. Ahí se usa Piper (docs/decisions/0002-*.md).
class SpeakService {
  SpeakService._();
  static final SpeakService instance = SpeakService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _webWarm = false;

  /// True en web hasta la primera síntesis exitosa: cargar el modelo (~63 MB,
  /// cacheado en el navegador) tarda, y la UI debería avisarlo.
  bool get needsWarmup => kIsWeb && !_webWarm;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
    _ready = true;
  }

  Future<void> speak(String text) async {
    if (kIsWeb) {
      await speakGerman(text);
      _webWarm = true;
      return;
    }
    await _ensureReady();
    await _tts.stop();
    await _tts.speak(text);
  }
}
