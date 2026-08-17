import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/config_notifier.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SprachheldApp());
}

class SprachheldApp extends StatelessWidget {
  const SprachheldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprachheld',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: FutureBuilder<ConfigNotifier>(
        future: _bootstrap(),
        builder: (context, snapshot) {
          final config = snapshot.data;
          if (config == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return HomeScreen(config: config);
        },
      ),
    );
  }

  Future<ConfigNotifier> _bootstrap() async {
    final storage = await StorageService.create();
    return ConfigNotifier.load(storage);
  }
}
