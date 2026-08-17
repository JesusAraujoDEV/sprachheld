/// Nivel MCER del ítem: A1, A2 o B1 (alcance de la v1, ver docs/PLAN.md).
enum Level { a1, a2, b1 }

Level levelFromJson(String value) => Level.values.firstWhere(
      (l) => l.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Level.a1,
    );

String levelToJson(Level level) => level.name.toUpperCase();
