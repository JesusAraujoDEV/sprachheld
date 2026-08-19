import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/config_notifier.dart';
import 'state/progress_notifier.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: si Supabase no inicializa (sin red, etc.), la app arranca
  // igual y el ranking simplemente no está disponible (ADR 0001).
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // La anon key es la publishable key (pública por diseño, ver ADR 0001).
      publishableKey: SupabaseConfig.anonKey,
    );
  } catch (_) {}
  runApp(const SprachheldApp());
}

class _Bootstrap {
  final ConfigNotifier config;
  final ProgressNotifier progress;

  const _Bootstrap(this.config, this.progress);
}

class SprachheldApp extends StatelessWidget {
  const SprachheldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprachheld',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: FutureBuilder<_Bootstrap>(
        future: _bootstrap(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return HomeScreen(config: data.config, progress: data.progress);
        },
      ),
    );
  }

  Future<_Bootstrap> _bootstrap() async {
    final storage = await StorageService.create();
    return _Bootstrap(ConfigNotifier.load(storage), ProgressNotifier.load(storage));
  }
}
