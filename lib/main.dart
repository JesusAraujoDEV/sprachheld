import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'models/adjective.dart';
import 'models/gender_rule.dart';
import 'models/noun.dart';
import 'models/phrase.dart';
import 'models/verb.dart';

void main() {
  runApp(const SprachheldApp());
}

class SprachheldApp extends StatelessWidget {
  const SprachheldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprachheld',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B14),
      ),
      home: const _DataCheckScreen(),
    );
  }
}

/// Fase 0: prueba de que el schema + el parsing de assets funcionan.
/// Carga los 5 mazos y muestra sus conteos. Se reemplaza por Home en la
/// Fase 7 (docs/PLAN.md §10).
class _DataCheckScreen extends StatelessWidget {
  const _DataCheckScreen();

  Future<_DeckCounts> _loadAll() async {
    final results = await Future.wait([
      DataRepository.loadVerbs(),
      DataRepository.loadNouns(),
      DataRepository.loadAdjectives(),
      DataRepository.loadGenderRules(),
      DataRepository.loadPhrases(),
    ]);
    return _DeckCounts(
      verbs: results[0] as List<Verb>,
      nouns: results[1] as List<Noun>,
      adjectives: results[2] as List<Adjective>,
      genderRules: results[3] as List<GenderRule>,
      phrases: results[4] as List<Phrase>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦸 Sprachheld — Fase 0')),
      body: FutureBuilder<_DeckCounts>(
        future: _loadAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final counts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Schema + assets cargados correctamente:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _DeckTile(label: 'Verbos', count: counts.verbs.length),
              _DeckTile(label: 'Sustantivos', count: counts.nouns.length),
              _DeckTile(label: 'Adjetivos', count: counts.adjectives.length),
              _DeckTile(label: 'Reglas de género', count: counts.genderRules.length),
              _DeckTile(label: 'Frases', count: counts.phrases.length),
              const SizedBox(height: 24),
              Text(
                'Ejemplo — ${counts.verbs.first.infinitiv} (${counts.verbs.first.es}): '
                'ich ${counts.verbs.first.praesens[0]}, '
                'du ${counts.verbs.first.praesens[1]}.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeckCounts {
  final List<Verb> verbs;
  final List<Noun> nouns;
  final List<Adjective> adjectives;
  final List<GenderRule> genderRules;
  final List<Phrase> phrases;

  const _DeckCounts({
    required this.verbs,
    required this.nouns,
    required this.adjectives,
    required this.genderRules,
    required this.phrases,
  });
}

class _DeckTile extends StatelessWidget {
  final String label;
  final int count;

  const _DeckTile({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$count')),
      title: Text(label),
    );
  }
}
