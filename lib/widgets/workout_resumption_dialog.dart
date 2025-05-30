import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/workout_resumption_service.dart';

/// 운동 재개 확인 다이얼로그
class WorkoutResumptionDialog extends StatelessWidget {
  final WorkoutResumptionData resumptionData;
  final VoidCallback onResumeWorkout;
  final VoidCallback onStartNewWorkout;

  const WorkoutResumptionDialog({
    super.key,
    required this.resumptionData,
    required this.onResumeWorkout,
    required this.onStartNewWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryData = resumptionData.primaryData;
    
    if (primaryData == null) {
      return const SizedBox.shrink();
    }

    // 복원 가능한 데이터 분석
    final workoutTitle = primaryData['workoutTitle'] as String? ?? '운동';
    final currentSet = (primaryData['currentSet'] as int? ?? 0) + 1; // 1-based index
    final completedRepsStr = primaryData['completedReps'] as String? ?? '';
    final completedReps = completedRepsStr.isNotEmpty 
        ? completedRepsStr.split(',').map(int.parse).toList()
        : <int>[];
    
    final completedSetsCount = completedReps.where((reps) => reps > 0).length;
    final totalCompletedReps = completedReps.fold(0, (sum, reps) => sum + reps);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Icon(
              Icons.restore,
              color: Color(AppColors.primaryColor),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '💪 운동 재개',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(AppColors.primaryColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 발견된 운동 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(AppColors.secondaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: const Color(AppColors.secondaryColor).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔍 발견된 운동',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(AppColors.secondaryColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '운동: $workoutTitle',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '진행: ${currentSet}세트 준비 중',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '완료된 세트: ${completedSetsCount}개',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '총 완료 횟수: ${totalCompletedReps}회',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 데이터 소스 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  resumptionData.dataSource == 'SharedPreferences'
                      ? Icons.phone_android
                      : Icons.storage,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '데이터 소스: ${resumptionData.dataSource}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 안내 메시지
          Text(
            '이전 운동을 이어서 계속하시겠습니까?\n아니면 새 운동을 시작하시겠습니까?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        // 새 운동 시작 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onStartNewWorkout();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('새 운동 시작'),
        ),
        
        // 운동 재개 버튼
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onResumeWorkout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primaryColor),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow, size: 18),
              const SizedBox(width: 4),
              const Text(
                '운동 재개',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}

/// 운동 재개 다이얼로그를 표시하는 헬퍼 함수
Future<bool?> showWorkoutResumptionDialog({
  required BuildContext context,
  required WorkoutResumptionData resumptionData,
}) async {
  bool? shouldResume;

  await showDialog<void>(
    context: context,
    barrierDismissible: false, // 백그라운드 터치로 닫기 방지
    builder: (BuildContext context) {
      return WorkoutResumptionDialog(
        resumptionData: resumptionData,
        onResumeWorkout: () {
          shouldResume = true;
        },
        onStartNewWorkout: () {
          shouldResume = false;
        },
      );
    },
  );

  return shouldResume;
}

/// 간단한 운동 재개 확인 다이얼로그
Future<bool> showSimpleResumptionDialog({
  required BuildContext context,
  required String workoutTitle,
  required int completedSets,
  required int totalReps,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: const Text(
          '💪 운동 재개',
          style: TextStyle(
            color: Color(AppColors.primaryColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fitness_center,
              color: Color(AppColors.primaryColor),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '미완료된 운동이 발견되었습니다!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '운동: $workoutTitle\n완료된 세트: ${completedSets}개\n총 횟수: ${totalReps}회',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '이어서 계속하시겠습니까?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '새로 시작',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
            ),
            child: const Text(
              '재개하기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
} 