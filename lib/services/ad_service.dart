import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // 광고 ID들
  static const String _bannerAdUnitId =
      'ca-app-pub-1075071967728463/9498612269';
  static const String _interstitialAdUnitId =
      'ca-app-pub-1075071967728463/7039728635';

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

  /// 광고 서비스 초기화
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
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
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('배너 광고 로드 완료');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('배너 광고 로드 실패: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
        },
        onAdOpened: (ad) => print('배너 광고 열림'),
        onAdClosed: (ad) => print('배너 광고 닫힘'),
      ),
    );

    _bannerAd?.load();
  }

  /// 전면 광고 로드
  static void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('전면 광고 로드 완료');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          // 전면 광고 이벤트 설정
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) => print('전면 광고 표시'),
                onAdDismissedFullScreenContent: (ad) {
                  print('전면 광고 닫힘');
                  ad.dispose();
                  _isInterstitialAdLoaded = false;
                  _loadInterstitialAd(); // 새 광고 로드
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  print('전면 광고 표시 실패: $error');
                  ad.dispose();
                  _isInterstitialAdLoaded = false;
                  _loadInterstitialAd(); // 새 광고 로드
                },
              );
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  /// 배너 광고 반환
  static BannerAd? getBannerAd() {
    return _isBannerAdLoaded ? _bannerAd : null;
  }

  /// 전면 광고 표시
  static void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
    } else {
      print('전면 광고가 준비되지 않음');
      _loadInterstitialAd(); // 광고 다시 로드 시도
    }
  }

  /// 배너 광고 높이
  static double get bannerHeight => 50.0;

  /// 배너 광고 로드 상태 확인
  static bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// 전면 광고 로드 상태 확인
  static bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  /// 리소스 정리
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
  }

  /// 워크아웃 완료 시 전면 광고 표시 (50% 확률)
  static void showWorkoutCompleteAd() {
    // 50% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      showInterstitialAd();
    }
  }

  /// 레벨업 시 전면 광고 표시 (30% 확률)
  static void showLevelUpAd() {
    // 30% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 10 < 3) {
      showInterstitialAd();
    }
  }

  /// 앱 시작 시 전면 광고 표시 (20% 확률)
  static void showAppLaunchAd() {
    // 20% 확률로 전면 광고 표시
    if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
      showInterstitialAd();
    }
  }
}
