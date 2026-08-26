import 'package:flutter/material.dart';

import '../../widgets/option_chip.dart';

/// Multiple-choice option grid for write-conjugation mode. Two columns,
/// variable height per chip (mirrors clock_quiz_screen.dart layout to avoid
/// clipping long conjugated forms).
class WriteConjugationOptions extends StatelessWidget {
  final List<String> options;
  final String? chosen;
  final String correctValue;
  final ValueChanged<String> onTap;

  const WriteConjugationOptions({
    required this.options,
    required this.chosen,
    required this.correctValue,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final chipWidth = (screenWidth - 48 - 12) / 2;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final option in options)
          SizedBox(
            width: chipWidth,
            child: OptionChip(
              label: option,
              chosen: chosen,
              correctValue: correctValue,
              onTap: () => onTap(option),
            ),
          ),
      ],
    );
  }
}
