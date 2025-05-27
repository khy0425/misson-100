// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🏠 MAIN.DART 완전 복구 작전! 🏠');

  await fixMainDartCompletely();

  print('✅ MAIN.DART 완전 복구 완료! ✅');
}

Future<void> fixMainDartCompletely() async {
  print('🏠 Main.dart 완전 재작성 중...');

  final file = File('lib/main.dart');

  // 완전히 새로운 내용으로 교체
  const content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/main_navigation_screen.dart';
import 'services/memory_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 화면 방향 고정 (세로)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AdMob 초기화
  MobileAds.instance.initialize();

  // 메모리 관리자 초기화
  MemoryManager.init();

  runApp(const MissionApp());
}

class MissionApp extends StatelessWidget {
  const MissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mission: 100',
      debugShowCheckedModeBanner: false,
      
      // 테마 설정
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 다국어 설정
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],

      // 홈 화면
      home: const SplashScreen(),
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();
    
    // 2초 대기 후 메인 화면으로 이동
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
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
      backgroundColor: Color(isDark 
          ? AppColors.backgroundDark 
          : AppColors.backgroundLight),
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
                  color: Color(AppColors.primaryColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(AppColors.primaryColor).withValues(alpha: 0.3),
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
                  color: Color(AppColors.primaryColor),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 16),

              // 부제목
              Text(
                '차드가 되는 여정',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 40),

              // 로딩 인디케이터
              SizedBox(
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
''';

  await file.writeAsString(content);
  print('  ✅ Main.dart 완전 재작성 완료');
}
