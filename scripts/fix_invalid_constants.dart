// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('❌ INVALID CONSTANT 대량 박멸 작전! ❌');

  await fixInvalidConstantErrors();
  await fixTestFileConstants();
  await fixInitialTestScreenConstants();
  await fixWorkoutScreenConstants();

  print('✅ INVALID CONSTANT 박멸 완료! CONST EMPEROR! ✅');
}

Future<void> fixInvalidConstantErrors() async {
  print('❌ 모든 파일 Invalid Constant 수정 중...');

  final allFiles = [
    'lib/screens/initial_test_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
    'lib/screens/workout_screen.dart',
  ];

  for (final filePath in allFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // 가장 흔한 invalid_constant 패턴들 수정
      content = content.replaceAll('const Color(', 'Color(');
      content = content.replaceAll(
        'const BorderRadius.circular',
        'BorderRadius.circular',
      );
      content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
      content = content.replaceAll('const Theme.of(', 'Theme.of(');
      content = content.replaceAll('const MediaQuery.of(', 'MediaQuery.of(');
      content = content.replaceAll('const Icons.', 'Icons.');
      content = content.replaceAll('const Colors.', 'Colors.');

      // 함수 호출에 const 사용하는 경우들 수정
      content = content.replaceAll('const Size.', 'Size.');
      content = content.replaceAll('const TextStyle(', 'TextStyle(');
      content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
      content = content.replaceAll('const Container(', 'Container(');

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 파일 Invalid Constant 수정 완료');
}

Future<void> fixTestFileConstants() async {
  print('🧪 테스트 파일 Constant 문제 수정 중...');

  final testFiles = [
    'test/app_test.dart',
    'test/widget_test.dart',
    'test/widgets/home_screen_test.dart',
    'test/integration/app_integration_test.dart',
  ];

  for (final filePath in testFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // const_with_non_const 수정
      content = content.replaceAll('const HomeScreen(', 'HomeScreen(');
      content = content.replaceAll('const MaterialApp(', 'MaterialApp(');
      content = content.replaceAll('const Mission100App(', 'Mission100App(');

      // invalid_constant 수정
      content = content.replaceAll('const MissionApp(', 'MissionApp(');

      // unnecessary_const 제거
      content = content.replaceAll(RegExp(r'\bconst\s+(\w+App)\('), r'\1(');

      await file.writeAsString(content);
    }
  }
  print('  ✅ 테스트 파일 수정 완료');
}

Future<void> fixInitialTestScreenConstants() async {
  print('🧪 Initial Test Screen 특별 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // argument_type_not_assignable 수정 - Future<int>를 int로 변환
    content = content.replaceAll(
      RegExp(
        r'PushupCount\(\s*pushupCount:\s*(\w+\.getCurrentMaxPushups\(\)),',
      ),
      'PushupCount(pushupCount: await \$1,',
    );

    // 특정 라인의 invalid_constant 수정
    content = content.replaceAll('const Color(AppColors.', 'Color(AppColors.');
    content = content.replaceAll('const Offset(', 'Offset(');

    await file.writeAsString(content);
  }
  print('  ✅ Initial Test Screen 특별 수정 완료');
}

Future<void> fixWorkoutScreenConstants() async {
  print('💪 Workout Screen 특별 수정 중...');

  final file = File('lib/screens/workout_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 가장 문제가 되는 패턴들 수정
    content = content.replaceAll(
      'const LinearProgressIndicator(',
      'LinearProgressIndicator(',
    );
    content = content.replaceAll(
      'const AnimatedContainer(',
      'AnimatedContainer(',
    );
    content = content.replaceAll(
      'const CircularProgressIndicator(',
      'CircularProgressIndicator(',
    );

    // const_with_non_const 수정
    content = content.replaceAll('const Duration(', 'Duration(');
    content = content.replaceAll('const Curve.', 'Curves.');

    await file.writeAsString(content);
  }
  print('  ✅ Workout Screen 특별 수정 완료');
}
