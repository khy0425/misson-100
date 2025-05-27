// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('⚡ ULTIMATE ERROR STRIKE 작전! ⚡');

  await fixFutureIntErrors();
  await fixTestFileImports();
  await fixRemainingConstErrors();
  await fixAllInvalidConstantsAgain();

  print('✅ ULTIMATE ERROR STRIKE 완료! ZERO ERROR EMPEROR! ✅');
}

Future<void> fixFutureIntErrors() async {
  print('🔮 Future<int> vs int 에러들 완전 해결 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // Future<int> vs int 문제 해결 - await 추가
    content = content.replaceAllMapped(
      RegExp(r'pushupCount:\s*([^,)]+\.getCurrentMaxPushups\(\))'),
      (match) => 'pushupCount: await ${match.group(1)}',
    );

    content = content.replaceAllMapped(
      RegExp(r'maxPushups:\s*([^,)]+\.getCurrentMaxPushups\(\))'),
      (match) => 'maxPushups: await ${match.group(1)}',
    );

    // async 메소드로 변경 필요한 경우
    if (content.contains('await') && !content.contains('Future<void> _')) {
      content = content.replaceAll(
        'void _completeInitialTest(',
        'Future<void> _completeInitialTest(',
      );
    }

    await file.writeAsString(content);
  }
  print('  ✅ Future<int> vs int 에러들 완전 해결');
}

Future<void> fixTestFileImports() async {
  print('🧪 Test 파일 import 에러들 완전 해결 중...');

  final files = ['test/app_test.dart', 'test/widget_test.dart'];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // avoid_relative_lib_imports 에러 해결
      content = content.replaceAll(
        "import '../lib/main.dart';",
        "import 'package:mission100_chad_pushup/main.dart';",
      );

      await file.writeAsString(content);
    }
  }
  print('  ✅ Test 파일 import 에러들 완전 해결');
}

Future<void> fixRemainingConstErrors() async {
  print('🔧 남은 const 에러들 완전 해결 중...');

  final files = [
    'lib/screens/initial_test_screen.dart',
    'lib/screens/workout_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // const_with_non_const 완전 제거
      content = content.replaceAll(
        'const MaterialPageRoute<void>(',
        'MaterialPageRoute<void>(',
      );
      content = content.replaceAll('const Navigator.', 'Navigator.');

      await file.writeAsString(content);
    }
  }
  print('  ✅ 남은 const 에러들 완전 해결');
}

Future<void> fixAllInvalidConstantsAgain() async {
  print('💥 모든 invalid_constant 완전 재정리 중...');

  final files = [
    'lib/screens/initial_test_screen.dart',
    'lib/screens/workout_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // 모든 가능한 invalid_constant 패턴들 완전 제거
      final patterns = [
        'const Color(',
        'const LinearGradient(',
        'const BoxDecoration(',
        'const BorderRadius.',
        'const EdgeInsets.',
        'const Duration(',
        'const Offset(',
        'const RoundedRectangleBorder(',
        'const Radius.',
        'const MaterialPageRoute(',
        'const TextStyle(',
        'const BoxShadow(',
        'const Border.',
      ];

      for (final pattern in patterns) {
        content = content.replaceAll(
          pattern,
          pattern.replaceFirst('const ', ''),
        );
      }

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 invalid_constant 완전 재정리');
}
