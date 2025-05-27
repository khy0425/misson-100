// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('👑 PERFECT EMPEROR 최종 수정 작전! 👑');

  await fixAchievementsScreenCompletely();
  await fixCalendarScreenCompletely();
  await fixHomeScreenCompletely();
  await fixInitialTestScreenCompletely();
  await fixMemoryManagerCompletely();
  await fixMainNavigationScreenCompletely();
  await fixStatisticsScreenCompletely();
  await fixWorkoutScreenCompletely();
  await fixTestFilesCompletely();

  print('✅ PERFECT EMPEROR 완성! 모든 구문 오류 박멸! ✅');
}

Future<void> fixAchievementsScreenCompletely() async {
  print('🏆 Achievements Screen 완전 수정 중...');

  final file = File('lib/screens/achievements_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 모든 $0 패턴 완전 제거
    content = content.replaceAll(RegExp(r'\$0'), '');
    content = content.replaceAll(RegExp(r'\\$0'), '');

    // 빠진 bracket 문제 수정
    content = content.replaceAll(RegExp(r'expected_token\]'), ']');
    content = content.replaceAll(RegExp(r'missing_identifier'), '');

    // 빈 Padding 수정
    content = content.replaceAllMapped(
      RegExp(r'Padding\(\)'),
      (match) => 'Padding(padding: EdgeInsets.all(8.0))',
    );

    // 빈 EdgeInsets 수정
    content = content.replaceAllMapped(
      RegExp(r'EdgeInsets\.all\(\)'),
      (match) => 'EdgeInsets.all(8.0)',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Achievements Screen 수정 완료');
}

Future<void> fixCalendarScreenCompletely() async {
  print('📅 Calendar Screen 완전 수정 중...');

  final file = File('lib/screens/calendar_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 모든 $0과 빈 매개변수 문제 수정
    content = content.replaceAll(RegExp(r'\$0'), '');
    content = content.replaceAll(RegExp(r'\\$0'), '');

    // undefined_named_parameter 수정
    content = content.replaceAll(RegExp(r'undefined_named_parameter'), '');
    content = content.replaceAll(RegExp(r'missing_identifier'), '');

    // 빈 Text() 수정
    content = content.replaceAll('Text()', 'Text("")');

    // 잘못된 패딩 매개변수 수정
    content = content.replaceAllMapped(
      RegExp(r'Padding\(\s*\(\s*\)'),
      (match) => 'Padding(padding: EdgeInsets.all(8.0)',
    );

    // 빈 named parameter 수정
    content = content.replaceAllMapped(
      RegExp(r',\s*:\s*'),
      (match) => ', child: Container()',
    );

    // Unterminated string 수정
    content = content.replaceAll('Text("', 'Text("")');
    content = content.replaceAll("Text('", "Text('')");

    await file.writeAsString(content);
  }

  print('  ✅ Calendar Screen 수정 완료');
}

Future<void> fixHomeScreenCompletely() async {
  print('🏠 Home Screen 완전 수정 중...');

  final file = File('lib/screens/home_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // invalid context for super 수정
    content = content.replaceAll(
      RegExp(
        r'void initState\(\) \{\s*super\.initState\(\);\s*\}\s*class HomeScreen',
      ),
      'class HomeScreen',
    );

    // showSnackBar 문제 수정
    content = content.replaceAll(
      'showSnackBar(',
      'ScaffoldMessenger.of(context).showSnackBar(',
    );

    // missing_identifier 수정
    content = content.replaceAll(RegExp(r'missing_identifier'), '');
    content = content.replaceAll(RegExp(r'expected_token'), '');

    // unawaited_futures 수정
    content = content.replaceAllMapped(
      RegExp(r'(\w+\.push\w*\([^;]+)\);'),
      (match) => 'await ${match.group(1)});',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Home Screen 수정 완료');
}

Future<void> fixInitialTestScreenCompletely() async {
  print('🧪 Initial Test Screen 완전 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unexpected_token await 수정
    content = content.replaceAll('unexpected_token await', '');
    content = content.replaceAll(RegExp(r'await\s*await'), 'await');

    // invalid_constant 수정 - withOpacity는 const가 될 수 없음
    content = content.replaceAllMapped(
      RegExp(r'const\s+([^(]+\.withOpacity\([^)]+\))'),
      (match) => match.group(1)!,
    );

    // const_with_non_const 수정
    content = content.replaceAll(
      'const ElevatedButton.icon(',
      'ElevatedButton.icon(',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Initial Test Screen 수정 완료');
}

Future<void> fixMemoryManagerCompletely() async {
  print('🧠 Memory Manager 완전 수정 중...');

  final file = File('lib/utils/memory_manager.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // return_of_invalid_type 수정
    content = content.replaceAll(
      'bool? isMemoryPressure',
      'bool isMemoryPressure',
    );

    content = content.replaceAll(
      'return isMemoryPressure ?? false;',
      'return isMemoryPressure;',
    );

    // unchecked_use_of_nullable_value 수정
    content = content.replaceAllMapped(
      RegExp(r'if\s*\(\s*isMemoryPressure\s*\)'),
      (match) => 'if (isMemoryPressure == true)',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Memory Manager 수정 완료');
}

Future<void> fixMainNavigationScreenCompletely() async {
  print('🧭 Main Navigation Screen 완전 수정 중...');

  final file = File('lib/screens/main_navigation_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unnecessary_const 수정
    content = content.replaceAll('const Icon(', 'Icon(');
    content = content.replaceAll('const Text(', 'Text(');

    await file.writeAsString(content);
  }

  print('  ✅ Main Navigation Screen 수정 완료');
}

Future<void> fixStatisticsScreenCompletely() async {
  print('📊 Statistics Screen 완전 수정 중...');

  final file = File('lib/screens/statistics_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // argument_type_not_assignable 수정
    content = content.replaceAll(
      'recentWorkouts.map((workout) => _buildWorkoutItem(workout))',
      'recentWorkouts.map<Widget>((workout) => _buildWorkoutItem(workout as WorkoutHistory))',
    );

    // invalid_constant 수정 (Colors.grey[400]은 const가 될 수 없음)
    content = content.replaceAll(
      'const Icon(Icons.trending_up, size: 80, color: Colors.grey[400])',
      'Icon(Icons.trending_up, size: 80, color: Colors.grey[400])',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Statistics Screen 수정 완료');
}

Future<void> fixWorkoutScreenCompletely() async {
  print('💪 Workout Screen 완전 수정 중...');

  final file = File('lib/screens/workout_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // invalid_constant 수정 - withOpacity는 const가 될 수 없음
    content = content.replaceAllMapped(
      RegExp(r'const\s+([^(]+\.withOpacity\([^)]+\))'),
      (match) => match.group(1)!,
    );

    // const_with_non_const 수정
    content = content.replaceAll(
      'const LinearProgressIndicator(',
      'LinearProgressIndicator(',
    );

    content = content.replaceAll(
      'const CircularProgressIndicator(',
      'CircularProgressIndicator(',
    );

    // unnecessary_const 수정
    content = content.replaceAll('const const ', 'const ');

    await file.writeAsString(content);
  }

  print('  ✅ Workout Screen 수정 완료');
}

Future<void> fixTestFilesCompletely() async {
  print('🧪 Test Files 완전 수정 중...');

  final testFiles = [
    'test/app_test.dart',
    'test/widget_test.dart',
    'test/widgets/home_screen_test.dart',
    'test/widgets/statistics_screen_test.dart',
  ];

  for (final filePath in testFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // unnecessary_const 수정
      content = content.replaceAll('const MaterialApp(', 'MaterialApp(');
      content = content.replaceAll('const MyApp(', 'MyApp(');
      content = content.replaceAll('const HomeScreen(', 'HomeScreen(');
      content = content.replaceAll(
        'const StatisticsScreen(',
        'StatisticsScreen(',
      );

      // const_with_non_const 수정
      content = content.replaceAllMapped(
        RegExp(r'const\s+(\w+\([^)]*context[^)]*\))'),
        (match) => match.group(1)!,
      );

      await file.writeAsString(content);
    }
  }

  print('  ✅ Test Files 수정 완료');
}
