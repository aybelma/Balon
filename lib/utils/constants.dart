import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> balloonColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFF7DC6F),
    Color(0xFFA29BFE),
    Color(0xFFFF8B94),
    Color(0xFF6BCB77),
    Color(0xFFFFAA5E),
    Color(0xFFFF85A1),
  ];

  static const Color skyTop = Color(0xFF1565C0);
  static const Color skyMid = Color(0xFF42A5F5);
  static const Color skyBottom = Color(0xFF90CAF9);
  static const Color instructionBg = Color(0xCC1A237E);
  static const Color successGold = Color(0xFFFFD700);
}

class AppSizes {
  static const double balloonWidth = 82.0;
  static const double balloonHeight = 100.0;
  static const double stringHeight = 28.0;
  static const double balloonTotalHeight = balloonHeight + stringHeight;
  static const double touchPadding = 18.0;
}

class GameConfig {
  static const int maxBalloonsOnScreen = 6;
  static const double baseSpawnInterval = 2.4;
  static const List<double> levelSpeeds = [0.05, 0.07, 0.095];
}
