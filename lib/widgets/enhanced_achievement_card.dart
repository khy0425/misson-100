import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/constants.dart';
import '../generated/app_localizations.dart';
import 'achievement_progress_bar.dart';

class EnhancedAchievementCard extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool isCompact;

  const EnhancedAchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.showProgress = true,
    this.isCompact = false,
  });

  @override
  State<EnhancedAchievementCard> createState() => _EnhancedAchievementCardState();
}

class _EnhancedAchievementCardState extends State<EnhancedAchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  Color _getRarityColor() {
    return widget.achievement.getRarityColor();
  }

  String _getRarityText(BuildContext context) {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return AppLocalizations.of(context)!.common;
      case AchievementRarity.rare:
        return AppLocalizations.of(context)!.rare;
      case AchievementRarity.epic:
        return AppLocalizations.of(context)!.epic;
      case AchievementRarity.legendary:
        return AppLocalizations.of(context)!.legendary;
    }
  }

  Widget _buildIcon() {
    final rarityColor = _getRarityColor();
    final iconSize = widget.isCompact ? 32.0 : 48.0;
    
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.achievement.isCompleted
            ? LinearGradient(
                colors: [
                  rarityColor,
                  rarityColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.achievement.isCompleted ? null : rarityColor.withOpacity(0.3),
        boxShadow: widget.achievement.isCompleted
            ? [
                BoxShadow(
                  color: rarityColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        widget.achievement.isCompleted ? Icons.emoji_events : Icons.lock_outline,
        color: widget.achievement.isCompleted ? Colors.white : rarityColor,
        size: iconSize * 0.6,
      ),
    );
  }

  Widget _buildRarityBadge() {
    final rarityColor = _getRarityColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: rarityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: rarityColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _getRarityText(context),
        style: TextStyle(
          color: rarityColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    if (!widget.achievement.isCompleted) return const SizedBox.shrink();
    
    final rarityColor = _getRarityColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: rarityColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        AppLocalizations.of(context)!.completed,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarityColor = _getRarityColor();
    
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChanged(true),
            onExit: (_) => _onHoverChanged(false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Card(
                elevation: _elevationAnimation.value,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: widget.achievement.isCompleted
                      ? BorderSide(
                          color: rarityColor.withOpacity(0.3),
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    gradient: widget.achievement.isCompleted
                        ? LinearGradient(
                            colors: [
                              rarityColor.withOpacity(0.05),
                              rarityColor.withOpacity(0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      widget.isCompact ? AppConstants.paddingM : AppConstants.paddingL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더 (아이콘, 제목, 배지)
                        Row(
                          children: [
                            _buildIcon(),
                            SizedBox(width: widget.isCompact ? AppConstants.paddingS : AppConstants.paddingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.achievement.getTitle(context),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: widget.achievement.isCompleted
                                                ? rarityColor
                                                : theme.colorScheme.onSurface,
                                          ),
                                          maxLines: widget.isCompact ? 1 : 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppConstants.paddingS),
                                      _buildRarityBadge(),
                                    ],
                                  ),
                                  if (!widget.isCompact) ...[
                                    const SizedBox(height: AppConstants.paddingS / 2),
                                    Text(
                                      widget.achievement.getDescription(context),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.achievement.isCompleted) ...[
                              const SizedBox(width: AppConstants.paddingS),
                              _buildCompletedBadge(),
                            ],
                          ],
                        ),
                        
                        // 진행도 바 (완료되지 않은 업적만)
                        if (widget.showProgress && !widget.achievement.isCompleted) ...[
                          SizedBox(height: widget.isCompact ? AppConstants.paddingS : AppConstants.paddingM),
                          AchievementProgressBar(
                            achievement: widget.achievement,
                            showLabel: !widget.isCompact,
                            height: widget.isCompact ? 6.0 : 8.0,
                          ),
                        ],
                        
                        // 완료 시간 (완료된 업적만)
                        if (widget.achievement.isCompleted && widget.achievement.unlockedAt != null) ...[
                          const SizedBox(height: AppConstants.paddingS),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: rarityColor,
                              ),
                              const SizedBox(width: AppConstants.paddingS / 2),
                              Text(
                                '완료: ${_formatDate(widget.achievement.unlockedAt!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: rarityColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

// 그리드용 컴팩트 업적 카드
class CompactAchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const CompactAchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedAchievementCard(
      achievement: achievement,
      onTap: onTap,
      showProgress: false,
      isCompact: true,
    );
  }
} 