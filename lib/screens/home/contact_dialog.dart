import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

const _contacts = [
  (icon: Icons.phone, label: '+58 4244165446'),
  (icon: Icons.link, label: 'linkedin.com/in/jesusaraujodev'),
  (icon: Icons.email, label: 'jesusaraujodev@gmail.com'),
];

/// Toca el pie "Desarrollado por..." del Home: datos de contacto, cada uno
/// se copia al portapapeles al tocarlo (sin url_launcher — no hay
/// dependencia nueva para esto, ver AGENTS.md Stack).
void showContactDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: kSurfaceContainer,
      title: const Text('Contacto — Jesús Araujo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in _contacts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(c.icon, color: kPrimary),
              title: Text(c.label),
              onTap: () {
                Clipboard.setData(ClipboardData(text: c.label));
                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(SnackBar(content: Text('Copiado: ${c.label}')));
              },
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cerrar')),
      ],
    ),
  );
}
