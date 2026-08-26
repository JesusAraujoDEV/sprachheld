import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Styled text field for the write-conjugation typing mode.
class WriteTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool? correct;
  final VoidCallback onSubmitted;

  const WriteTextInput({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.correct,
    required this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = correct == null ? kPrimary : (correct! ? kGenderDas : kError);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      textAlign: TextAlign.center,
      autocorrect: false,
      style: Theme.of(context).textTheme.headlineSmall,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}
