// Smoke test: Home carga y abrir un modo levanta una sesión real con datos
// de assets/data/ (prueba indirectamente que el schema/parsing funciona).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sprachheld/main.dart';

void main() {
  testWidgets('Home abre el quiz de verbos con datos reales', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SprachheldApp());

    // AuraBackground anima en loop infinito: pumpAndSettle nunca terminaría.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('🦸 Sprachheld'), findsOneWidget);
    expect(find.text('Verbos'), findsOneWidget);

    await tester.tap(find.text('Verbos'));
    await tester.pump(); // dispara la navegación
    await tester.pump(const Duration(milliseconds: 300)); // resuelve la carga de assets

    // La sesión cargó preguntas reales: el ícono de audio confirma que la
    // pantalla de quiz (no un loader) terminó de renderizar.
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });
}
