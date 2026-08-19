import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Tile para ver/cambiar el nombre del jugador usado en el ranking.
/// Self-contained — carga el nombre desde StorageService y muestra un
/// diálogo para editarlo.
class PlayerNameTile extends StatefulWidget {
  const PlayerNameTile({super.key});

  @override
  State<PlayerNameTile> createState() => _PlayerNameTileState();
}

class _PlayerNameTileState extends State<PlayerNameTile> {
  String? _name;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await StorageService.create();
    if (!mounted) return;
    setState(() {
      _name = storage.playerName;
      _loaded = true;
    });
  }

  Future<void> _edit() async {
    final controller = TextEditingController(text: _name ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurfaceContainer,
        title: const Text('Nombre para el ranking'),
        content: TextField(
          controller: controller,
          maxLength: 24,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tu nombre',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newName == null || !mounted) return;
    final storage = await StorageService.create();
    await storage.setPlayerName(newName);
    setState(() => _name = storage.playerName);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final display = (_name != null && _name!.isNotEmpty) ? _name! : 'Sin nombre';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline, color: kOnSurfaceVariant),
      title: Text(display),
      subtitle: const Text('Nombre para el ranking'),
      trailing: const Icon(Icons.edit_outlined, size: 20, color: kOnSurfaceVariant),
      onTap: _edit,
    );
  }
}
