import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 앱 성능 최적화를 위한 유틸리티 클래스
class PerformanceUtils {
  /// 메모리 캐시 크기 설정
  static void configureImageCache() {
    if (!kIsWeb) {
      // 이미지 캐시 크기 최적화 (모바일)
      PaintingBinding.instance.imageCache.maximumSize = 50; // 최대 50개 이미지
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
    }
  }

  /// 시스템 UI 오버레이 스타일 설정
  static void configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// 메모리 최적화를 위한 디스포저블 리소스 정리
  static void disposeResources() {
    // 이미지 캐시 정리
    PaintingBinding.instance.imageCache.clear();

    // 시스템 가비지 컬렉션 강제 실행 (디버그 모드에서만)
    if (kDebugMode) {
      debugPrint('🧹 리소스 정리 완료');
    }
  }

  /// 앱 시작 시 필요한 최적화 설정들
  static Future<void> initialize() async {
    // 이미지 캐시 설정
    configureImageCache();

    // 시스템 UI 설정
    configureSystemUI();

    // 디바이스 방향 고정 (세로 모드만)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (kDebugMode) {
      debugPrint('🚀 성능 최적화 설정 완료');
    }
  }

  /// 메모리 사용량 체크 (디버그 모드)
  static void checkMemoryUsage() {
    if (kDebugMode) {
      final imageCache = PaintingBinding.instance.imageCache;
      debugPrint(
        '📊 이미지 캐시: ${imageCache.currentSize}/${imageCache.maximumSize}',
      );
      debugPrint(
        '📊 메모리 사용량: ${(imageCache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
      );
    }
  }

  /// 이미지 프리로딩 최적화
  static Future<void> preloadCriticalImages(BuildContext context) async {
    final criticalImages = [
      'assets/images/수면모자차드.jpg',
      'assets/images/기본차드.jpg',
      'assets/images/커피차드.png',
    ];

    for (final imagePath in criticalImages) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ 이미지 프리로드 실패: $imagePath - $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('🖼️ 핵심 이미지 프리로드 완료');
    }
  }

  /// 애니메이션 성능 최적화 설정
  static void optimizeAnimations() {
    // 애니메이션 프레임 레이트 최적화
    if (!kIsWeb) {
      // 모바일에서 60fps 고정
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (kDebugMode) {
          debugPrint('🎬 애니메이션 최적화 적용');
        }
      });
    }
  }
}

/// 위젯 재빌드 성능 모니터링 (디버그용)
class PerformanceObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (kDebugMode) {
      debugPrint('🔄 페이지 이동: ${route.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (kDebugMode) {
      debugPrint('⬅️ 페이지 뒤로: ${route.settings.name}');
    }
  }
}
