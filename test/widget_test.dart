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
    // Abre el selector de mazo (Top 100/500/1000/Todos): el bottom sheet
    // tarda una transición en deslizarse a la vista, un solo pump() lo
    // deja a mitad de camino y el tap subsiguiente no le pega.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Top 100'));
    await tester.pump(); // dispara la navegación

    // Cargar y parsear assets/data/verbs.json (ya con miles de verbos)
    // implica I/O real de archivo, no solo trabajo en memoria — el reloj
    // simulado de pump(duration) no lo destraba. runAsync deja correr el
    // event loop real un instante para que la carga efectivamente termine.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    // La sesión cargó preguntas reales: el ícono de audio confirma que la
    // pantalla de quiz (no un loader) terminó de renderizar.
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });
}
