import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 앱 메모리 관리 및 최적화 유틸리티
class MemoryManager {
  static bool _isInitialized = false;
  static Timer? _memoryCheckTimer;

  /// 메모리 관리 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // 이미지 캐시 최적화
    _configureImageCache();

    // 메모리 모니터링 시작 (디버그 모드만)
    if (kDebugMode) {
      _startMemoryMonitoring();
    }

    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('🧠 메모리 관리 초기화 완료');
    }
  }

  /// 이미지 캐시 설정 최적화
  static void _configureImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;

    // 메모리 제한 설정 (기기 성능에 따라 조정)
    imageCache.maximumSize = 100; // 최대 100개 이미지
    imageCache.maximumSizeBytes = 50 << 20; // 50MB 제한

    if (kDebugMode) {
      debugPrint(
        '🖼️ 이미지 캐시 최적화: ${imageCache.maximumSize}개, ${(imageCache.maximumSizeBytes / (1024 * 1024)).round()}MB',
      );
    }
  }

  /// 메모리 사용량 모니터링 (디버그 모드)
  static void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _logMemoryUsage(),
    );
  }

  /// 현재 메모리 사용량 로깅
  static void _logMemoryUsage() {
    if (!kDebugMode) return;

    final imageCache = PaintingBinding.instance.imageCache;
    final currentSizeMB = (imageCache.currentSizeBytes / (1024 * 1024))
        .toStringAsFixed(1);
    final maxSizeMB = (imageCache.maximumSizeBytes / (1024 * 1024)).round();

    debugPrint(
      '📊 메모리 상태: 이미지 캐시 ${imageCache.currentSize}/${imageCache.maximumSize}개, '
      '$currentSizeMB/${maxSizeMB}MB',
    );
  }

  /// 메모리 정리 실행
  static Future<void> clearMemory() async {
    // 이미지 캐시 정리
    PaintingBinding.instance.imageCache.clear();

    // 시스템 가비지 컬렉션 요청 (디버그 모드만)
    if (kDebugMode) {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      debugPrint('🧹 메모리 정리 완료');
    }
  }

  /// 앱 백그라운드 진입시 메모리 최적화
  static void onAppPaused() {
    // 불필요한 이미지 캐시 정리
    final imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.currentSize > imageCache.maximumSize * 0.8) {
      imageCache.clear();
    }

    if (kDebugMode) {
      debugPrint('⏸️ 앱 일시정지 - 메모리 최적화 실행');
    }
  }

  /// 앱 종료시 리소스 정리
  static void dispose() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;

    // 모든 캐시 정리
    PaintingBinding.instance.imageCache.clear();

    if (kDebugMode) {
      debugPrint('🔚 메모리 관리 종료');
    }
  }

  /// 현재 메모리 통계 반환
  static Map<String, dynamic> getMemoryStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    return {
      'imageCacheCount': imageCache.currentSize,
      'imageCacheMaxCount': imageCache.maximumSize,
      'imageCacheSizeBytes': imageCache.currentSizeBytes,
      'imageCacheMaxSizeBytes': imageCache.maximumSizeBytes,
      'imageCacheUsagePercent':
          (imageCache.currentSizeBytes / imageCache.maximumSizeBytes * 100)
              .round(),
    };
  }

  /// 메모리 압박 상황 감지
  static bool isMemoryPressure() {
    final stats = getMemoryStats();
    final usagePercent = stats['imageCacheUsagePercent'] as int;
    return usagePercent > 80;
  }

  /// 자동 메모리 정리 (압박 상황시)
  static void autoCleanup() {
    if (isMemoryPressure()) {
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.clearLiveImages();

      if (kDebugMode) {
        debugPrint('🚨 메모리 압박 - 자동 정리 실행');
      }
    }
  }
}

/// 메모리 사용량 모니터링 위젯
class MemoryMonitorWidget extends StatefulWidget {
  final Widget child;

  const MemoryMonitorWidget({super.key, required this.child});

  @override
  State<MemoryMonitorWidget> createState() => _MemoryMonitorWidgetState();
}

class _MemoryMonitorWidgetState extends State<MemoryMonitorWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        MemoryManager.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        MemoryManager.autoCleanup();
        break;
      case AppLifecycleState.detached:
        MemoryManager.dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
