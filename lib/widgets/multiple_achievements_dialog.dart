import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../generated/app_localizations.dart';
import '../models/achievement.dart';
import '../utils/constants.dart';

class MultipleAchievementsDialog extends StatefulWidget {
  final List<Achievement> achievements;
  final VoidCallback? onDismiss;

  const MultipleAchievementsDialog({
    super.key,
    required this.achievements,
    this.onDismiss,
  });

  @override
  State<MultipleAchievementsDialog> createState() =>
      _MultipleAchievementsDialogState();
}

class _MultipleAchievementsDialogState extends State<MultipleAchievementsDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // 햅틱 피드백
    HapticFeedback.heavyImpact();

    // 애니메이션 시작
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  String _getRarityText(BuildContext context, AchievementRarity rarity) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    switch (rarity) {
      case AchievementRarity.common:
        return isKorean ? '일반' : 'Common';
      case AchievementRarity.rare:
        return isKorean ? '레어' : 'Rare';
      case AchievementRarity.epic:
        return isKorean ? '에픽' : 'Epic';
      case AchievementRarity.legendary:
        return isKorean ? '전설' : 'Legendary';
    }
  }

  int get _totalXP => widget.achievements.fold(0, (sum, achievement) => sum + achievement.xpReward);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // 축하 아이콘
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.celebration,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 축하 메시지
                          Text(
                            isKorean ? '축하합니다!' : 'Congratulations!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            isKorean 
                              ? '${widget.achievements.length}개의 업적을 달성했습니다!'
                              : 'You\'ve unlocked ${widget.achievements.length} achievements!',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // 업적 목록
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 업적 리스트
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: widget.achievements.length,
                                separatorBuilder: (context, index) => const Divider(height: 16),
                                itemBuilder: (context, index) {
                                  final achievement = widget.achievements[index];
                                  final rarityColor = achievement.getRarityColor();
                                  
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: rarityColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                      border: Border.all(
                                        color: rarityColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // 업적 아이콘
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: rarityColor.withOpacity(0.2),
                                            border: Border.all(
                                              color: rarityColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            achievement.icon,
                                            color: rarityColor,
                                            size: 24,
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 12),
                                        
                                        // 업적 정보
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      achievement.getTitle(context),
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: rarityColor,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      _getRarityText(context, achievement.rarity),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                achievement.getDescription(context),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // XP 보상
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.stars,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+${achievement.xpReward}',
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 총 XP 표시
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.stars,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isKorean 
                                      ? '총 $_totalXP XP 획득!'
                                      : 'Total $_totalXP XP Earned!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 확인 버튼
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDismiss?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ),
                          child: Text(
                            isKorean ? '확인' : 'OK',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 