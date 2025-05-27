import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mission100/generated/app_localizations.dart';

/// 테스트 환경 초기화
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 팩토리 초기화 (sqflite_ffi 사용)
  databaseFactory = databaseFactoryFfi;

  // SharedPreferences 모킹 설정
  SharedPreferences.setMockInitialValues({});

  // 메소드 채널 모킹 (광고, 기타 플러그인용)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/google_mobile_ads'),
        (MethodCall methodCall) async {
          // 광고 관련 메소드 호출 모킹
          switch (methodCall.method) {
            case 'loadBannerAd':
            case 'loadInterstitialAd':
            case 'loadRewardedAd':
            case 'showAdWithoutView':
            case 'disposeAd':
              return <String, dynamic>{
                'responseInfo': <String, dynamic>{
                  'responseId': 'test_response_id',
                  'mediationAdapterClassName': 'test_adapter',
                },
              };
            case 'getAdSize':
              return <String, dynamic>{
                'width': 320,
                'height': 50,
              };
            case 'initialize':
              return <String, dynamic>{
                'status': <String, dynamic>{
                  'initialization_status': 'ready',
                },
              };
            default:
              return null;
          }
        },
      );

  // 알림 관련 메소드 채널 모킹
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          // 알림 관련 메소드 호출 모킹
          switch (methodCall.method) {
            case 'initialize':
            case 'show':
            case 'cancel':
            case 'cancelAll':
            case 'getNotificationAppLaunchDetails':
            case 'requestPermissions':
              return true;
            case 'pendingNotificationRequests':
              return <Map<String, dynamic>>[];
            default:
              return null;
          }
        },
      );

  // 기타 플러그인들 모킹
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, Object>{};
          }
          return null;
        },
      );
}

/// 테스트용 위젯 래퍼 생성
Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
    locale: const Locale('ko', 'KR'),
  );
}

/// 테스트 종료 시 정리
void tearDownTestEnvironment() {
  // 메소드 채널 핸들러 제거
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/google_mobile_ads'),
        null,
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        null,
      );
}
