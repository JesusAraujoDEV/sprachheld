import 'dart:js_interop';

@JS('sprachheldSpeakDe')
external JSPromise<JSAny?> _speakDe(JSString text);

/// Pronuncia [text] en alemán con Piper (web/piper_bridge.js). Solo web.
Future<void> speakGerman(String text) async {
  await _speakDe(text.toJS).toDart;
}
