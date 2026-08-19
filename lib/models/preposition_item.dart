import 'level.dart';

/// Ítem del Nivel 2 del modo de preposiciones (docs/PLAN-preposiciones.md §3.3):
/// dos respuestas encadenadas — la preposición y el artículo declinado. La
/// [sentence] trae DOS marcadores "___" (preposición, luego artículo), que se
/// rellenan en secuencia. Solo casos donde preposición y artículo son palabras
/// separadas (sin contracción tipo "ins"/"am" — esas viven en el Nivel 1).
class PrepositionItem {
  final String id;
  final String sentence;
  final String prep;
  final List<String> prepOptions;
  final String article;
  final List<String> articleOptions;
  final String es;
  final String note;
  final Level level;

  const PrepositionItem({
    required this.id,
    required this.sentence,
    required this.prep,
    required this.prepOptions,
    required this.article,
    required this.articleOptions,
    required this.es,
    required this.note,
    required this.level,
  });

  factory PrepositionItem.fromJson(Map<String, dynamic> json) => PrepositionItem(
        id: json['id'] as String,
        sentence: json['sentence'] as String,
        prep: json['prep'] as String,
        prepOptions: List<String>.from(json['prepOptions'] as List),
        article: json['article'] as String,
        articleOptions: List<String>.from(json['articleOptions'] as List),
        es: json['es'] as String,
        note: json['note'] as String,
        level: levelFromJson(json['level'] as String),
      );
}
