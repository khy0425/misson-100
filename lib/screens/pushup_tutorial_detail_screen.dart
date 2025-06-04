import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../generated/app_localizations.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/pushup_type.dart';
import '../services/pushup_tutorial_service.dart';
import '../services/chad_encouragement_service.dart';
import '../services/achievement_service.dart';

import '../widgets/ad_banner_widget.dart';

class PushupTutorialDetailScreen extends StatefulWidget {
  final PushupType pushupType;

  const PushupTutorialDetailScreen({super.key, required this.pushupType});

  @override
  State<PushupTutorialDetailScreen> createState() =>
      _PushupTutorialDetailScreenState();
}

class _PushupTutorialDetailScreenState
    extends State<PushupTutorialDetailScreen> {
  final _encouragementService = ChadEncouragementService();
  late YoutubePlayerController _youtubeController;


  @override
  void initState() {
    super.initState();
    
    // 튜토리얼 조회 카운트 증가
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AchievementService.incrementTutorialViewCount();
        debugPrint('🎓 튜토리얼 상세 조회 및 업적 체크 완료');
      } catch (e) {
        debugPrint('❌ 튜토리얼 상세 조회 처리 실패: $e');
      }
    });
    
    // 유튜브 플레이어 초기화
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.pushupType.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true, // 반복 재생
        enableCaption: false,
        hideControls: true, // 컨트롤 완전히 숨기기
        controlsVisibleAtStart: false,
        disableDragSeek: true, // 드래그로 탐색 비활성화
        forceHD: false,
        useHybridComposition: true,
      ),
    );

    // 푸시업 선택에 따른 격려 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final difficultyName = _getDifficultyName();
      final message = _encouragementService.getMessageForDifficulty(
        difficultyName,
      );
      _encouragementService.showEncouragementSnackBar(context, message);
    });
  }

  @override
  void dispose() {
    _youtubeController.dispose();
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
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: Text(
          _getPushupName(widget.pushupType),
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 유튜브 썸네일과 재생 버튼
          _buildVideoSection(),

          // 스크롤 가능한 컨텐츠
          Expanded(
            child: SafeArea(
              bottom: false, // 하단은 배너 광고 때문에 SafeArea 제외
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
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
                      Localizations.localeOf(context).languageCode == 'ko' 
                        ? '💪 차드 설명' 
                        : AppLocalizations.of(context)!.chadDescription,
                      _getPushupDescription(widget.pushupType),
                      Icons.fitness_center,
                      Color(0xFF51CF66),
                    ),

                    // 차드의 조언 섹션
                    _buildSection(
                      Localizations.localeOf(context).languageCode == 'ko' 
                        ? '🔥 차드의 조언' 
                        : AppLocalizations.of(context)!.chadAdvice,
                      _getChadMotivation(widget.pushupType),
                      Icons.psychology,
                      Color(0xFFFFD43B),
                    ),

                    // 배너 광고 공간 확보
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
    return Container(
      height: 220,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4DABF7), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _youtubeController,
            showVideoProgressIndicator: false, // 진행률 표시줄 숨기기
            progressIndicatorColor: Color(0xFF4DABF7),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFF4DABF7),
              handleColor: Color(0xFF51CF66),
            ),
            onReady: () {
              setState(() {
                // Player ready
              });
            },
            onEnded: (metaData) {
              // 영상 시청 완료 후 격려 메시지
              _encouragementService.maybeShowEncouragement(context);
            },
          ),
          builder: (context, player) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: player,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getPushupName(widget.pushupType),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getPushupDescription(widget.pushupType),
          style: TextStyle(
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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF4DABF7), width: 1),
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
                  style: TextStyle(
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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF51CF66), width: 1),
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
                  style: TextStyle(
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            content,
            style: TextStyle(
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
        return AppLocalizations.of(context)!.difficultyBeginner;
      case PushupDifficulty.intermediate:
        return AppLocalizations.of(context)!.difficultyIntermediate;
      case PushupDifficulty.advanced:
        return AppLocalizations.of(context)!.difficultyAdvanced;
      case PushupDifficulty.extreme:
        return AppLocalizations.of(context)!.difficultyExtreme;
    }
  }

  String _getTargetMuscleName(TargetMuscle muscle) {
    switch (muscle) {
      case TargetMuscle.chest:
        return AppLocalizations.of(context)!.chest;
      case TargetMuscle.triceps:
        return AppLocalizations.of(context)!.triceps;
      case TargetMuscle.shoulders:
        return AppLocalizations.of(context)!.shoulders;
      case TargetMuscle.core:
        return AppLocalizations.of(context)!.core;
      case TargetMuscle.full:
        return AppLocalizations.of(context)!.fullBody;
    }
  }

  String _getPushupName(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return AppLocalizations.of(context)!.pushupStandard;
      case 'knee':
        return AppLocalizations.of(context)!.pushupKnee;
      case 'incline':
        return AppLocalizations.of(context)!.pushupIncline;
      case 'wide_grip':
        return AppLocalizations.of(context)!.pushupWideGrip;
      case 'diamond':
        return AppLocalizations.of(context)!.pushupDiamond;
      case 'decline':
        return AppLocalizations.of(context)!.pushupDecline;
      case 'archer':
        return AppLocalizations.of(context)!.pushupArcher;
      case 'pike':
        return AppLocalizations.of(context)!.pushupPike;
      case 'clap':
        return AppLocalizations.of(context)!.pushupClap;
      case 'one_arm':
        return AppLocalizations.of(context)!.pushupOneArm;
      default:
        return pushup.id;
    }
  }

  String _getPushupDescription(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return AppLocalizations.of(context)!.pushupStandardDesc;
      case 'knee':
        return AppLocalizations.of(context)!.pushupKneeDesc;
      case 'incline':
        return AppLocalizations.of(context)!.pushupInclineDesc;
      case 'wide_grip':
        return AppLocalizations.of(context)!.pushupWideGripDesc;
      case 'diamond':
        return AppLocalizations.of(context)!.pushupDiamondDesc;
      case 'decline':
        return AppLocalizations.of(context)!.pushupDeclineDesc;
      case 'archer':
        return AppLocalizations.of(context)!.pushupArcherDesc;
      case 'pike':
        return AppLocalizations.of(context)!.pushupPikeDesc;
      case 'clap':
        return AppLocalizations.of(context)!.pushupClapDesc;
      case 'one_arm':
        return AppLocalizations.of(context)!.pushupOneArmDesc;
      default:
        return Localizations.localeOf(context).languageCode == 'ko'
          ? '차드를 위한 특별한 푸시업' 
          : 'Special pushup for chads';
    }
  }

  String _getChadMotivation(PushupType pushup) {
    switch (pushup.id) {
      case 'standard':
        return AppLocalizations.of(context)!.chadMotivationStandard;
      case 'knee':
        return AppLocalizations.of(context)!.chadMotivationKnee;
      case 'incline':
        return AppLocalizations.of(context)!.chadMotivationIncline;
      case 'wide_grip':
        return AppLocalizations.of(context)!.chadMotivationWideGrip;
      case 'diamond':
        return AppLocalizations.of(context)!.chadMotivationDiamond;
      case 'decline':
        return AppLocalizations.of(context)!.chadMotivationDecline;
      case 'archer':
        return AppLocalizations.of(context)!.chadMotivationArcher;
      case 'pike':
        return AppLocalizations.of(context)!.chadMotivationPike;
      case 'clap':
        return AppLocalizations.of(context)!.chadMotivationClap;
      case 'one_arm':
        return AppLocalizations.of(context)!.chadMotivationOneArm;
      default:
        return AppLocalizations.of(context)!.chadMotivationDefault;
    }
  }

  /// 반응형 배너 광고 위젯
  Widget _buildResponsiveBannerAd(BuildContext context, double adHeight) {
    // AdBannerWidget 사용으로 변경
    return Container(
      height: adHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF4DABF7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: const AdBannerWidget(
        adSize: AdSize.banner,
        showOnError: true,
      ),
    );


  }
}
