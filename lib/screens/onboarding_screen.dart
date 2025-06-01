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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 애니메이션 컨트롤러 초기화
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  @override
  void dispose() {
    _pageController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        return _buildWelcomeStep(context, onboardingService, step);
      case OnboardingStepType.programIntroduction:
        return _buildProgramIntroductionStep(context, onboardingService, step);
      case OnboardingStepType.chadEvolution:
        return _buildChadEvolutionStep(context, onboardingService, step);
      case OnboardingStepType.initialTest:
        return _buildInitialTestStep(context, onboardingService, step);
      case OnboardingStepType.completion:
        return _buildCompletionStep(context, onboardingService, step);
    }
  }

  Widget _buildWelcomeStep(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
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
              // 스킵 버튼 (환영 화면에서는 숨김)
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
              
              // Chad 이미지
              Hero(
                tag: 'chad_image',
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DABF7).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      step.imagePath ?? 'assets/images/기본차드.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
              _buildProgressIndicator(onboardingService),
              
              const SizedBox(height: 20),
              
              // 시작 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await _animateToNextStep(onboardingService);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DABF7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF4DABF7).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                      ? '시작하기'
                      : 'Get Started'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramIntroductionStep(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
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
                    onPressed: () async {
                      await _animateToPreviousStep(onboardingService);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  if (step.canSkip)
                    TextButton(
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
                  else
                    const SizedBox(width: 48),
                ],
              ),
              
              const Spacer(),
              
              // Chad 이미지
              Hero(
                tag: 'chad_image',
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF51CF66).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      step.imagePath ?? 'assets/images/정면차드.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1A1A1A) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF51CF66).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _buildProgressIndicator(onboardingService),
              
              const SizedBox(height: 20),
              
              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await _animateToNextStep(onboardingService);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF51CF66),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF51CF66).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                      ? '다음'
                      : 'Next'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChadEvolutionStep(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
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
                    onPressed: () async {
                      await _animateToPreviousStep(onboardingService);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  if (step.canSkip)
                    TextButton(
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
                  else
                    const SizedBox(width: 48),
                ],
              ),
              
              const Spacer(),
              
              // Chad 진화 이미지들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChadEvolutionImage('assets/images/기본차드.jpg', 60),
                  const Icon(Icons.arrow_forward, color: Color(0xFFFFD43B), size: 24),
                  _buildChadEvolutionImage('assets/images/더블차드.jpg', 80),
                  const Icon(Icons.arrow_forward, color: Color(0xFFFFD43B), size: 24),
                  _buildChadEvolutionImage('assets/images/수면모자차드.jpg', 100),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1A1A1A) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD43B).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _buildProgressIndicator(onboardingService),
              
              const SizedBox(height: 20),
              
              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await _animateToNextStep(onboardingService);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD43B),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFFD43B).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                      ? '멋져요!'
                      : 'Awesome!'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialTestStep(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
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
                    onPressed: () async {
                      await _animateToPreviousStep(onboardingService);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 48), // 테스트는 스킵 불가
                ],
              ),
              
              const Spacer(),
              
              // Chad 이미지
              Hero(
                tag: 'chad_image',
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      step.imagePath ?? 'assets/images/썬글차드.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1A1A1A) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              
              const Spacer(),
              
              // 진행률 표시
              _buildProgressIndicator(onboardingService),
              
              const SizedBox(height: 20),
              
              // 테스트 시작 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // 온보딩 완료 처리
                      await onboardingService.completeOnboarding();
                      debugPrint('온보딩 완료 처리됨');
                      
                      // 저장 완료까지 잠시 대기
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      if (mounted) {
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
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const PermissionScreen(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    step.buttonText ?? (Localizations.localeOf(context).languageCode == 'ko'
                      ? '테스트 시작'
                      : 'Start Test'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStep(
    BuildContext context,
    OnboardingService onboardingService,
    OnboardingStep step,
  ) {
    // 완료 단계는 별도로 처리하지 않고 홈 화면으로 이동
    return const SizedBox.shrink();
  }

  Widget _buildChadEvolutionImage(String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD43B).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(OnboardingService onboardingService) {
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