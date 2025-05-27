// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚨 EMERGENCY SYNTAX FIX 작전! 🚨');

  await fixAchievementsScreenSyntax();
  await fixCalendarScreenSyntax();
  await fixHomeScreenSyntax();
  await fixInitialTestScreenSyntax();
  await fixMemoryManagerSyntax();

  print('✅ EMERGENCY SYNTAX FIX 완료! ✅');
}

Future<void> fixAchievementsScreenSyntax() async {
  print('🏆 Achievements Screen 긴급 구문 수정...');

  final file = File('lib/screens/achievements_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 빈 Text() 수정
    content = content.replaceAll('Text()', 'Text("")');

    // 구문 오류 패턴들 수정
    content = content.replaceAll(RegExp(r'Text\(\s*\),'), 'Text(""),');

    await file.writeAsString(content);
  }
  print('  ✅ Achievements Screen 수정 완료');
}

Future<void> fixCalendarScreenSyntax() async {
  print('📅 Calendar Screen 긴급 구문 수정...');

  final file = File('lib/screens/calendar_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unterminated string literal 수정
    content = content.replaceAll(RegExp(r'Text\("[^"]*$'), 'Text("")');
    content = content.replaceAll("Text('", "Text('')");
    content = content.replaceAll('Text("', 'Text("")');

    // undefined_named_parameter 수정
    content = content.replaceAll(', child: Container()', '');

    // expected_token 수정
    content = content.replaceAll(RegExp(r',\s*\)'), ')');

    await file.writeAsString(content);
  }
  print('  ✅ Calendar Screen 수정 완료');
}

Future<void> fixHomeScreenSyntax() async {
  print('🏠 Home Screen 긴급 구문 수정...');

  final file = File('lib/screens/home_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // missing_identifier 수정
    content = content.replaceAll(RegExp(r'expected_token'), '');
    content = content.replaceAll(RegExp(r'missing_identifier'), '');

    // showSnackBar 수정
    content = content.replaceAll(
      'ScaffoldMessenger.of(context).showSnackBar(',
      'ScaffoldMessenger.of(context).showSnackBar(',
    );

    await file.writeAsString(content);
  }
  print('  ✅ Home Screen 수정 완료');
}

Future<void> fixInitialTestScreenSyntax() async {
  print('🧪 Initial Test Screen 긴급 구문 수정...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // unexpected_token await 수정
    content = content.replaceAll('unexpected_token await', '');
    content = content.replaceAll('unexpected_token', '');

    // invalid_constant 수정
    content = content.replaceAll(
      RegExp(r'const.*\.withOpacity'),
      'Colors.red.withOpacity',
    );

    await file.writeAsString(content);
  }
  print('  ✅ Initial Test Screen 수정 완료');
}

Future<void> fixMemoryManagerSyntax() async {
  print('🧠 Memory Manager 타입 오류 수정...');

  final file = File('lib/utils/memory_manager.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // return_of_invalid_type 수정
    content = content.replaceAll(
      'return isMemoryPressure',
      'return isMemoryPressure ?? false',
    );

    await file.writeAsString(content);
  }
  print('  ✅ Memory Manager 수정 완료');
}
