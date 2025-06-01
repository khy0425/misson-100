import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryData = resumptionData.primaryData;
    
    if (primaryData == null) {
      return const SizedBox.shrink();
    }

    // 복원 가능한 데이터 분석
    final workoutTitle = primaryData['workoutTitle'] as String? ?? l10n.workout;
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
              Localizations.localeOf(context).languageCode == 'ko'
                ? '💪 운동 재개'
                : '💪 Resume Workout',
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
          if (workoutTitle.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '🔍 발견된 운동'
                      : '🔍 Found Workout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '운동: $workoutTitle'
                      : 'Workout: $workoutTitle',
                  ),
                  if (currentSet > 0)
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '진행: ${currentSet}세트 준비 중'
                        : 'Progress: Set ${currentSet} ready',
                    ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '완료된 세트: ${completedSetsCount}개'
                      : 'Completed sets: ${completedSetsCount}',
                  ),
                  if (totalCompletedReps > 0)
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '총 완료 횟수: ${totalCompletedReps}회'
                        : 'Total completed: ${totalCompletedReps} reps',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'ko'
                          ? '⚠️ 운동 중단 발견'
                          : '⚠️ Workout Interruption Detected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '이전 운동을 이어서 계속하시겠습니까?\n아니면 새 운동을 시작하시겠습니까?'
                    : 'Would you like to continue the previous workout?\nOr start a new workout?',
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // 새 운동 시작 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onStartNewWorkout();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            Localizations.localeOf(context).languageCode == 'ko'
              ? '새 운동 시작'
              : 'Start New Workout',
          ),
        ),
        
        // 운동 재개 버튼
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
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
              Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '운동 재개'
                  : 'Resume Workout',
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
Future<bool?> showSimpleResumptionDialog({
  required BuildContext context,
  required String workoutTitle,
  required int completedSets,
  required int totalReps,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(
        Localizations.localeOf(context).languageCode == 'ko'
          ? '💪 운동 재개'
          : '💪 Resume Workout',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '미완료된 운동이 발견되었습니다!'
                    : 'Incomplete workout found!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '운동: $workoutTitle\n완료된 세트: ${completedSets}개\n총 횟수: ${totalReps}회'
                    : 'Workout: $workoutTitle\nCompleted sets: ${completedSets}\nTotal reps: ${totalReps}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            Localizations.localeOf(context).languageCode == 'ko'
              ? '재개'
              : 'Resume',
          ),
        ),
      ],
    ),
  );
} 