// Smoke test de Fase 0: los assets JSON parsean con el schema y la pantalla
// de verificación los muestra. Sube el conteo esperado al añadir verbos.

import 'package:flutter_test/flutter_test.dart';

import 'package:sprachheld/main.dart';

void main() {
  testWidgets('carga y parsea los 5 mazos desde assets/data', (tester) async {
    await tester.pumpWidget(const SprachheldApp());
    await tester.pumpAndSettle();

    expect(find.text('Verbos'), findsOneWidget);
    expect(find.text('Sustantivos'), findsOneWidget);
    expect(find.text('Adjetivos'), findsOneWidget);
    expect(find.text('Reglas de género'), findsOneWidget);
    expect(find.text('Frases'), findsOneWidget);

    // Ningún mazo semilla debería quedar vacío.
    expect(find.text('0'), findsNothing);
  });
}
