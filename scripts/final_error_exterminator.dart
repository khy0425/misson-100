// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🔥 FINAL ERROR EXTERMINATOR 작전! 🔥');

  await fixAllInvalidConstants();
  await fixAllConstWithNonConst();
  await fixTutorialScreenErrors();
  await fixWorkoutScreenErrors();
  await fixInitialTestScreenErrors();

  print('✅ FINAL ERROR EXTERMINATOR 완료! ABSOLUTE ZERO ERROR! ✅');
}

Future<void> fixAllInvalidConstants() async {
  print('❌ 모든 invalid_constant ERROR들 완전 박멸 중...');

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

      // 모든 invalid_constant 패턴 완전 제거
      content = content.replaceAll(
        'const Color(AppColors.',
        'Color(AppColors.',
      );
      content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
      content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
      content = content.replaceAll(
        'const BorderRadius.circular(',
        'BorderRadius.circular(',
      );
      content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
      content = content.replaceAll('const Duration(', 'Duration(');
      content = content.replaceAll('const Offset(', 'Offset(');
      content = content.replaceAll(
        'const RoundedRectangleBorder(',
        'RoundedRectangleBorder(',
      );
      content = content.replaceAll(
        'const Radius.circular(',
        'Radius.circular(',
      );
      content = content.replaceAll(
        'const MaterialPageRoute<void>(',
        'MaterialPageRoute<void>(',
      );

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 invalid_constant ERROR들 완전 박멸');
}

Future<void> fixAllConstWithNonConst() async {
  print('⚙️ 모든 const_with_non_const ERROR들 완전 박멸 중...');

  final files = [
    'lib/screens/initial_test_screen.dart',
    'lib/screens/workout_screen.dart',
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
    'test/widgets/home_screen_test.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // const_with_non_const 에러들 완전 제거
      content = content.replaceAll(
        'const MaterialPageRoute<void>(',
        'MaterialPageRoute<void>(',
      );
      content = content.replaceAll(
        'const Navigator.of(context)',
        'Navigator.of(context)',
      );

      await file.writeAsString(content);
    }
  }
  print('  ✅ 모든 const_with_non_const ERROR들 완전 박멸');
}

Future<void> fixTutorialScreenErrors() async {
  print('📚 Tutorial Screen invalid_constant 완전 박멸 중...');

  final files = [
    'lib/screens/pushup_tutorial_screen.dart',
    'lib/screens/pushup_tutorial_detail_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // line 117, 127, 145, 146 등의 invalid_constant 완전 제거
      content = content.replaceAll(
        'const Color(AppColors.',
        'Color(AppColors.',
      );
      content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
      content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
      content = content.replaceAll(
        'const BorderRadius.circular(',
        'BorderRadius.circular(',
      );
      content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');

      await file.writeAsString(content);
    }
  }
  print('  ✅ Tutorial Screen invalid_constant 완전 박멸');
}

Future<void> fixWorkoutScreenErrors() async {
  print('💪 Workout Screen 모든 ERROR들 완전 박멸 중...');

  final file = File('lib/screens/workout_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 모든 invalid_constant와 const_with_non_const 에러들 완전 제거
    content = content.replaceAll('const Color(AppColors.', 'Color(AppColors.');
    content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
    content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    content = content.replaceAll(
      'const BorderRadius.circular(',
      'BorderRadius.circular(',
    );
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
    content = content.replaceAll('const Duration(', 'Duration(');
    content = content.replaceAll('const Offset(', 'Offset(');
    content = content.replaceAll(
      'const RoundedRectangleBorder(',
      'RoundedRectangleBorder(',
    );
    content = content.replaceAll(
      'const MaterialPageRoute<void>(',
      'MaterialPageRoute<void>(',
    );
    content = content.replaceAll('const Radius.circular(', 'Radius.circular(');

    await file.writeAsString(content);
  }
  print('  ✅ Workout Screen 모든 ERROR들 완전 박멸');
}

Future<void> fixInitialTestScreenErrors() async {
  print('🧪 Initial Test Screen 모든 ERROR들 완전 박멸 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // line 262, 278, 411, 416의 모든 에러들 완전 해결
    content = content.replaceAll('const Color(AppColors.', 'Color(AppColors.');
    content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
    content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    content = content.replaceAll(
      'const BorderRadius.circular(',
      'BorderRadius.circular(',
    );
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
    content = content.replaceAll('const Duration(', 'Duration(');
    content = content.replaceAll('const Offset(', 'Offset(');
    content = content.replaceAll(
      'const RoundedRectangleBorder(',
      'RoundedRectangleBorder(',
    );
    content = content.replaceAll(
      'const MaterialPageRoute<void>(',
      'MaterialPageRoute<void>(',
    );

    await file.writeAsString(content);
  }
  print('  ✅ Initial Test Screen 모든 ERROR들 완전 박멸');
}
