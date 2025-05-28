import 'package:flutter/material.dart';

/// 테스트 환경에서 사용할 모킹된 광고 위젯
class MockAdBannerWidget extends StatelessWidget {
  final String adUnitId;
  final double? width;
  final double? height;

  const MockAdBannerWidget({
    Key? key,
    required this.adUnitId,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 320,
      height: height ?? 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'Test Ad Banner',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// 테스트 환경에서 사용할 모킹된 전면 광고 위젯
class MockInterstitialAdWidget extends StatelessWidget {
  final String adUnitId;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;
  final VoidCallback? onAdDismissed;

  const MockInterstitialAdWidget({
    Key? key,
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 테스트에서는 즉시 로드 완료 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onAdLoaded?.call();
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Interstitial Ad',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onAdDismissed?.call();
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 광고 서비스 모킹 클래스
class MockAdService {
  static bool _isInitialized = false;
  static bool _shouldFailToLoad = false;

  /// 광고 서비스 초기화 (테스트용)
  static Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  /// 광고 로딩 실패 시뮬레이션 설정
  static void setShouldFailToLoad(bool shouldFail) {
    _shouldFailToLoad = shouldFail;
  }

  /// 광고 초기화 상태 확인
  static bool get isInitialized => _isInitialized;

  /// 배너 광고 로드 시뮬레이션
  static Future<bool> loadBannerAd(String adUnitId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return !_shouldFailToLoad;
  }

  /// 전면 광고 로드 시뮬레이션
  static Future<bool> loadInterstitialAd(String adUnitId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return !_shouldFailToLoad;
  }

  /// 전면 광고 표시 시뮬레이션
  static Future<void> showInterstitialAd() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 테스트 정리
  static void reset() {
    _isInitialized = false;
    _shouldFailToLoad = false;
  }
} 