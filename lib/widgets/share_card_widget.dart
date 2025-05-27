import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../utils/workout_data.dart';

class ShareCardWidget extends StatelessWidget {
  final ShareCardType type;
  final Map<String, dynamic> data;

  const ShareCardWidget({
    super.key,
    required this.type,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(AppColors.primaryColor).withValues(alpha: 0.8),
                  const Color(AppColors.primaryColor).withValues(alpha: 0.6),
                ]
              : [
                  const Color(AppColors.primaryColor),
                  const Color(AppColors.primaryColor).withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 20),
          _buildContent(context, l10n),
          const SizedBox(height: 20),
          _buildFooter(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Color(AppColors.primaryColor),
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MISSION: 100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '차드가 되는 여정',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    switch (type) {
      case ShareCardType.dailyWorkout:
        return _buildDailyWorkoutContent(l10n);
      case ShareCardType.levelUp:
        return _buildLevelUpContent(l10n);
      case ShareCardType.achievement:
        return _buildAchievementContent(l10n);
      case ShareCardType.weeklyProgress:
        return _buildWeeklyProgressContent(l10n);
      case ShareCardType.mission100:
        return _buildMission100Content(l10n);
    }
  }

  Widget _buildDailyWorkoutContent(AppLocalizations l10n) {
    final pushupCount = data['pushupCount'] as int;
    final currentDay = data['currentDay'] as int;
    final level = data['level'] as UserLevel;
    final levelName = _getLevelName(level, l10n);

    return Column(
      children: [
        const Text(
          '🔥 일일 기록 🔥',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📅 Day',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '$currentDay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💪 푸시업',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${pushupCount}개',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🏆 레벨',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    levelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelUpContent(AppLocalizations l10n) {
    final newLevel = data['newLevel'] as UserLevel;
    final totalDays = data['totalDays'] as int;
    final totalPushups = data['totalPushups'] as int;
    final levelName = _getLevelName(newLevel, l10n);
    final levelEmoji = _getLevelEmoji(newLevel);

    return Column(
      children: [
        Text(
          '$levelEmoji 레벨업! $levelEmoji',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '새로운 레벨',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                levelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        '📅',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${totalDays}일',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        '💪',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${totalPushups}개',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementContent(AppLocalizations l10n) {
    final title = data['title'] as String;
    final description = data['description'] as String;
    final xpReward = data['xpReward'] as int;

    return Column(
      children: [
        const Text(
          '🏆 업적 달성! 🏆',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🎯 +${xpReward} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressContent(AppLocalizations l10n) {
    final weekNumber = data['weekNumber'] as int;
    final completedDays = data['completedDays'] as int;
    final totalPushups = data['totalPushups'] as int;
    final progressPercentage = data['progressPercentage'] as double;

    return Column(
      children: [
        const Text(
          '📊 주간 리포트 📊',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Week $weekNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 20)),
                      Text(
                        '${completedDays}일',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('💪', style: TextStyle(fontSize: 20)),
                      Text(
                        '${totalPushups}개',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(progressPercentage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMission100Content(AppLocalizations l10n) {
    final totalDays = data['totalDays'] as int;
    final duration = data['duration'] as int;

    return Column(
      children: [
        const Text(
          '🎉 MISSION COMPLETE! 🎉',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                '💪 푸시업 100개 연속 달성! 💪',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 20)),
                      Text(
                        '${duration}일',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '소요일',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      Text(
                        '${totalDays}회',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '🔥 진정한 차드 완성! 🔥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Column(
      children: [
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 12),
        Text(
          '나도 차드가 되고 싶다면?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const Text(
          'Mission: 100 앱 다운로드!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getLevelName(UserLevel level, AppLocalizations l10n) {
    switch (level) {
      case UserLevel.rookie:
        return l10n.rookieShort;
      case UserLevel.rising:
        return l10n.risingShort;
      case UserLevel.alpha:
        return l10n.alphaShort;
      case UserLevel.giga:
        return l10n.gigaShort;
    }
  }

  String _getLevelEmoji(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return '🌱';
      case UserLevel.rising:
        return '🔥';
      case UserLevel.alpha:
        return '⚡';
      case UserLevel.giga:
        return '👑';
    }
  }
}

enum ShareCardType {
  dailyWorkout,
  levelUp,
  achievement,
  weeklyProgress,
  mission100,
} 