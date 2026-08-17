// Smoke test de Fase 3: Home carga, y abrir un modo Flashcard levanta una
// sesión real con datos de assets/data/ (sigue probando indirectamente que
// el schema/parsing de Fase 0 funciona, ahora a través de la UI real).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sprachheld/main.dart';

void main() {
  testWidgets('Home abre una sesión de Flashcard con datos reales', (tester) async {
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

    expect(find.text('Toca la carta para voltear'), findsOneWidget);
  });
}
