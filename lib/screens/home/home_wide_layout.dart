import 'package:flutter/material.dart';

import '../../modes/timed_arcade_screen.dart';
import '../../state/config_notifier.dart';
import '../../state/progress_notifier.dart';
import '../../widgets/mode_card.dart';
import '../../theme/app_theme.dart';
import 'home_header.dart';
import 'home_section_header.dart';
import 'home_settings.dart';
import 'home_stats.dart';
import 'lookup_list.dart';
import 'practice_grid.dart';

/// Layout de escritorio del Home (context.isWide): dos paneles en vez de la
/// columna única de teléfono. Izquierda (práctica) recibe más peso que la
/// columna derecha (consulta + ajustes). Reutiliza los mismos widgets que el
/// layout móvil — solo cambia la disposición (ux-architect).
class HomeWideLayout extends StatelessWidget {
  final ConfigNotifier config;
  final ProgressNotifier progress;

  const HomeWideLayout({required this.config, required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _practicePanel(context)),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: _lookupPanel()),
        ],
      ),
    );
  }

  Widget _practicePanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeHeader(),
        const SizedBox(height: 24),
        HomeStats(progress: progress),
        const SizedBox(height: 24),
        ModeCard(
          title: 'Contrarreloj',
          subtitle: '60 segundos, racha y puntos',
          accent: kError,
          onTap: () => _openArcade(context),
        ),
        const SizedBox(height: 24),
        const HomeSectionHeader('Practicar'),
        const SizedBox(height: 12),
        PracticeGrid(progress: progress),
      ],
    );
  }

  Widget _lookupPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader('Consulta y progreso'),
        const SizedBox(height: 12),
        LookupList(progress: progress),
        const SizedBox(height: 32),
        HomeSettings(config: config),
      ],
    );
  }

  void _openArcade(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimedArcadeScreen(progress: progress)),
    );
  }
}
