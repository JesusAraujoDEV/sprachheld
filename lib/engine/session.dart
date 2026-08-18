import 'dart:math';

import 'question.dart';
import 'srs.dart';

class SessionOptions {
  final int size;

  /// itemId → estado SRS. Si viene, prioriza ítems 'due' sobre los nuevos.
  final Map<String, SrsState>? srs;
  final bool shuffle;

  const SessionOptions({this.size = 10, this.srs, this.shuffle = true});
}

/// Arma la lista de preguntas de una sesión a partir de un mazo ya
/// convertido a [Question] (la conversión Verb/Noun/Phrase → Question vive
/// en cada modo, no aquí — esta función solo selecciona/prioriza/recorta).
List<Question> buildSession(List<Question> deck, SessionOptions options) {
  final pool = List<Question>.from(deck);
  if (options.shuffle) pool.shuffle(Random());

  if (options.srs == null) {
    return pool.take(options.size).toList();
  }

  final now = DateTime.now();
  final due = <Question>[];
  final fresh = <Question>[];
  final notDue = <Question>[];
  for (final q in pool) {
    final state = options.srs![q.id];
    if (state == null) {
      fresh.add(q);
    } else if (Srs.isDue(state, now)) {
      due.add(q);
    } else {
      notDue.add(q);
    }
  }

  // due/fresh tienen prioridad, pero un mazo nunca debe quedar vacío solo
  // porque nada esté "vencido" todavía — notDue es el relleno de último
  // recurso (ej.: un mazo chico ya dominado, jugado dos veces seguidas).
  return [...due, ...fresh, ...notDue].take(options.size).toList();
}
