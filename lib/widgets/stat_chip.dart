import 'package:flutter/material.dart';

/// Un valor de la fila de stats del Home (racha, XP, dominados, débiles).
class StatChip extends StatelessWidget {
  final String icon;
  final String label;

  const StatChip({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
