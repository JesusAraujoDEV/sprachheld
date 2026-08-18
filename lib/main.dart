import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/config_notifier.dart';
import 'state/progress_notifier.dart';
import 'theme/app_theme.dart';

void main() {
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
