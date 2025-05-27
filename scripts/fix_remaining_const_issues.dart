// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('⚡ EMPEROR CONST 최종 정리 작전! ⚡');

  await fixMainConstIssues();
  await fixScreenConstIssues();
  await fixThemeConstIssues();
  await fixTestConstIssues();
  await fixUnnecessaryConsts();
  await fixPreferConstConstructors();
  await addMissingConsts();

  print('✅ CONST 최종 정리 완료! PERFECT EMPEROR! ✅');
}

Future<void> fixMainConstIssues() async {
  print('🏠 Main.dart const 이슈 수정 중...');

  final file = File('lib/main.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // localizationsDelegates와 supportedLocales const 제거
    content = content.replaceAll(
      'const AppLocalizations.',
      'AppLocalizations.',
    );

    // 동적 값이 포함된 const 제거
    content = content.replaceAll(RegExp(r'const\s+(?=\w+\([^)]*\$)'), '');
    content = content.replaceAll(RegExp(r'const\s+(?=\w+\([^)]*context)'), '');

    await file.writeAsString(content);
    print('  ✅ Main.dart const 이슈 수정 완료');
  }
}

Future<void> fixScreenConstIssues() async {
  print('📱 Screen 파일들 const 이슈 수정 중...');

  final screenFiles = [
    'lib/screens/achievements_screen.dart',
    'lib/screens/calendar_screen.dart',
    'lib/screens/workout_screen.dart',
    'lib/screens/home_screen.dart',
    'lib/screens/main_navigation_screen.dart',
    'lib/screens/settings_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
  ];

  for (final filePath in screenFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // invalid_constant 에러 수정 - 변수 보간이 있는 Text에서 const 제거
      content = content.replaceAllMapped(
        RegExp(r'const Text\([^)]*\$[^)]*\)'),
        (match) {
          final inner = match.group(0)!.substring(11); // "const Text(" 제거
          return 'Text($inner';
        },
      );

      // 동적 값이 있는 const 제거
      content = content.replaceAll(RegExp(r'const\s+(?=\w+\([^)]*\.\w+)'), '');
      content = content.replaceAll(
        RegExp(r'const\s+(?=\w+\([^)]*\[[^]]*\])'),
        '',
      );

      // const_with_non_const 에러 수정
      content = content.replaceAll(
        'const LinearProgressIndicator(',
        'LinearProgressIndicator(',
      );
      content = content.replaceAll(
        'const CircularProgressIndicator(',
        'CircularProgressIndicator(',
      );
      content = content.replaceAll(
        'const MaterialPageRoute(',
        'MaterialPageRoute(',
      );

      await file.writeAsString(content);
    }
  }

  print('  ✅ Screen 파일들 const 이슈 수정 완료');
}

Future<void> fixThemeConstIssues() async {
  print('🎨 Theme const 이슈 수정 중...');

  final file = File('lib/utils/theme.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // prefer_const_constructors 추가 (TextStyle만)
    content = content.replaceAll('TextStyle(', 'const TextStyle(');
    content = content.replaceAll('const const TextStyle(', 'const TextStyle(');

    // 다른 위젯들은 const 제거 유지
    content = content.replaceAll('const Color(', 'Color(');
    content = content.replaceAll('const BorderRadius', 'BorderRadius');
    content = content.replaceAll('const EdgeInsets', 'EdgeInsets');
    content = content.replaceAll(
      'const RoundedRectangleBorder',
      'RoundedRectangleBorder',
    );

    await file.writeAsString(content);
    print('  ✅ Theme const 이슈 수정 완료');
  }
}

Future<void> fixTestConstIssues() async {
  print('🧪 테스트 파일 const 이슈 수정 중...');

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

      // unnecessary_const 제거
      content = content.replaceAll('const MaterialApp(', 'MaterialApp(');
      content = content.replaceAll('const WidgetTester', 'WidgetTester');
      content = content.replaceAll('const MyApp(', 'MyApp(');

      await file.writeAsString(content);
    }
  }

  print('  ✅ 테스트 파일 const 이슈 수정 완료');
}

Future<void> fixUnnecessaryConsts() async {
  print('🗑️ 불필요한 const 제거 중...');

  final allDartFiles = await Directory('lib')
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  for (final file in allDartFiles) {
    String content = await file.readAsString();

    // 명백히 불필요한 const들 제거
    content = content.replaceAll('const Container(', 'Container(');
    content = content.replaceAll('const Scaffold(', 'Scaffold(');
    content = content.replaceAll('const Column(', 'Column(');
    content = content.replaceAll('const Row(', 'Row(');
    content = content.replaceAll('const Expanded(', 'Expanded(');
    content = content.replaceAll('const Flexible(', 'Flexible(');
    content = content.replaceAll('const Center(', 'Center(');
    content = content.replaceAll('const Padding(', 'Padding(');
    content = content.replaceAll('const SafeArea(', 'SafeArea(');
    content = content.replaceAll('const ClipRRect(', 'ClipRRect(');
    content = content.replaceAll('const ElevatedButton(', 'ElevatedButton(');
    content = content.replaceAll(
      'const FloatingActionButton(',
      'FloatingActionButton(',
    );
    content = content.replaceAll('const AppBar(', 'AppBar(');
    content = content.replaceAll('const Card(', 'Card(');
    content = content.replaceAll('const ListTile(', 'ListTile(');
    content = content.replaceAll('const Switch(', 'Switch(');
    content = content.replaceAll('const Slider(', 'Slider(');
    content = content.replaceAll('const DropdownButton(', 'DropdownButton(');

    // 스타일 관련 const 제거
    content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
    content = content.replaceAll('const BorderRadius.', 'BorderRadius.');
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
    content = content.replaceAll('const Color(', 'Color(');
    content = content.replaceAll('const Alignment.', 'Alignment.');

    await file.writeAsString(content);
  }

  print('  ✅ 불필요한 const 제거 완료');
}

Future<void> fixPreferConstConstructors() async {
  print('✨ prefer_const_constructors 추가 중...');

  final allDartFiles = await Directory('lib')
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  for (final file in allDartFiles) {
    String content = await file.readAsString();

    // const를 추가해야 하는 간단한 위젯들
    content = content.replaceAll('SizedBox(', 'const SizedBox(');
    content = content.replaceAll('const const SizedBox(', 'const SizedBox(');

    content = content.replaceAll('Text(\'', 'const Text(\'');
    content = content.replaceAll('const const Text(', 'const Text(');

    content = content.replaceAll('Icon(Icons.', 'const Icon(Icons.');
    content = content.replaceAll('const const Icon(', 'const Icon(');

    content = content.replaceAll('Divider(', 'const Divider(');
    content = content.replaceAll('const const Divider(', 'const Divider(');

    content = content.replaceAll('Spacer(', 'const Spacer(');
    content = content.replaceAll('const const Spacer(', 'const Spacer(');

    await file.writeAsString(content);
  }

  print('  ✅ prefer_const_constructors 추가 완료');
}

Future<void> addMissingConsts() async {
  print('➕ 빠진 const 추가 중...');

  final files = [
    'lib/services/achievement_service.dart',
    'lib/services/workout_history_service.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // prefer_final_locals 수정 - 단순한 패턴만 수정
      content = content.replaceAll(
        'List<Achievement> achievements = ',
        'final achievements = ',
      );
      content = content.replaceAll(
        'Map<String, dynamic> data = ',
        'final data = ',
      );

      await file.writeAsString(content);
    }
  }

  print('  ✅ 빠진 const 추가 완료');
}
