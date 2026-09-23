import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Cabecera del Home: título de marca + subtítulo. Compartida por el layout
/// móvil y el de escritorio para no duplicar el markup (frontend-architect).
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🦸 Sprachheld',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          'Practica alemán',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
        ),
      ],
    );
  }
}
