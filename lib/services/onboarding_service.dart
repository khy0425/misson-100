import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_step.dart';

/// 온보딩 플로우를 관리하는 서비스
class OnboardingService extends ChangeNotifier {
  static const String _onboardingProgressKey = 'onboarding_progress';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  OnboardingProgress _progress = const OnboardingProgress(
    status: OnboardingStatus.notStarted,
    currentStepIndex: 0,
    totalSteps: 0,
  );

  List<OnboardingStep> _steps = [];
  bool _isInitialized = false;

  /// 현재 온보딩 진행 상태
  OnboardingProgress get progress => _progress;

  /// 온보딩 스텝 목록
  List<OnboardingStep> get steps => List.unmodifiable(_steps);

  /// 현재 스텝
  OnboardingStep? get currentStep {
    if (_progress.currentStepIndex >= 0 && _progress.currentStepIndex < _steps.length) {
      return _steps[_progress.currentStepIndex];
    }
    return null;
  }

  /// 다음 스텝
  OnboardingStep? get nextStepData {
    final nextIndex = _progress.currentStepIndex + 1;
    if (nextIndex >= 0 && nextIndex < _steps.length) {
      return _steps[nextIndex];
    }
    return null;
  }

  /// 이전 스텝
  OnboardingStep? get previousStepData {
    final prevIndex = _progress.currentStepIndex - 1;
    if (prevIndex >= 0 && prevIndex < _steps.length) {
      return _steps[prevIndex];
    }
    return null;
  }

  /// 첫 번째 스텝인지 확인
  bool get isFirstStep => _progress.currentStepIndex == 0;

  /// 마지막 스텝인지 확인
  bool get isLastStep => _progress.currentStepIndex == _steps.length - 1;

  /// 다음 스텝이 있는지 확인
  bool get hasNextStep => _progress.currentStepIndex < _steps.length - 1;

  /// 이전 스텝이 있는지 확인
  bool get hasPreviousStep => _progress.currentStepIndex > 0;

  /// 온보딩 완료 여부
  bool get isCompleted => _progress.isCompleted;

