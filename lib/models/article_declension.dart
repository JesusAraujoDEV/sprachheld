/// Fila de la tabla de apuntes de declinación: un artículo (der/die/das/plural)
/// o un pronombre personal con sus tres formas de caso en Nominativ, Akkusativ
/// y Dativ. Solo consulta — no alimenta ningún quiz. [kind] separa las dos
/// familias ("article" vs "pronoun") para agruparlas en una sola tabla.
class ArticleDeclension {
  final String id;
  final String kind;
  final String label;
  final String nominativ;
  final String akkusativ;
  final String dativ;
  final String? example;

  const ArticleDeclension({
    required this.id,
    required this.kind,
    required this.label,
    required this.nominativ,
    required this.akkusativ,
    required this.dativ,
    this.example,
  });

  factory ArticleDeclension.fromJson(Map<String, dynamic> json) => ArticleDeclension(
        id: json['id'] as String,
        kind: json['kind'] as String,
        label: json['label'] as String,
        nominativ: json['nominativ'] as String,
        akkusativ: json['akkusativ'] as String,
        dativ: json['dativ'] as String,
        example: json['example'] as String?,
      );
}
