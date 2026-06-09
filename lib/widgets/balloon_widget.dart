import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/balloon_data.dart';
import '../utils/constants.dart';

class BalloonWidget extends StatelessWidget {
  final BalloonData balloon;
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const BalloonWidget({
    super.key,
    required this.balloon,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final centerY = screenHeight -
        (screenHeight + AppSizes.balloonTotalHeight) * balloon.progress;
    final left = balloon.x * screenWidth -
        AppSizes.balloonWidth / 2 +
        balloon.swayOffset +
        balloon.shakeX;
    final top = centerY - AppSizes.balloonTotalHeight / 2;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: balloon.opacity,
          child: Transform.scale(
            scale: balloon.popScale,
            child: _BalloonBody(balloon: balloon),
          ),
        ),
      ),
    );
  }
}

class _BalloonBody extends StatelessWidget {
  final BalloonData balloon;
  const _BalloonBody({required this.balloon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.balloonWidth + AppSizes.touchPadding * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.balloonWidth,
            height: AppSizes.balloonHeight,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 0.9,
                colors: [
                  Color.lerp(balloon.color, Colors.white, 0.55)!,
                  balloon.color,
                  Color.lerp(balloon.color, Colors.black, 0.18)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: balloon.color.withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                balloon.letter,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(100),
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Balloon knot
          Container(
            width: 10,
            height: 6,
            decoration: BoxDecoration(
              color: Color.lerp(balloon.color, Colors.black, 0.25),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
          // String
          CustomPaint(
            size: const Size(AppSizes.balloonWidth, AppSizes.stringHeight),
            painter: _StringPainter(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _StringPainter extends CustomPainter {
  final Color color;
  const _StringPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(
        size.width / 2 + 5,
        size.height * 0.3,
        size.width / 2 - 5,
        size.height * 0.7,
        size.width / 2,
        size.height,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StringPainter old) => false;
}

class CloudWidget extends StatelessWidget {
  final double left;
  final double top;
  final double scale;
  final double opacity;

  const CloudWidget({
    super.key,
    required this.left,
    required this.top,
    this.scale = 1.0,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: CustomPaint(
            size: const Size(140, 60),
            painter: _CloudPainter(),
          ),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(230);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.65), width: size.width * 0.8, height: size.height * 0.55), paint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.42), size.height * 0.38, paint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.32), size.height * 0.42, paint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.44), size.height * 0.3, paint);
  }

  @override
  bool shouldRepaint(_CloudPainter _) => false;
}

class StarParticle {
  double x, y, angle, speed, size, life;
  final Color color;
  StarParticle({required this.x, required this.y, required this.color})
      : angle = math.Random().nextDouble() * math.pi * 2,
        speed = 80 + math.Random().nextDouble() * 120,
        size = 6 + math.Random().nextDouble() * 10,
        life = 1.0;

  void update(double dt) {
    x += math.cos(angle) * speed * dt;
    y += math.sin(angle) * speed * dt - 40 * dt;
    life -= dt * 1.8;
    size = size * (0.98);
  }

  bool get isDead => life <= 0;
}
