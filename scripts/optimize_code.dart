#!/usr/bin/env dart

import 'package:flutter/foundation.dart';
import 'dart:io';

void main(List<String> args) {
  debugPrint('🚀 Mission100 코드 최적화 시작...\n');

  final tasks = [
    OptimizationTask('사용되지 않는 import 제거', () => removeUnusedImports()),
    OptimizationTask(
      'deprecated API 교체 (withOpacity → withValues)',
      () => replaceDeprecatedApi(),
    ),
    OptimizationTask('const 생성자 최적화', () => optimizeConstConstructors()),
    OptimizationTask('문자열 보간 최적화', () => optimizeStringInterpolation()),
    OptimizationTask('사용되지 않는 변수/필드 정리', () => cleanUnusedVariables()),
  ];

  int completed = 0;
  for (final task in tasks) {
    try {
      debugPrint('📝 ${task.description}...');
      task.action();
      completed++;
      debugPrint('✅ 완료\n');
    } catch (e) {
      debugPrint('❌ 오류: $e\n');
    }
  }

  debugPrint('🎉 최적화 완료: $completed/${tasks.length}개 작업');
}

class OptimizationTask {
  final String description;
  final Function() action;

  OptimizationTask(this.description, this.action);
}

void removeUnusedImports() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .where((entity) => entity.path.endsWith('.dart'))
      .cast<File>();

  for (final file in libFiles) {
    String content = file.readAsStringSync();

    // 사용되지 않는 일반적인 import들 제거
    final unusedImports = [
      "import '../generated/app_localizations.dart';",
      "import '../utils/workout_data.dart';",
      "import '../services/database_service.dart';",
      "import '../utils/level_classifier.dart';",
      "import '../models/workout_session.dart';",
      "import 'package:flutter_localizations/flutter_localizations.dart';",
    ];

    bool changed = false;
    for (final unusedImport in unusedImports) {
      if (content.contains(unusedImport) &&
          !isImportUsed(content, unusedImport)) {
        content = content.replaceAll('$unusedImport\n', '');
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
    }
  }
}

bool isImportUsed(String content, String importLine) {
  // 간단한 사용 여부 체크 로직
  if (importLine.contains('app_localizations')) {
    return content.contains('AppLocalizations') || content.contains('l10n');
  }
  if (importLine.contains('workout_data')) {
    return content.contains('WorkoutData') ||
        content.contains('workoutPrograms');
  }
  if (importLine.contains('database_service')) {
    return content.contains('DatabaseService');
  }
  if (importLine.contains('level_classifier')) {
    return content.contains('LevelClassifier');
  }
  return false;
}

void replaceDeprecatedApi() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .where((entity) => entity.path.endsWith('.dart'))
      .cast<File>();

  for (final file in libFiles) {
    String content = file.readAsStringSync();

    // withOpacity → withValues 교체
    final opacityPattern = RegExp(r'\.withOpacity\(([^)]+)\)');
    content = content.replaceAllMapped(opacityPattern, (match) {
      final opacityValue = match.group(1)!;
      return '.withValues(alpha: $opacityValue)';
    });

    file.writeAsStringSync(content);
  }
}

void optimizeConstConstructors() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .where((entity) => entity.path.endsWith('.dart'))
      .cast<File>();

  for (final file in libFiles) {
    String content = file.readAsStringSync();

    // 일반적인 const 최적화 패턴들
    final constPatterns = {
      'SizedBox(': 'const SizedBox(',
      'const EdgeInsets.all(': 'const EdgeInsets.all(',
      'const EdgeInsets.symmetric(': 'const EdgeInsets.symmetric(',
      'const EdgeInsets.only(': 'const EdgeInsets.only(',
      'BorderRadius.circular(': 'const BorderRadius.circular(',
      'TextStyle(': 'const TextStyle(',
      'Icon(': 'const Icon(',
    };

    for (final entry in constPatterns.entries) {
      // 이미 const가 있는 경우는 제외
      final pattern = RegExp('(?<!const )${RegExp.escape(entry.key)}');
      content = content.replaceAll(pattern, 'const ${entry.key}');
    }

    file.writeAsStringSync(content);
  }
}

void optimizeStringInterpolation() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .where((entity) => entity.path.endsWith('.dart'))
      .cast<File>();

  for (final file in libFiles) {
    String content = file.readAsStringSync();

    // 불필요한 중괄호 제거: $variable → $variable
    final interpolationPattern = RegExp(r'\$\{(\w+)\}');
    content = content.replaceAllMapped(interpolationPattern, (match) {
      final variable = match.group(1)!;
      return '\$$variable';
    });

    file.writeAsStringSync(content);
  }
}

void cleanUnusedVariables() {
  debugPrint('🧹 사용되지 않는 변수 정리는 수동으로 확인이 필요합니다.');
  debugPrint('   flutter analyze 결과를 참고하여 각 파일을 개별적으로 수정해주세요.');
}
