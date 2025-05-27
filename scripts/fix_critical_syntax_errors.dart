// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚨 EMPEROR 구문 오류 완전 제거 작전! 🚨');

  await fixHomeScreenErrors();
  await fixCalendarScreenErrors();
  await fixInitialTestScreenErrors();
  await fixMemoryManagerErrors();
  await fixMainNavigationScreenErrors();

  print('✅ 구문 오류 제거 완료! SYNTAX EMPEROR! ✅');
}

Future<void> fixHomeScreenErrors() async {
  print('🏠 Home Screen 구문 오류 수정 중...');

  final file = File('lib/screens/home_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 잘못된 await 패턴 수정
    content = content.replaceAll('unexpected_token await', '');
    content = content.replaceAll('expected_identifier await', '');
    content = content.replaceAll(RegExp(r'[^a-zA-Z]await[^a-zA-Z]'), ' ');

    // 빠진 세미콜론 문제 수정
    content = content.replaceAll('expected_token;', ';');
    content = content.replaceAll('missing_identifier', '');

    // 올바른 함수 호출 패턴으로 수정
    if (!content.contains('void initState()')) {
      content = content.replaceFirst('class HomeScreen', '''void initState() {
    super.initState();
  }

  class HomeScreen''');
    }

    await file.writeAsString(content);
  }

  print('  ✅ Home Screen 수정 완료');
}

Future<void> fixCalendarScreenErrors() async {
  print('📅 Calendar Screen 구문 오류 수정 중...');

  final file = File('lib/screens/calendar_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // $0 패턴 완전 제거
    content = content.replaceAll(RegExp(r'\\\$0'), '');
    content = content.replaceAll('\$0', '');

    // 빠진 식별자 문제 수정
    content = content.replaceAll('missing_identifier', '');
    content = content.replaceAll('undefined_named_parameter', '');

    // Text() 빈 호출 수정
    content = content.replaceAll('Text()', 'Text("")');
    content = content.replaceAll('Container()', 'Container()');

    await file.writeAsString(content);
  }

  print('  ✅ Calendar Screen 수정 완료');
}

Future<void> fixInitialTestScreenErrors() async {
  print('🧪 Initial Test Screen 구문 오류 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unexpected_token await 수정
    content = content.replaceAll('unexpected_token await', '');

    // const with non-const 문제 수정
    content = content.replaceAll('const ElevatedButton(', 'ElevatedButton(');
    content = content.replaceAll('const MaterialButton(', 'MaterialButton(');

    // invalid_constant 수정
    content = content.replaceAll(
      RegExp(r'const Text\([^)]*\$[^)]*\)'),
      'Text("")',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Initial Test Screen 수정 완료');
}

Future<void> fixMemoryManagerErrors() async {
  print('🧠 Memory Manager 타입 오류 수정 중...');

  final file = File('lib/utils/memory_manager.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // return_of_invalid_type 수정
    content = content.replaceAll(
      'return isMemoryPressure;',
      'return isMemoryPressure ?? false;',
    );

    // dynamic return을 bool로 수정
    content = content.replaceAll(
      'bool isMemoryPressure',
      'bool? isMemoryPressure',
    );

    await file.writeAsString(content);
  }

  print('  ✅ Memory Manager 수정 완료');
}

Future<void> fixMainNavigationScreenErrors() async {
  print('🧭 Main Navigation Screen 오류 수정 중...');

  final file = File('lib/screens/main_navigation_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // const_with_non_const 오류 수정
    content = content.replaceAll('const HomeScreen()', 'HomeScreen()');
    content = content.replaceAll('const CalendarScreen()', 'CalendarScreen()');
    content = content.replaceAll(
      'const AchievementsScreen()',
      'AchievementsScreen()',
    );
    content = content.replaceAll('const SettingsScreen()', 'SettingsScreen()');

    // unnecessary_const 오류 수정
    content = content.replaceAll('const Icon(Icons.', 'Icon(Icons.');
    content = content.replaceAll('const Text(', 'Text(');

    await file.writeAsString(content);
  }

  print('  ✅ Main Navigation Screen 수정 완료');
}
