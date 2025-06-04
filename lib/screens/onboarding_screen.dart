import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/onboarding_step.dart';
import '../services/onboarding_service.dart';
import '../screens/initial_test_screen.dart';
import '../screens/home_screen.dart';
import '../screens/permission_screen.dart';
import '../generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // 이미지 미리 로딩을 위한 리스트
  final List<String> _imagePaths = [
    'assets/images/기본차드.jpg',
    'assets/images/정면차드.jpg',
    'assets/images/더블차드.jpg',
    'assets/images/수면모자차드.jpg',
    'assets/images/썬글차드.jpg',
  ];
  
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _initializeAnimations();
    _preloadImages();
  }
  
  void _initializeAnimations() {
    // 애니메이션 컨트롤러 초기화 - 지속시간 최적화
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // 800ms -> 400ms로 단축
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // 600ms -> 300ms로 단축
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 애니메이션 시작
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }
  
  Future<void> _preloadImages() async {
    try {
      // 모든 이미지를 병렬로 미리 로딩
      await Future.wait(_imagePaths.map((path) => 
        precacheImage(AssetImage(path), context)
      ));
      
      if (mounted) {
        setState(() {
          _imagesLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('이미지 미리 로딩 실패: $e');
      // 실패해도 계속 진행
      if (mounted) {
        setState(() {
          _imagesLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 이미지가 로딩되지 않았으면 로딩 화면 표시
    if (!_imagesLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DABF7)),
          ),
        ),
      );
    }
    
    return Consumer<OnboardingService>(
      builder: (context, onboardingService, child) {
        if (onboardingService.isCompleted) {
          // 온보딩이 완료된 경우 권한 설정 화면으로 이동
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PermissionScreen()),
            );
          });
          return const SizedBox.shrink();
        }

        final currentStep = onboardingService.currentStep;
        if (currentStep == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildStepContent(context, onboardingService, currentStep),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
    switch (step.type) {
      case OnboardingStepType.welcome:
        return _WelcomeStepWidget(
          step: step,
          onboardingService: onboardingService,
          onNext: () => _animateToNextStep(onboardingService),
        );
      case OnboardingStepType.programIntroduction:
        return _ProgramIntroductionStepWidget(
          step: step,
          onboardingService: onboardingService,
          onNext: () => _animateToNextStep(onboardingService),
          onPrevious: () => _animateToPreviousStep(onboardingService),
        );
      case OnboardingStepType.chadEvolution:
        return _ChadEvolutionStepWidget(
          step: step,
          onboardingService: onboardingService,
          onNext: () => _animateToNextStep(onboardingService),
          onPrevious: () => _animateToPreviousStep(onboardingService),
        );
      case OnboardingStepType.initialTest:
        return _InitialTestStepWidget(
          step: step,
          onboardingService: onboardingService,
          onPrevious: () => _animateToPreviousStep(onboardingService),
        );
      case OnboardingStepType.completion:
        return const SizedBox.shrink();
    }
  }

  Future<void> _animateToNextStep(OnboardingService onboardingService) async {
    // 페이드 아웃 애니메이션
    await _fadeAnimationController.reverse();
    
    // 다음 스텝으로 이동
    await onboardingService.nextStep();
    
    // 페이드 인 애니메이션
    await _fadeAnimationController.forward();
  }

  Future<void> _animateToPreviousStep(OnboardingService onboardingService) async {
    // 페이드 아웃 애니메이션
    await _fadeAnimationController.reverse();
    
    // 이전 스텝으로 이동
    await onboardingService.previousStep();
    
    // 페이드 인 애니메이션
    await _fadeAnimationController.forward();
  }
}

// 성능 최적화를 위한 개별 위젯 분리

class _WelcomeStepWidget extends StatelessWidget {
  final OnboardingStep step;
  final OnboardingService onboardingService;
  final VoidCallback onNext;

