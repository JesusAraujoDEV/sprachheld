/// Repetición espaciada — Leitner de 5 cajas (no SM-2, ponytail: ver
/// docs/PLAN.md §7). Acierto sube de caja, fallo vuelve a la 1.
class SrsState {
  final int box; // 1..5
  final DateTime dueDate;
  final int wrongCount;
  final DateTime lastSeen;

  const SrsState({
    required this.box,
    required this.dueDate,
    required this.wrongCount,
    required this.lastSeen,
  });

  factory SrsState.initial(DateTime now) =>
      SrsState(box: 1, dueDate: now, wrongCount: 0, lastSeen: now);

  factory SrsState.fromJson(Map<String, dynamic> json) => SrsState(
        box: json['box'] as int,
        dueDate: DateTime.parse(json['dueDate'] as String),
        wrongCount: json['wrongCount'] as int,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
      );

  Map<String, dynamic> toJson() => {
        'box': box,
        'dueDate': dueDate.toIso8601String(),
        'wrongCount': wrongCount,
        'lastSeen': lastSeen.toIso8601String(),
      };
}

class Srs {
  /// Días de espera por caja (índice 0 = caja 1).
  static const intervalDays = [0, 1, 3, 7, 16];

  static bool isDue(SrsState state, DateTime now) => !state.dueDate.isAfter(now);

  static SrsState next(SrsState state, {required bool correct, required DateTime now}) {
    final newBox = correct ? (state.box + 1).clamp(1, intervalDays.length) : 1;
    return SrsState(
      box: newBox,
      dueDate: now.add(Duration(days: intervalDays[newBox - 1])),
      wrongCount: correct ? state.wrongCount : state.wrongCount + 1,
      lastSeen: now,
    );
  }
}
