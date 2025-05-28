import 'package:mission100/models/workout_session.dart';
import 'package:mission100/models/workout_history.dart';
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/services/workout_program_service.dart';

/// 테스트용 운동 프로그램 서비스 모킹 클래스
class MockWorkoutProgramService {
  // 인메모리 데이터 저장소
  final Map<String, WorkoutSession> _workoutSessions = {};
  final List<WorkoutHistory> _workoutHistory = [];
  final Map<String, double> _progressData = {};
  UserProfile? _userProfile;
  bool _isInitialized = false;

  // 테스트 데이터 설정을 위한 헬퍼 메서드들
  void setMockUserProfile(UserProfile profile) {
    _userProfile = profile;
  }

  void setMockWorkoutSession(int week, int day, WorkoutSession session) {
    final key = '${week}_$day';
    _workoutSessions[key] = session;
  }

  void addMockWorkoutHistory(WorkoutHistory history) {
    _workoutHistory.add(history);
  }

  void setMockProgress(int week, double progress) {
    _progressData[week.toString()] = progress;
  }

  void clearMockData() {
    _workoutSessions.clear();
    _workoutHistory.clear();
    _progressData.clear();
    _userProfile = null;
    _isInitialized = false;
  }

  void initialize() {
    _isInitialized = true;
  }

  // WorkoutProgramService 메서드들 모킹
  Future<void> initializeProgram(UserProfile userProfile) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    _userProfile = userProfile;
  }

  Future<WorkoutSession> getTodayWorkout(int week, int day) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final key = '${week}_$day';
    if (_workoutSessions.containsKey(key)) {
      return _workoutSessions[key]!;
    }

    // 기본 운동 생성 (실제 서비스와 유사한 로직)
    return _generateDefaultWorkout(week, day);
  }

  Future<double> getWeekProgress(int week) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _progressData[week.toString()] ?? 0.0;
  }

  Future<double> getOverallProgress() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    if (_progressData.isEmpty) return 0.0;
    
    final totalProgress = _progressData.values.fold(0.0, (sum, progress) => sum + progress);
    return totalProgress / _progressData.length;
  }

  Future<List<WorkoutHistory>> getWorkoutHistory() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _workoutHistory.toList();
  }

  Future<int> getTotalCompletedWorkouts() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _workoutSessions.values
        .where((session) => session.isCompleted)
        .length;
  }

  Future<int> getTotalReps() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _workoutSessions.values
        .where((session) => session.isCompleted)
        .fold<int>(0, (sum, session) => sum + session.totalReps);
  }

  Future<int> getCurrentWeek() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    if (_userProfile == null) return 1;
    
    final daysSinceStart = DateTime.now().difference(_userProfile!.startDate).inDays;
    return (daysSinceStart ~/ 7) + 1;
  }

  Future<int> getCurrentDay() async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    if (_userProfile == null) return 1;
    
    final daysSinceStart = DateTime.now().difference(_userProfile!.startDate).inDays;
    return (daysSinceStart % 7) + 1;
  }

  Future<bool> isWorkoutCompleted(int week, int day) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final key = '${week}_$day';
    return _workoutSessions[key]?.isCompleted ?? false;
  }

  Future<void> markWorkoutCompleted(int week, int day) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final key = '${week}_$day';
    if (_workoutSessions.containsKey(key)) {
      final session = _workoutSessions[key]!;
      _workoutSessions[key] = session.copyWith(isCompleted: true);
    }
  }

  Future<List<int>> getWeeklyTargets(int week) async {
    if (!_isInitialized) {
      throw Exception('Service not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    // 주차별 목표 반환 (실제 프로그램 로직과 유사)
    final baseReps = _userProfile?.initialMaxReps ?? 10;
    final weekMultiplier = 1 + (week - 1) * 0.1;
    
    return List.generate(7, (day) {
      final dayMultiplier = 1 + (day * 0.05);
      return (baseReps * weekMultiplier * dayMultiplier).round();
    });
  }

  // 헬퍼 메서드들
  WorkoutSession _generateDefaultWorkout(int week, int day) {
    final baseReps = _userProfile?.initialMaxReps ?? 10;
    final weekMultiplier = 1 + (week - 1) * 0.1;
    final dayMultiplier = 1 + (day * 0.05);
    final targetReps = (baseReps * weekMultiplier * dayMultiplier).round();
    
    return WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now(),
      week: week,
      day: day,
      targetReps: [targetReps, (targetReps * 0.8).round(), (targetReps * 0.6).round()],
      completedReps: [],
      isCompleted: false,
      totalReps: 0,
    );
  }

  // 테스트용 헬퍼 메서드들
  bool get isInitialized => _isInitialized;
  int get workoutSessionCount => _workoutSessions.length;
  int get workoutHistoryCount => _workoutHistory.length;
  bool get hasUserProfile => _userProfile != null;
  UserProfile? get userProfile => _userProfile;
  
  Map<String, WorkoutSession> get workoutSessions => Map.unmodifiable(_workoutSessions);
  List<WorkoutHistory> get workoutHistory => List.unmodifiable(_workoutHistory);
  Map<String, double> get progressData => Map.unmodifiable(_progressData);
} 