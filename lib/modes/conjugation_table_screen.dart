import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/conjugation.dart';
import '../models/verb.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_background.dart';

const _personLabels = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie/Sie'];

/// Herramienta de CONSULTA (no quiz): buscar un verbo y ver sus formas.
/// Un tab por tiempo verbal en vez de una tabla ancha — las formas
/// compuestas alemanas ("arbeiteten") no caben sin scroll horizontal en un
/// teléfono (diseño de ux-architect).
class ConjugationTableScreen extends StatefulWidget {
  const ConjugationTableScreen({super.key});

  @override
  State<ConjugationTableScreen> createState() => _ConjugationTableScreenState();
}

class _ConjugationTableScreenState extends State<ConjugationTableScreen> {
  List<Verb>? _verbs;
  Verb? _selected;

  @override
  void initState() {
    super.initState();
    DataRepository.loadVerbs().then((verbs) {
      if (mounted) setState(() => _verbs = verbs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tabla de conjugación'),
      ),
      body: AuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearch(),
                const SizedBox(height: 24),
                Expanded(
                  child: _selected == null ? _buildEmptyState() : _buildTable(_selected!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    final verbs = _verbs;
    if (verbs == null) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Autocomplete<Verb>(
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<Verb>.empty();
        return verbs.where(
          (v) => v.infinitiv.toLowerCase().contains(query) || v.es.toLowerCase().contains(query),
        );
      },
      displayStringForOption: (v) => v.infinitiv,
      onSelected: (v) => setState(() => _selected = v),
      fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
        controller: controller,
        focusNode: focusNode,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Buscá un verbo (ej. gehen, comer...)',
          prefixIcon: const Icon(Icons.search_rounded, color: kOnSurfaceVariant),
          filled: true,
          fillColor: kSurfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: kSurfaceContainer,
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 48,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final v = options.elementAt(i);
                  return ListTile(
                    title: Text(v.infinitiv, style: const TextStyle(color: kOnSurface)),
                    subtitle: Text(v.es, style: const TextStyle(color: kOnSurfaceVariant)),
                    onTap: () => onSelected(v),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 40, color: kOnSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Buscá un verbo para ver su conjugación',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(Verb verb) {
    final werden = _verbs!.firstWhere((v) => v.id == 'werden', orElse: () => verb);
    final auxLookup = {
      Aux.haben: _verbs!.firstWhere((v) => v.id == 'haben', orElse: () => verb),
      Aux.sein: _verbs!.firstWhere((v) => v.id == 'sein', orElse: () => verb),
    };
    // Perfekt ya trae el auxiliar correcto por fila (habe/bin según el verbo)
    // — no hace falta un badge aparte para distinguir haben de sein.
    final tenses = <String, List<String>>{
      'Presente': verb.praesens,
      'Pasado simple': verb.praeteritum,
      'Pasado compuesto': Conjugation.perfekt(verb, auxLookup),
      'Futuro': Conjugation.futurI(verb, werden),
    };
    return DefaultTabController(
      length: tenses.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(verb.infinitiv, style: Theme.of(context).textTheme.headlineSmall),
          Text(verb.es, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 12),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: kPrimary,
            unselectedLabelColor: kOnSurfaceVariant,
            indicatorColor: kPrimary,
            tabs: const [
              Tab(icon: Icon(Icons.wb_sunny_rounded), text: 'Presente'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Pasado simple'),
              Tab(icon: Icon(Icons.done_all_rounded), text: 'Pasado compuesto'),
              Tab(icon: Icon(Icons.arrow_forward_rounded), text: 'Futuro'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [for (final forms in tenses.values) _buildTenseList(forms)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenseList(List<String> forms) {
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
        ],
      ),
    );
  }
}
