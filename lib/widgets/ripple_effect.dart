import 'package:flutter/material.dart';
import 'dart:math';

/// 波紋エフェクトのコントローラー
class RippleController {
  final Offset position;
  final AnimationController controller;

  RippleController({
    required this.position,
    required this.controller,
  });
}

/// 波紋エフェクトを描画するペインター
class RipplePainter extends CustomPainter {
  final Offset position;
  final Animation<double> animation;

  RipplePainter({
    required this.position,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = min(size.width, size.height) / 6;
    final radius = maxRadius * animation.value;
    final opacity = (1 - animation.value) * 0.4;

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
}

/// 波紋エフェクトウィジェット
class RippleEffect extends StatelessWidget {
  final List<RippleController> ripples;
  
  const RippleEffect({
    super.key,
    required this.ripples,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: ripples.map((ripple) => 
        Positioned.fill(
          child: CustomPaint(
            painter: RipplePainter(
              position: ripple.position,
              animation: ripple.controller,
            ),
          ),
        ),
      ).toList(),
    );
  }
}
