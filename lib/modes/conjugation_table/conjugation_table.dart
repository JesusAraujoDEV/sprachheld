import 'package:flutter/material.dart';

import '../../engine/conjugation.dart';
import '../../models/verb.dart';
import '../../theme/app_theme.dart';
import '../../widgets/audio_button.dart';

const _personLabels = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie/Sie'];

/// Tabla de conjugación de un verbo: un tab por tiempo verbal, cada uno con
/// las 6 formas personales y su botón de audio. Las formas compuestas
/// alemanas no caben en una tabla ancha, de ahí los tabs (ux-architect).
class ConjugationTable extends StatelessWidget {
  final Verb verb;
  final List<Verb> verbs;

  const ConjugationTable({required this.verb, required this.verbs, super.key});

  @override
  Widget build(BuildContext context) {
    final tenses = _tenses();
    return DefaultTabController(
      length: tenses.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(verb.infinitiv, style: Theme.of(context).textTheme.headlineSmall),
          Text(verb.es, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: kPrimary,
            unselectedLabelColor: kOnSurfaceVariant,
            indicatorColor: kPrimary,
            tabs: [
              Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'Presente'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Pasado simple'),
              Tab(icon: Icon(Icons.done_all_rounded), text: 'Pasado compuesto'),
              Tab(icon: Icon(Icons.arrow_forward_rounded), text: 'Futuro'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [for (final forms in tenses.values) _TenseList(forms: forms)],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _tenses() {
    final werden = verbs.firstWhere((v) => v.id == 'werden', orElse: () => verb);
    // Perfekt ya trae el auxiliar correcto por fila (habe/bin según el verbo).
    final auxLookup = {
      Aux.haben: verbs.firstWhere((v) => v.id == 'haben', orElse: () => verb),
      Aux.sein: verbs.firstWhere((v) => v.id == 'sein', orElse: () => verb),
    };
    return {
      'Presente': verb.praesens,
      'Pasado simple': verb.praeteritum,
      'Pasado compuesto': Conjugation.perfekt(verb, auxLookup),
      'Futuro': Conjugation.futurI(verb, werden),
    };
  }
}

class _TenseList extends StatelessWidget {
  final List<String> forms;

  const _TenseList({required this.forms});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: forms.length,
      separatorBuilder: (_, _) => const Divider(color: kOutlineVariant, height: 24),
      itemBuilder: (context, i) => Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _personLabels[i],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              forms[i],
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
            ),
          ),
          AudioButton(text: '${_personLabels[i]} ${forms[i]}'),
        ],
      ),
    );
  }
}
