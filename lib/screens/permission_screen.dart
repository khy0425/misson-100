import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';
import 'main_navigation_screen.dart';
import 'initial_test_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isRequestingPermission = false;
  bool _hasRequestedBefore = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPermissionStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _checkPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasRequestedBefore = prefs.getBool('has_requested_notification_permission') ?? false;
    
    // 이미 권한이 허용되어 있는지 확인
    final hasPermission = await NotificationService.hasPermission();
    if (hasPermission) {
      _navigateToMainScreen();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPermissionIcon(),
                        const SizedBox(height: 32),
                        _buildTitle(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 40),
                        _buildPermissionList(),
                      ],
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.primaryColor),
            const Color(AppColors.primaryColor).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.notifications_active,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    final theme = Theme.of(context);
    
    return Text(
      '🔔 알림 권한이 필요해요',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(AppColors.primaryColor),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    final theme = Theme.of(context);
    
    return Text(
      _hasRequestedBefore 
        ? '차드가 되는 여정을 위해\n알림 권한이 꼭 필요합니다!\n\n설정에서 알림을 허용해주세요 💪'
        : '차드가 되는 여정을 함께하기 위해\n알림 권한이 필요합니다!\n\n운동 리마인더와 업적 알림을 통해\n꾸준한 운동을 도와드릴게요 🔥',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPermissionList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Color(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: const Color(AppColors.primaryColor).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildPermissionItem(
            '💪 운동 리마인더',
            '매일 설정한 시간에 운동을 알려드려요',
            Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            '🏆 업적 알림',
            '새로운 업적 달성 시 축하 메시지를 보내드려요',
            Icons.emoji_events,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            '🔥 동기부여 메시지',
            '차드가 되는 여정을 응원하는 메시지를 보내드려요',
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, String description, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(AppColors.primaryColor),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isRequestingPermission ? null : _requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              elevation: 4,
            ),
            child: _isRequestingPermission
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _hasRequestedBefore ? '설정에서 허용하기' : '알림 허용하기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isRequestingPermission ? null : _skipPermission,
          child: Text(
            '나중에 설정하기',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_permission_requested', true);

      bool granted;
      
      if (_hasRequestedBefore) {
        // 이미 한 번 요청했다면 설정 화면으로 이동
        granted = await NotificationService.openNotificationSettings();
        
        // 설정 화면에서 돌아온 후 권한 상태 재확인
        await Future.delayed(const Duration(milliseconds: 500));
        granted = await NotificationService.hasPermission();
      } else {
        // 처음 요청하는 경우
        granted = await NotificationService.requestPermissions();
        
        // 권한 요청 후 상태 저장
        await prefs.setBool('has_requested_notification_permission', true);
      }

      if (granted) {
        // 권한이 허용되면 알림 채널 생성 및 기본 설정
        await NotificationService.createNotificationChannels();
        
        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notificationPermissionGrantedMessage),
              backgroundColor: const Color(AppColors.primaryColor),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMainScreen();
      } else {
        setState(() {
          _hasRequestedBefore = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notificationPermissionDeniedMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('권한 요청 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notificationPermissionErrorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  Future<void> _skipPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_screen_shown', true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notificationPermissionLaterMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    _navigateToMainScreen();
  }

  void _navigateToMainScreen() async {
    if (mounted) {
      // 처음 사용자인지 확인
      final prefs = await SharedPreferences.getInstance();
      final hasSelectedDifficulty = prefs.getBool('has_selected_difficulty') ?? false;
      
      if (hasSelectedDifficulty) {
        // 이미 난이도를 선택한 사용자는 바로 메인 화면으로
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      } else {
        // 처음 사용자는 난이도 선택 화면으로
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const InitialTestScreen(),
          ),
        );
      }
    }
  }
} 