// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  debugPrint('🚀 ULTIMATE EMPEROR 코드 품질 MAX 업그레이드! 🚀');

  // 1. 타입 추론 문제들 해결
  await fixTypeInference();

  // 2. const 생성자 문제들 해결
  await fixConstConstructors();

  // 3. await 누락 문제들 해결
  await fixMissingAwaits();

  // 4. final 변수 문제들 해결
  await fixFinalVariables();

  // 5. Single quotes 문제들 해결
  await fixSingleQuotes();

  debugPrint('✅ 모든 MAJOR 문제 해결 완료! EMPEROR LEVEL 달성! ✅');
}

Future<void> fixTypeInference() async {
  debugPrint('🔍 타입 추론 문제 수정 중...');

  // MaterialPageRoute 타입 추론 문제 해결
  final files = [
    'lib/screens/home_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      content = content.replaceAll(
        'MaterialPageRoute(',
        'MaterialPageRoute<void>(',
      );
      await file.writeAsString(content);
    }
  }

  // Future.delayed 타입 추론 문제 해결
  final delayedFiles = [
    'lib/screens/initial_test_screen.dart',
    'lib/screens/statistics_screen.dart',
  ];

  for (final filePath in delayedFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      content = content.replaceAll('Future.delayed(', 'Future<void>.delayed(');
      await file.writeAsString(content);
    }
  }

  // showDialog 타입 추론 문제 해결
  final dialogFiles = ['lib/screens/settings_screen.dart'];

  for (final filePath in dialogFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      content = content.replaceAll('showDialog(', 'showDialog<void>(');
      await file.writeAsString(content);
    }
  }

  debugPrint('  ✅ 타입 추론 문제 수정 완료');
}

Future<void> fixConstConstructors() async {
  debugPrint('🏗️ Const constructors 문제 수정 중...');

  // 여러 파일들의 const 생성자 문제들을 일괄 수정
  final patterns = {
    'lib/screens/achievements_screen.dart': [
      'SizedBox(',
      'Padding(',
      'Text(',
      'Icon(',
    ],
    'lib/screens/calendar_screen.dart': [
      'SizedBox(',
      'Padding(',
      'Text(',
      'Icon(',
    ],
    'lib/screens/main_navigation_screen.dart': ['SizedBox(', 'Icon('],
    'lib/screens/pushup_tutorial_screen.dart': ['SizedBox('],
    'lib/screens/workout_screen.dart': ['SizedBox('],
    'lib/utils/theme.dart': [
      'TextStyle(',
      'BorderRadius.circular(',
      'EdgeInsets.',
      'Color(',
    ],
  };

  for (final entry in patterns.entries) {
    final file = File(entry.key);
    if (await file.exists()) {
      String content = await file.readAsString();

      for (final pattern in entry.value) {
        if (!content.contains('const $pattern')) {
          content = content.replaceAll(pattern, 'const $pattern');
        }
      }

      await file.writeAsString(content);
    }
  }

  debugPrint('  ✅ Const constructors 수정 완료');
}

Future<void> fixMissingAwaits() async {
  debugPrint('⏰ Missing awaits 문제 수정 중...');

  // unawaited_futures 문제들 해결
  final files = [
    'lib/screens/home_screen.dart',
    'lib/screens/initial_test_screen.dart',
    'lib/screens/statistics_screen.dart',
    'lib/services/database_service.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // 일반적인 패턴들 수정
      content = content.replaceAll(
        'Navigator.pushNamed(',
        'await Navigator.pushNamed(',
      );
      content = content.replaceAll(
        'Navigator.pushReplacementNamed(',
        'await Navigator.pushReplacementNamed(',
      );
      content = content.replaceAll('showSnackBar(', 'await showSnackBar(');

      await file.writeAsString(content);
    }
  }

  debugPrint('  ✅ Missing awaits 수정 완료');
}

Future<void> fixFinalVariables() async {
  debugPrint('🔒 Final 변수 문제 수정 중...');

  // final 변수가 필요한 파일들
  final files = [
    'lib/services/achievement_service.dart',
    'lib/services/workout_history_service.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // var를 final로 변경
      content = content.replaceAll(
        RegExp(r'\s+var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*='),
        '  final \$1 =',
      );

      await file.writeAsString(content);
    }
  }

  debugPrint('  ✅ Final 변수 수정 완료');
}

Future<void> fixSingleQuotes() async {
  debugPrint('📝 Single quotes 문제 수정 중...');

  final file = File('lib/services/chad_encouragement_service.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // double quotes를 single quotes로 변경
    final replacements = {
      '"motivationMessage': '\'motivationMessage',
      '"completionMessage': '\'completionMessage',
      '"encouragementMessage': '\'encouragementMessage',
      '"chadMessage': '\'chadMessage',
      '"message"': '\'message\'',
      '"Chad message type not found"': '\'Chad message type not found\'',
      '"https://github.com/': '\'https://github.com/',
      '"support@mission100chad.com"': '\'support@mission100chad.com\'',
    };

    for (final entry in replacements.entries) {
      content = content.replaceAll(entry.key, entry.value);
    }

    await file.writeAsString(content);
    debugPrint('  ✅ Single quotes 수정 완료');
  }

  // constants.dart의 single quotes 문제도 해결
  final constantsFile = File('lib/utils/constants.dart');
  if (await constantsFile.exists()) {
    String content = await constantsFile.readAsString();

    content = content.replaceAll(
      '"https://github.com/',
      '\'https://github.com/',
    );
    content = content.replaceAll(
      '"support@mission100chad.com"',
      '\'support@mission100chad.com\'',
    );

    await constantsFile.writeAsString(content);
  }
}

// 테스트 파일들의 const 문제 해결
Future<void> fixTestFiles() async {
  debugPrint('🧪 테스트 파일 문제 수정 중...');

  final testFiles = [
    'test/app_test.dart',
    'test/integration/app_integration_test.dart',
    'test/widget_test.dart',
    'test/widgets/home_screen_test.dart',
    'test/widgets/statistics_screen_test.dart',
  ];

  for (final filePath in testFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      content = content.replaceAll('ProviderScope(', 'const ProviderScope(');
      content = content.replaceAll('Mission100App(', 'const Mission100App(');

      await file.writeAsString(content);
    }
  }

  debugPrint('  ✅ 테스트 파일 수정 완료');
}
