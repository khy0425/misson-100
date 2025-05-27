import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  // 광고 ID 상수
  static const String _androidAppId = 'ca-app-pub-1075071967728463~6042582986';
  static const String _androidBannerId = 'ca-app-pub-1075071967728463/9498612269';
  static const String _androidInterstitialId = 'ca-app-pub-1075071967728463/7039728635';
  
  // 테스트 광고 ID (개발 중에 사용)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // 현재 사용할 광고 ID (릴리즈 모드에서는 실제 ID, 디버그 모드에서는 테스트 ID)
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerId;
    }
    return Platform.isAndroid ? _androidBannerId : _testBannerId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialId;
    }
    return Platform.isAndroid ? _androidInterstitialId : _testInterstitialId;
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // AdMob 초기화
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // 요청 설정 (개인화 광고 비활성화 옵션)
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID'] : [],
    );
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  // 배너 광고 생성
  BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => debugPrint('배너 광고 열림'),
        onAdClosed: (Ad ad) => debugPrint('배너 광고 닫힘'),
      ),
    );
  }

  // 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('전면 광고 로드 완료');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('전면 광고 로드 실패: $error');
          _interstitialAd = null;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // 전면 광고 표시
  Future<void> showInterstitialAd({
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          debugPrint('전면 광고 표시됨');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('전면 광고 닫힘');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          onAdDismissed?.call();
          // 다음 광고를 미리 로드
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('전면 광고 표시 실패: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          onAdFailedToShow?.call();
          // 다음 광고를 미리 로드
          loadInterstitialAd();
        },
      );
      
      await _interstitialAd!.show();
    } else {
      debugPrint('전면 광고가 준비되지 않음');
      onAdFailedToShow?.call();
      // 광고 로드 시도
      await loadInterstitialAd();
    }
  }

  // 전면 광고 준비 상태 확인
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // 리소스 정리
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
