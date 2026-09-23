import 'package:flutter/material.dart';

import '../modes/timed_arcade_screen.dart';
import '../state/config_notifier.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../widgets/aura_background.dart';
import '../widgets/mode_card.dart';
import 'home/home_header.dart';
import 'home/home_section_header.dart';
import 'home/home_settings.dart';
import 'home/home_stats.dart';
import 'home/home_wide_layout.dart';
import 'home/lookup_list.dart';
import 'home/practice_grid.dart';

/// Home: modo destacado (Contrarreloj) → grid "Practicar" → lista "Consulta
/// y progreso" → ajustes. En escritorio (context.isWide) reordena las mismas
/// piezas en dos paneles vía [HomeWideLayout]; móvil/tablet mantienen la
/// columna única idéntica a hoy (docs/PLAN-hora.md §7, ux-architect).
class HomeScreen extends StatelessWidget {
  final ConfigNotifier config;
  final ProgressNotifier progress;

  const HomeScreen({required this.config, required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuraBackground(
        child: SafeArea(
          child: context.isWide
              ? HomeWideLayout(config: config, progress: progress)
              : _mobileLayout(context),
        ),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          const SizedBox(height: 20),
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
          const SizedBox(height: 24),
          const HomeSectionHeader('Consulta y progreso'),
          const SizedBox(height: 12),
          LookupList(progress: progress),
          const SizedBox(height: 32),
          HomeSettings(config: config),
        ],
      ),
    );
  }

  void _openArcade(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimedArcadeScreen(progress: progress)),
    );
  }
}
