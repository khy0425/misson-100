import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/permission_screen.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/permission_service.dart';
// MemoryManager import 제거됨

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 고정 (세로)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AdMob 초기화
  await AdService.initialize();

  // 알림 서비스 초기화
  await NotificationService.initialize();
  await NotificationService.createNotificationChannels();

  // 테마 서비스 초기화
  final themeService = ThemeService();
  await themeService.initialize();

  // 로케일 서비스 초기화
  final localeNotifier = LocaleNotifier();
  await localeNotifier.loadLocale();

  // 메모리 관리자 초기화
  // // MemoryManager.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localeNotifier),
      ],
      child: const MissionApp(),
    ),
  );
}

// 로케일 변경을 위한 Notifier
class LocaleNotifier extends ChangeNotifier {
  Locale _locale = LocaleService.koreanLocale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    await LocaleService.setLocale(newLocale);
    _locale = newLocale;
    notifyListeners();
  }

  Future<void> loadLocale() async {
    _locale = await LocaleService.getLocale();
    notifyListeners();
  }
}

class MissionApp extends StatelessWidget {
  const MissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LocaleNotifier>(
      builder: (context, themeService, localeService, child) {
        return MaterialApp(
          title: 'Mission: 100',
          debugShowCheckedModeBanner: false,

          // 테마 설정
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,

          // 다국어 설정
          locale: localeService.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleService.supportedLocales,

          // 홈 화면
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // 2초 대기 후 권한 확인
    await Future<void>.delayed(const Duration(seconds: 1));

    if (mounted) {
      // 알림 권한과 저장소 권한 모두 확인
      final hasNotificationPermission = await NotificationService.hasPermission();
      
      // 저장소 권한 확인 (PermissionService 사용)
      bool hasStoragePermission = false;
      try {
        final storageStatus = await PermissionService.getStoragePermissionStatus();
        hasStoragePermission = storageStatus == PermissionStatus.granted;
      } catch (e) {
        debugPrint('저장소 권한 확인 오류: $e');
        hasStoragePermission = false;
      }
      
      // 모든 권한이 허용되었는지 확인
      final hasAllPermissions = hasNotificationPermission && hasStoragePermission;
      
      // 권한 상태에 따라 화면 이동
      final targetScreen = hasAllPermissions 
          ? const MainNavigationScreen()
          : const PermissionScreen();
      
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => targetScreen),
        );
      }
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
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고/아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        AppColors.primaryColor,
                      ).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // 앱 이름
              Text(
                'MISSION: 100',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(AppColors.primaryColor),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // 부제목
              Text(
                '차드가 되는 여정',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 로딩 인디케이터
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
