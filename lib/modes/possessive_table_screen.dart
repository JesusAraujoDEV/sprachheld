import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../models/possessive_pronoun.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/aura_background.dart';

/// Herramienta de CONSULTA (no quiz): tabla fija pronombre → posesivo,
/// mismo patrón que ConjugationTableScreen pero sin búsqueda (son 9 filas).
class PossessiveTableScreen extends StatefulWidget {
  const PossessiveTableScreen({super.key});

  @override
  State<PossessiveTableScreen> createState() => _PossessiveTableScreenState();
}

class _PossessiveTableScreenState extends State<PossessiveTableScreen> {
  List<PossessivePronoun>? _rows;

  @override
  void initState() {
    super.initState();
    DataRepository.loadPossessivePronouns().then((rows) {
      if (mounted) setState(() => _rows = rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Possessivpronomen'),
      ),
      body: AuraBackground(
        child: SafeArea(
          child: rows == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(color: kOutlineVariant, height: 24),
                  itemBuilder: (context, i) => _RowTile(row: rows[i]),
                ),
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  final PossessivePronoun row;

  const _RowTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.pronoun, style: Theme.of(context).textTheme.bodyLarge),
              Text(row.pronounEs, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_rounded, size: 16, color: kOnSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.possessive,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: kPrimary),
              ),
              Text(row.example, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        AudioButton(text: row.example),
      ],
    );
  }
}
