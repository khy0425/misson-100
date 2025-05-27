import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final bool showOnError;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.showOnError = false,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.instance.createBannerAd(
      adSize: widget.adSize,
      onAdLoaded: (Ad ad) {
        debugPrint('배너 광고 로드 완료');
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
            _hasError = false;
          });
        }
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        debugPrint('배너 광고 로드 실패: $error');
        ad.dispose();
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _hasError = true;
          });
        }
      },
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고 로드 실패 시 에러 표시 여부에 따라 처리
    if (_hasError && !widget.showOnError) {
      return const SizedBox.shrink();
    }

    // 광고가 로드되지 않았을 때
    if (!_isAdLoaded) {
      if (_hasError && widget.showOnError) {
        return Container(
          margin: widget.margin,
          height: widget.adSize.height.toDouble(),
          child: const Center(
            child: Text(
              '광고를 불러올 수 없습니다',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        );
      }
      
      // 로딩 중일 때
      return Container(
        margin: widget.margin,
        height: widget.adSize.height.toDouble(),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // 광고 표시
    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
} 