import 'level.dart';

class Adjective {
  final String id;
  final String de;
  final String es;
  final Level level;
  final String? opposite;

  const Adjective({
    required this.id,
    required this.de,
    required this.es,
    required this.level,
    this.opposite,
  });

  factory Adjective.fromJson(Map<String, dynamic> json) => Adjective(
        id: json['id'] as String,
        de: json['de'] as String,
        es: json['es'] as String,
        level: levelFromJson(json['level'] as String),
        opposite: json['opposite'] as String?,
      );
}
