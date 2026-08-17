import 'package:flutter_tts/flutter_tts.dart';

/// Envoltura mínima sobre flutter_tts — motor nativo de cada plataforma
/// (docs/PLAN.md §5). [speak] debe llamarse siempre dentro de un gesto de
/// usuario (onPressed), nunca en initState/build: obligatorio en iOS.
class SpeakService {
  SpeakService._();
  static final SpeakService instance = SpeakService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.45);
    _ready = true;
  }

  Future<void> speak(String text) async {
    await _ensureReady();
    await _tts.stop();
    await _tts.speak(text);
  }
}
