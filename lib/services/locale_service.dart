import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'selected_locale';

  static const Locale koreanLocale = Locale('ko');
  static const Locale englishLocale = Locale('en');

  static const List<Locale> supportedLocales = [koreanLocale, englishLocale];

  /// 저장된 언어 설정을 불러온다
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode == null) {
      return koreanLocale; // 기본값은 한국어
    }

    return Locale(localeCode);
  }

  /// 언어 설정을 저장한다
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
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
