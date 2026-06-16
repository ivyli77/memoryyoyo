import 'package:flutter/material.dart';

/// 胶片 / 旅行明信片 复古配色
class AppColors {
  static const paper = Color(0xFFEDE3CE); // 做旧纸张底色
  static const paperDeep = Color(0xFFE2D4B8);
  static const card = Color(0xFFFBF4E4); // 奶油明信片
  static const ink = Color(0xFF3B322A); // 深褐墨水
  static const inkSoft = Color(0xFF7A6E5C);
  static const film = Color(0xFF211D18); // 胶片黑
  static const filmLight = Color(0xFF2E2820);
  static const kodakRed = Color(0xFFC2562F); // 柯达暖橙红
  static const warmAmber = Color(0xFFE3A86C);
  static const teal = Color(0xFF4C6B66); // 复古墨绿
  static const stamp = Color(0xFFB5482F);
}

/// 等宽字体（打字机感），用于日期 / 标签 / 按钮
const String kMono = 'monospace';

/// 衬线字体（明信片手写感），用于正文
const String kSerif = 'serif';

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.kodakRed,
        secondary: AppColors.teal,
        surface: AppColors.card,
        onSurface: AppColors.ink,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
        fontFamily: kSerif,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.film,
        contentTextStyle: TextStyle(color: AppColors.paper, fontFamily: kMono),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
