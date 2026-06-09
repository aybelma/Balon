import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BalloonState { rising, popping, wrongTap }

class BalloonData {
  final String id;
  final String letter;
  final Color color;
  final double x;
  double progress;
  BalloonState state;
  double popProgress;
  double shakeTime;
  double swayPhase;
  final double swaySpeed;
  double swayOffset;

  BalloonData({
    required this.id,
    required this.letter,
    required this.color,
    required this.x,
    this.progress = -0.05,
    this.state = BalloonState.rising,
    this.popProgress = 0.0,
    this.shakeTime = 0.0,
    double? swayPhase,
    double? swaySpeed,
    this.swayOffset = 0.0,
  })  : swayPhase = swayPhase ?? math.Random().nextDouble() * math.pi * 2,
        swaySpeed = swaySpeed ?? 0.5 + math.Random().nextDouble() * 0.5;

  double get shakeX {
    if (state != BalloonState.wrongTap) return 0.0;
    final t = shakeTime / 0.6;
    return (1.0 - t) * 14 * math.sin(shakeTime * 35);
  }

  double get popScale {
    if (state == BalloonState.popping) return 1.0 + popProgress * 0.5;
    return 1.0;
  }

  double get opacity {
    if (state == BalloonState.popping) return (1.0 - popProgress).clamp(0.0, 1.0);
    return 1.0;
  }

  bool get shouldRemove {
    if (state == BalloonState.popping && popProgress >= 1.0) return true;
    if (state != BalloonState.popping && progress >= 1.15) return true;
    return false;
  }
}
