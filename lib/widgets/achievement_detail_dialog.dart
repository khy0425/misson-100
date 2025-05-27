import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/constants.dart';
import 'achievement_progress_bar.dart';

class AchievementDetailDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailDialog({
    super.key,
    required this.achievement,
  });

  Color _getRarityColor() {
    return achievement.getRarityColor();
  }

  String _getRarityText() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '레어';
      case AchievementRarity.epic:
        return '에픽';
      case AchievementRarity.legendary:
        return '전설';
    }
  }

  String _getTypeText() {
    switch (achievement.type) {
      case AchievementType.first:
        return '첫 번째 도전';
      case AchievementType.volume:
        return '총량 달성';
      case AchievementType.streak:
        return '연속 기록';
      case AchievementType.perfect:
        return '완벽한 수행';
      case AchievementType.special:
        return '특별 업적';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarityColor = _getRarityColor();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: rarityColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rarityColor.withOpacity(0.1),
                    rarityColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Column(
                children: [
                  // 업적 아이콘
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: achievement.isCompleted
                          ? LinearGradient(
                              colors: [
                                rarityColor,
                                rarityColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: achievement.isCompleted ? null : rarityColor.withOpacity(0.3),
                      boxShadow: achievement.isCompleted
                          ? [
                              BoxShadow(
                                color: rarityColor.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      achievement.isCompleted ? Icons.emoji_events : Icons.lock_outline,
                      color: achievement.isCompleted ? Colors.white : rarityColor,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingM),
                  
                  // 업적 제목
                  Text(
                    achievement.getTitle(context),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: rarityColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingS),
                  
                  // 희귀도 및 타입 배지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(_getRarityText(), rarityColor),
                      const SizedBox(width: AppConstants.paddingS),
                      _buildBadge(_getTypeText(), theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
            
            // 본문
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 설명
                  Text(
                    '설명',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    achievement.getDescription(context),
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingM),
                  
                  // 진행도 (미완료 업적만)
                  if (!achievement.isCompleted) ...[
                    Text(
                      '진행도',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    AchievementProgressBar(
                      achievement: achievement,
                      showLabel: true,
                      height: 12.0,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                  ],
                  
                  // 완료 정보 (완료된 업적만)
                  if (achievement.isCompleted && achievement.unlockedAt != null) ...[
                    Text(
                      '완료 정보',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: rarityColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: rarityColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Text(
                                '완료일: ${_formatDate(achievement.unlockedAt!)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingS / 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Text(
                                '획득 XP: ${achievement.xpReward}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                  ],
                  
                  // 동기부여 메시지
                  if (achievement.getMotivation(context).isNotEmpty) ...[
                    Text(
                      '동기부여 메시지',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        achievement.getMotivation(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rarityColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: AppConstants.paddingS / 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
} 