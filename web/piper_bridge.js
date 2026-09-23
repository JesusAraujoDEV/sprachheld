// Voz alemana en el navegador. speechSynthesis depende de las voces que traiga
// el sistema (Windows suele no traer alemán y habla en español), así que la web
// sintetiza con Piper (WASM) + la voz Thorsten. Ver docs/decisions/0002-*.md.
// Dart lo llama vía window.sprachheldSpeakDe (lib/services/german_voice_web.dart).
import * as tts from './piper/piper-tts-web.js';

const VOICE = 'de_DE-thorsten-medium';
const RATE = 0.9; // un poco más lento que normal, para escuchar bien
const cache = new Map(); // ponytail: sin límite, son palabras/frases cortas
let audio = null;

window.sprachheldSpeakDe = async (text) => {
  let url = cache.get(text);
  if (!url) {
    const wav = await tts.predict({ text, voiceId: VOICE });
    url = URL.createObjectURL(wav);
    cache.set(text, url);
  }
  if (audio) audio.pause();
  audio = new Audio(url);
  audio.playbackRate = RATE;
  await audio.play();
};
