import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/ad_service.dart';
import '../widgets/enhanced_achievement_card.dart';
import '../widgets/achievement_unlock_animation.dart';
import '../widgets/achievement_detail_dialog.dart';
import '../generated/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  int _totalXP = 0;
  int _unlockedCount = 0;
  int _totalCount = 0;
  Map<AchievementRarity, int> _rarityCount = {};
  bool _isLoading = true;

  // 업적 화면 전용 배너 광고
  BannerAd? _achievementsBannerAd;
  
  // 업적 달성 애니메이션 상태
  bool _showUnlockAnimation = false;
  Achievement? _currentUnlockedAchievement;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAchievements();
    _createAchievementsBannerAd();
    
    // 업적 달성 시 업적 목록 새로고침을 위한 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AchievementService.setOnAchievementUnlocked(() {
        if (mounted) {
          _loadAchievements();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _achievementsBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      // 업적 서비스 초기화
      await AchievementService.initialize();

      // 업적 진행도 체크 및 업데이트 (새로 달성된 업적 확인)
      await _checkForNewAchievements();

      // 데이터 로드
      final unlocked = await AchievementService.getUnlockedAchievements();
      final locked = await AchievementService.getLockedAchievements();
      final totalXP = await AchievementService.getTotalXP();
      final unlockedCount = await AchievementService.getUnlockedCount();
      final totalCount = await AchievementService.getTotalCount();
      final rarityCount = await AchievementService.getUnlockedCountByRarity();

      setState(() {
        _unlockedAchievements = unlocked;
        _lockedAchievements = locked;
        _totalXP = totalXP;
        _unlockedCount = unlockedCount;
        _totalCount = totalCount;
        _rarityCount = rarityCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('')));
      }
    }
  }

  /// 업적 화면 전용 배너 광고 생성
  void _createAchievementsBannerAd() {
    _achievementsBannerAd = AdService.instance.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (Ad ad) {
        debugPrint('업적 배너 광고 로드 완료');
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        debugPrint('업적 배너 광고 로드 실패: $error');
        ad.dispose();
        if (mounted) {
          setState(() {
            _achievementsBannerAd = null;
          });
        }
      },
    );
    _achievementsBannerAd?.load();
  }

  /// 업적 달성 애니메이션 표시
  void _showAchievementUnlockAnimation(Achievement achievement) {
    setState(() {
      _currentUnlockedAchievement = achievement;
      _showUnlockAnimation = true;
    });

    // 3초 후 애니메이션 숨김
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUnlockAnimation = false;
          _currentUnlockedAchievement = null;
        });
      }
    });
  }

  /// 업적 진행도 체크 및 새로 달성된 업적 확인
  Future<void> _checkForNewAchievements() async {
    final newlyUnlocked = await AchievementService.checkAndUpdateAchievements();
    
    // 새로 달성된 업적이 있으면 애니메이션 표시
    for (final achievement in newlyUnlocked) {
      _showAchievementUnlockAnimation(achievement);
      // 여러 업적이 동시에 달성된 경우 순차적으로 표시
      await Future<void>.delayed(const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          Column(
            children: [
              // 메인 콘텐츠
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 헤더 통계
                    SliverToBoxAdapter(child: _buildStatsHeader()),

                    // 탭바
                    SliverToBoxAdapter(child: _buildTabBar()),

                    // 업적 리스트
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUnlockedAchievements(),
                          _buildLockedAchievements(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 배너 광고
              _buildBannerAd(),
            ],
          ),

          // 업적 달성 애니메이션 오버레이
          if (_showUnlockAnimation && _currentUnlockedAchievement != null)
            AchievementUnlockAnimation(
              achievement: _currentUnlockedAchievement!,
              onComplete: () {
                setState(() {
                  _showUnlockAnimation = false;
                  _currentUnlockedAchievement = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: isDark 
          ? LinearGradient(
              colors: [
                Color(AppColors.chadGradient[0]),
                Color(AppColors.chadGradient[1]),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                const Color(0xFF2196F3), // 밝은 파란색
                const Color(0xFF1976D2), // 진한 파란색
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏆 ${AppLocalizations.of(context)!.achievements}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // 메인 통계
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  value: '$_unlockedCount/$_totalCount',
                  label: AppLocalizations.of(context)!.unlockedAchievements(_unlockedCount),
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  value: '$_totalXP XP',
                  label: AppLocalizations.of(context)!.totalExperience,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingM),

          // 레어도별 통계
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRarityBadge(
                AchievementRarity.common,
                _rarityCount[AchievementRarity.common] ?? 0,
              ),
              _buildRarityBadge(
                AchievementRarity.rare,
                _rarityCount[AchievementRarity.rare] ?? 0,
              ),
              _buildRarityBadge(
                AchievementRarity.epic,
                _rarityCount[AchievementRarity.epic] ?? 0,
              ),
              _buildRarityBadge(
                AchievementRarity.legendary,
                _rarityCount[AchievementRarity.legendary] ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppConstants.paddingS / 2),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildRarityBadge(AchievementRarity rarity, int count) {
    final theme = Theme.of(context);
    final color = Achievement(
      id: '',
      titleKey: 'achievementTutorialExplorerTitle',
      descriptionKey: 'achievementTutorialExplorerDesc',
      motivationKey: 'achievementTutorialExplorerMotivation',
      type: AchievementType.first,
      rarity: rarity,
      targetValue: 0,
      icon: Icons.star,
    ).getRarityColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: AppConstants.paddingS / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rarity == AchievementRarity.common
                ? AppLocalizations.of(context)!.common
                : rarity == AchievementRarity.rare
                ? AppLocalizations.of(context)!.rare
                : rarity == AchievementRarity.epic
                ? AppLocalizations.of(context)!.epic
                : AppLocalizations.of(context)!.legendary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(AppColors.primaryColor),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: const Color(AppColors.primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: '${AppLocalizations.of(context)!.unlockedAchievements(_unlockedAchievements.length)}'),
          Tab(text: '${AppLocalizations.of(context)!.lockedAchievements(_lockedAchievements.length)}'),
        ],
      ),
    );
  }

  Widget _buildUnlockedAchievements() {
    if (_unlockedAchievements.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: AppLocalizations.of(context)!.noAchievementsYet,
        message: AppLocalizations.of(context)!.startWorkoutForAchievements,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _unlockedAchievements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: EnhancedAchievementCard(
            achievement: _unlockedAchievements[index],
            showProgress: false, // 완료된 업적이므로 진행도 바 숨김
            onTap: () => _showAchievementDetail(_unlockedAchievements[index]),
          ),
        );
      },
    );
  }

  Widget _buildLockedAchievements() {
    if (_lockedAchievements.isEmpty) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        title: AppLocalizations.of(context)!.allAchievementsUnlocked,
        message: AppLocalizations.of(context)!.congratulationsChad,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _lockedAchievements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: EnhancedAchievementCard(
            achievement: _lockedAchievements[index],
            showProgress: true, // 미완료 업적이므로 진행도 바 표시
            onTap: () => _showAchievementDetail(_lockedAchievements[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  /// 업적 상세 정보 다이얼로그 표시
  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailDialog(achievement: achievement),
    );
  }

  Widget _buildBannerAd() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(AppColors.primaryColor), width: 1),
        ),
      ),
      child: _achievementsBannerAd != null
          ? AdWidget(ad: _achievementsBannerAd!)
          : Container(
              height: 60,
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '업적을 달성해서 차드가 되자! 🏆',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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
