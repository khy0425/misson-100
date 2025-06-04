import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../generated/app_localizations.dart';
import '../models/pushup_type.dart';
import '../services/pushup_tutorial_service.dart';
import '../services/chad_encouragement_service.dart';

import '../widgets/ad_banner_widget.dart';
import 'pushup_tutorial_detail_screen.dart';

class PushupTutorialScreen extends StatefulWidget {
  const PushupTutorialScreen({super.key});

  @override
  State<PushupTutorialScreen> createState() => _PushupTutorialScreenState();
}

class _PushupTutorialScreenState extends State<PushupTutorialScreen> {
  final _encouragementService = ChadEncouragementService();

  @override
  void initState() {
    super.initState();
    // 화면 로드 후 격려 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _encouragementService.maybeShowEncouragement(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final service = PushupTutorialService();
    final allPushups = service.getAllPushupTypes();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    // 반응형 광고 높이
    final adHeight = isSmallScreen ? 50.0 : 60.0;

    // 난이도별로 그룹핑
    final groupedPushups = <PushupDifficulty, List<PushupType>>{};
    for (final pushup in allPushups) {
      groupedPushups.putIfAbsent(pushup.difficulty, () => []).add(pushup);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: Text(
          Localizations.localeOf(context).languageCode == 'ko' 
            ? '차드 푸시업 도장' 
            : AppLocalizations.of(context)!.pushupTutorialTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 메인 컨텐츠 영역 (스크롤 가능)
          Expanded(
            child: SafeArea(
              bottom: false, // 하단은 배너 광고 때문에 SafeArea 제외
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4DABF7), width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: Color(0xFF4DABF7),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            Localizations.localeOf(context).languageCode == 'ko' 
                              ? '진짜 차드들은 자세부터 다르다! 💪' 
                              : AppLocalizations.of(context)!.pushupTutorialSubtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 난이도별 섹션
                    ...PushupDifficulty.values.map((difficulty) {
                      final pushups = groupedPushups[difficulty] ?? [];
                      if (pushups.isEmpty) return const SizedBox.shrink();

                      return _buildDifficultySection(
                        context,
                        difficulty,
                        pushups,
                      );
                    }),

                    // 배너 광고 공간 확보용 여백
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

  Widget _buildDifficultySection(
    BuildContext context,
    PushupDifficulty difficulty,
    List<PushupType> pushups,
  ) {
    final difficultyName = _getDifficultyName(difficulty);
    final color = Color(PushupTutorialService.getDifficultyColor(difficulty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 난이도 제목
        Row(
          children: [
            Icon(Icons.star, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              difficultyName,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 푸시업 카드들
        ...pushups.map((pushup) => _buildPushupCard(context, pushup)),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPushupCard(BuildContext context, PushupType pushup) {
    final difficultyColor = Color(
      PushupTutorialService.getDifficultyColor(pushup.difficulty),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 난이도에 따른 격려 메시지 표시
          final difficultyName = _getDifficultyName(pushup.difficulty);
          final message = _encouragementService.getMessageForDifficulty(
            difficultyName,
          );
          _encouragementService.showEncouragementSnackBar(context, message);

          // 상세 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  PushupTutorialDetailScreen(pushupType: pushup),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: difficultyColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: difficultyColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPushupName(pushup),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPushupDescription(pushup),
                      style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Color(0xFF4DABF7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pushup.estimatedCaloriesPerRep}kcal/rep',
                          style: const TextStyle(
                            color: Color(0xFF4DABF7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.psychology,
                          color: Color(0xFF51CF66),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pushup.targetMuscles
                              .take(2)
                              .map((muscle) => _getTargetMuscleName(muscle))
                              .join(', '),
                          style: const TextStyle(
                            color: Color(0xFF51CF66),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, color: Color(0xFF4DABF7), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyName(PushupDifficulty difficulty) {
    switch (difficulty) {
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

  /// 반응형 배너 광고 위젯
  Widget _buildResponsiveBannerAd(BuildContext context, double adHeight) {
    // AdBannerWidget 사용으로 변경
    return Container(
      height: adHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4DABF7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: const AdBannerWidget(
        adSize: AdSize.banner,
        showOnError: true,
      ),
    );

    // 광고가 로드되지 않은 경우 반응형 플레이스홀더
    return Container(
      height: adHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4DABF7).withValues(alpha: 0.3),
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
              color: const Color(0xFF4DABF7).withValues(alpha: 0.6),
              size: adHeight * 0.4,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.advertisement,
              style: TextStyle(
                color: const Color(0xFF4DABF7).withValues(alpha: 0.6),
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
