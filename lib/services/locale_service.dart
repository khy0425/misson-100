import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'selected_locale';
  static const String _localeSetKey = 'locale_manually_set';

  static const Locale koreanLocale = Locale('ko');
  static const Locale englishLocale = Locale('en');

  static const List<Locale> supportedLocales = [koreanLocale, englishLocale];

  /// 저장된 언어 설정을 불러온다
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    final wasManuallySet = prefs.getBool(_localeSetKey) ?? false;

    // 수동으로 설정된 적이 없다면 시스템 기본 언어 감지
    if (localeCode == null || !wasManuallySet) {
      return _getSystemBasedLocale();
    }

    return Locale(localeCode);
  }

  /// 시스템 언어를 기반으로 로케일 결정
  static Locale _getSystemBasedLocale() {
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    
    debugPrint('🌐 시스템 언어 목록: ${systemLocales.map((l) => '${l.languageCode}_${l.countryCode}').join(', ')}');
    
    // 시스템 언어 중 한국어가 있으면 한국어 선택
    for (final locale in systemLocales) {
      debugPrint('🌐 확인 중인 언어: ${locale.languageCode}_${locale.countryCode}');
      if (locale.languageCode == 'ko') {
        debugPrint('🌐 ✅ 한국어 발견! 한국어로 설정');
        return koreanLocale;
      }
    }
    
    // 한국어가 없으면 영어 선택
    debugPrint('🌐 ❌ 한국어 없음. 영어로 설정');
    return englishLocale;
  }

  /// 언어 설정을 저장한다 (수동 설정 표시)
  static Future<void> setLocale(Locale locale, {bool manuallySet = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    await prefs.setBool(_localeSetKey, manuallySet);
  }

  /// 초기 언어 설정 (자동 감지)
  static Future<void> initializeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final wasManuallySet = prefs.getBool(_localeSetKey) ?? false;
    final currentLocaleCode = prefs.getString(_localeKey);
    
    debugPrint('🌐 언어 초기화 시작');
    debugPrint('🌐 현재 저장된 언어: $currentLocaleCode');
    debugPrint('🌐 수동 설정 여부: $wasManuallySet');
    
    // 수동으로 설정된 적이 없다면 시스템 언어 기반으로 자동 설정
    if (!wasManuallySet) {
      debugPrint('🌐 자동 언어 탐지 수행');
      final systemLocale = _getSystemBasedLocale();
      debugPrint('🌐 탐지된 언어: ${systemLocale.languageCode}');
      await setLocale(systemLocale, manuallySet: false);
      debugPrint('🌐 언어 설정 완료: ${systemLocale.languageCode}');
    } else {
      debugPrint('🌐 수동 설정된 언어 유지: $currentLocaleCode');
    }
  }

  /// 현재 언어가 한국어인지 확인
  static bool isKorean(Locale locale) {
    return locale.languageCode == 'ko';
  }

  /// 현재 언어가 영어인지 확인
  static bool isEnglish(Locale locale) {
    return locale.languageCode == 'en';
  }

  /// 언어를 토글한다 (한국어 ↔ 영어)
  static Locale toggleLocale(Locale currentLocale) {
    if (isKorean(currentLocale)) {
      return englishLocale;
    } else {
      return koreanLocale;
    }
  }

  /// 언어 이름을 반환한다
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  /// 언어 축약형을 반환한다
  static String getLocaleShort(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return 'KR';
      case 'en':
        return 'EN';
      default:
        return 'UN';
    }
  }
}
