import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../models/article_declension.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../widgets/audio_button.dart';
import '../widgets/aura_background.dart';

/// Herramienta de CONSULTA (no quiz): tabla de declinación de artículos y
/// pronombres personales en los tres casos (Nominativ/Akkusativ/Dativ),
/// mismo molde que PossessiveTableScreen. Agrupa por [ArticleDeclension.kind].
class ArticleDeclensionTableScreen extends StatefulWidget {
  const ArticleDeclensionTableScreen({super.key});

  @override
  State<ArticleDeclensionTableScreen> createState() =>
      _ArticleDeclensionTableScreenState();
}

class _ArticleDeclensionTableScreenState
    extends State<ArticleDeclensionTableScreen> {
  List<ArticleDeclension>? _rows;

  @override
  void initState() {
    super.initState();
    DataRepository.loadArticleDeclensions().then((rows) {
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
        title: const Text('Artikel & Pronomen'),
      ),
      body: AuraBackground(
        child: SafeArea(
          child: rows == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.isWide ? kReadableMaxWidth : double.infinity,
                    ),
                    child: _DeclensionList(rows: rows),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Lista con encabezado de columnas y separadores entre familias
/// (artículos → pronombres) sin romper el límite de 30 líneas por función.
class _DeclensionList extends StatelessWidget {
  final List<ArticleDeclension> rows;

  const _DeclensionList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: rows.length + 1,
      separatorBuilder: (_, _) => const Divider(color: kOutlineVariant, height: 24),
      itemBuilder: (context, i) {
        if (i == 0) return const _HeaderRow();
        return _DeclensionTile(row: rows[i - 1]);
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: kPrimary);
    return Row(
      children: [
        SizedBox(width: 110, child: Text('Caso →', style: style)),
        Expanded(child: Text('Nominativ', style: style)),
        Expanded(child: Text('Akkusativ', style: style)),
        Expanded(child: Text('Dativ', style: style)),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _DeclensionTile extends StatelessWidget {
  final ArticleDeclension row;

  const _DeclensionTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final caseStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w600, color: kOnSurface);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            row.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: kOnSurfaceVariant),
          ),
        ),
        Expanded(child: Text(row.nominativ, style: caseStyle)),
        Expanded(
          child: Text(row.akkusativ, style: caseStyle?.copyWith(color: kPrimary)),
        ),
        Expanded(child: Text(row.dativ, style: caseStyle)),
        AudioButton(text: row.example ?? '${row.nominativ}, ${row.akkusativ}, ${row.dativ}'),
      ],
    );
  }
}
