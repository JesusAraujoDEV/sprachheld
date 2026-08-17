import 'package:flutter/material.dart';

import '../modes/flashcard_screen.dart';
import '../state/config_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_background.dart';

class HomeScreen extends StatelessWidget {
  final ConfigNotifier config;

  const HomeScreen({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                const SizedBox(height: 32),
                _ModeCard(
                  title: 'Verbos',
                  subtitle: 'Flashcard · infinitivo ↔ traducción',
                  accent: kPrimary,
                  onTap: () => _openFlashcards(context, FlashcardDeck.verbs),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'der / die / das',
                  subtitle: 'Flashcard · sustantivo ↔ género',
                  accent: kGenderDas,
                  onTap: () => _openFlashcards(context, FlashcardDeck.nouns),
                ),
                const Spacer(),
                ListenableBuilder(
                  listenable: config,
                  builder: (context, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.ttsEnabled,
                    onChanged: config.setTtsEnabled,
                    title: const Text('Pronunciación (TTS)'),
                    activeThumbColor: kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFlashcards(BuildContext context, FlashcardDeck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FlashcardScreen(deck: deck)),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOutline),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kOnSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