  /// 온보딩 진행 중 여부
  bool get isInProgress => _progress.isInProgress;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _initializeSteps();
    await _loadProgress();
    _isInitialized = true;
    notifyListeners();
  }

  /// 온보딩 스텝 초기화
  void _initializeSteps() {
    _steps = [
      const OnboardingStep(
        type: OnboardingStepType.welcome,
        title: 'Mission 100에 오신 것을 환영합니다!',
        description: '6주 동안 100개의 푸시업을 목표로 하는 여정을 시작해보세요.\n체계적인 프로그램으로 당신의 한계를 뛰어넘어보세요!',
        imagePath: 'assets/images/기본차드.jpg',
        buttonText: '시작하기',
        canSkip: false,
      ),
      const OnboardingStep(
        type: OnboardingStepType.programIntroduction,
        title: '6주 프로그램 소개',
        description: '과학적으로 설계된 6주 프로그램으로 점진적으로 실력을 향상시킵니다.\n\n• 1주차: 기초 체력 다지기\n• 2-3주차: 근력 강화\n• 4-5주차: 지구력 향상\n• 6주차: 목표 달성',
        imagePath: 'assets/images/정면차드.jpg',
        buttonText: '다음',
        canSkip: true,
      ),
      const OnboardingStep(
        type: OnboardingStepType.chadEvolution,
        title: 'Chad 진화 시스템',
        description: '운동을 완료할 때마다 Chad가 진화합니다!\n\n🏃‍♂️ Rookie Chad → 💪 Giga Chad → 👑 Legendary Chad\n\n각 단계마다 새로운 Chad 이미지와 업적을 해제하세요!',
        imagePath: 'assets/images/더블차드.jpg',
        buttonText: '멋져요!',
        canSkip: true,
      ),
      const OnboardingStep(
        type: OnboardingStepType.initialTest,
        title: '초기 실력 테스트',
        description: '현재 실력을 측정하여 맞춤형 프로그램을 제공합니다.\n\n• 최대한 많은 푸시업을 해보세요\n• 정확한 자세로 실시하세요\n• 결과에 따라 프로그램이 조정됩니다',
        imagePath: 'assets/images/썬글차드.jpg',
        buttonText: '테스트 시작',
        canSkip: false,
      ),
    ];

    _progress = _progress.copyWith(totalSteps: _steps.length);
  }

  /// 저장된 진행 상태 로드
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 온보딩 완료 여부 확인 (이전 버전 호환성)
      final isCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
      if (isCompleted) {
        _progress = _progress.copyWith(
          status: OnboardingStatus.completed,
          currentStepIndex: _steps.length,
          completedAt: DateTime.now(),
        );
        return;
      }

      // 상세 진행 상태 로드
      final progressJson = prefs.getString(_onboardingProgressKey);
      if (progressJson != null) {
        final progressData = jsonDecode(progressJson) as Map<String, dynamic>;
        _progress = OnboardingProgress.fromJson(progressData);
      }
    } catch (e) {
      debugPrint('온보딩 진행 상태 로드 오류: $e');
      // 오류 발생 시 기본 상태로 초기화
      _progress = OnboardingProgress(
        status: OnboardingStatus.notStarted,
        currentStepIndex: 0,
        totalSteps: _steps.length,
      );
    }
  }

  /// 진행 상태 저장
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 상세 진행 상태 저장
      final progressJson = jsonEncode(_progress.toJson());
      await prefs.setString(_onboardingProgressKey, progressJson);
      
      // 완료 여부 저장 (이전 버전 호환성)
      await prefs.setBool(_onboardingCompletedKey, _progress.isCompleted);
    } catch (e) {
      debugPrint('온보딩 진행 상태 저장 오류: $e');
    }
  }

  /// 온보딩 시작
  Future<void> startOnboarding() async {
    if (_progress.status == OnboardingStatus.completed) {
      return; // 이미 완료된 경우 시작하지 않음
    }

    _progress = _progress.copyWith(
      status: OnboardingStatus.inProgress,
      currentStepIndex: 0,
      startedAt: DateTime.now(),
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 다음 스텝으로 이동
  Future<void> nextStep() async {
    if (!hasNextStep) {
      await completeOnboarding();
      return;
    }

    _progress = _progress.copyWith(
      currentStepIndex: _progress.currentStepIndex + 1,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 이전 스텝으로 이동
  Future<void> previousStep() async {
    if (!hasPreviousStep) return;

    _progress = _progress.copyWith(
      currentStepIndex: _progress.currentStepIndex - 1,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 특정 스텝으로 이동
  Future<void> goToStep(int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= _steps.length) return;

    _progress = _progress.copyWith(
      currentStepIndex: stepIndex,
      status: OnboardingStatus.inProgress,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 온보딩 완료
  Future<void> completeOnboarding() async {
    _progress = _progress.copyWith(
      status: OnboardingStatus.completed,
      currentStepIndex: _steps.length,
      completedAt: DateTime.now(),
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 온보딩 스킵
  Future<void> skipOnboarding() async {
    _progress = _progress.copyWith(
      status: OnboardingStatus.skipped,
      currentStepIndex: _steps.length,
      completedAt: DateTime.now(),
      wasSkipped: true,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 온보딩 재시작
  Future<void> resetOnboarding() async {
    _progress = OnboardingProgress(
      status: OnboardingStatus.notStarted,
      currentStepIndex: 0,
      totalSteps: _steps.length,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// 온보딩 완료 여부 확인 (정적 메서드)
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      debugPrint('온보딩 완료 여부 확인 오류: $e');
      return false;
    }
  }

  /// 현재 스텝이 스킵 가능한지 확인
  bool canSkipCurrentStep() {
    return currentStep?.canSkip ?? false;
  }

  /// 진행률 백분율 (0-100)
  double get progressPercentage => _progress.progressPercentage * 100;

  /// 남은 스텝 수
  int get remainingSteps => _steps.length - _progress.currentStepIndex;

  @override
  void dispose() {
    super.dispose();
  }
} 