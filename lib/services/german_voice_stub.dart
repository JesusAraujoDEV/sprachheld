/// Stub para plataformas no-web: nunca se llama (SpeakService lo guarda con
/// kIsWeb); existe para que el import condicional compile en móvil/tests.
Future<void> speakGerman(String text) async {
  throw UnsupportedError('La voz Piper solo existe en web');
}
