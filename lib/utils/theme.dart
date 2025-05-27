import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  // 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 기본 색상 스키마
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryColor),
        brightness: Brightness.light,
        background: const Color(AppColors.backgroundLight),
        surface: const Color(AppColors.surfaceLight),
        onBackground: const Color(AppColors.textPrimaryLight),
        onSurface: const Color(AppColors.textPrimaryLight),
      ),

      // 배경 색상
      scaffoldBackgroundColor: const Color(AppColors.backgroundLight),

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        elevation: AppConstants.elevationS,
        centerTitle: true,
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        elevation: AppConstants.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        color: const Color(AppColors.surfaceLight),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimaryLight),
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimaryLight),
        ),
        headlineLarge: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.w600,
          color: Color(AppColors.textPrimaryLight),
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w600,
          color: Color(AppColors.textPrimaryLight),
        ),
        titleLarge: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryLight),
        ),
        titleMedium: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryLight),
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          color: Color(AppColors.textPrimaryLight),
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: Color(AppColors.textSecondaryLight),
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryLight),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),

      // 프로그레스 인디케이터 테마
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(AppColors.primaryColor),
        linearTrackColor: const Color(
          AppColors.primaryColor,
        ).withValues(alpha: 0.2),
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppColors.textPrimaryLight),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        elevation: AppConstants.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
      ),

      // 플로팅 액션 버튼 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppConstants.elevationM,
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
      ),
    );
  }

  // 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 기본 색상 스키마
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryColor),
        brightness: Brightness.dark,
        background: const Color(AppColors.backgroundDark),
        surface: const Color(AppColors.surfaceDark),
        onBackground: const Color(AppColors.textPrimaryDark),
        onSurface: const Color(AppColors.textPrimaryDark),
      ),

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        elevation: AppConstants.elevationS,
        centerTitle: true,
        backgroundColor: Color(AppColors.surfaceDark),
        foregroundColor: Color(AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimaryDark),
        ),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        elevation: AppConstants.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        color: const Color(AppColors.surfaceDark),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppConstants.elevationS,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeXXL,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimaryDark),
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textPrimaryDark),
        ),
        headlineLarge: TextStyle(
          fontSize: AppConstants.fontSizeXL,
          fontWeight: FontWeight.w600,
          color: Color(AppColors.textPrimaryDark),
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w600,
          color: Color(AppColors.textPrimaryDark),
        ),
        titleLarge: TextStyle(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryDark),
        ),
        titleMedium: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryDark),
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          color: Color(AppColors.textPrimaryDark),
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeS,
          color: Color(AppColors.textSecondaryDark),
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.w500,
          color: Color(AppColors.textPrimaryDark),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),

      // 프로그레스 인디케이터 테마
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(AppColors.primaryColor),
        linearTrackColor: const Color(
          AppColors.primaryColor,
        ).withValues(alpha: 0.2),
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppColors.surfaceDark),
        contentTextStyle: const TextStyle(
          color: Color(AppColors.textPrimaryDark),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        elevation: AppConstants.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        backgroundColor: const Color(AppColors.surfaceDark),
      ),

      // 플로팅 액션 버튼 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppConstants.elevationM,
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
      ),

      // 배경 색상
      scaffoldBackgroundColor: const Color(AppColors.backgroundDark),
    );
  }
}

// 커스텀 버튼 스타일들
class ButtonStyles {
  // 차드 버튼 스타일 (그라데이션)
  static ButtonStyle get chadButton => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.paddingXL,
      vertical: AppConstants.paddingL,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
    ),
    elevation: AppConstants.elevationM,
  );

  // 성공 버튼 스타일
  static ButtonStyle get successButton => ElevatedButton.styleFrom(
    backgroundColor: const Color(AppColors.successColor),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.paddingL,
      vertical: AppConstants.paddingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
  );

  // 위험 버튼 스타일
  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
    backgroundColor: const Color(AppColors.errorColor),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.paddingL,
      vertical: AppConstants.paddingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
  );

  // 둥근 버튼 스타일
  static ButtonStyle get roundButton => ElevatedButton.styleFrom(
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(AppConstants.paddingL),
    elevation: AppConstants.elevationM,
  );
}

// 커스텀 텍스트 스타일들
class TextStyles {
  // 차드 타이틀 스타일
  static TextStyle get chadTitle => const TextStyle(
    fontSize: AppConstants.fontSizeXXL,
    fontWeight: FontWeight.bold,
    color: Color(AppColors.primaryColor),
  );

  // 카운터 텍스트 스타일 (큰 숫자)
  static TextStyle get counter => const TextStyle(
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    color: Color(AppColors.primaryColor),
  );

  // 강조 텍스트 스타일
  static TextStyle get emphasis => const TextStyle(
    fontSize: AppConstants.fontSizeL,
    fontWeight: FontWeight.w600,
    color: Color(AppColors.primaryColor),
  );

  // 캡션 텍스트 스타일
  static TextStyle get caption => const TextStyle(
    fontSize: AppConstants.fontSizeXS,
    color: Color(AppColors.textSecondaryLight),
    fontStyle: FontStyle.italic,
  );
}
