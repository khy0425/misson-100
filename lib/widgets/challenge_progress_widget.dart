import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';

class ChallengeProgressWidget extends StatelessWidget {
  final Challenge challenge;
  final ChallengeService challengeService;

  const ChallengeProgressWidget({
    super.key,
    required this.challenge,
    required this.challengeService,
  });

  @override
  Widget build(BuildContext context) {
    switch (challenge.type) {
      case ChallengeType.consecutiveDays:
        return _buildConsecutiveDaysProgress(context);
      case ChallengeType.singleSession:
        return _buildSingleSessionProgress(context);
      case ChallengeType.cumulative:
        return _buildCumulativeProgress(context);
    }
  }

  Widget _buildConsecutiveDaysProgress(BuildContext context) {
    final progress = challengeService.getConsecutiveDaysProgress();
    final current = challenge.currentProgress;
    final target = challenge.targetValue;
    final todayCompleted = true; // 임시로 true 설정
    final daysSinceStart = 0; // 임시로 0 설정

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '연속 운동 진행 상황'
                    : 'Consecutive Workout Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 진행률 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '연속 일수'
                        : 'Streak Days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '$current일'
                        : '$current days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '목표'
                        : 'Goal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '$target일'
                        : '$target days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 오늘 상태
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: todayCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: todayCompleted ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    todayCompleted ? Icons.check_circle : Icons.schedule,
                    color: todayCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    todayCompleted 
                      ? (Localizations.localeOf(context).languageCode == 'ko'
                          ? '오늘 운동 완료!'
                          : "Today's Workout Complete!")
                      : (Localizations.localeOf(context).languageCode == 'ko'
                          ? '오늘 운동을 완료하세요'
                          : 'Complete Today\'s Workout'),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: todayCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // 힌트
            Text(
              challengeService.getChallengeHint(challenge.type),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSessionProgress(BuildContext context) {
    final bestRecord = challengeService.getSingleSessionBestRecord();
    final target = challenge.targetValue;

    return FutureBuilder<int>(
      future: bestRecord,
      builder: (context, snapshot) {
        final recordValue = snapshot.data ?? 0;
        final progressPercentage = target > 0 ? (recordValue / target).clamp(0.0, 1.0) : 0.0;

        return Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '단일 세션 챌린지'
                        : 'Single Session Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 최고 기록 vs 목표
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '최고 기록'
                            : 'Best Record',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '${recordValue}개'
                            : '$recordValue reps',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '목표'
                            : 'Goal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '$target개'
                            : '$target reps',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 진행률 바
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Localizations.localeOf(context).languageCode == 'ko' 
                          ? '진행률' 
                          : 'Progress'),
                        Text('${(progressPercentage * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressPercentage >= 1.0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 남은 개수
                if (recordValue < target)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '${target - recordValue}개 더 하면 달성!'
                            : '${target - recordValue} more reps to achieve!',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                
                // 힌트
                Text(
                  challengeService.getChallengeHint(challenge.type),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCumulativeProgress(BuildContext context) {
    final progress = challengeService.getCumulativeProgress();

    return FutureBuilder<int>(
      future: progress,
      builder: (context, snapshot) {
        final current = snapshot.data ?? 0;
        final target = challenge.targetValue;
        final remaining = target - current;
        final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

        return Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '누적 챌린지'
                        : 'Cumulative Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 현재 vs 목표
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '현재 누적'
                            : 'Current Total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '$current개'
                            : '$current reps',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '목표'
                            : 'Goal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '$target개'
                            : '$target reps',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 진행률 바
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Localizations.localeOf(context).languageCode == 'ko' 
                          ? '진행률' 
                          : 'Progress'),
                        Text('${(percentage * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 남은 개수
                if (remaining > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '$remaining개 더 하면 달성!'
                            : '$remaining more reps to achieve!',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                
                // 힌트
                Text(
                  challengeService.getChallengeHint(challenge.type),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 