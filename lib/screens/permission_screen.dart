import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
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
    _hasRequestedBefore = prefs.getBool('has_requested_permissions') ?? false;
    
    // 이미 권한이 허용되어 있는지 확인
    final hasNotificationPermission = await NotificationService.hasPermission();
    final hasStoragePermission = await PermissionService.getStoragePermissionStatus();
    
    if (hasNotificationPermission && hasStoragePermission == PermissionStatus.granted) {
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
        Icons.security,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    final theme = Theme.of(context);
    
    return Text(
      AppLocalizations.of(context)!.permissionsRequired,
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
        ? AppLocalizations.of(context)!.permissionAlreadyRequested
        : AppLocalizations.of(context)!.permissionsDescription,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알림 권한 섹션
          _buildPermissionSection(
            AppLocalizations.of(context)!.notificationPermissionTitle,
            AppLocalizations.of(context)!.notificationPermissionDesc,
            Icons.notifications_active,
            [
              AppLocalizations.of(context)!.notificationBenefit1,
              AppLocalizations.of(context)!.notificationBenefit2,
              AppLocalizations.of(context)!.notificationBenefit3,
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 저장소 권한 섹션
          _buildPermissionSection(
            AppLocalizations.of(context)!.storagePermissionTitle,
            AppLocalizations.of(context)!.storagePermissionDesc,
            Icons.folder,
            [
              AppLocalizations.of(context)!.storageBenefit1,
              AppLocalizations.of(context)!.storageBenefit2,
              AppLocalizations.of(context)!.storageBenefit3,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection(
    String title,
    String description,
    IconData icon,
    List<String> benefits,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        const SizedBox(height: 12),
        ...benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            benefit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        )),
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
            onPressed: _isRequestingPermission ? null : _requestPermissions,
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
                    _hasRequestedBefore 
                      ? AppLocalizations.of(context)!.goToSettings 
                      : AppLocalizations.of(context)!.allowPermissions,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isRequestingPermission ? null : _skipPermissions,
          child: Text(
            AppLocalizations.of(context)!.skipPermissions,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permission_screen_shown', true);

      bool notificationGranted = false;
      bool storageGranted = false;
      
      if (_hasRequestedBefore) {
        // 이미 한 번 요청했다면 설정 화면으로 이동
        debugPrint('🔄 설정 화면으로 이동...');
        
        try {
          await NotificationService.openNotificationSettings();
        } catch (e) {
          debugPrint('⚠️ 설정 화면 열기 실패: $e');
        }
        
        // 설정 화면에서 돌아온 후 충분한 시간 대기 후 권한 상태 재확인
        debugPrint('⏳ 설정 화면에서 돌아온 후 권한 상태 재확인 대기...');
        await Future.delayed(const Duration(seconds: 3));
        
        try {
          notificationGranted = await NotificationService.hasPermission();
          debugPrint('📱 알림 권한 재확인 결과: $notificationGranted');
        } catch (e) {
          debugPrint('⚠️ 알림 권한 재확인 실패: $e');
          notificationGranted = false;
        }
        
        try {
          final storageStatus = await PermissionService.getStoragePermissionStatus();
          storageGranted = storageStatus == PermissionStatus.granted;
          debugPrint('💾 저장소 권한 재확인 결과: $storageGranted');
        } catch (e) {
          debugPrint('⚠️ 저장소 권한 재확인 실패: $e');
          storageGranted = false;
        }
      } else {
        // 처음 요청하는 경우
        debugPrint('🔔 처음 권한 요청 시작...');
        
        // 1. 알림 권한 요청 (타임아웃 적용)
        try {
          notificationGranted = await NotificationService.requestPermissions()
              .timeout(const Duration(seconds: 30));
          debugPrint('📱 알림 권한 요청 결과: $notificationGranted');
        } catch (e) {
          debugPrint('⚠️ 알림 권한 요청 실패 또는 타임아웃: $e');
          notificationGranted = false;
        }
        
        // 2. 저장소 권한 요청 (타임아웃 적용)
        try {
          final storageStatus = await PermissionService.requestStoragePermission()
              .timeout(const Duration(seconds: 30));
          storageGranted = storageStatus == PermissionStatus.granted;
          debugPrint('💾 저장소 권한 요청 결과: $storageGranted');
        } catch (e) {
          debugPrint('⚠️ 저장소 권한 요청 실패 또는 타임아웃: $e');
          storageGranted = false;
        }
        
        // 권한 요청 후 상태 저장
        try {
          await prefs.setBool('has_requested_permissions', true);
        } catch (e) {
          debugPrint('⚠️ SharedPreferences 저장 실패: $e');
        }
      }

      if (notificationGranted && storageGranted) {
        debugPrint('✅ 모든 권한 허용됨');
        
        // 모든 권한이 허용되면 알림 채널 생성 및 기본 설정
        try {
          await NotificationService.createNotificationChannels();
        } catch (e) {
          debugPrint('⚠️ 알림 채널 생성 실패: $e');
        }
        
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
        debugPrint('⚠️ 일부 권한 거부됨 - 알림: $notificationGranted, 저장소: $storageGranted');
        
        setState(() {
          _hasRequestedBefore = true;
        });
        
        String message = '';
        if (!notificationGranted && !storageGranted) {
          message = '알림 및 저장소 권한이 필요합니다. 설정에서 허용해주세요.';
        } else if (!notificationGranted) {
          message = AppLocalizations.of(context)!.notificationPermissionDeniedMessage;
        } else {
          message = '저장소 권한이 필요합니다. 설정에서 허용해주세요.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ 권한 요청 중 전체 오류: $e');
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

  Future<void> _skipPermissions() async {
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