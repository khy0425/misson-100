import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  // 테스트 환경 감지
  static bool get _isTestEnvironment {
    try {
      // 테스트 환경에서는 Platform.environment를 사용할 수 없을 수 있음
      return Platform.environment.containsKey('FLUTTER_TEST') ||
          kDebugMode && !kIsWeb;
    } catch (e) {
      // 테스트 환경에서는 Platform 접근이 실패할 수 있음
      return true;
    }
  }

  // 테스트 광고 ID들 (개발 중 사용)
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // 광고 인스턴스들
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;

  // 광고 로드 상태
  static bool _isBannerAdLoaded = false;
  static bool _isInterstitialAdLoaded = false;
  static bool _isInitialized = false;

  /// 광고 서비스 초기화
  static Future<void> initialize() async {
    if (_isTestEnvironment) {
      debugPrint('테스트 환경에서 광고 초기화 건너뜀');
      _isInitialized = true;
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _loadBannerAd();
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('광고 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  /// 배너 광고 ID 반환 (테스트/실제 구분)
  static String get bannerAdUnitId {
    // TODO: 릴리즈 빌드에서는 실제 광고 ID 사용
    return Platform.isAndroid
        ? _testBannerAdUnitId // 현재는 테스트 ID 사용
        : _testBannerAdUnitId;
  }

  /// 전면 광고 ID 반환 (테스트/실제 구분)
  static String get interstitialAdUnitId {
    // TODO: 릴리즈 빌드에서는 실제 광고 ID 사용
    return Platform.isAndroid
        ? _testInterstitialAdUnitId // 현재는 테스트 ID 사용
        : _testInterstitialAdUnitId;
  }

  /// 배너 광고 로드
  static void _loadBannerAd() {
    if (_isTestEnvironment || !_isInitialized) return;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('배너 광고 로드 완료');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('배너 광고 로드 실패: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
        },
        onAdOpened: (ad) => debugPrint('배너 광고 열림'),
        onAdClosed: (ad) => debugPrint('배너 광고 닫힘'),
      ),
    );

    _bannerAd?.load();
  }

  /// 전면 광고 로드
  static void _loadInterstitialAd() {
    if (_isTestEnvironment || !_isInitialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('전면 광고 로드 완료');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          // 전면 광고 이벤트 설정
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) => debugPrint('전면 광고 표시'),
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint('전면 광고 닫힘');
                  ad.dispose();
                  _isInterstitialAdLoaded = false;
                  _loadInterstitialAd(); // 새 광고 로드
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('전면 광고 표시 실패: $error');
                  ad.dispose();
                  _isInterstitialAdLoaded = false;
                  _loadInterstitialAd(); // 새 광고 로드
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('전면 광고 로드 실패: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  /// 배너 광고 반환 (테스트 환경에서는 null 반환)
  static BannerAd? getBannerAd() {
    if (_isTestEnvironment) return null;
    return _isBannerAdLoaded ? _bannerAd : null;
  }

  /// 새로운 배너 광고 생성 (화면별 개별 배너용)
  static BannerAd? createBannerAd() {
    if (_isTestEnvironment || !_isInitialized) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('개별 배너 광고 로드 완료'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('개별 배너 광고 로드 실패: $error');
          ad.dispose();
        },
      ),
    );
  }

  /// 전면 광고 표시
  static void showInterstitialAd() {
    if (_isTestEnvironment) {
      debugPrint('테스트 환경에서 전면 광고 표시 건너뜀');
      return;
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
    } else {
      debugPrint('전면 광고가 준비되지 않음');
      _loadInterstitialAd(); // 광고 다시 로드 시도
    }
  }

  /// 배너 광고 높이
  static double get bannerHeight => 50.0;

  /// 배너 광고 로드 상태 확인 (테스트 환경에서는 항상 false)
  static bool get isBannerAdLoaded =>
      _isTestEnvironment ? false : _isBannerAdLoaded;

  /// 전면 광고 로드 상태 확인 (테스트 환경에서는 항상 false)
  static bool get isInterstitialAdLoaded =>
      _isTestEnvironment ? false : _isInterstitialAdLoaded;

  /// 리소스 정리
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isInitialized = false;
  }

  /// 워크아웃 완료 시 전면 광고 표시 (50% 확률)
  static void showWorkoutCompleteAd() {
    if (_isTestEnvironment) return;

    // 50% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      showInterstitialAd();
    }
  }

  /// 레벨업 시 전면 광고 표시 (30% 확률)
  static void showLevelUpAd() {
    if (_isTestEnvironment) return;

    // 30% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 10 < 3) {
      showInterstitialAd();
    }
  }

  /// 앱 시작 시 전면 광고 표시 (20% 확률)
  static void showAppLaunchAd() {
    if (_isTestEnvironment) return;

    // 20% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
      showInterstitialAd();
    }
  }
}
