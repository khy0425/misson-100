import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
// import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 설정 화면 전용 배너 광고
  BannerAd? _settingsBannerAd;

  // 설정 값들
  bool _achievementNotifications = true;
  bool _workoutReminders = true;
  bool _isDarkMode = true;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadSettings();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _settingsBannerAd?.dispose();
    super.dispose();
  }

  /// 설정 화면 전용 배너 광고 생성
  void _loadBannerAd() {
    _settingsBannerAd = AdService.createBannerAd();
    _settingsBannerAd?.load();
  }

  /// 설정 값 로드
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _achievementNotifications =
          prefs.getBool('achievement_notifications') ?? true;
      _workoutReminders = prefs.getBool('workout_reminders') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? true;
    });
  }

  Future<void> _initializeNotifications() async {
    // 알림 시스템 초기화
    // await NotificationService.initialize();
    // await NotificationService.createNotificationChannels();

    // 권한 요청
    // final granted = await NotificationService.requestPermissions();
    // if (!granted) {
    //   debugPrint('⚠️ 알림 권한이 거부되었습니다');
    // }
  }

  /// 설정 값 저장
  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // 알림 관련 설정 처리
    if (key == 'workout_reminders') {
      if (value) {
        // 기본 시간 (저녁 7시)에 운동 리마인더 설정
        // await NotificationService.scheduleWorkoutReminder(
        //   hour: 19,
        //   minute: 0,
        //   enabled: true,
        // );
      } else {
        // await NotificationService.cancelWorkoutReminder();
      }
    }

    debugPrint('설정 저장: $key = $value');
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
                // 헤더
                SliverToBoxAdapter(child: _buildHeader()),

                // 설정 섹션들
                SliverToBoxAdapter(child: _buildNotificationSettings()),
                SliverToBoxAdapter(child: _buildAppearanceSettings()),
                SliverToBoxAdapter(child: _buildDataSettings()),
                SliverToBoxAdapter(child: _buildAboutSettings()),

                // 하단 여백
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // 하단 배너 광고
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

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
      child: Row(
        children: [
          const Icon(Icons.settings, color: Colors.white, size: 32),
          const SizedBox(width: AppConstants.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚙️ 차드 설정',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '당신의 차드 여정을 커스터마이즈하세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection('🔔 알림 설정', [
      _buildSwitchSetting(
        '푸시 알림',
        '앱 알림을 받을지 설정합니다',
        _pushNotifications,
        Icons.notifications,
        (value) {
          setState(() => _pushNotifications = value);
          _saveBoolSetting('push_notifications', value);
        },
      ),
      _buildNotificationToggle(
        '업적 알림',
        '새로운 업적 달성 시 알림을 받습니다',
        _achievementNotifications,
        Icons.emoji_events,
        (value) {
          setState(() => _achievementNotifications = value);
          _saveBoolSetting('achievement_notifications', value);
        },
        enabled: _pushNotifications,
      ),
      _buildNotificationToggle(
        '운동 리마인더',
        '매일 운동 시간을 알려줍니다',
        _workoutReminders,
        Icons.schedule,
        (value) {
          setState(() => _workoutReminders = value);
          _saveBoolSetting('workout_reminders', value);
        },
        enabled: _pushNotifications,
      ),
    ]);
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsSection('🎨 외형 설정', [
      _buildSwitchSetting(
        '다크 모드',
        '어두운 테마를 사용합니다',
        _isDarkMode,
        Icons.dark_mode,
        (value) {
          setState(() => _isDarkMode = value);
          _saveBoolSetting('dark_mode', value);
          _showComingSoonDialog('테마 변경 기능이 곧 추가됩니다!');
        },
      ),
    ]);
  }

  Widget _buildDataSettings() {
    return _buildSettingsSection('💾 데이터 관리', [
      _buildTapSetting(
        '데이터 백업',
        '운동 기록과 업적을 백업합니다',
        Icons.backup,
        () => _showComingSoonDialog('데이터 백업 기능이 곧 추가됩니다!'),
      ),
      _buildTapSetting(
        '데이터 복원',
        '백업된 데이터를 복원합니다',
        Icons.restore,
        () => _showComingSoonDialog('데이터 복원 기능이 곧 추가됩니다!'),
      ),
      _buildTapSetting(
        '데이터 초기화',
        '모든 데이터를 삭제합니다',
        Icons.delete_forever,
        () => _showResetDataDialog(),
        isDestructive: true,
      ),
    ]);
  }

  Widget _buildAboutSettings() {
    return _buildSettingsSection('ℹ️ 앱 정보', [
      _buildTapSetting(
        '버전 정보',
        'Mission: 100 v1.0.0',
        Icons.info,
        () => _showVersionDialog(),
      ),
      _buildTapSetting(
        '개발자 정보',
        '차드가 되는 여정을 함께하세요',
        Icons.code,
        () => _showDeveloperDialog(),
      ),
      _buildTapSetting(
        '피드백 보내기',
        '의견을 공유해주세요',
        Icons.feedback,
        () => _showComingSoonDialog('피드백 기능이 곧 추가됩니다!'),
      ),
    ]);
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? Color(AppColors.primaryColor) : Colors.grey,
      ),
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: Color(AppColors.primaryColor),
      ),
      enabled: enabled,
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? Color(AppColors.primaryColor) : Colors.grey,
      ),
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: Color(AppColors.primaryColor),
      ),
      enabled: enabled,
    );
  }

  Widget _buildTapSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Color(AppColors.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 운동 기록과 업적이 삭제됩니다.\n정말로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog('데이터 초기화 기능이 곧 추가됩니다!');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('버전 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mission: 100 💪'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            Text('빌드: 2024.01.01'),
            SizedBox(height: 16),
            Text('차드가 되는 여정을 응원합니다!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개발자 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💪 Mission: 100'),
            SizedBox(height: 8),
            Text('모든 사람이 차드가 될 수 있다는'),
            Text('믿음으로 만들어진 앱입니다.'),
            SizedBox(height: 16),
            Text('당신의 차드 여정을 응원합니다! 🔥'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Coming Soon'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
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
      child: _settingsBannerAd != null
          ? AdWidget(ad: _settingsBannerAd!)
          : Container(
              height: 60,
              color: Color(0xFF1A1A1A),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '차드의 설정을 맞춤화하세요! ⚙️',
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
