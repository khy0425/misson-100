import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../generated/app_localizations.dart';
import '../models/user_profile.dart';
import '../utils/workout_data.dart';

class SocialShareService {
  static const String _appName = 'Mission: 100';
  static const String _appDescription = '6주 만에 푸시업 100개 달성!';
  static const String _downloadMessage = '나도 차드가 되고 싶다면? Mission: 100 앱 다운로드!';

  /// 일일 운동 기록 공유
  static Future<void> shareDailyWorkout({
    required BuildContext context,
    required int pushupCount,
    required int currentDay,
    required UserLevel level,
  }) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final levelName = _getLevelName(level, l10n);
      
      final message = '''
🔥 $_appName 일일 기록 🔥

📅 Day $currentDay
💪 푸시업: ${pushupCount}개
🏆 레벨: $levelName

$_downloadMessage

#Mission100 #푸시업챌린지 #차드되기 #운동기록
''';

      await Share.share(
        message,
        subject: '$_appName - Day $currentDay 운동 완료!',
      );
    } catch (e) {
      debugPrint('일일 운동 기록 공유 오류: $e');
    }
  }

  /// 레벨업 달성 공유
  static Future<void> shareLevelUp({
    required BuildContext context,
    required UserLevel newLevel,
    required int totalDays,
    required int totalPushups,
  }) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final levelName = _getLevelName(newLevel, l10n);
      final levelEmoji = _getLevelEmoji(newLevel);
      
      final message = '''
$levelEmoji 레벨업 달성! $levelEmoji

🎉 새로운 레벨: $levelName
📅 총 운동일: ${totalDays}일
💪 총 푸시업: ${totalPushups}개

차드가 되는 여정이 계속됩니다! 💪

$_downloadMessage

#Mission100 #레벨업 #푸시업마스터 #차드
''';

      await Share.share(
        message,
        subject: '$_appName - $levelName 레벨 달성!',
      );
    } catch (e) {
      debugPrint('레벨업 공유 오류: $e');
    }
  }

  /// 업적 달성 공유
  static Future<void> shareAchievement({
    required BuildContext context,
    required String achievementTitle,
    required String achievementDescription,
    required int xpReward,
  }) async {
    try {
      final message = '''
🏆 업적 달성! 🏆

✨ $achievementTitle
📝 $achievementDescription
🎯 획득 XP: ${xpReward}점

한 걸음씩 차드에 가까워지고 있습니다! 💪

$_downloadMessage

#Mission100 #업적달성 #푸시업챌린지 #차드
''';

      await Share.share(
        message,
        subject: '$_appName - 업적 달성!',
      );
    } catch (e) {
      debugPrint('업적 공유 오류: $e');
    }
  }

  /// 주간 진행률 공유
  static Future<void> shareWeeklyProgress({
    required BuildContext context,
    required int weekNumber,
    required int completedDays,
    required int totalPushups,
    required double progressPercentage,
  }) async {
    try {
      final progressBar = _generateProgressBar(progressPercentage);
      
      final message = '''
📊 $_appName 주간 리포트 📊

📅 Week $weekNumber
✅ 완료일: ${completedDays}일
💪 총 푸시업: ${totalPushups}개
📈 진행률: ${progressPercentage.toStringAsFixed(1)}%

$progressBar

꾸준함이 차드를 만듭니다! 🔥

$_downloadMessage

#Mission100 #주간리포트 #푸시업챌린지 #꾸준함
''';

      await Share.share(
        message,
        subject: '$_appName - Week $weekNumber 리포트',
      );
    } catch (e) {
      debugPrint('주간 진행률 공유 오류: $e');
    }
  }

  /// 100개 달성 공유
  static Future<void> share100Achievement({
    required BuildContext context,
    required int totalDays,
    required DateTime startDate,
  }) async {
    try {
      final duration = DateTime.now().difference(startDate).inDays;
      
      final message = '''
🎉🎉🎉 MISSION COMPLETE! 🎉🎉🎉

💪 푸시업 100개 연속 달성! 💪

📅 총 소요일: ${duration}일
🏆 완료 세션: ${totalDays}회
🔥 진정한 차드가 되었습니다! 🔥

불가능해 보였던 목표도 꾸준함으로 이뤄낼 수 있습니다!

$_downloadMessage

#Mission100 #100개달성 #차드완성 #불가능은없다 #푸시업마스터
''';

      await Share.share(
        message,
        subject: '$_appName - 🎉 MISSION COMPLETE! 🎉',
      );
    } catch (e) {
      debugPrint('100개 달성 공유 오류: $e');
    }
  }

  /// 친구 도전장 보내기
  static Future<void> shareFriendChallenge({
    required BuildContext context,
    required String userName,
  }) async {
    try {
      final message = '''
💪 푸시업 챌린지 도전장! 💪

${userName.isNotEmpty ? userName : '친구'}가 당신에게 도전장을 보냅니다!

🎯 목표: 6주 만에 푸시업 100개
🔥 함께 차드가 되어보세요!

준비되셨나요? 💪

$_downloadMessage

#Mission100 #친구도전 #푸시업챌린지 #함께차드되기
''';

      await Share.share(
        message,
        subject: '$_appName - 푸시업 챌린지 도전장!',
      );
    } catch (e) {
      debugPrint('친구 도전장 공유 오류: $e');
    }
  }

  /// 동기부여 메시지 공유
  static Future<void> shareMotivation({
    required BuildContext context,
    required String motivationMessage,
  }) async {
    try {
      final message = '''
💪 오늘의 동기부여 💪

"$motivationMessage"

작은 시작이 큰 변화를 만듭니다!
오늘도 한 걸음씩 차드에 가까워져요! 🔥

$_downloadMessage

#Mission100 #동기부여 #푸시업챌린지 #오늘도화이팅
''';

      await Share.share(
        message,
        subject: '$_appName - 오늘의 동기부여',
      );
    } catch (e) {
      debugPrint('동기부여 메시지 공유 오류: $e');
    }
  }

  /// 위젯을 이미지로 캡처하여 공유
  static Future<void> shareWidgetAsImage({
    required GlobalKey repaintBoundaryKey,
    required String message,
    required String subject,
  }) async {
    try {
      // 위젯을 이미지로 캡처
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/mission100_share.png').create();
      await file.writeAsBytes(pngBytes);

      // 이미지와 텍스트 함께 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
        subject: subject,
      );
    } catch (e) {
      debugPrint('위젯 이미지 공유 오류: $e');
      // 이미지 공유 실패 시 텍스트만 공유
      await Share.share(message, subject: subject);
    }
  }

  /// 레벨명 가져오기
  static String _getLevelName(UserLevel level, AppLocalizations l10n) {
    switch (level) {
      case UserLevel.rookie:
        return l10n.rookieShort;
      case UserLevel.rising:
        return l10n.risingShort;
      case UserLevel.alpha:
        return l10n.alphaShort;
      case UserLevel.giga:
        return l10n.gigaShort;
    }
  }

  /// 레벨 이모지 가져오기
  static String _getLevelEmoji(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return '🌱';
      case UserLevel.rising:
        return '🔥';
      case UserLevel.alpha:
        return '⚡';
      case UserLevel.giga:
        return '👑';
    }
  }

  /// 진행률 바 생성
  static String _generateProgressBar(double percentage) {
    const int totalBars = 10;
    final int filledBars = (percentage / 10).round();
    final int emptyBars = totalBars - filledBars;
    
    return '[${'█' * filledBars}${'░' * emptyBars}] ${percentage.toStringAsFixed(1)}%';
  }
} 