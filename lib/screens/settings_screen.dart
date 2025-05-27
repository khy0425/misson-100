import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import '../services/difficulty_service.dart';
import '../services/theme_service.dart';
import '../services/locale_service.dart';
import '../services/notification_service.dart';
import '../generated/app_localizations.dart';
import '../main.dart'; // LocaleNotifier를 위해 추가

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  // 설정 화면 전용 배너 광고
  BannerAd? _settingsBannerAd;

  // 설정 값들
  bool _achievementNotifications = true;
  bool _workoutReminders = true;
  bool _pushNotifications = true;
  DifficultyLevel _currentDifficulty = DifficultyLevel.beginner;
  Locale _currentLocale = LocaleService.koreanLocale;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0); // 기본 오후 7시

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();
    _loadSettings();
    _initializeNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsBannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 앱이 다시 활성화되었을 때 (설정에서 돌아왔을 때) 권한 상태 재확인
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  /// 권한 상태 재확인
  Future<void> _checkPermissionStatus() async {
    final hasPermission = await NotificationService.hasPermission();
    if (mounted && hasPermission != _pushNotifications) {
      setState(() {
        _pushNotifications = hasPermission;
      });
      
      // 권한이 허용되었으면 설정 저장
      if (hasPermission) {
        await _saveBoolSetting('push_notifications', true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 허용되었습니다! 🎉'),
              backgroundColor: Color(AppColors.primaryColor),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// 설정 화면 전용 배너 광고 생성
  void _loadBannerAd() {
    _settingsBannerAd = AdService.createBannerAd();
    _settingsBannerAd?.load();
  }

  /// 설정 값 로드
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final difficulty = await DifficultyService.getCurrentDifficulty();
    final locale = await LocaleService.getLocale();
    
    // 저장된 리마인더 시간 로드
    final reminderTimeString = prefs.getString('reminder_time') ?? '19:00';
    final timeParts = reminderTimeString.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 19;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    
    setState(() {
      _achievementNotifications =
          prefs.getBool('achievement_notifications') ?? true;
      _workoutReminders = prefs.getBool('workout_reminders') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _currentDifficulty = difficulty;
      _currentLocale = locale;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _initializeNotifications() async {
    // 알림 시스템 초기화
    await NotificationService.initialize();
    await NotificationService.createNotificationChannels();

    // 권한 상태 확인
    final hasPermission = await NotificationService.hasPermission();
    setState(() {
      _pushNotifications = hasPermission;
    });
    
    if (!hasPermission) {
      debugPrint('⚠️ 알림 권한이 없습니다');
    }
  }

  /// 설정 값 저장
  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // 알림 관련 설정 처리
    if (key == 'workout_reminders') {
      if (value && _pushNotifications) {
        // 설정된 시간에 운동 리마인더 설정
        await NotificationService.scheduleWorkoutReminder(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
          enabled: true,
        );
      } else {
        await NotificationService.cancelWorkoutReminder();
      }
    }

    debugPrint('설정 저장: $key = $value');
  }

  /// 리마인더 시간 저장
  Future<void> _saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString('reminder_time', timeString);
    
    setState(() {
      _reminderTime = time;
    });

    // 운동 리마인더가 활성화되어 있으면 새 시간으로 재설정
    if (_workoutReminders && _pushNotifications) {
      await NotificationService.scheduleWorkoutReminder(
        hour: time.hour,
        minute: time.minute,
        enabled: true,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('리마인더 시간이 ${time.format(context)}로 변경되었습니다!'),
            backgroundColor: const Color(AppColors.primaryColor),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    debugPrint('리마인더 시간 저장: $timeString');
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
                SliverToBoxAdapter(child: _buildWorkoutSettings()),
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
      child: Row(
        children: [
          const Icon(Icons.settings, color: Colors.white, size: 32),
          const SizedBox(width: AppConstants.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).settingsTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).settingsSubtitle,
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

  Widget _buildWorkoutSettings() {
    return _buildSettingsSection(AppLocalizations.of(context).workoutSettings, [
      _buildTapSetting(
        AppLocalizations.of(context).difficultySettings,
        AppLocalizations.of(context)!.currentDifficulty(
          _currentDifficulty.displayName,
          _currentDifficulty.description,
        ),
        Icons.fitness_center,
        () => _showDifficultyDialog(),
      ),
    ]);
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(AppLocalizations.of(context).notificationSettings, [
      _buildSwitchSetting(
        AppLocalizations.of(context).pushNotifications,
        AppLocalizations.of(context).pushNotificationsDesc,
        _pushNotifications,
        Icons.notifications,
        (value) async {
          if (value) {
            // 알림을 켜려고 할 때 권한 확인
            final hasPermission = await NotificationService.hasPermission();
            if (!hasPermission) {
              // 권한이 없으면 권한 요청 다이얼로그 표시
              _showPermissionRequestDialog();
              return;
            }
          }
          
          setState(() {
            _pushNotifications = value;
          });
          await _saveBoolSetting('push_notifications', value);
          
          if (!value) {
            // 푸시 알림을 끄면 모든 알림 취소
            await NotificationService.cancelWorkoutReminder();
          } else if (_workoutReminders) {
            // 푸시 알림을 켜고 운동 리마인더가 활성화되어 있으면 재설정
            await NotificationService.scheduleWorkoutReminder(
              hour: _reminderTime.hour,
              minute: _reminderTime.minute,
              enabled: true,
            );
          }
        },
      ),
      _buildNotificationToggle(
        AppLocalizations.of(context).achievementNotifications,
        AppLocalizations.of(context).achievementNotificationsDesc,
        _achievementNotifications,
        Icons.emoji_events,
        (value) {
          setState(() => _achievementNotifications = value);
          _saveBoolSetting('achievement_notifications', value);
        },
        enabled: _pushNotifications,
      ),
      _buildNotificationToggle(
        AppLocalizations.of(context).workoutReminders,
        AppLocalizations.of(context).workoutRemindersDesc,
        _workoutReminders,
        Icons.schedule,
        (value) {
          setState(() => _workoutReminders = value);
          _saveBoolSetting('workout_reminders', value);
        },
        enabled: _pushNotifications,
      ),
      // 리마인더 시간 설정 (운동 리마인더가 켜져있을 때만 표시)
      if (_workoutReminders && _pushNotifications)
        _buildTimePickerSetting(
          AppLocalizations.of(context).reminderTime,
          AppLocalizations.of(context).reminderTimeDesc,
          _reminderTime,
          Icons.access_time,
          _showTimePicker,
        ),
    ]);
  }

  Widget _buildAppearanceSettings() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return _buildSettingsSection(AppLocalizations.of(context).appearanceSettings, [
          _buildSwitchSetting(
            AppLocalizations.of(context).darkMode,
            AppLocalizations.of(context).darkModeDesc,
            themeService.isDarkMode,
            Icons.dark_mode,
            (value) async {
              final newMode = value ? ThemeMode.dark : ThemeMode.light;
              await themeService.setThemeMode(newMode);
              
              // 성공 메시지 표시
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value 
                      ? AppLocalizations.of(context)!.darkModeEnabled 
                      : AppLocalizations.of(context)!.lightModeEnabled),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          _buildTapSetting(
            AppLocalizations.of(context).languageSettings,
            AppLocalizations.of(context)!.currentLanguage(
              LocaleService.getLocaleName(_currentLocale),
            ),
            Icons.language,
            () => _showLanguageDialog(),
          ),
        ]);
      },
    );
  }

  Widget _buildDataSettings() {
    return _buildSettingsSection(AppLocalizations.of(context).dataSettings, [
      _buildTapSetting(
        AppLocalizations.of(context).dataBackup,
        AppLocalizations.of(context).dataBackupDesc,
        Icons.backup,
        () => _showComingSoonDialog(AppLocalizations.of(context)!.dataBackupComingSoon),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).dataRestore,
        AppLocalizations.of(context).dataRestoreDesc,
        Icons.restore,
        () => _showComingSoonDialog(AppLocalizations.of(context)!.dataRestoreComingSoon),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).dataReset,
        AppLocalizations.of(context).dataResetDesc,
        Icons.delete_forever,
        () => _showResetDataDialog(),
        isDestructive: true,
      ),
    ]);
  }

  Widget _buildAboutSettings() {
    return _buildSettingsSection(AppLocalizations.of(context).aboutSettings, [
      _buildTapSetting(
        AppLocalizations.of(context).versionInfo,
        AppLocalizations.of(context).versionInfoDesc,
        Icons.info,
        () => _showVersionDialog(),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).developerInfo,
        AppLocalizations.of(context).developerInfoDesc,
        Icons.code,
        () => _showDeveloperDialog(),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).sendFeedback,
        AppLocalizations.of(context).sendFeedbackDesc,
        Icons.feedback,
        () => _showComingSoonDialog(AppLocalizations.of(context)!.feedbackComingSoon),
      ),
    ]);
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: Color(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
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
        color: enabled ? const Color(AppColors.primaryColor) : Colors.grey,
      ),
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(AppColors.primaryColor),
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
        color: enabled ? const Color(AppColors.primaryColor) : Colors.grey,
      ),
      title: Text(title, style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: enabled ? Colors.grey[600] : Colors.grey[400]),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(AppColors.primaryColor),
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
        color: isDestructive ? Colors.red : const Color(AppColors.primaryColor),
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

  Widget _buildTimePickerSetting(
    String title,
    String subtitle,
    TimeOfDay time,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(AppColors.primaryColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(AppColors.primaryColor).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            time.format(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.primaryColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dataReset),
        content: Text(AppLocalizations.of(context)!.dataResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog(AppLocalizations.of(context)!.dataResetComingSoon);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.versionInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mission: 100 💪'),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.versionAndBuild('1.0.0', '2024.01.01')),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.joinChadJourney),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(AppColors.primaryColor)),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.developerInfo),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💪 Mission: 100', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${AppLocalizations.of(context)!.appVersion}: ${packageInfo.version}'),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.builtWithFlutter),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Text(AppLocalizations.of(context)!.madeWithLove),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.supportChadJourney),
            const SizedBox(height: 16),
            
            // 개발자 연락처
            Text(AppLocalizations.of(context)!.developerContact,
              style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // GitHub 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGitHub(),
                icon: const Icon(Icons.code, size: 20),
                label: Text(AppLocalizations.of(context)!.githubRepository),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // 피드백 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendFeedback(),
                icon: const Icon(Icons.email, size: 20),
                label: Text(AppLocalizations.of(context)!.sendFeedback),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryColor),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🌍 ${AppLocalizations.of(context)!.languageSettings}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.selectLanguage),
            const SizedBox(height: 16),
            ListTile(
              leading: const Text('🇰🇷', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.korean),
              subtitle: Text(AppLocalizations.of(context)!.koreanLanguage),
              trailing: _currentLocale.languageCode == 'ko' 
                ? const Icon(Icons.check, color: Color(AppColors.primaryColor))
                : null,
              onTap: () => _changeLanguage(LocaleService.koreanLocale),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.englishLanguage),
              subtitle: Text(AppLocalizations.of(context)!.english),
              trailing: _currentLocale.languageCode == 'en' 
                ? const Icon(Icons.check, color: Color(AppColors.primaryColor))
                : null,
              onTap: () => _changeLanguage(LocaleService.englishLocale),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(Locale newLocale) async {
    if (_currentLocale.languageCode == newLocale.languageCode) {
      Navigator.pop(context);
      return;
    }

    // Provider를 통해 언어 변경 (실시간 반영)
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    await localeNotifier.setLocale(newLocale);
    
    setState(() {
      _currentLocale = newLocale;
    });

    Navigator.pop(context);

    // 언어 변경 완료 메시지 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.languageChanged(LocaleService.getLocaleName(newLocale)),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(AppColors.primaryColor),
        ),
      );
    }
  }

  /// 시간 선택 다이얼로그 표시
  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteTextColor: const Color(AppColors.primaryColor),
              dialHandColor: const Color(AppColors.primaryColor),
              dialTextColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      await _saveReminderTime(picked);
    }
  }

  void _showPermissionRequestDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.notificationPermissionRequired),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.notificationPermissionMessage),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.notificationPermissionFeatures),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.notificationPermissionRequest),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService.openNotificationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.goToSettings),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.comingSoon),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  /// GitHub 저장소 열기
  Future<void> _openGitHub() async {
    const githubUrl = 'https://github.com/your-username/mission100_chad_pushup'; // 실제 GitHub URL로 변경
    final uri = Uri.parse(githubUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cannotOpenGithub),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('GitHub 열기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotOpenGithub),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 피드백 이메일 보내기
  Future<void> _sendFeedback() async {
    const email = 'osu355@gmail.com';
    const subject = 'Mission 100 Chad Pushup 피드백';
    const body = '안녕하세요! Mission 100 Chad Pushup 앱에 대한 피드백을 보내드립니다.\n\n';
    
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cannotOpenEmail),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('이메일 열기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotOpenEmail),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDifficultyDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.difficultySettingsTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DifficultyLevel.values.map((difficulty) {
            return RadioListTile<DifficultyLevel>(
              title: Text(difficulty.displayName),
              subtitle: Text(difficulty.description),
              value: difficulty,
              groupValue: _currentDifficulty,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _currentDifficulty = value;
                  });
                  await DifficultyService.setDifficulty(value);
                  Navigator.pop(context);
                  
                  // 난이도 변경 완료 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.difficultyChanged(value.displayName)),
                      backgroundColor: const Color(AppColors.primaryColor),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
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
              color: const Color(0xFF1A1A1A),
              child: Center(
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
                      AppLocalizations.of(context)!.settingsBannerText,
                      style: const TextStyle(
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
