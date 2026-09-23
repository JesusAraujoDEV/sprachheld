// Layout responsive del Home: en banda móvil se usa la columna única y a
// ancho de escritorio (1280) aparece HomeWideLayout. Un solo test cubre ambos
// extremos del breakpoint de escritorio (kDesktopMinWidth = 1024).
//
// El extremo móvil se prueba a 599 (justo bajo kTabletMinWidth), no a 400: la
// fila de estadísticas (4 StatChip, spaceBetween) desborda por ~87px a 400 —
// comportamiento PREEXISTENTE del layout móvil, idéntico a hoy, fuera del
// alcance de este cambio (ver work-log § Follow-ups). 599 sigue siendo banda
// móvil y evita ese desborde ajeno al breakpoint que se está verificando.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sprachheld/main.dart';
import 'package:sprachheld/screens/home/home_wide_layout.dart';

void main() {
  testWidgets('Home usa columna única en móvil y dos paneles en escritorio', (tester) async {
    // devicePixelRatio 1.0 => physicalSize mapea 1:1 al ancho lógico.
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({});

    // Móvil: ancho de banda mobile (< kTabletMinWidth) => sin layout ancho.
    tester.view.physicalSize = const Size(599, 900);
    await tester.pumpWidget(const SprachheldApp());
    // AuraBackground anima en loop: pump() en vez de pumpAndSettle().
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomeWideLayout), findsNothing);

    // Escritorio: 1280 de ancho => banda desktop, layout de dos paneles.
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(HomeWideLayout), findsOneWidget);
  });
}
