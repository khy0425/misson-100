import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/constants.dart';
import '../generated/app_localizations.dart';

class AchievementProgressBar extends StatefulWidget {
  final Achievement achievement;
  final bool showLabel;
  final double height;

  const AchievementProgressBar({
    super.key,
    required this.achievement,
    this.showLabel = true,
    this.height = 8.0,
  });

  @override
  State<AchievementProgressBar> createState() => _AchievementProgressBarState();
}

class _AchievementProgressBarState extends State<AchievementProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.achievement.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AchievementProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.achievement.currentValue != widget.achievement.currentValue) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.achievement.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    return widget.achievement.getRarityColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarityColor = _getRarityColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.progress,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.achievement.currentValue}/${widget.achievement.targetValue}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rarityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS / 2),
        ],
        
        // 진행도 바 컨테이너
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            color: theme.colorScheme.surfaceVariant,
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 진행도 바
                  Container(
                    width: double.infinity,
                    height: widget.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      color: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                  
                  // 진행된 부분
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        gradient: LinearGradient(
                          colors: [
                            rarityColor,
                            rarityColor.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: widget.achievement.isCompleted
                            ? [
                                BoxShadow(
                                  color: rarityColor.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  
                  // 완료 시 반짝이는 효과
                  if (widget.achievement.isCompleted)
                    Container(
                      width: double.infinity,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        
        if (widget.showLabel) ...[
          const SizedBox(height: AppConstants.paddingS / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.percentComplete((widget.achievement.progress * 100).toInt()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (widget.achievement.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.completed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: rarityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// 간단한 진행도 바 (라벨 없이)
class SimpleProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;

  const SimpleProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.primaryColor;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: progressColor,
          ),
        ),
      ),
    );
  }
} 