import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/locale_service.dart';

/// 현재 선택된 언어를 관리하는 StateNotifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(LocaleService.koreanLocale) {
    _loadLocale();
  }

  /// 저장된 언어 설정을 불러온다
  Future<void> _loadLocale() async {
    final locale = await LocaleService.getLocale();
    state = locale;
  }

  /// 언어를 변경하고 저장한다
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await LocaleService.setLocale(locale);
  }

  /// 언어를 토글한다 (한국어 ↔ 영어)
  Future<void> toggleLocale() async {
    final newLocale = LocaleService.toggleLocale(state);
    await setLocale(newLocale);
  }

  /// 현재 언어가 한국어인지 확인
  bool get isKorean => LocaleService.isKorean(state);

  /// 현재 언어가 영어인지 확인
  bool get isEnglish => LocaleService.isEnglish(state);

  /// 현재 언어 이름
  String get localeName => LocaleService.getLocaleName(state);

  /// 현재 언어 축약형
  String get localeShort => LocaleService.getLocaleShort(state);
}

/// 언어 설정 provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// 언어 토글 provider (간편 사용용)
final localeToggleProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(localeProvider.notifier).toggleLocale();
  };
});

/// 현재 언어가 한국어인지 확인하는 provider
final isKoreanProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return LocaleService.isKorean(locale);
});

/// 현재 언어가 영어인지 확인하는 provider
final isEnglishProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return LocaleService.isEnglish(locale);
});

/// 현재 언어 이름을 제공하는 provider
final localeNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return LocaleService.getLocaleName(locale);
});

/// 현재 언어 축약형을 제공하는 provider
final localeShortProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return LocaleService.getLocaleShort(locale);
});
