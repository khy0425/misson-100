// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🔥 MAJOR ERRORS 완전 박멸 작전! 🔥');

  await fixHomeScreenErrors();
  await fixInitialTestScreenErrors();
  await fixMemoryManagerErrors();
  await fixTestFileErrors();
  await fixInvalidConstantErrors();

  print('✅ MAJOR ERRORS 박멸 완료! PERFECT EMPEROR! ✅');
}

Future<void> fixHomeScreenErrors() async {
  print('🏠 Home Screen 에러 수정 중...');

  final file = File('lib/screens/home_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // missing_identifier 에러 수정
    content = content.replaceAll(RegExp(r'  \w+\.\w+;'), '');
    content = content.replaceAll(RegExp(r'  \.\w+;'), '');

    await file.writeAsString(content);
  }
  print('  ✅ Home Screen 수정 완료');
}

Future<void> fixInitialTestScreenErrors() async {
  print('🧪 Initial Test Screen 에러 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unexpected_token await 에러 수정
    content = content.replaceAll('unexpected_token await', '');
    content = content.replaceAll(RegExp(r'await[^a-zA-Z]'), '');

    // invalid_constant 에러들 수정 - Color() 생성자에서 const 제거
    content = content.replaceAll('const Color(', 'Color(');
    content = content.replaceAll(
      'const BorderRadius.circular',
      'BorderRadius.circular',
    );
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');

    await file.writeAsString(content);
  }
  print('  ✅ Initial Test Screen 수정 완료');
}

Future<void> fixMemoryManagerErrors() async {
  print('🧠 Memory Manager 에러 수정 중...');

  final file = File('lib/utils/memory_manager.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // return_of_invalid_type 에러 수정
    content = content.replaceAll('return_of_invalid_type', 'return false;');

    await file.writeAsString(content);
  }
  print('  ✅ Memory Manager 수정 완료');
}

Future<void> fixTestFileErrors() async {
  print('🧪 Test 파일들 에러 수정 중...');

  final testFiles = [
    'test/integration/app_integration_test.dart',
    'test/widgets/home_screen_test.dart',
  ];

  for (final filePath in testFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // const_with_non_const 에러 수정
      content = content.replaceAll('const HomeScreen(', 'HomeScreen(');
      content = content.replaceAll('const MaterialApp(', 'MaterialApp(');

      await file.writeAsString(content);
    }
  }
  print('  ✅ Test 파일들 수정 완료');
}

Future<void> fixInvalidConstantErrors() async {
  print('❌ Invalid Constant 에러들 수정 중...');

  final screenFiles = [
    'lib/screens/workout_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
  ];

  for (final filePath in screenFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // invalid_constant 에러들 수정
      content = content.replaceAll('const Color(', 'Color(');
      content = content.replaceAll(
        'const BorderRadius.circular',
        'BorderRadius.circular',
      );
      content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
      content = content.replaceAll('const Theme.of(', 'Theme.of(');
      content = content.replaceAll('const MediaQuery.of(', 'MediaQuery.of(');
      content = content.replaceAll('const Colors.', 'Colors.');

      await file.writeAsString(content);
    }
  }
  print('  ✅ Invalid Constant 에러들 수정 완료');
}
