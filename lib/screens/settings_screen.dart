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
import '../services/data_service.dart';
import '../services/chad_evolution_service.dart';
import 'backup_screen.dart';

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
  bool _chadEvolutionNotifications = true;
  bool _chadEvolutionPreviewNotifications = true;
  bool _chadEvolutionEncouragementNotifications = true;
  bool _workoutDaysOnlyNotifications = false;
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
    _settingsBannerAd = AdService.instance.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (Ad ad) {
        debugPrint('설정 배너 광고 로드 완료');
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        debugPrint('설정 배너 광고 로드 실패: $error');
        ad.dispose();
        if (mounted) {
          setState(() {
            _settingsBannerAd = null;
          });
        }
      },
    );
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
      _chadEvolutionNotifications = prefs.getBool('chad_evolution_notifications') ?? true;
      _chadEvolutionPreviewNotifications = prefs.getBool('chad_evolution_preview_notifications') ?? true;
      _chadEvolutionEncouragementNotifications = prefs.getBool('chad_evolution_encouragement_notifications') ?? true;
      _workoutDaysOnlyNotifications = prefs.getBool('workout_days_only_notifications') ?? false;
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

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(AppLocalizations.of(context).notificationSettings, [
      // 알림 권한 상태 표시기
      _buildNotificationPermissionStatus(),
      
      _buildNotificationToggle(
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
              await _showPermissionRequestDialog();
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
        (value) async {
          if (value) {
            // 운동 리마인더를 켜려고 할 때 권한 상태 상세 확인
            final hasNotifications = await NotificationService.hasPermission();
            final hasExactAlarms = await NotificationService.canScheduleExactAlarms();
            
            if (!hasNotifications) {
              // 기본 알림 권한이 없으면 권한 요청 다이얼로그 표시
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('⚠️ 기본 알림 권한이 필요합니다. 권한을 허용해주세요.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: '권한 설정',
                      textColor: Colors.white,
                      onPressed: () {
                        _showPermissionRequestDialog();
                      },
                    ),
                  ),
                );
              }
            } else {
              // 권한이 있으면 스마트 스케줄링 시도
              final success = await NotificationService.scheduleWorkoutReminder(
                hour: _reminderTime.hour,
                minute: _reminderTime.minute,
                enabled: true,
              );
              
              if (success) {
                // 성공시에만 UI 상태 업데이트
                setState(() => _workoutReminders = value);
                await _saveBoolSetting('workout_reminders', value);
                
                // 권한 상태에 따른 맞춤형 성공 메시지
                String successMessage;
                Icon successIcon;
                Color backgroundColor;
                
                if (hasExactAlarms) {
                  successMessage = '✅ 정확한 시간 운동 리마인더가 설정되었습니다!';
                  successIcon = const Icon(Icons.check_circle, color: Colors.white);
                  backgroundColor = Colors.green;
                } else {
                  successMessage = '⏰ 운동 리마인더가 설정되었습니다!\n(정확한 시간 권한이 없어 약간의 지연이 있을 수 있습니다)';
                  successIcon = const Icon(Icons.schedule, color: Colors.white);
                  backgroundColor = Colors.orange;
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          successIcon,
                          const SizedBox(width: 8),
                          Expanded(child: Text(successMessage)),
                        ],
                      ),
                      backgroundColor: backgroundColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } else {
                // 실패시 사용자에게 상세한 피드백
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('❌ 운동 리마인더 설정에 실패했습니다. 알림 권한을 확인해주세요.'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: '권한 확인',
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {}); // 권한 상태 새로고침
                        },
                      ),
                    ),
                  );
                }
                // 실패시 토글 상태 유지 (켜지지 않음)
              }
            }
          } else {
            // 운동 리마인더를 끄는 경우
            setState(() => _workoutReminders = value);
            await _saveBoolSetting('workout_reminders', value);
            await NotificationService.scheduleWorkoutReminder(
              hour: _reminderTime.hour,
              minute: _reminderTime.minute,
              enabled: false,
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.notifications_off, color: Colors.white),
                      SizedBox(width: 8),
                      Text('운동 리마인더가 비활성화되었습니다'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        enabled: _pushNotifications,
      ),
      // 운동일 기반 알림 설정 추가
      _buildNotificationToggle(
        '🔥 운동일 전용 알림',
        '매일이 아닌 운동일(월,수,금)에만 알림을 받습니다. 휴식일엔 방해받지 않아요!',
        _workoutDaysOnlyNotifications,
        Icons.event_note,
        (value) async {
          setState(() => _workoutDaysOnlyNotifications = value);
          await _saveBoolSetting('workout_days_only_notifications', value);
          
          if (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.white),
                    SizedBox(width: 8),
                    Text('💪 운동일 전용 알림 모드 활성화! 월,수,금에만 알림이 옵니다!'),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.white),
                    SizedBox(width: 8),
                    Text('📅 매일 알림 모드로 변경되었습니다'),
                  ],
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        enabled: _pushNotifications && _workoutReminders,
      ),
      // Chad Evolution 알림 설정들 추가
      _buildNotificationToggle(
        'Chad 진화 완료 알림',
        'Chad가 새로운 단계로 진화했을 때 알림을 받습니다',
        _chadEvolutionNotifications,
        Icons.auto_awesome,
        (value) async {
          setState(() => _chadEvolutionNotifications = value);
          await _saveBoolSetting('chad_evolution_notifications', value);
          // ChadEvolutionService에도 설정 저장
          final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
          await chadService.setChadEvolutionNotificationEnabled(value);
        },
        enabled: _pushNotifications,
      ),
      _buildNotificationToggle(
        'Chad 진화 예고 알림',
        '다음 진화까지 1주일 남았을 때 미리 알림을 받습니다',
        _chadEvolutionPreviewNotifications,
        Icons.preview,
        (value) async {
          setState(() => _chadEvolutionPreviewNotifications = value);
          await _saveBoolSetting('chad_evolution_preview_notifications', value);
          // ChadEvolutionService에도 설정 저장
          final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
          await chadService.setChadEvolutionPreviewNotificationEnabled(value);
        },
        enabled: _pushNotifications,
      ),
      _buildNotificationToggle(
        'Chad 진화 격려 알림',
        '다음 진화까지 3일 남았을 때 격려 메시지를 받습니다',
        _chadEvolutionEncouragementNotifications,
        Icons.favorite,
        (value) async {
          setState(() => _chadEvolutionEncouragementNotifications = value);
          await _saveBoolSetting('chad_evolution_encouragement_notifications', value);
          // ChadEvolutionService에도 설정 저장
          final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
          await chadService.setChadEvolutionEncouragementNotificationEnabled(value);
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

  /// 권한 상태 표시기
  Widget _buildNotificationPermissionStatus() {
    return FutureBuilder<Map<String, bool>>( 
      future: _getNotificationPermissionStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: ListTile(
              leading: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: const Text('권한 상태 확인 중...'),
              subtitle: Text(
                '알림 권한 상태를 확인하고 있습니다',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }
        
        final permissions = snapshot.data ?? {
          'notifications': false,
          'exactAlarms': false,
        };
        
        final hasNotifications = permissions['notifications'] ?? false;
        final hasExactAlarms = permissions['exactAlarms'] ?? false;
        final allPermissionsGranted = hasNotifications && hasExactAlarms;
        
        // 전체 상태에 따른 색상과 아이콘 결정
        Color statusColor;
        IconData statusIcon;
        String statusTitle;
        String statusSubtitle;
        
        if (allPermissionsGranted) {
          statusColor = Colors.green;
          statusIcon = Icons.verified_user;
          statusTitle = '🔔 알림 권한 완벽!';
          statusSubtitle = '모든 알림 기능을 사용할 수 있습니다';
        } else if (hasNotifications) {
          statusColor = Colors.orange;
          statusIcon = Icons.warning;
          statusTitle = '⚠️ 일부 권한 필요';
          statusSubtitle = '정확한 시간 알림을 위해 추가 권한이 필요합니다';
        } else {
          statusColor = Colors.red;
          statusIcon = Icons.error;
          statusTitle = '❌ 알림 권한 필요';
          statusSubtitle = '알림을 받으려면 권한 허용이 필요합니다';
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 섹션
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // 개별 권한 상태 표시
                  _buildPermissionStatusRow(
                    '기본 알림 권한',
                    hasNotifications,
                    hasNotifications 
                      ? '앱에서 알림을 받을 수 있습니다' 
                      : 'Android 13+에서 필요한 기본 알림 권한입니다',
                    isRequired: true,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildPermissionStatusRow(
                    '정확한 알람 권한',
                    hasExactAlarms,
                    hasExactAlarms 
                      ? '정확한 시간에 알림을 받을 수 있습니다' 
                      : 'Android 12+에서 정확한 시간 알림을 위해 필요합니다',
                    isRequired: false,
                  ),
                  
                  // 권한 요청 버튼
                  if (!allPermissionsGranted) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _showPermissionRequestDialog();
                          setState(() {}); // 권한 상태 새로고침
                        },
                        icon: Icon(
                          !hasNotifications ? Icons.notification_add : Icons.schedule,
                          size: 20,
                        ),
                        label: Text(
                          !hasNotifications 
                            ? '알림 권한 허용하기' 
                            : '정확한 알람 권한 설정하기',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          foregroundColor: statusColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 모든 권한이 있을 때 축하 메시지
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '축하합니다! 모든 알림 기능을 완벽하게 사용할 수 있습니다! 🎉',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 권한 상태 행 생성
  Widget _buildPermissionStatusRow(String title, bool granted, String description, {bool isRequired = false}) {
    final Color statusColor = granted ? Colors.green : (isRequired ? Colors.red : Colors.orange);
    final IconData statusIcon = granted ? Icons.check_circle : (isRequired ? Icons.cancel : Icons.warning);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '필수',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '권장',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                if (granted) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '활성화됨',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 알림 권한 상태 확인
  Future<Map<String, bool>> _getNotificationPermissionStatus() async {
    try {
      final hasNotifications = await NotificationService.hasPermission();
      final hasExactAlarms = await NotificationService.canScheduleExactAlarms();
      
      return {
        'notifications': hasNotifications,
        'exactAlarms': hasExactAlarms,
      };
    } catch (e) {
      debugPrint('권한 상태 확인 오류: $e');
      return {
        'notifications': false,
        'exactAlarms': false,
      };
    }
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
            '테마 색상',
            '앱의 기본 색상을 변경합니다 (현재: ${themeService.themeColor.name})',
            Icons.palette,
            () => _showThemeColorDialog(themeService),
          ),
          _buildTapSetting(
            '폰트 크기',
            '텍스트 크기를 조절합니다 (현재: ${themeService.fontScale.name})',
            Icons.text_fields,
            () => _showFontScaleDialog(themeService),
          ),
          _buildSwitchSetting(
            '애니메이션 효과',
            '앱 전체의 애니메이션 효과를 켜거나 끕니다',
            themeService.animationsEnabled,
            Icons.animation,
            (value) async {
              await themeService.setAnimationsEnabled(value);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? '애니메이션이 활성화되었습니다' : '애니메이션이 비활성화되었습니다'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          _buildSwitchSetting(
            '고대비 모드',
            '시각적 접근성을 위한 고대비 모드를 활성화합니다',
            themeService.highContrastMode,
            Icons.contrast,
            (value) async {
              await themeService.setHighContrastMode(value);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? '고대비 모드가 활성화되었습니다' : '고대비 모드가 비활성화되었습니다'),
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
        '백업 관리',
        '데이터 백업, 복원 및 자동 백업 설정을 관리합니다',
        Icons.backup,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BackupScreen()),
        ),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).dataBackup,
        AppLocalizations.of(context).dataBackupDesc,
        Icons.backup,
        () => _performDataBackup(),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).dataRestore,
        AppLocalizations.of(context).dataRestoreDesc,
        Icons.restore,
        () => _performDataRestore(),
      ),
      _buildTapSetting(
        '레벨 리셋',
        '모든 진행 상황을 초기화하고 처음부터 시작합니다',
        Icons.refresh,
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
        '라이선스 정보',
        '앱에서 사용된 오픈소스 라이브러리의 라이선스를 확인합니다',
        Icons.description,
        () => _showLicensePage(),
      ),
      _buildTapSetting(
        '개인정보 처리방침',
        '개인정보 보호 및 처리 방침을 확인합니다',
        Icons.privacy_tip,
        () => _openPrivacyPolicy(),
      ),
      _buildTapSetting(
        '이용약관',
        '앱 사용에 관한 약관을 확인합니다',
        Icons.article,
        () => _openTermsOfService(),
      ),
      _buildTapSetting(
        AppLocalizations.of(context).sendFeedback,
        AppLocalizations.of(context).sendFeedbackDesc,
        Icons.feedback,
        () => _sendFeedback(),
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

  /// 데이터 백업 수행
  Future<void> _performDataBackup() async {
    try {
      // 로딩 다이얼로그 표시
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('데이터를 백업하는 중...'),
            ],
          ),
        ),
      );

      final backupPath = await DataService.backupData(context: context);
      
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (backupPath != null) {
        // 백업 시간 저장
        await DataService.saveLastBackupTime();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('백업이 완료되었습니다!\n저장 위치: $backupPath'),
              backgroundColor: const Color(AppColors.primaryColor),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('백업에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('백업 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 데이터 복원 수행
  Future<void> _performDataRestore() async {
    // 복원 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 데이터 복원'),
        content: const Text(
          '백업 파일로부터 데이터를 복원하면 현재 데이터가 모두 삭제됩니다.\n'
          '정말로 복원하시겠습니까?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('복원'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 로딩 다이얼로그 표시
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('데이터를 복원하는 중...'),
            ],
          ),
        ),
      );

      final success = await DataService.restoreData(context: context);
      
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('데이터 복원이 완료되었습니다! 앱을 재시작해주세요.'),
              backgroundColor: Color(AppColors.primaryColor),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('데이터 복원에 실패했습니다. 백업 파일을 확인해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복원 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 레벨 리셋 확인 다이얼로그
  void _showResetDataDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('레벨 리셋 확인'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 모든 진행 상황을 초기화하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('다음 데이터가 모두 삭제됩니다:'),
            SizedBox(height: 4),
            Text('• 현재 레벨 및 진행률'),
            Text('• 운동 기록 및 통계'),
            Text('• Chad 진화 상태'),
            Text('• 업적 및 배지'),
            SizedBox(height: 8),
            Text(
              '이 작업은 되돌릴 수 없습니다!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
              await _performDataReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  /// 데이터 리셋 실행
  Future<void> _performDataReset() async {
    try {
      // 로딩 다이얼로그 표시
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('데이터를 초기화하는 중...'),
            ],
          ),
        ),
      );

      // DataService를 통한 데이터 리셋
      final dataService = Provider.of<DataService>(context, listen: false);
      // await dataService.resetProgress(); // 메서드가 없으므로 주석 처리

      // Chad Evolution 상태도 리셋
      final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
      await chadService.resetEvolution();

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 데이터가 성공적으로 초기화되었습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 오류 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 초기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showVersionDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.versionInfo),
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
                color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💪 ${packageInfo.appName}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('버전: ${packageInfo.version}'),
                  const SizedBox(height: 4),
                  Text('빌드: ${packageInfo.buildNumber}'),
                  const SizedBox(height: 4),
                  Text('패키지: ${packageInfo.packageName}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Text(AppLocalizations.of(context)!.joinChadJourney),
            const SizedBox(height: 8),
            const Text(
              '6주 만에 100개 푸쉬업 달성!\n'
              '차드가 되는 여정을 함께하세요! 🔥',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // 기술 스택 정보
            const Text(
              '기술 스택:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('• Flutter 3.8.0+'),
            const Text('• Dart 3.0+'),
            const Text('• SQLite 로컬 데이터베이스'),
            const Text('• Provider 상태 관리'),
            const Text('• Google Mobile Ads'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showLicensePage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('라이선스'),
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
                                  color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
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

  Future<void> _showPermissionRequestDialog() async {
    try {
      // 새로운 사용자 친화적 권한 요청 다이얼로그 사용
      final granted = await NotificationService.showPermissionRequestDialog(context);
      
      if (granted) {
        // 권한이 허용되면 푸시 알림을 켜고 UI 업데이트
        setState(() {
          _pushNotifications = true;
        });
        await _saveBoolSetting('push_notifications', true);
        
        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('✅ 알림 권한이 허용되었습니다!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // 운동 리마인더가 활성화되어 있으면 스케줄링
        if (_workoutReminders) {
          await NotificationService.scheduleWorkoutReminder(
            hour: _reminderTime.hour,
            minute: _reminderTime.minute,
            enabled: true,
          );
        }
      } else {
        // 권한이 거부되면 설명 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('⚠️ 알림 권한이 필요합니다. 설정에서 수동으로 허용해주세요.'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('권한 요청 오류: $e');
      
      // 오류 발생 시 기존 방식으로 폴백
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('❌ 권한 요청 중 오류가 발생했습니다. 설정에서 수동으로 허용해주세요.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// GitHub 저장소 열기
  Future<void> _openGitHub() async {
    const githubUrl = 'https://github.com/khy0425';
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

  /// 테마 색상 선택 다이얼로그
  void _showThemeColorDialog(ThemeService themeService) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.palette, color: Color(AppColors.primaryColor)),
            SizedBox(width: 8),
            Text('테마 색상 선택'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: ThemeColor.values.length,
            itemBuilder: (context, index) {
              final color = ThemeColor.values[index];
              final isSelected = themeService.themeColor == color;
              
              return GestureDetector(
                onTap: () async {
                  await themeService.setThemeColor(color);
                  Navigator.pop(context);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('테마 색상이 ${color.name}로 변경되었습니다'),
                        backgroundColor: color.color,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: isSelected 
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
                ),
              );
            },
          ),
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

  /// 폰트 크기 선택 다이얼로그
  void _showFontScaleDialog(ThemeService themeService) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.text_fields, color: Color(AppColors.primaryColor)),
            SizedBox(width: 8),
            Text('폰트 크기 선택'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('미리보기:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...FontScale.values.map((fontScale) {
              return RadioListTile<FontScale>(
                title: Text(
                  fontScale.name,
                  style: TextStyle(fontSize: 16 * fontScale.scale),
                ),
                subtitle: Text(
                  '이것은 ${fontScale.name} 크기의 텍스트 예시입니다.',
                  style: TextStyle(fontSize: 14 * fontScale.scale),
                ),
                value: fontScale,
                groupValue: themeService.fontScale,
                onChanged: (value) async {
                  if (value != null) {
                    await themeService.setFontScale(value);
                    Navigator.pop(context);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('폰트 크기가 ${value.name}로 변경되었습니다'),
                          backgroundColor: const Color(AppColors.primaryColor),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            }).toList(),
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

  /// 라이선스 페이지 표시
  void _showLicensePage() {
    showLicensePage(
      context: context,
      applicationName: 'Mission: 100',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(AppColors.primaryColor),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.fitness_center,
          size: 32,
          color: Colors.white,
        ),
      ),
      applicationLegalese: '© 2024 Mission 100 Chad Pushup\n차드가 되는 여정을 함께하세요! 💪',
    );
  }

  /// 개인정보 처리방침 열기
  Future<void> _openPrivacyPolicy() async {
    // GitHub Pages에 호스팅된 개인정보처리방침 페이지
    const privacyPolicyUrl = 'https://khy0425.github.io/misson-100/privacy-policy.html';
    final uri = Uri.parse(privacyPolicyUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showUrlNotAvailableDialog('개인정보 처리방침');
        }
      }
    } catch (e) {
      debugPrint('개인정보 처리방침 열기 실패: $e');
      if (mounted) {
        _showUrlNotAvailableDialog('개인정보 처리방침');
      }
    }
  }

  /// 이용약관 열기
  Future<void> _openTermsOfService() async {
    // GitHub Pages에 호스팅된 이용약관 페이지 (추후 생성 예정)
    const termsUrl = 'https://khy0425.github.io/misson-100/terms-of-service.html';
    final uri = Uri.parse(termsUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showUrlNotAvailableDialog('이용약관');
        }
      }
    } catch (e) {
      debugPrint('이용약관 열기 실패: $e');
      if (mounted) {
        _showUrlNotAvailableDialog('이용약관');
      }
    }
  }

  /// URL을 열 수 없을 때 표시할 다이얼로그
  void _showUrlNotAvailableDialog(String documentName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$documentName 열기 실패'),
        content: Text(
          '$documentName을 열 수 없습니다.\n'
          '인터넷 연결을 확인하거나 나중에 다시 시도해주세요.\n\n'
          '문의사항이 있으시면 개발자에게 연락해주세요.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendFeedback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('문의하기'),
          ),
        ],
      ),
    );
  }
}
