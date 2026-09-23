import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../models/verb.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../widgets/aura_background.dart';
import 'conjugation_table/conjugation_table.dart';

/// Herramienta de CONSULTA (no quiz): buscar un verbo y ver sus formas.
/// Un tab por tiempo verbal en vez de una tabla ancha — las formas
/// compuestas alemanas ("arbeiteten") no caben sin scroll horizontal en un
/// teléfono (diseño de ux-architect). En escritorio el contenido se centra
/// con un ancho legible en vez de estirarse (ux-architect).
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.isWide ? kReadableMaxWidth : double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final selected = _selected;
    if (selected == null) return _buildEmptyState();
    return ConjugationTable(verb: selected, verbs: _verbs!);
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
      optionsBuilder: (value) => _matches(verbs, value.text),
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
      optionsViewBuilder: (context, onSelected, options) => _buildOptions(context, onSelected, options),
    );
  }

  Iterable<Verb> _matches(List<Verb> verbs, String text) {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) return const Iterable<Verb>.empty();
    return verbs.where(
      (v) => v.infinitiv.toLowerCase().contains(query) || v.es.toLowerCase().contains(query),
    );
  }

  Widget _buildOptions(
    BuildContext context,
    AutocompleteOnSelected<Verb> onSelected,
    Iterable<Verb> options,
  ) {
    return Align(
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
}
