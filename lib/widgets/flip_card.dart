import 'dart:math';

import 'package:flutter/material.dart';

/// Flip 3D nativo (Matrix4), sin paquete externo — 30 líneas no justifican
/// una dependencia (docs/PLAN.md §8). El ángulo de la cara trasera se
/// re-mapea a `angle - pi` para que el texto nunca se muestre espejado.
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCard({required this.front, required this.back, super.key});

  @override
  State<FlipCard> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  bool get isShowingBack => _controller.value > 0.5;

  void flip() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            _controller.value < 0.5 ? widget.front : widget.back,
      );
    }

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final angle = curved.value * pi;
        final isBack = angle > pi / 2;
        final shownAngle = isBack ? angle - pi : angle;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(shownAngle),
          child: isBack ? widget.back : widget.front,
        );
      },
    );
  }
}
