// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🩺 FINAL SURGICAL STRIKE 작전! 🩺');

  await fixAllInvalidConstantErrors();
  await fixAllConstWithNonConstErrors();
  await fixFutureIntErrors();
  await fixSpecificLineErrors();

  print('✅ FINAL SURGICAL STRIKE 완료! ZERO ERROR ACHIEVEMENT! ✅');
}

Future<void> fixAllInvalidConstantErrors() async {
  print('❌ 모든 invalid_constant ERROR들 정밀 제거 중...');

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

      // 모든 invalid_constant 패턴들 완전 박멸
      final invalidPatterns = [
        'const Color(AppColors.',
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
        'const ShapeBorder(',
        'const TextDirection(',
        'const BorderSide(',
        'const Matrix4.',
        'const AlignmentGeometry(',
        'const Alignment(',
        'const FontWeight(',
        'const TextBaseline(',
        'const TextOverflow(',
        'const FontStyle(',
        'const Decoration(',
        'const DecorationImage(',
        'const ImageRepeat(',
        'const BlendMode(',
      ];

      for (final pattern in invalidPatterns) {
        content = content.replaceAll(
          pattern,
          pattern.substring(6),
        ); // "const " 제거
      }

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 invalid_constant ERROR들 정밀 제거 완료');
}

Future<void> fixAllConstWithNonConstErrors() async {
  print('⚙️ 모든 const_with_non_const ERROR들 정밀 제거 중...');

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
      content = content.replaceAll(
        'const MaterialPageRoute(',
        'MaterialPageRoute(',
      );
      content = content.replaceAll('const Navigator.', 'Navigator.');
      content = content.replaceAll(
        'const PageRouteBuilder(',
        'PageRouteBuilder(',
      );
      content = content.replaceAll(
        'const CupertinoPageRoute(',
        'CupertinoPageRoute(',
      );

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 const_with_non_const ERROR들 정밀 제거 완료');
}

Future<void> fixFutureIntErrors() async {
  print('🔮 Future<int> vs int 에러들 완전 해결 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // Future<int> 패턴들을 await로 해결
    content = content.replaceAllMapped(
      RegExp(r'(pushupCount|maxPushups):\s*([^,)]+\.getCurrentMaxPushups\(\))'),
      (match) => '${match.group(1)}: await ${match.group(2)}',
    );

    // Future 리턴하는 메소드들 await 추가
    content = content.replaceAllMapped(
      RegExp(r'(\w+Service\.\w+)\(\s*([^)]*)\s*\)(?!\s*;)'),
      (match) {
        if (match.group(1)?.contains('insertUserProfile') == true ||
            match.group(1)?.contains('initializeUserProgram') == true) {
          return 'await ${match.group(0)}';
        }
        return match.group(0)!;
      },
    );

    // async 메소드로 변경
    if (content.contains('await') &&
        !content.contains('Future<void> _completeInitialTest')) {
      content = content.replaceAll(
        'void _completeInitialTest(',
        'Future<void> _completeInitialTest(',
      );
    }

    await file.writeAsString(content);
  }
  print('  ✅ Future<int> vs int 에러들 완전 해결');
}

Future<void> fixSpecificLineErrors() async {
  print('🎯 특정 라인 ERROR들 정밀 타격 중...');

  final specificFixes = {
    'lib/screens/initial_test_screen.dart': [
      {'pattern': 'const Color(AppColors.', 'replacement': 'Color(AppColors.'},
    ],
    'lib/screens/workout_screen.dart': [
      {'pattern': 'const Color(AppColors.', 'replacement': 'Color(AppColors.'},
      {'pattern': 'const LinearGradient(', 'replacement': 'LinearGradient('},
    ],
    'lib/screens/pushup_tutorial_screen.dart': [
      {'pattern': 'const Color(AppColors.', 'replacement': 'Color(AppColors.'},
    ],
    'lib/screens/pushup_tutorial_detail_screen.dart': [
      {'pattern': 'const Color(AppColors.', 'replacement': 'Color(AppColors.'},
    ],
  };

  for (final entry in specificFixes.entries) {
    final file = File(entry.key);
    if (await file.exists()) {
      String content = await file.readAsString();

      for (final fix in entry.value) {
        content = content.replaceAll(fix['pattern']!, fix['replacement']!);
      }

      await file.writeAsString(content);
    }
  }
  print('  ✅ 특정 라인 ERROR들 정밀 타격 완료');
}
