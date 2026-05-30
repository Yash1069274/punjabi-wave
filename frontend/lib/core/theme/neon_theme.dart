import 'package:flutter/material.dart';

class NeonTheme {
  static const obsidian = Color(0xFF05040A);
  static const plasmaPink = Color(0xFFFF2FD6);
  static const cyberBlue = Color(0xFF15F4FF);
  static const laserViolet = Color(0xFF8F4DFF);
  static const glass = Color(0x26FFFFFF);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: obsidian,
      colorScheme: const ColorScheme.dark(
        primary: cyberBlue,
        secondary: plasmaPink,
        tertiary: laserViolet,
        surface: Color(0xFF100B1D),
      ),
      textTheme: Typography.whiteMountainView.apply(fontFamily: 'Inter'),
    );
  }
}
