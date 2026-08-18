import 'package:flutter/foundation.dart';

import '../engine/srs.dart';
import '../services/storage_service.dart';

const _progressKey = 'sh.progress';
const _statsKey = 'sh.stats';

/// Progreso persistido: SRS por ítem (Leitner) + XP/racha/high-score. Un
/// solo notifier para no duplicar plumbing entre pantallas (docs/PLAN.md §7).
class ProgressNotifier extends ChangeNotifier {
  final StorageService _storage;
  final Map<String, SrsState> _states;
  int xp;
  int streakDays;
  String? _lastPlayedDate; // yyyy-MM-dd
  int arcadeHighScore;

  ProgressNotifier(
    this._storage,
    this._states, {
    this.xp = 0,
    this.streakDays = 0,
    String? lastPlayedDate,
    this.arcadeHighScore = 0,
  }) : _lastPlayedDate = lastPlayedDate;

  factory ProgressNotifier.load(StorageService storage) {
    final progressRaw = storage.getJson<Map<String, dynamic>>(
      _progressKey,
      const {},
      (decoded) => Map<String, dynamic>.from(decoded as Map),
    );
    final states = {
      for (final entry in progressRaw.entries)
        entry.key: SrsState.fromJson(entry.value as Map<String, dynamic>),
    };
    final statsRaw = storage.getJson<Map<String, dynamic>>(
      _statsKey,
      const {},
      (decoded) => Map<String, dynamic>.from(decoded as Map),
    );
    return ProgressNotifier(
      storage,
      states,
      xp: statsRaw['xp'] as int? ?? 0,
      streakDays: statsRaw['streakDays'] as int? ?? 0,
      lastPlayedDate: statsRaw['lastPlayedDate'] as String?,
      arcadeHighScore: statsRaw['arcadeHighScore'] as int? ?? 0,
    );
  }

  Map<String, SrsState> get states => Map.unmodifiable(_states);
  int get masteredCount => _states.values.where((s) => s.box >= 4).length;
  int get weakCount => _states.values.where((s) => s.box <= 2).length;

  void record(String itemId, {required bool correct}) {
    final now = DateTime.now();
    final prev = _states[itemId] ?? SrsState.initial(now);
    _states[itemId] = Srs.next(prev, correct: correct, now: now);
    xp += correct ? 10 : 2;
    _persistProgress();
    _persistStats();
    notifyListeners();
  }

  /// Llamar una vez al terminar cualquier sesión — sube la racha si hoy
  /// todavía no se había jugado.
  void recordSessionComplete() {
    final today = _dateKey(DateTime.now());
    if (_lastPlayedDate == today) return;
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    streakDays = (_lastPlayedDate == yesterday) ? streakDays + 1 : 1;
    _lastPlayedDate = today;
    _persistStats();
    notifyListeners();
  }

  void recordArcadeScore(int score) {
    if (score <= arcadeHighScore) return;
    arcadeHighScore = score;
    _persistStats();
    notifyListeners();
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _persistProgress() {
    _storage.setJson(_progressKey, {
      for (final entry in _states.entries) entry.key: entry.value.toJson(),
    });
  }

  void _persistStats() {
    _storage.setJson(_statsKey, {
      'xp': xp,
      'streakDays': streakDays,
      'lastPlayedDate': _lastPlayedDate,
      'arcadeHighScore': arcadeHighScore,
    });
  }
}
