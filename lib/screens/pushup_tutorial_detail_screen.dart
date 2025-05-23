import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/pushup_type.dart';
import '../services/pushup_tutorial_service.dart';
import '../services/chad_encouragement_service.dart';
import '../services/ad_service.dart';

class PushupTutorialDetailScreen extends StatefulWidget {
  final PushupType pushupType;

  const PushupTutorialDetailScreen({super.key, required this.pushupType});

  @override
  State<PushupTutorialDetailScreen> createState() =>
      _PushupTutorialDetailScreenState();
}

class _PushupTutorialDetailScreenState
    extends State<PushupTutorialDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _showPlayer = false; // 플레이어 표시 여부
  final _encouragementService = ChadEncouragementService();

  @override
  void initState() {
    super.initState();

    // 푸시업 선택에 따른 격려 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final difficultyName = _getDifficultyName();
      final message = _encouragementService.getMessageForDifficulty(
        difficultyName,
      );
      _encouragementService.showEncouragementSnackBar(context, message);
    });
  }

  void _initializePlayer() {
    if (_controller == null) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.pushupType.youtubeVideoId,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true, // 사용자가 재생 버튼을 눌렀을 때는 자동재생
          disableDragSeek: false,
          loop: true, // 반복재생 활성화 - 쇼츠 영상에 최적화
          isLive: false,
          forceHD: false,
          enableCaption: true,
          hideControls: false,
          controlsVisibleAtStart: true,
          showLiveFullscreenButton: false,
        ),
      );
    }
    setState(() {
      _showPlayer = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    // 반응형 광고 높이
    final adHeight = isSmallScreen ? 50.0 : 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: Text(
          _getPushupName(widget.pushupType),
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 유튜브 플레이어 또는 썸네일 (고정 높이)
          _buildVideoSection(),

          // 스크롤 가능한 컨텐츠
          Expanded(
            child: SafeArea(
              bottom: false, // 하단은 배너 광고 때문에 SafeArea 제외
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 타이틀과 설명
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // 난이도와 타겟 근육
                    _buildInfoSection(),
                    const SizedBox(height: 24),

                    // 간단한 설명 섹션
                    _buildSection(
                      '💪 차드 설명',
                      _getPushupDescription(widget.pushupType),
                      Icons.fitness_center,
                      const Color(0xFF51CF66),
                    ),

                    // 차드의 조언 섹션
                    _buildSection(
                      '🔥 차드의 조언',
                      _getChadMotivation(widget.pushupType),
                      Icons.psychology,
                      const Color(0xFFFFD43B),
                    ),

                    // 하단 여백 (광고 공간 확보)
                    SizedBox(height: adHeight + 16),
                  ],
                ),
              ),
            ),
          ),

          // 하단 배너 광고
          _buildResponsiveBannerAd(context, adHeight),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (_showPlayer && _controller != null) {
      return Container(
        height: 220, // 고정 높이
        child: YoutubePlayerBuilder(
          onExitFullScreen: () {
            // 전체화면에서 나올 때 시스템 UI 복원
            // SystemChrome.setPreferredOrientations 사용할 수 있음
          },
          player: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF4DABF7),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFF4DABF7),
              handleColor: Color(0xFF4DABF7),
            ),
            onReady: () {
              setState(() {
                _isPlayerReady = true;
              });
            },
            onEnded: (data) {
              // 영상 종료 시 반복재생을 위한 처리
              // 차드 격려 메시지로 동기부여 제공
              _encouragementService.maybeShowEncouragement(context);
            },
          ),
          builder: (context, player) => player,
        ),
      );
    } else {
      // 썸네일과 재생 버튼
      return Container(
        height: 220, // 고정 높이
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4DABF7), width: 2),
        ),
        child: Stack(
          children: [
            // 썸네일 배경 - 실제 유튜브 썸네일 이미지 사용
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://img.youtube.com/vi/${widget.pushupType.youtubeVideoId}/maxresdefault.jpg',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),

            // 중앙 재생 버튼
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _initializePlayer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DABF7).withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DABF7).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🎬 차드 튜토리얼 영상 보기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '완벽한 폼을 배워라, 만삣삐! 🔄',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '자동 반복재생으로 계속 연습하세요',
                    style: TextStyle(
                      color: Color(0xFF4DABF7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getPushupName(widget.pushupType),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getPushupDescription(widget.pushupType),
          style: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Row(
      children: [
        // 난이도
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(
                  PushupTutorialService.getDifficultyColor(
                    widget.pushupType.difficulty,
                  ),
                ),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.star,
                  color: Color(
                    PushupTutorialService.getDifficultyColor(
                      widget.pushupType.difficulty,
                    ),
                  ),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  _getDifficultyName(),
                  style: TextStyle(
                    color: Color(
                      PushupTutorialService.getDifficultyColor(
                        widget.pushupType.difficulty,
                      ),
                    ),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 칼로리
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4DABF7), width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF4DABF7),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.pushupType.estimatedCaloriesPerRep}kcal/rep',
                  style: const TextStyle(
                    color: Color(0xFF4DABF7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 타겟 근육
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF51CF66), width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Color(0xFF51CF66),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pushupType.targetMuscles
                      .take(2)
                      .map((muscle) => _getTargetMuscleName(muscle))
                      .join(', '),
                  style: const TextStyle(
                    color: Color(0xFF51CF66),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getDifficultyName() {
    switch (widget.pushupType.difficulty) {
      case PushupDifficulty.beginner:
        return '푸시 - 시작하는 만삣삐들';
      case PushupDifficulty.intermediate:
        return '알파 지망생 - 성장하는 차드들';
      case PushupDifficulty.advanced:
        return '차드 - 강력한 기가들';
      case PushupDifficulty.extreme:
        return '기가 차드 - 전설의 영역';
    }
  }

  String _getTargetMuscleName(TargetMuscle muscle) {
    switch (muscle) {
      case TargetMuscle.chest:
        return '가슴';
      case TargetMuscle.triceps:
        return '삼두';
      case TargetMuscle.shoulders:
        return '어깨';
      case TargetMuscle.core:
        return '코어';
      case TargetMuscle.full:
        return '전신';
    }
  }

  String _getPushupName(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return '기본 푸시업';
      case 'knee':
        return '무릎 푸시업';
      case 'incline':
        return '인클라인 푸시업';
      case 'wide_grip':
        return '와이드 그립 푸시업';
      case 'diamond':
        return '다이아몬드 푸시업';
      case 'decline':
        return '디클라인 푸시업';
      case 'archer':
        return '아처 푸시업';
      case 'pike':
        return '파이크 푸시업';
      case 'clap':
        return '박수 푸시업';
      case 'one_arm':
        return '원핸드 푸시업';
      default:
        return pushup.id;
    }
  }

  String _getPushupDescription(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return '모든 차드의 시작점. 완벽한 기본기가 진짜 강함이다, 만삣삐!';
      case 'knee':
        return '입문자도 할 수 있다! 무릎 대고 하는 거 부끄러워하지 마라, 만삣삐!';
      case 'incline':
        return '경사면을 이용해서 난이도 조절! 계단이나 벤치면 충분하다, 만삣삐!';
      case 'wide_grip':
        return '와이드하게 벌려서 가슴을 더 넓게! 진짜 차드 가슴을 만들어라!';
      case 'diamond':
        return '삼두근 집중 공략! 다이아몬드 모양이 진짜 차드의 상징이다!';
      case 'decline':
        return '발을 높게 올려서 강도 업! 어깨와 상체 근육을 제대로 자극한다!';
      case 'archer':
        return '한쪽씩 집중하는 고급 기술! 균형감각과 코어가 필요하다, 만삣삐!';
      case 'pike':
        return '어깨 집중 공략! 핸드스탠드 푸시업의 전 단계다!';
      case 'clap':
        return '박수치면서 하는 폭발적인 파워! 진짜 차드만이 할 수 있다!';
      case 'one_arm':
        return '원핸드 푸시업은 차드의 완성형이다! 이거 한 번이라도 하면 진짜 기가 차드 인정!';
      default:
        return '차드를 위한 특별한 푸시업';
    }
  }

  String _getChadMotivation(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return '기본이 제일 중요하다, 만삣삐! 완벽한 폼으로 하나하나 쌓아가면 진짜 차드가 된다!';
      case 'knee':
        return '시작이 반이다! 무릎 푸시업도 제대로 하면 금방 일반 푸시업으로 갈 수 있어!';
      case 'incline':
        return '단계적으로 올라가는 것이 차드의 길이다! 각도를 점점 낮춰가면서 도전해봐!';
      case 'wide_grip':
        return '가슴을 활짝 펴고 차드의 기운을 받아라! 넓은 가슴이 진짜 차드의 상징이다!';
      case 'diamond':
        return '다이아몬드처럼 귀한 네 삼두근을 만들어라! 팔 근육 폭발하는 기분을 느껴봐!';
      case 'decline':
        return '높은 곳을 향해 도전하는 것이 차드다! 어깨와 상체가 불타오르는 걸 느껴봐!';
      case 'archer':
        return '균형과 집중력이 필요한 고급 기술! 한쪽씩 완벽하게 해내면 진짜 차드 인정!';
      case 'pike':
        return '핸드스탠드의 첫걸음! 어깨 근육이 터져나갈 것 같은 기분을 만끽해라!';
      case 'clap':
        return '폭발적인 파워로 박수를 쳐라! 이거 되면 너도 진짜 차드다, fxxk yeah!';
      case 'one_arm':
        return '원핸드 푸시업은 차드의 완성형이다! 이거 한 번이라도 하면 진짜 기가 차드 인정, fxxk yeah!';
      default:
        return '차드의 길은 험하지만 그래서 더 가치있다! 포기하지 마라, 만삣삐!';
    }
  }

  /// 반응형 배너 광고 위젯
  Widget _buildResponsiveBannerAd(BuildContext context, double adHeight) {
    final bannerAd = AdService.getBannerAd();

    if (bannerAd != null && AdService.isBannerAdLoaded) {
      return Container(
        height: adHeight,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF4DABF7).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: AdWidget(ad: bannerAd),
      );
    }

    // 광고가 로드되지 않은 경우 반응형 플레이스홀더
    return Container(
      height: adHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4DABF7).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              color: const Color(0xFF4DABF7).withOpacity(0.6),
              size: adHeight * 0.4,
            ),
            const SizedBox(width: 8),
            Text(
              'Advertisement',
              style: TextStyle(
                color: const Color(0xFF4DABF7).withOpacity(0.6),
                fontSize: adHeight * 0.25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
