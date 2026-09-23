import 'package:flutter/widgets.dart';

/// Único origen de los breakpoints responsive (ux-architect). Tres bandas:
/// móvil (< 600) idéntico a hoy, tablet (600–1023) y escritorio (>= 1024),
/// donde recién se activa el layout ancho de verdad. Ancho máximo de
/// contenido para que en monitores ultra-anchos no se estire absurdamente.
const double kTabletMinWidth = 600;
const double kDesktopMinWidth = 1024;
const double kMaxContentWidth = 1200;

/// Ancho máximo de un modal (bottom sheet / diálogo) en pantallas anchas: un
/// sheet a todo el ancho se ve mal en escritorio (ux-architect).
const double kModalMaxWidth = 640;

/// Ancho máximo legible para pantallas de lectura/consulta (tablas): más
/// angosto que kMaxContentWidth para no fatigar la línea de lectura.
const double kReadableMaxWidth = 760;

/// Banda responsive del viewport actual, derivada del ancho lógico.
enum ScreenSize { mobile, tablet, desktop }

/// Acceso a la banda responsive desde cualquier widget, sin repetir los
/// umbrales por archivo. Reutilizado por todas las pantallas.
extension Breakpoints on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= kDesktopMinWidth) return ScreenSize.desktop;
    if (width >= kTabletMinWidth) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isWide => screenSize == ScreenSize.desktop;
}
