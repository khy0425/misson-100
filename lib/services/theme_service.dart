import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// 테마 색상 옵션
enum ThemeColor {
  blue(Color(AppColors.primaryColor), 'Blue'),
  purple(Color(0xFF9C27B0), 'Purple'),
  green(Color(0xFF4CAF50), 'Green'),
  orange(Color(0xFFFF9800), 'Orange'),
  red(Color(0xFFF44336), 'Red'),
  teal(Color(0xFF009688), 'Teal'),
  indigo(Color(0xFF3F51B5), 'Indigo'),
  pink(Color(0xFFE91E63), 'Pink');

  const ThemeColor(this.color, this.name);
  final Color color;
  final String name;
}

/// 폰트 크기 옵션
enum FontScale {
  small(0.85, 'Small'),
  normal(1.0, 'Normal'),
  large(1.15, 'Large');

  const FontScale(this.scale, this.name);
  final double scale;
  final String name;
}

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';
  static const String _fontScaleKey = 'font_scale';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _highContrastKey = 'high_contrast_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeColor _themeColor = ThemeColor.blue;
  FontScale _fontScale = FontScale.normal;
  bool _animationsEnabled = true;
  bool _highContrastMode = false;
  
  ThemeMode get themeMode => _themeMode;
  ThemeColor get themeColor => _themeColor;
  FontScale get fontScale => _fontScale;
  bool get animationsEnabled => _animationsEnabled;
  bool get highContrastMode => _highContrastMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get primaryColor => _themeColor.color;
  double get textScaleFactor => _fontScale.scale;
  
  /// 테마 초기화
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 테마 모드 로드
    final themeModeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    if (themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    } else {
      _themeMode = ThemeMode.dark;
    }
    
    // 테마 색상 로드
    final themeColorIndex = prefs.getInt(_themeColorKey) ?? ThemeColor.blue.index;
    if (themeColorIndex >= 0 && themeColorIndex < ThemeColor.values.length) {
      _themeColor = ThemeColor.values[themeColorIndex];
    } else {
      _themeColor = ThemeColor.blue;
    }
    
    // 폰트 크기 로드
    final fontScaleIndex = prefs.getInt(_fontScaleKey) ?? FontScale.normal.index;
    if (fontScaleIndex >= 0 && fontScaleIndex < FontScale.values.length) {
      _fontScale = FontScale.values[fontScaleIndex];
    } else {
      _fontScale = FontScale.normal;
    }
    
    // 애니메이션 설정 로드
    _animationsEnabled = prefs.getBool(_animationsEnabledKey) ?? true;
    
    // 고대비 모드 로드
    _highContrastMode = prefs.getBool(_highContrastKey) ?? false;
    
    notifyListeners();
  }
  
  /// 테마 변경
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    
    notifyListeners();
  }
  
  /// 테마 색상 변경
  Future<void> setThemeColor(ThemeColor themeColor) async {
    if (_themeColor == themeColor) return;
    
    _themeColor = themeColor;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, themeColor.index);
    
    notifyListeners();
  }
  
  /// 폰트 크기 변경
  Future<void> setFontScale(FontScale fontScale) async {
    if (_fontScale == fontScale) return;
    
    _fontScale = fontScale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontScaleKey, fontScale.index);
    
    notifyListeners();
  }
  
  /// 애니메이션 효과 설정
  Future<void> setAnimationsEnabled(bool enabled) async {
    if (_animationsEnabled == enabled) return;
    
    _animationsEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, enabled);
    
    notifyListeners();
  }
  
  /// 고대비 모드 설정
  Future<void> setHighContrastMode(bool enabled) async {
    if (_highContrastMode == enabled) return;
    
    _highContrastMode = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
    
    notifyListeners();
  }
  
  /// 다크 모드 토글
  Future<void> toggleDarkMode() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// 현재 테마에 맞는 ColorScheme 생성
  ColorScheme getColorScheme() {
    final baseColor = _themeColor.color;
    
    if (_themeMode == ThemeMode.dark) {
      return ColorScheme.dark(
        primary: baseColor,
        secondary: baseColor.withValues(alpha: 0.7),
        surface: _highContrastMode ? Colors.black : const Color(0xFF1E1E1E),
        onSurface: _highContrastMode ? Colors.white : Colors.white70,
        background: _highContrastMode ? Colors.black : const Color(0xFF121212),
        onBackground: _highContrastMode ? Colors.white : Colors.white70,
      );
    } else {
      return ColorScheme.light(
        primary: baseColor,
        secondary: baseColor.withValues(alpha: 0.7),
        surface: _highContrastMode ? Colors.white : const Color(0xFFFAFAFA),
        onSurface: _highContrastMode ? Colors.black : Colors.black87,
        background: _highContrastMode ? Colors.white : const Color(0xFFFFFFFF),
        onBackground: _highContrastMode ? Colors.black : Colors.black87,
      );
    }
  }
  
  /// 현재 설정에 맞는 ThemeData 생성
  ThemeData getThemeData() {
    final colorScheme = getColorScheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      fontFamily: 'Pretendard',
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: _highContrastMode ? 4 : 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: _highContrastMode ? 4 : 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
  
  /// 폰트 크기에 맞는 TextTheme 생성
  TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final baseTextTheme = ThemeData(
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
    ).textTheme;
    
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: (baseTextTheme.displayLarge?.fontSize ?? 57) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: (baseTextTheme.displayMedium?.fontSize ?? 45) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: (baseTextTheme.displaySmall?.fontSize ?? 36) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * _fontScale.scale,
        color: colorScheme.onBackground,
      ),
    );
  }
} 