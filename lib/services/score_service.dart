import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/ranking_config.dart';

/// Un puntaje del ranking (fila de `sprachheld.scores`).
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

/// Ranking online (API propia, ver ADR 0003). Best-effort: nunca lanza al
/// caller — si no hay red o la API falla, subir devuelve false y leer
/// devuelve lista vacía, y la app sigue funcionando igual (offline-first).
class ScoreService {
  static Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${RankingConfig.baseUrl}$path').replace(queryParameters: query);

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
    final trimmed = name?.trim();
    try {
      final response = await http.post(
        _uri('/scores'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': (trimmed == null || trimmed.isEmpty) ? null : trimmed,
          'mode': mode,
          'score': score,
          'correct': correct,
          'total': total,
          'best_combo': bestCombo,
          'duration_seconds': durationSeconds,
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Top [limit] puntajes de un modo, de mayor a menor score. Vacío ante error.
  static Future<List<ScoreEntry>> top(String mode, {int limit = 20}) async {
    try {
      final response = await http.get(
        _uri('/scores', {'mode': mode, 'limit': '$limit'}),
      );
      if (response.statusCode != 200) return const [];
      final rows = jsonDecode(response.body) as List<dynamic>;
      return rows
          .map((r) => ScoreEntry.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
