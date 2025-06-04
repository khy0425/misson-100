import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/permission_service.dart';
import 'services/onboarding_service.dart';
import 'services/chad_evolution_service.dart';
import 'services/chad_image_service.dart';
import 'services/achievement_service.dart';
import 'services/database_service.dart';
import 'services/challenge_service.dart';
import 'screens/initial_test_screen.dart';
// MemoryManager import 제거됨

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 화면 방향 고정 (세로) - 필수
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 즉시 필요한 서비스들만 동기 초기화
    
    // 테마 서비스 초기화 (UI 렌더링에 필요)
    final themeService = ThemeService();
    await themeService.initialize();
    debugPrint('✅ ThemeService 초기화 완료');

    // 로케일 서비스 초기화 (다국어 지원에 필요)
    final localeNotifier = LocaleNotifier();
    await localeNotifier.loadLocale();
    debugPrint('✅ LocaleService 초기화 완료');

    // 온보딩 서비스 초기화 (첫 화면 결정에 필요)
    final onboardingService = OnboardingService();
    await onboardingService.initialize();
    debugPrint('✅ OnboardingService 초기화 완료');

    // Chad 진화 서비스 초기화 (메인 UI에 필요)
    final chadEvolutionService = ChadEvolutionService();
    await chadEvolutionService.initialize();
    debugPrint('✅ ChadEvolutionService 초기화 완료');

    debugPrint('🚀 앱 기본 초기화 완료 - 빠른 시작!');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: localeNotifier),
          ChangeNotifierProvider.value(value: onboardingService),
          ChangeNotifierProvider.value(value: chadEvolutionService),
        ],
        child: const MissionApp(),
      ),
    );

    // 나머지 서비스들은 백그라운드에서 초기화 (non-blocking)
    _initializeBackgroundServices();

  } catch (e, stackTrace) {
    debugPrint('🚨 앱 초기화 중 치명적인 오류 발생: $e');
    debugPrint('스택 트레이스: $stackTrace');
    
    // 앱이 완전히 중단되지 않도록 기본 앱으로 실행
    runApp(
      MaterialApp(
        title: 'Mission: 100',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화 중 오류가 발생했습니다.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '오류: $e',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('앱 재시작 시도');
                    // 앱 재시작 로직
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 백그라운드에서 나머지 서비스들을 초기화하는 함수
void _initializeBackgroundServices() {
  // 광고 서비스 초기화 (백그라운드)
  AdService.initialize().then((_) {
    debugPrint('✅ AdService 백그라운드 초기화 완료');
  }).catchError((e) {
    debugPrint('❌ AdService 초기화 오류: $e');
  });

  // 알림 서비스 초기화 (백그라운드)
  NotificationService.initialize().then((_) async {
    await NotificationService.createNotificationChannels();
    debugPrint('✅ NotificationService 백그라운드 초기화 완료');
  }).catchError((e) {
    debugPrint('❌ NotificationService 초기화 오류: $e');
  });

  // Chad 이미지 서비스 초기화 (백그라운드)
  ChadImageService().initialize().then((_) {
    debugPrint('✅ ChadImageService 백그라운드 초기화 완료');
  }).catchError((e) {
    debugPrint('❌ ChadImageService 초기화 오류: $e');
  });

  // 업적 서비스 초기화 (백그라운드)
  Future.delayed(const Duration(milliseconds: 500), () {
    AchievementService.initialize().then((_) async {
      final totalCount = await AchievementService.getTotalCount();
      final unlockedCount = await AchievementService.getUnlockedCount();
      debugPrint('✅ 업적 서비스 백그라운드 초기화 완료 - 총 $totalCount개 업적, $unlockedCount개 잠금해제');
    }).catchError((e) {
      debugPrint('❌ 업적 서비스 초기화 오류: $e');
    });
  });

  // 챌린지 서비스 초기화 (백그라운드)
  Future.delayed(const Duration(milliseconds: 700), () {
    ChallengeService().initialize().then((_) {
      debugPrint('✅ 챌린지 서비스 백그라운드 초기화 완료');
    }).catchError((e) {
      debugPrint('❌ 챌린지 서비스 초기화 오류: $e');
    });
  });

  // Chad 이미지 프리로드 (더 늦게, 메모리 부담 줄이기)
  Future.delayed(const Duration(seconds: 2), () {
    final chadEvolutionService = ChadEvolutionService();
    chadEvolutionService.preloadAllImages(targetSize: 150).catchError((e) {
      debugPrint('Chad 이미지 프리로드 오류: $e');
    });
  });
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
    // 로케일 자동 초기화는 스플래시 화면에서 처리
    // await LocaleService.initializeLocale();
    
    // 설정된 언어 불러오기
    _locale = await LocaleService.getLocale();
    notifyListeners();
  }
}

class MissionApp extends StatefulWidget {
  const MissionApp({super.key});

  @override
  State<MissionApp> createState() => _MissionAppState();
}

class _MissionAppState extends State<MissionApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 앱이 포그라운드로 돌아왔을 때 권한 상태 재확인
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 앱이 포그라운드로 돌아왔습니다. 권한 상태 재확인...');
      
      // 알림 권한 재확인 (약간의 지연 후)
      Future.delayed(const Duration(milliseconds: 500), () {
        NotificationService.recheckPermissionsOnResume();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LocaleNotifier>(
      builder: (context, themeService, localeService, child) {
        return MaterialApp(
          title: 'Mission: 100',
          debugShowCheckedModeBanner: false,

          // 테마 설정 - ThemeService의 커스터마이징된 테마 사용
          theme: themeService.getThemeData(),
          darkTheme: themeService.getThemeData(),
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

          // 스플래시 화면을 홈으로 설정
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    if (!mounted) return;

    try {
      // 0단계: 스마트 언어 탐지 (앱 실행할 때마다)
      debugPrint('🌐 스마트 언어 탐지 시작...');
      try {
        await LocaleService.initializeLocale();
        debugPrint('🌐 스마트 언어 탐지 완료');
        
        // 언어 변경이 있었다면 LocaleNotifier 업데이트
        if (mounted) {
          final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
          await localeNotifier.loadLocale();
        }
      } catch (e) {
        debugPrint('🌐 스마트 언어 탐지 오류: $e (기존 설정 유지)');
      }
      
      // 1단계: 온보딩 완료 여부 확인 (최우선)
      bool isOnboardingCompleted = false;
      try {
        isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
        debugPrint('온보딩 완료 여부: $isOnboardingCompleted');
      } catch (e) {
        debugPrint('온보딩 서비스 확인 오류: $e (기본값: false 사용)');
        isOnboardingCompleted = false;
      }
      
      if (!isOnboardingCompleted) {
        // 온보딩이 완료되지 않았으면 온보딩 화면으로
        debugPrint('화면 이동: 온보딩 화면 (첫 실행)');
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const OnboardingScreen()),
          );
        }
        return;
      }
      
      // 2단계: 권한 확인 (온보딩 완료 후) - 병렬 처리로 속도 향상
      final permissionFutures = await Future.wait([
        NotificationService.hasPermission().catchError((e) {
          debugPrint('알림 권한 확인 오류: $e');
          return false;
        }),
        PermissionService.getStoragePermissionStatus().then((status) => 
          status == PermissionStatus.granted).catchError((e) {
          debugPrint('저장소 권한 확인 오류: $e');
          return false;
        }),
      ]);
      
      final hasNotificationPermission = permissionFutures[0];
      final hasStoragePermission = permissionFutures[1];
      final hasAllPermissions = hasNotificationPermission && hasStoragePermission;
      
      debugPrint('권한 상태 - 알림: $hasNotificationPermission, 저장소: $hasStoragePermission');
      
      if (!hasAllPermissions) {
        // 권한이 없으면 권한 요청 화면
        debugPrint('화면 이동: 권한 요청 화면');
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const PermissionScreen()),
          );
        }
        return;
      }
      
      // 3단계: UserProfile 생성 여부 확인 (난이도 선택 완료)
      bool hasUserProfile = false;
      try {
        final databaseService = DatabaseService();
        final userProfile = await databaseService.getUserProfile();
        hasUserProfile = userProfile != null;
        debugPrint('UserProfile 존재 여부: $hasUserProfile');
      } catch (e) {
        debugPrint('UserProfile 확인 오류: $e (기본값: false 사용)');
        hasUserProfile = false;
      }
      
      if (!hasUserProfile) {
        // 온보딩과 권한은 완료했지만 난이도 선택이 안 되었으면 초기 테스트 화면
        debugPrint('화면 이동: 초기 테스트 화면 (난이도 선택)');
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const InitialTestScreen()),
          );
        }
        return;
      }
      
      // 4단계: 모든 설정이 완료되었으면 메인 화면
      debugPrint('화면 이동: 메인 화면');
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🚨 스플래시 화면 초기화 중 치명적인 오류 발생: $e');
      debugPrint('스택 트레이스: $stackTrace');
      
      // 오류가 발생했을 때 온보딩 화면으로 안전하게 이동
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const OnboardingScreen()),
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
              // 앱 로고/아이콘 (회전 및 스케일 애니메이션 적용)
              ScaleTransition(
                scale: _scaleAnimation,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: Container(
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
                ),
              ),

              const SizedBox(height: 32),

              // 앱 이름 (페이드 인 애니메이션)
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
                ),
                child: Text(
                  'MISSION: 100',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(AppColors.primaryColor),
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 부제목 (페이드 인 애니메이션)
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
                ),
                child: Text(
                  '차드가 되는 여정',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 로딩 인디케이터 (페이드 인 애니메이션)
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeInOut),
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(AppColors.primaryColor),
                    ),
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
