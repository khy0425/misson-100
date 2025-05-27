// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🔄 FUTURE TYPE ERRORS 완전 해결 작전! 🔄');

  await fixInitialTestScreenFutureErrors();
  await fixAsyncAwaitErrors();
  await fixMissingAwaitErrors();

  print('✅ FUTURE TYPE ERRORS 해결 완료! ASYNC EMPEROR! ✅');
}

Future<void> fixInitialTestScreenFutureErrors() async {
  print('🧪 Initial Test Screen Future<int> 타입 에러 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // argument_type_not_assignable 수정 - Future<int>를 int로 변환
    // 패턴 1: PushupCount(pushupCount: service.getCurrentMaxPushups())
    content = content.replaceAllMapped(
      RegExp(
        r'PushupCount\(\s*pushupCount:\s*([^,)]+\.getCurrentMaxPushups\(\))\s*,',
      ),
      (match) {
        final futureCall = match.group(1)!;
        return 'PushupCount(pushupCount: await $futureCall,';
      },
    );

    // 패턴 2: Navigator.pushReplacement에서 사용되는 경우
    content = content.replaceAllMapped(
      RegExp(r'pushupCount:\s*([^,)]+\.getCurrentMaxPushups\(\))'),
      (match) {
        final futureCall = match.group(1)!;
        return 'pushupCount: await $futureCall';
      },
    );

    // 함수를 async로 변경해야 하는 경우들 찾기
    if (content.contains('await ')) {
      // _completeInitialTest 함수를 async로 변경
      content = content.replaceAll(
        'void _completeInitialTest() {',
        'void _completeInitialTest() async {',
      );

      // _retryTest 함수를 async로 변경
      content = content.replaceAll(
        'void _retryTest() {',
        'void _retryTest() async {',
      );
    }

    await file.writeAsString(content);
  }
  print('  ✅ Initial Test Screen Future<int> 타입 수정 완료');
}

Future<void> fixAsyncAwaitErrors() async {
  print('⏳ Missing await 에러들 수정 중...');

  final files = [
    'lib/main.dart',
    'lib/screens/initial_test_screen.dart',
    'lib/screens/home_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();

      // unawaited_futures 문제 해결
      content = content.replaceAll(
        'Future.delayed(Duration(',
        'await Future.delayed(Duration(',
      );

      content = content.replaceAll(
        'Navigator.of(context).pushReplacement(',
        'await Navigator.of(context).pushReplacement(',
      );

      content = content.replaceAll(
        'Navigator.of(context).push(',
        'await Navigator.of(context).push(',
      );

      await file.writeAsString(content);
    }
  }
  print('  ✅ Missing await 에러 수정 완료');
}

Future<void> fixMissingAwaitErrors() async {
  print('🔧 기타 await 관련 문제들 수정 중...');

  final file = File('lib/screens/initial_test_screen.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // 특정 함수 호출에 대한 await 추가
    content = content.replaceAll(
      '_completeInitialTest();',
      'await _completeInitialTest();',
    );

    content = content.replaceAll('_retryTest();', 'await _retryTest();');

    await file.writeAsString(content);
  }
  print('  ✅ 기타 await 문제 수정 완료');
}
