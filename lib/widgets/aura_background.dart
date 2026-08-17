import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fondo que "respira": gradiente radial cuyo radio oscila lentamente
/// (docs/PLAN.md §8). Respeta `disableAnimations` (reduce motion).
class AuraBackground extends StatefulWidget {
  final Widget child;

  const AuraBackground({required this.child, super.key});

  @override
  State<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends State<AuraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return DecoratedBox(decoration: _decoration(1.0), child: widget.child);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final radius = 0.9 + 0.3 * Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(decoration: _decoration(radius), child: child);
      },
      child: widget.child,
    );
  }

  BoxDecoration _decoration(double radius) => BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: radius,
          colors: const [kSurface, kBackground],
        ),
      );
}
