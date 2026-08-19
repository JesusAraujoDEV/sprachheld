/// Una hora concreta (0..23 : 0..55, múltiplos de 5). No es contenido
/// curado — es un value object efímero que el motor de "La Hora" genera y
/// convierte a expresión alemana en runtime (docs/PLAN-hora.md §2-3).
class ClockTime {
  final int hour;
  final int minute;

  const ClockTime(this.hour, this.minute);

  String get digital =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
