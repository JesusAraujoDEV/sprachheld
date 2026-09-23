import 'package:flutter/material.dart';

import '../../state/config_notifier.dart';
import '../../theme/app_theme.dart';
import '../../version.dart';
import '../../widgets/player_name_tile.dart';
import 'contact_dialog.dart';

/// Ajustes del Home: interruptor de TTS, nombre del jugador y crédito.
/// Compartido por el layout móvil y el de escritorio (frontend-architect).
class HomeSettings extends StatelessWidget {
  final ConfigNotifier config;

  const HomeSettings({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),
        const PlayerNameTile(),
        const SizedBox(height: 24),
        Center(
          child: InkWell(
            onTap: () => showContactDialog(context),
            child: Text(
              'Desarrollado por Jesús Araujo · v$kAppVersion',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kOnSurfaceVariant.withValues(alpha: 0.6),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
