import 'package:supabase_flutter/supabase_flutter.dart';

/// Un puntaje del ranking (fila de `public.scores`).
class ScoreEntry {
  final String? name;
  final String mode;
  final int? score;
  final int correct;
  final int total;
  final int? bestCombo;
  final DateTime createdAt;

  const ScoreEntry({
    required this.name,
    required this.mode,
    required this.score,
    required this.correct,
    required this.total,
    required this.bestCombo,
    required this.createdAt,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        name: json['name'] as String?,
        mode: json['mode'] as String,
        score: json['score'] as int?,
        correct: (json['correct'] as int?) ?? 0,
        total: (json['total'] as int?) ?? 0,
        bestCombo: json['best_combo'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Ranking online (Supabase). TODO best-effort: nunca lanza al caller — si no
/// hay red o Supabase falla, subir devuelve false y leer devuelve lista vacía,
/// y la app sigue funcionando igual (offline-first, ver ADR 0001).
class ScoreService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null; // Supabase no se inicializó (sin red al arrancar, etc.)
    }
  }

  /// Sube un puntaje. Devuelve true si se guardó. [name] es opcional (alias).
  static Future<bool> submit({
    required String mode,
    int? score,
    int correct = 0,
    int total = 0,
    int? bestCombo,
    int? durationSeconds,
    String? name,
  }) async {
    final client = _client;
    if (client == null) return false;
    final trimmed = name?.trim();
    try {
      await client.from('scores').insert({
        'name': (trimmed == null || trimmed.isEmpty) ? null : trimmed,
        'mode': mode,
        'score': score,
        'correct': correct,
        'total': total,
        'best_combo': bestCombo,
        'duration_seconds': durationSeconds,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Top [limit] puntajes de un modo, de mayor a menor score. Vacío ante error.
  static Future<List<ScoreEntry>> top(String mode, {int limit = 20}) async {
    final client = _client;
    if (client == null) return const [];
    try {
      final rows = await client
          .from('scores')
          .select()
          .eq('mode', mode)
          .order('score', ascending: false)
          .limit(limit);
      return rows.map((r) => ScoreEntry.fromJson(r)).toList();
    } catch (_) {
      return const [];
    }
  }
}
