// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚀 FINAL EMPEROR CLEANUP! 모든 문제 박멸 작전! 🚀');

  // 1. theme.dart const 문제들 완전 해결
  await fixThemeConstIssues();

  // 2. main.dart const 문제들 해결
  await fixMainConstIssues();

  // 3. progress.dart final 변수 문제 해결
  await fixProgressFinalIssues();

  // 4. chad_encouragement_service.dart quotes 문제 완전 해결
  await fixChadServiceQuotes();

  // 5. constants.dart quotes 문제 해결
  await fixConstantsQuotes();

  // 6. 테스트 파일들 const 문제 완전 해결
  await fixAllTestFiles();

  // 7. 스크립트 파일들 avoid_print 해결
  await addDebugPrintImports();

  print('✅ FINAL CLEANUP 완료! ABSOLUTE EMPEROR LEVEL 달성! ✅');
}

Future<void> fixThemeConstIssues() async {
  print('🎨 Theme.dart const 문제 완전 해결 중...');

  final file = File('lib/utils/theme.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 잘못된 const들 제거
    content = content.replaceAll(
      'const BorderRadius.circular',
      'BorderRadius.circular',
    );
    content = content.replaceAll('const Color(', 'Color(');
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
    content = content.replaceAll(
      'const RoundedRectangleBorder',
      'RoundedRectangleBorder',
    );

    // TextStyle은 const 유지
    content = content.replaceAll('TextStyle(', 'const TextStyle(');

    await file.writeAsString(content);
    print('  ✅ Theme.dart 수정 완료');
  }
}

Future<void> fixMainConstIssues() async {
  print('🏠 Main.dart const 문제 해결 중...');

  final file = File('lib/main.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // main.dart의 widget들에 const 추가
    final patterns = [
      'AppLocalizations.localizationsDelegates',
      'AppLocalizations.supportedLocales',
      'SplashScreen({super.key})',
      'SafeArea(',
      'Column(',
      'Align(',
      'Padding(',
      'ElevatedButton(',
      'Row(',
      'Icon(',
      'SizedBox(',
      'Text(',
      'Expanded(',
      'Center(',
      'ClipRRect(',
      'Container(',
    ];

    for (final pattern in patterns) {
      if (!content.contains('const $pattern')) {
        content = content.replaceAll(pattern, 'const $pattern');
      }
    }

    await file.writeAsString(content);
    print('  ✅ Main.dart 수정 완료');
  }
}

Future<void> fixProgressFinalIssues() async {
  print('📊 Progress.dart final 변수 문제 해결 중...');

  final file = File('lib/models/progress.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 54, 55라인의 final 변수 문제 해결
    content = content.replaceAll(
      'double weekProgress = ',
      'final double weekProgress = ',
    );
    content = content.replaceAll(
      'double dayProgress = ',
      'final double dayProgress = ',
    );

    await file.writeAsString(content);
    print('  ✅ Progress.dart 수정 완료');
  }
}

Future<void> fixChadServiceQuotes() async {
  print('💪 Chad service quotes 문제 완전 해결 중...');

  final file = File('lib/services/chad_encouragement_service.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 모든 double quotes를 single quotes로 변경
    final doubleQuotePatterns = [
      '"motivationMessage1"',
      '"motivationMessage2"',
      '"motivationMessage3"',
      '"motivationMessage4"',
      '"motivationMessage5"',
      '"completionMessage1"',
      '"completionMessage2"',
      '"completionMessage3"',
      '"completionMessage4"',
      '"completionMessage5"',
      '"encouragementMessage1"',
      '"encouragementMessage2"',
      '"encouragementMessage3"',
      '"encouragementMessage4"',
      '"encouragementMessage5"',
      '"chadMessage1"',
      '"chadMessage2"',
      '"chadMessage3"',
      '"chadMessage4"',
      '"chadMessage5"',
      '"chadMessage6"',
      '"message"',
      '"Chad message type not found"',
    ];

    for (final pattern in doubleQuotePatterns) {
      content = content.replaceAll(pattern, pattern.replaceAll('"', '\''));
    }

    await file.writeAsString(content);
    print('  ✅ Chad service quotes 수정 완료');
  }
}

Future<void> fixConstantsQuotes() async {
  print('📋 Constants.dart quotes 문제 해결 중...');

  final file = File('lib/utils/constants.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // URL과 email 패턴들
    content = content.replaceAll('"errorGeneral"', '\'errorGeneral\'');
    content = content.replaceAll('"errorDatabase"', '\'errorDatabase\'');
    content = content.replaceAll('"errorNetwork"', '\'errorNetwork\'');
    content = content.replaceAll('"errorNotFound"', '\'errorNotFound\'');
    content = content.replaceAll(
      '"successWorkoutCompleted"',
      '\'successWorkoutCompleted\'',
    );
    content = content.replaceAll(
      '"successProfileSaved"',
      '\'successProfileSaved\'',
    );
    content = content.replaceAll(
      '"successSettingsSaved"',
      '\'successSettingsSaved\'',
    );
    content = content.replaceAll(
      '"https://github.com/',
      '\'https://github.com/',
    );
    content = content.replaceAll(
      '"support@mission100chad.com"',
      '\'support@mission100chad.com\'',
    );

    await file.writeAsString(content);
    print('  ✅ Constants.dart 수정 완료');
  }
}

Future<void> fixAllTestFiles() async {
  print('🧪 모든 테스트 파일 const 문제 해결 중...');

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

      // 테스트에서 자주 사용되는 패턴들에 const 추가
      final patterns = [
        'ProviderScope(',
        'Mission100App(',
        'MaterialApp(',
        'Scaffold(',
        'AppBar(',
        'Text(',
        'Center(',
        'Container(',
        'Column(',
        'Row(',
        'SizedBox(',
        'Icon(',
        'Padding(',
      ];

      for (final pattern in patterns) {
        if (!content.contains('const $pattern')) {
          content = content.replaceAll(pattern, 'const $pattern');
        }
      }

      await file.writeAsString(content);
    }
  }

  print('  ✅ 모든 테스트 파일 수정 완료');
}

Future<void> addDebugPrintImports() async {
  print('🖨️ 스크립트 파일들 debugPrint 변환 중...');

  final scriptFiles = [
    'scripts/fix_lint_issues.dart',
    'scripts/fix_major_issues.dart',
    'scripts/optimize_code.dart',
  ];

  for (final filePath in scriptFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // flutter/foundation.dart import 추가 (아직 없다면)
      if (!content.contains('import \'package:flutter/foundation.dart\'')) {
        content = 'import \'package:flutter/foundation.dart\';\n$content';
      }

      // print를 debugPrint로 변경
      content = content.replaceAll('print(', 'debugPrint(');

      await file.writeAsString(content);
    }
  }

  print('  ✅ 스크립트 파일들 debugPrint 변환 완료');
}

Future<void> fixWorkoutHistoryService() async {
  print('📈 Workout history service final 변수 문제 해결 중...');

  final file = File('lib/services/workout_history_service.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 24라인의 final 변수 문제 해결
    content = content.replaceAll(
      RegExp(r'  List<Map<String, dynamic>> maps = '),
      '  final List<Map<String, dynamic>> maps = ',
    );

    await file.writeAsString(content);
    print('  ✅ Workout history service 수정 완료');
  }
}
