import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/ad_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAchievements();
    _createAchievementsBannerAd();
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

      // 업적 진행도 체크 및 업데이트
      await AchievementService.checkAndUpdateAchievements();

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('업적을 불러오는데 실패했습니다: $e')));
      }
    }
  }

  /// 업적 화면 전용 배너 광고 생성
  void _createAchievementsBannerAd() {
    _achievementsBannerAd = AdService.createBannerAd();
    _achievementsBannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: Column(
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

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppColors.chadGradient[0]),
            Color(AppColors.chadGradient[1]),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏆 차드 업적',
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
                  label: '획득 업적',
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  value: '$_totalXP XP',
                  label: '총 경험치',
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
    final color = Color(
      Achievement(
        id: '',
        title: '',
        description: '',
        iconCode: '',
        type: AchievementType.first,
        rarity: rarity,
        targetValue: 0,
        motivationalMessage: '',
      ).getRarityColor(),
    );

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
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rarity == AchievementRarity.common
                ? '일반'
                : rarity == AchievementRarity.rare
                ? '레어'
                : rarity == AchievementRarity.epic
                ? '에픽'
                : '레전더리',
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
        color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Color(AppColors.primaryColor),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: Color(AppColors.primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: '획득한 업적 (${_unlockedAchievements.length})'),
          Tab(text: '미획득 업적 (${_lockedAchievements.length})'),
        ],
      ),
    );
  }

  Widget _buildUnlockedAchievements() {
    if (_unlockedAchievements.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: '아직 획득한 업적이 없습니다',
        message: '운동을 시작해서 첫 번째 업적을 획득해보세요!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _unlockedAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(_unlockedAchievements[index], true);
      },
    );
  }

  Widget _buildLockedAchievements() {
    if (_lockedAchievements.isEmpty) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        title: '모든 업적을 획득했습니다!',
        message: '축하합니다! 진정한 차드가 되셨습니다! 🎉',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _lockedAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(_lockedAchievements[index], false);
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
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.paddingL),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    final theme = Theme.of(context);
    final rarityColor = Color(achievement.getRarityColor());

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isUnlocked ? rarityColor : Colors.grey[300]!,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? rarityColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isUnlocked ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? rarityColor.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: isUnlocked ? rarityColor : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  isUnlocked ? achievement.iconCode : '🔒',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: AppConstants.paddingM),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isUnlocked ? null : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingS / 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS / 2,
                          ),
                        ),
                        child: Text(
                          achievement.getRarityName(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: rarityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingS / 2),

                  Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),

                  if (!isUnlocked) ...[
                    const SizedBox(height: AppConstants.paddingS),

                    // 진행도 바
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: achievement.progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rarityColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        Text(
                          '${achievement.currentValue}/${achievement.targetValue}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (isUnlocked) ...[
                    const SizedBox(height: AppConstants.paddingS),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (achievement.unlockedAt != null) ...[
                          const Spacer(),
                          Text(
                            '${achievement.unlockedAt?.month}/${achievement.unlockedAt?.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
              color: Color(0xFF1A1A1A),
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