  const _WelcomeStepWidget({
    required this.step,
    required this.onboardingService,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE9ECEF),
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 스킵 버튼
              Align(
                alignment: Alignment.topRight,
                child: step.canSkip
                    ? TextButton(
                        onPressed: () => onboardingService.skipOnboarding(),
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'ko'
                            ? '건너뛰기'
                            : 'Skip',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
              
              const Spacer(),
              
              // Chad 이미지 - 최적화된 이미지 위젯
              _OptimizedImageWidget(
                imagePath: step.imagePath ?? 'assets/images/기본차드.jpg',
                width: 200,
                height: 200,
                shadowColor: const Color(0xFF4DABF7),
              ),
              
              const SizedBox(height: 40),
              
              // 제목
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4DABF7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 설명
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _ProgressIndicatorWidget(onboardingService: onboardingService),
              
              const SizedBox(height: 20),
              
              // 시작 버튼
              _ActionButtonWidget(
                onPressed: onNext,
                backgroundColor: const Color(0xFF4DABF7),
                text: step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                  ? '시작하기'
                  : 'Get Started'),
                foregroundColor: Colors.white,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramIntroductionStepWidget extends StatelessWidget {
  final OnboardingStep step;
  final OnboardingService onboardingService;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _ProgramIntroductionStepWidget({
    required this.step,
    required this.onboardingService,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE9ECEF),
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 상단 네비게이션
              _TopNavigationWidget(
                onPrevious: onPrevious,
                canSkip: step.canSkip,
                onSkip: () => onboardingService.skipOnboarding(),
              ),
              
              const Spacer(),
              
              // Chad 이미지
              _OptimizedImageWidget(
                imagePath: step.imagePath ?? 'assets/images/정면차드.jpg',
                width: 160,
                height: 160,
                shadowColor: const Color(0xFF51CF66),
              ),
              
              const SizedBox(height: 32),
              
              // 제목
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF51CF66),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 설명
              _DescriptionContainerWidget(
                description: step.description,
                borderColor: const Color(0xFF51CF66),
                isDark: isDark,
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _ProgressIndicatorWidget(onboardingService: onboardingService),
              
              const SizedBox(height: 20),
              
              // 다음 버튼
              _ActionButtonWidget(
                onPressed: onNext,
                backgroundColor: const Color(0xFF51CF66),
                text: step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                  ? '다음'
                  : 'Next'),
                foregroundColor: Colors.white,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChadEvolutionStepWidget extends StatelessWidget {
  final OnboardingStep step;
  final OnboardingService onboardingService;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _ChadEvolutionStepWidget({
    required this.step,
    required this.onboardingService,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE9ECEF),
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 상단 네비게이션
              _TopNavigationWidget(
                onPrevious: onPrevious,
                canSkip: step.canSkip,
                onSkip: () => onboardingService.skipOnboarding(),
              ),
              
              const Spacer(),
              
              // Chad 진화 이미지들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OptimizedImageWidget(
                    imagePath: 'assets/images/기본차드.jpg',
                    width: 60,
                    height: 60,
                    shadowColor: const Color(0xFFFFD43B),
                  ),
                  const Icon(Icons.arrow_forward, color: Color(0xFFFFD43B), size: 24),
                  _OptimizedImageWidget(
                    imagePath: 'assets/images/더블차드.jpg',
                    width: 80,
                    height: 80,
                    shadowColor: const Color(0xFFFFD43B),
                  ),
                  const Icon(Icons.arrow_forward, color: Color(0xFFFFD43B), size: 24),
                  _OptimizedImageWidget(
                    imagePath: 'assets/images/수면모자차드.jpg',
                    width: 100,
                    height: 100,
                    shadowColor: const Color(0xFFFFD43B),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 제목
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD43B),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 설명
              _DescriptionContainerWidget(
                description: step.description,
                borderColor: const Color(0xFFFFD43B),
                isDark: isDark,
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _ProgressIndicatorWidget(onboardingService: onboardingService),
              
              const SizedBox(height: 20),
              
              // 다음 버튼
              _ActionButtonWidget(
                onPressed: onNext,
                backgroundColor: const Color(0xFFFFD43B),
                text: step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                  ? '멋져요!'
                  : 'Awesome!'),
                foregroundColor: Colors.black,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialTestStepWidget extends StatelessWidget {
  final OnboardingStep step;
  final OnboardingService onboardingService;
  final VoidCallback onPrevious;

  const _InitialTestStepWidget({
    required this.step,
    required this.onboardingService,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE9ECEF),
                ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 상단 네비게이션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 48), // 테스트는 스킵 불가
                ],
              ),
              
              const Spacer(),
              
              // Chad 이미지
              _OptimizedImageWidget(
                imagePath: step.imagePath ?? 'assets/images/썬글차드.jpg',
                width: 160,
                height: 160,
                shadowColor: const Color(0xFFFF6B6B),
              ),
              
              const SizedBox(height: 32),
              
              // 제목
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 설명
              _DescriptionContainerWidget(
                description: step.description,
                borderColor: const Color(0xFFFF6B6B),
                isDark: isDark,
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _ProgressIndicatorWidget(onboardingService: onboardingService),
              
              const SizedBox(height: 20),
              
              // 테스트 시작 버튼
              _ActionButtonWidget(
                onPressed: () async {
                  try {
                    // 온보딩 완료 처리
                    await onboardingService.completeOnboarding();
                    debugPrint('온보딩 완료 처리됨');
                    
                    // 저장 완료까지 잠시 대기
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    if (context.mounted) {
                      // 권한 설정 화면으로 이동
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const PermissionScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('온보딩 완료 처리 오류: $e');
                    
                    // 오류 발생 시에도 권한 화면으로 이동 (재시도 가능하도록)
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const PermissionScreen(),
                        ),
                      );
                    }
                  }
                },
                backgroundColor: const Color(0xFFFF6B6B),
                text: step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                  ? '테스트 시작'
                  : 'Start Test'),
                foregroundColor: Colors.white,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 공통 위젯들

class _OptimizedImageWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final Color shadowColor;

  const _OptimizedImageWidget({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'chad_image_$imagePath',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.1), // 크기에 비례한 radius
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.3),
              blurRadius: width * 0.1,
              offset: Offset(0, width * 0.05),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.1),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            // 캐시 최적화
            cacheWidth: width.toInt() * 2, // 고해상도 디스플레이를 위한 2배 크기 캐시
            cacheHeight: height.toInt() * 2,
          ),
        ),
      ),
    );
  }
}

class _TopNavigationWidget extends StatelessWidget {
  final VoidCallback onPrevious;
  final bool canSkip;
  final VoidCallback? onSkip;

  const _TopNavigationWidget({
    required this.onPrevious,
    required this.canSkip,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.arrow_back),
        ),
        if (canSkip && onSkip != null)
          TextButton(
            onPressed: onSkip,
            child: Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '건너뛰기'
                : 'Skip',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

class _DescriptionContainerWidget extends StatelessWidget {
  final String description;
  final Color borderColor;
  final bool isDark;

  const _DescriptionContainerWidget({
    required this.description,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          height: 1.6,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _ProgressIndicatorWidget extends StatelessWidget {
  final OnboardingService onboardingService;

  const _ProgressIndicatorWidget({
    required this.onboardingService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            onboardingService.steps.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= onboardingService.progress.currentStepIndex
                    ? const Color(0xFF4DABF7)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${onboardingService.progress.currentStepIndex + 1} / ${onboardingService.steps.length}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ActionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String text;
  final Color foregroundColor;

  const _ActionButtonWidget({
    required this.onPressed,
    required this.backgroundColor,
    required this.text,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 