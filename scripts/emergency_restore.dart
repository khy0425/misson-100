// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚨 EMPEROR 긴급 복구 작전! 🚨');

  await fixStatisticsScreen();
  await fixDatabaseService();
  await fixOptimizeCode();

  print('✅ 긴급 복구 완료! EMPEROR 부활! ✅');
}

Future<void> fixStatisticsScreen() async {
  print('📊 Statistics Screen 완전 복구 중...');

  final file = File('lib/screens/statistics_screen.dart');
  String content = await file.readAsString();

  // 모든 \1await \2 패턴 제거
  content = content.replaceAll(RegExp(r'\\1await \\2'), '');
  content = content.replaceAll('\\1await \\2', '');
  content = content.replaceAll('\1await \2', '');

  // 빠진 함수 수정
  content = content.replaceAll(
    'void initState() {',
    'void initState() {\n    super.initState();',
  );
  content = content.replaceAll(
    'void dispose() {',
    'void dispose() {\n    _counterController.dispose();\n    _chartController.dispose();',
  );
  content = content.replaceAll(
    '_statisticsBannerAd =',
    '_statisticsBannerAd = AdService.createBannerAd();',
  );
  content = content.replaceAll(
    'final history = await',
    'final history = await WorkoutHistoryService.getAllWorkoutHistory();',
  );
  content = content.replaceAll('final now =', 'final now = DateTime.now();');
  content = content.replaceAll(
    'final today =',
    'final today = DateTime.now();',
  );
  content = content.replaceAll(
    'final theme =',
    'final theme = Theme.of(context);',
  );
  content = content.replaceAll(
    '_counterController.forward();',
    'await _counterController.forward();',
  );

  await file.writeAsString(content);
  print('  ✅ Statistics Screen 복구 완료');
}

Future<void> fixDatabaseService() async {
  print('🗄️ Database Service 완전 복구 중...');

  final file = File('lib/services/database_service.dart');
  String content = await file.readAsString();

  // 모든 \1await \2 패턴 제거
  content = content.replaceAll(RegExp(r'\\1await \\2'), '');
  content = content.replaceAll('\\1await \\2', '');
  content = content.replaceAll('\1await \2', '');

  // 빠진 함수들 복구
  content = content.replaceAll(
    'static final DatabaseService _instance =',
    'static final DatabaseService _instance = DatabaseService._internal();',
  );
  content = content.replaceAll(
    'factory DatabaseService() => _instance;',
    'factory DatabaseService() => _instance;\n  DatabaseService._internal();',
  );
  content = content.replaceAll(
    'final maps = await',
    'final maps = await db.query(\'user_profile\');',
  );
  content = content.replaceAll(
    'return',
    'return UserProfile.fromMap(maps.first);',
  );
  content = content.replaceAll(
    'return await',
    'return await db.delete(\'user_profile\', where: \'id = ?\', whereArgs: [id]);',
  );

  await file.writeAsString(content);
  print('  ✅ Database Service 복구 완료');
}

Future<void> fixOptimizeCode() async {
  print('⚙️ Optimize Code 파일 수정 중...');

  final file = File('scripts/optimize_code.dart');
  if (await file.exists()) {
    await file.delete();
    print('  ✅ 손상된 optimize_code.dart 제거 완료');
  }
}
