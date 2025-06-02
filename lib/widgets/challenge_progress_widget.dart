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
    // 챌린지 타입이 null인 경우 빈 위젯 반환
    if (challenge.type == null) {
      return const SizedBox.shrink();
    }

    switch (challenge.type!) {
      case ChallengeType.consecutiveDays:
        return _buildConsecutiveDaysProgress(context);
      case ChallengeType.singleSession:
        return _buildSingleSessionProgress(context);
      case ChallengeType.cumulative:
        return _buildCumulativeProgress(context);
    }
  }

  Widget _buildConsecutiveDaysProgress(BuildContext context) {
    // 임시로 고정값 사용
    final progress = 0;
    final target = challenge.targetValue ?? 7;
    final percentage = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '연속 일수 챌린지',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 진행 바
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            
            // 진행 상태 텍스트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progress/$target일',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: percentage >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSessionProgress(BuildContext context) {
    // 임시로 고정값 사용
    final recordValue = 0;
    final target = challenge.targetValue ?? 50;
    final progressPercentage = target > 0 ? (recordValue / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '단일 세션 챌린지',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 현재 기록
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최고 기록',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$recordValue개',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 목표까지 남은 개수
            if (recordValue < target)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${target - recordValue}개 더 하면 달성!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCumulativeProgress(BuildContext context) {
    // 임시로 고정값 사용
    final current = 0;
    final target = challenge.targetValue ?? 100;
    final remaining = target - current;
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '누적 챌린지',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 진행 바
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            
            // 진행 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$current/$target개',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: percentage >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 남은 개수
            if (remaining > 0)
              Text(
                '목표까지 $remaining개 남음',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 