import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Rótulo de sección del Home ("Practicar", "Consulta y progreso").
/// Compartido por ambos layouts para no repetir el estilo.
class HomeSectionHeader extends StatelessWidget {
  final String title;

  const HomeSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: kOnSurfaceVariant),
    );
  }
}
