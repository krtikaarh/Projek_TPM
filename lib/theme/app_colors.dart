import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFFC8E6C9);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);

  // Pet Type Colors
  static const Color dogColor = Color(0xFF8D6E63);
  static const Color catColor = Color(0xFFFF7043);
  static const Color birdColor = Color(0xFF42A5F5);
  static const Color fishColor = Color(0xFF26C6DA);
  static const Color rabbitColor = Color(0xFFAB47BC);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF21CBF3),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  // Get color by pet type
  static Color getPetTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'anjing':
        return dogColor;
      case 'cat':
      case 'kucing':
        return catColor;
      case 'bird':
      case 'burung':
        return birdColor;
      case 'fish':
      case 'ikan':
        return fishColor;
      case 'rabbit':
      case 'kelinci':
        return rabbitColor;
      default:
        return primary;
    }
  }
}
