import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Which tense(s) to include in the conjugation drill.
enum TenseFilter { praesens, praeteritum, both }

/// ChoiceChip row for selecting tense filter. Shown above the quiz area.
class TenseSelector extends StatelessWidget {
  final TenseFilter selected;
  final ValueChanged<TenseFilter> onChanged;

  const TenseSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _chip(context, TenseFilter.praesens, 'Präsens'),
        _chip(context, TenseFilter.praeteritum, 'Präteritum'),
        _chip(context, TenseFilter.both, 'Ambos'),
      ],
    );
  }

  Widget _chip(BuildContext context, TenseFilter value, String label) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: kPrimary.withValues(alpha: 0.22),
      onSelected: (_) => onChanged(value),
    );
  }
}
