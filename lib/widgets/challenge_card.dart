import 'package:flutter/material.dart';
import '../models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onStart;
  final VoidCallback? onAbandon;
  final bool showStartButton;
  final bool showAbandonButton;
  final bool showCompletionDate;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onStart,
    this.onAbandon,
    this.showStartButton = false,
    this.showAbandonButton = false,
    this.showCompletionDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (제목, 난이도, 상태)
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDifficultyChip(),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            
            // 설명
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // 목표 정보
            Row(
              children: [
                Icon(
                  _getTypeIcon(),
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '목표: ${challenge.targetValue}${challenge.targetUnit}'
                    : 'Goal: ${challenge.targetValue}${challenge.targetUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (challenge.estimatedDuration > 0)
                  Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '예상 기간: ${challenge.estimatedDuration}일'
                      : 'Estimated: ${challenge.estimatedDuration} days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            
            // 진행률 (활성 챌린지인 경우)
            if (challenge.isActive) ...[
              const SizedBox(height: 12),
              _buildProgressBar(context),
            ],
            
            // 완료 날짜 (완료된 챌린지인 경우)
            if (showCompletionDate && challenge.completionDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '완료일: ${_formatDate(challenge.completionDate!)}'
                      : 'Completed: ${_formatDate(challenge.completionDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            // 보상 정보
            if (challenge.rewards.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRewardsSection(context),
            ],
            
            // 액션 버튼들
            if (showStartButton || showAbandonButton) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getDifficultyColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            challenge.difficulty.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            challenge.difficulty.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getDifficultyColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            challenge.status.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            challenge.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '진행률'
                : 'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${challenge.currentProgress}/${challenge.targetValue}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: challenge.progressPercentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            challenge.progressPercentage >= 1.0 ? Colors.green : Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '${(challenge.progressPercentage * 100).toInt()}% 완료'
            : '${(challenge.progressPercentage * 100).toInt()}% Complete',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '보상'
            : 'Rewards',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: challenge.rewards.map((reward) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                reward.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (showStartButton && onStart != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: challenge.isLocked ? null : onStart,
              icon: const Icon(Icons.play_arrow),
              label: Text(Localizations.localeOf(context).languageCode == 'ko'
                ? '시작하기'
                : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        if (showAbandonButton && onAbandon != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAbandon,
              icon: const Icon(Icons.stop),
              label: Text(Localizations.localeOf(context).languageCode == 'ko'
                ? '포기하기'
                : 'Abandon'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getTypeIcon() {
    switch (challenge.type) {
      case ChallengeType.consecutiveDays:
        return Icons.calendar_today;
      case ChallengeType.singleSession:
        return Icons.fitness_center;
      case ChallengeType.cumulative:
        return Icons.trending_up;
    }
  }

  Color _getDifficultyColor() {
    switch (challenge.difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
      case ChallengeDifficulty.extreme:
        return Colors.purple;
    }
  }

  Color _getStatusColor() {
    switch (challenge.status) {
      case ChallengeStatus.available:
        return Colors.blue;
      case ChallengeStatus.active:
        return Colors.orange;
      case ChallengeStatus.completed:
        return Colors.green;
      case ChallengeStatus.failed:
        return Colors.red;
      case ChallengeStatus.locked:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
} 