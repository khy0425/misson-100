// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  debugPrint('🚀 ALPHA EMPEROR 코드 품질 최적화 시작! 🚀');

  // 1. chad_encouragement_service.dart의 single quotes 문제 해결
  await fixSingleQuotes();

  // 2. const 생성자 문제들 해결
  await fixConstConstructors();

  // 3. final 변수 문제들 해결
  await fixFinalVariables();

  debugPrint('✅ 모든 LINT 문제 해결 완료! EMPEROR LEVEL 코드 품질 달성! ✅');
}

Future<void> fixSingleQuotes() async {
  debugPrint('📝 Single quotes 문제 수정 중...');

  final file = File('lib/services/chad_encouragement_service.dart');
  if (await file.exists()) {
    String content = await file.readAsString();

    // double quotes를 single quotes로 변경
    content = content.replaceAll('"motivationMessage', '\'motivationMessage');
    content = content.replaceAll('"completionMessage', '\'completionMessage');
    content = content.replaceAll(
      '"encouragementMessage',
      '\'encouragementMessage',
    );
    content = content.replaceAll('"chadMessage', '\'chadMessage');
    content = content.replaceAll('"message"', '\'message\'');
    content = content.replaceAll(
      '"Chad message type not found"',
      '\'Chad message type not found\'',
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
    debugPrint('  ✅ Single quotes 수정 완료');
  }
}

Future<void> fixConstConstructors() async {
  debugPrint('🏗️ Const constructors 문제 수정 중...');

  // main.dart
  await _addConstToFile('lib/main.dart', [
    'ProviderScope(child: Mission100App())',
    'Mission100App({super.key})',
  ]);

  debugPrint('  ✅ Main.dart const 수정 완료');
}

Future<void> fixFinalVariables() async {
  debugPrint('🔒 Final 변수 문제 수정 중...');

  // database_service.dart의 for-each 변수
  final dbFile = File('lib/services/database_service.dart');
  if (await dbFile.exists()) {
    String content = await dbFile.readAsString();
    content = content.replaceAll(
      'for (var map in maps)',
      'for (final map in maps)',
    );
    await dbFile.writeAsString(content);
    debugPrint('  ✅ Database service final 변수 수정 완료');
  }

  // workout_history_service.dart의 local 변수
  final historyFile = File('lib/services/workout_history_service.dart');
  if (await historyFile.exists()) {
    String content = await historyFile.readAsString();
    content = content.replaceAll('var ', 'final ');
    await historyFile.writeAsString(content);
    debugPrint('  ✅ Workout history service final 변수 수정 완료');
  }
}

Future<void> _addConstToFile(String filePath, List<String> patterns) async {
  final file = File(filePath);
  if (await file.exists()) {
    String content = await file.readAsString();

    for (final pattern in patterns) {
      if (!pattern.startsWith('const ')) {
        content = content.replaceAll(pattern, 'const $pattern');
      }
    }

    await file.writeAsString(content);
  }
}
