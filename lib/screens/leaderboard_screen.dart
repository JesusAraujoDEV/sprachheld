import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_background.dart';

/// Ranking online (Contrarreloj). Best-effort: si no hay red, muestra un
/// estado vacío en vez de un error (ADR 0001).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<ScoreEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ScoreService.top('arcade');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ranking · Contrarreloj'),
      ),
      body: AuraBackground(
        child: SafeArea(
          child: FutureBuilder<List<ScoreEntry>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final scores = snapshot.data ?? const [];
              if (scores.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Todavía no hay puntajes\n(o no hay conexión).\n¡Jugá Contrarreloj y subí el tuyo!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: scores.length,
                separatorBuilder: (_, _) => const Divider(color: kOutlineVariant, height: 8),
                itemBuilder: (context, i) => _ScoreRow(rank: i + 1, entry: scores[i]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final ScoreEntry entry;

  const _ScoreRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) { 1 => '🥇', 2 => '🥈', 3 => '🥉', _ => '$rank' };
    return ListTile(
      leading: SizedBox(
        width: 32,
        child: Text(medal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(
        entry.name?.isNotEmpty == true ? entry.name! : 'Anónimo',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: entry.bestCombo != null
          ? Text('combo máx. ×${entry.bestCombo}', style: Theme.of(context).textTheme.labelSmall)
          : null,
      trailing: Text(
        '${entry.score ?? 0}',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kPrimary),
      ),
    );
  }
}
