import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../utils/workout_data.dart';
import '../services/workout_program_service.dart';
import '../services/database_service.dart';
import '../services/ad_service.dart';
import '../models/user_profile.dart';
import 'workout_screen.dart';
import 'pushup_tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTitle),
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: Column(
        children: [
          // 메인 콘텐츠 영역
          Expanded(
            child: SafeArea(
              bottom: false, // 하단은 배너 광고 영역
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Chad 이미지 및 환영 메시지
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        color: Color(
                          isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Chad 이미지
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/기본차드.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          Text(
                            AppLocalizations.of(context)!.welcomeMessage,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(AppColors.primaryColor),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            AppLocalizations.of(context)!.dailyMotivation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXL),

                    // 오늘의 워크아웃 버튼
                    ElevatedButton(
                      onPressed: () => _startTodayWorkout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            AppLocalizations.of(context)!.startTodayWorkout,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // 푸시업 튜토리얼 버튼
                    ElevatedButton(
                      onPressed: () => _openTutorial(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DABF7),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            AppLocalizations.of(context)!.tutorialButton,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // 진행 상황 카드 (임시)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        color: Color(
                          isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.weekProgress,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingM),
                          LinearProgressIndicator(
                            value: 0.3, // 임시 값
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.progressWeekDay(1, 3, 1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 하단 정보
                    Text(
                      AppLocalizations.of(context)!.bottomMotivation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.primaryColor),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 배너 광고
          _buildBannerAd(),
        ],
      ),
    );
  }

  void _startTodayWorkout(BuildContext context) async {
    try {
      // 임시 사용자 프로필 생성 (실제로는 데이터베이스에서 가져와야 함)
      final userProfile = UserProfile(
        level: UserLevel.rookie, // 임시 레벨
        initialMaxReps: 5,
        startDate: DateTime.now(),
        chadLevel: 0,
        reminderEnabled: false,
      );

      // 임시 오늘의 워크아웃 생성 (실제로는 WorkoutProgramService에서 가져와야 함)
      final todayWorkout = TodayWorkout(
        week: 1,
        day: 1,
        workout: [6, 6, 4, 4, 2], // 임시 워크아웃 데이터
        totalReps: 22,
        restTimeSeconds: 60,
      );

      // 워크아웃 화면으로 이동
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkoutScreen(
            userProfile: userProfile,
            todayWorkout: todayWorkout,
          ),
        ),
      );
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.workoutStartError(e.toString()),
          ),
          backgroundColor: const Color(AppColors.errorColor),
        ),
      );
    }
  }

  void _openTutorial(BuildContext context) {
    // 튜토리얼 화면으로 이동
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => PushupTutorialScreen()));
  }

  Widget _buildBannerAd() {
    final bannerAd = AdService.getBannerAd();

    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(AppColors.primaryColor), width: 1),
        ),
      ),
      child: bannerAd != null
          ? AdWidget(ad: bannerAd)
          : Container(
              height: 60,
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Color(AppColors.primaryColor),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '차드가 되는 여정을 함께하세요! 💪',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
