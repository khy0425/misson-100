import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../generated/app_localizations.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;
  final bool showCompletionDate;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.showCompletionDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 상태
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challenge.title ?? challenge.titleKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (challenge.status != null) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        challenge.status!.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 설명
              Text(
                challenge.description ?? challenge.descriptionKey,
                style: theme.textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 12),
              
              // 진행 정보
              if (challenge.targetValue != null)
                Text(
                  '목표: ${challenge.targetValue}${challenge.targetUnit ?? ''}',
                  style: theme.textTheme.bodySmall,
                ),
              
              const SizedBox(height: 8),
              
              // 난이도와 기타 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (challenge.difficulty != null)
                    Row(
                      children: [
                        Text(
                          challenge.difficulty!.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          challenge.difficulty!.displayName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  
                  if (challenge.estimatedDuration != null && challenge.estimatedDuration! > 0)
                    Text(
                      '예상 기간: ${challenge.estimatedDuration}일',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (challenge.status) {
      case ChallengeStatus.available:
        return Colors.green;
      case ChallengeStatus.active:
        return Colors.blue;
      case ChallengeStatus.completed:
        return Colors.purple;
      case ChallengeStatus.failed:
        return Colors.red;
      case ChallengeStatus.locked:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 