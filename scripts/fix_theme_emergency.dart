// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚨 EMPEROR EMERGENCY! theme.dart 긴급 수정 작전! 🚨');

  await fixThemeEmergency();
  await fixMainEmergency();
  await fixTestEmergency();
  await fixChadsServiceEmergency();

  print('✅ 긴급 수정 완료! EMPEROR 구조 성공! ✅');
}

Future<void> fixThemeEmergency() async {
  print('🎨 Theme.dart 긴급 수정 중...');

  final file = File('lib/utils/theme.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 1. const const 중복 제거 (가장 심각한 문제)
    content = content.replaceAll('const const', 'const');

    // 2. Color(, BorderRadius.circular, EdgeInsets에서 const 제거
    content = content.replaceAll('const Color(', 'Color(');
    content = content.replaceAll(
      'const BorderRadius.circular',
      'BorderRadius.circular',
    );
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');
    content = content.replaceAll(
      'const RoundedRectangleBorder',
      'RoundedRectangleBorder',
    );

    // 3. TextStyle은 const 유지하되 중복 제거
    content = content.replaceAll('TextStyle(', 'const TextStyle(');
    content = content.replaceAll('const const TextStyle(', 'const TextStyle(');

    await file.writeAsString(content);
    print('  ✅ Theme.dart 긴급 수정 완료');
  }
}

Future<void> fixMainEmergency() async {
  print('🏠 Main.dart 긴급 수정 중...');

  final file = File('lib/main.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // localizationsDelegates 문제 수정
    content = content.replaceAll(
      'localizationsDelegates: [\n        const AppLocalizations.localizationsDelegates,\n      ].expand((x) => x).toList(),',
      'localizationsDelegates: AppLocalizations.localizationsDelegates,',
    );

    // supportedLocales 문제 수정
    content = content.replaceAll(
      'supportedLocales: const AppLocalizations.supportedLocales,',
      'supportedLocales: AppLocalizations.supportedLocales,',
    );

    // 불필요한 const들 제거
    content = content.replaceAll('const Container(', 'Container(');
    content = content.replaceAll('const LinearGradient(', 'LinearGradient(');
    content = content.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    content = content.replaceAll('const Alignment.', 'Alignment.');
    content = content.replaceAll('const Scaffold(', 'Scaffold(');
    content = content.replaceAll('const SafeArea(', 'SafeArea(');
    content = content.replaceAll('const Column(', 'Column(');
    content = content.replaceAll('const Expanded(', 'Expanded(');
    content = content.replaceAll('const Center(', 'Center(');
    content = content.replaceAll('const ClipRRect(', 'ClipRRect(');
    content = content.replaceAll('const ElevatedButton(', 'ElevatedButton(');
    content = content.replaceAll(
      'const ElevatedButton.styleFrom(',
      'ElevatedButton.styleFrom(',
    );
    content = content.replaceAll(
      'const RoundedRectangleBorder(',
      'RoundedRectangleBorder(',
    );
    content = content.replaceAll(
      'const BorderRadius.circular(',
      'BorderRadius.circular(',
    );
    content = content.replaceAll('const EdgeInsets.', 'EdgeInsets.');

    // Container와 Icon은 child/data가 있으면 const 불가
    content = content.replaceAll('const Icon(Icons.', 'const Icon(Icons.');
    content = content.replaceAll('const Row(', 'Row(');
    content = content.replaceAll('const SizedBox(', 'const SizedBox(');
    content = content.replaceAll('const Text(', 'const Text(');
    content = content.replaceAll('const TextStyle(', 'const TextStyle(');

    await file.writeAsString(content);
    print('  ✅ Main.dart 긴급 수정 완료');
  }
}

Future<void> fixTestEmergency() async {
  print('🧪 테스트 파일 긴급 수정 중...');

  final testFile = File('test/integration/app_integration_test.dart');
  if (await testFile.exists()) {
    String content = await testFile.readAsString();

    // byconst 오타 수정
    content = content.replaceAll('find.byconst', 'find.byType');

    await testFile.writeAsString(content);
    print('  ✅ 통합 테스트 파일 수정 완료');
  }
}

Future<void> fixChadsServiceEmergency() async {
  print('💪 Chad service 긴급 수정 중...');

  final file = File('lib/services/chad_encouragement_service.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 모든 남은 double quotes를 single quotes로 변경
    final quotes = [
      '"ALPHA EMPEROR',
      '"🔥 ULTRA',
      '"💪 ALPHA',
      '"⚡ MEGA',
      '"🚀 SUPREME',
      '"👑 ULTIMATE',
      '"💯 LEGENDARY',
      '"🌟 UNSTOPPABLE',
      '"⭐ MAXIMUM',
    ];

    for (final quote in quotes) {
      content = content.replaceAll(quote, quote.replaceFirst('"', '\''));
    }

    // 종료 quotes도 수정
    content = content.replaceAll('EMPEROR!"', 'EMPEROR!\'');
    content = content.replaceAll('ALPHA!"', 'ALPHA!\'');
    content = content.replaceAll('POWER!"', 'POWER!\'');
    content = content.replaceAll('CHAD!"', 'CHAD!\'');

    await file.writeAsString(content);
    print('  ✅ Chad service 수정 완료');
  }
}
