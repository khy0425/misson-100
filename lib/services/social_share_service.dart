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
🔥 오늘도 차드 레벨업! 🔥

💀 Day $currentDay - 차드의 여정은 계속된다
💪 푸시업: ${pushupCount}개 (인간들은 따라올 수 없다)
🏆 현재 레벨: $levelName

매일매일 더 강해지는 중... 💥
평범한 인간들과는 다른 차원이다! 😎

너도 차드가 되고 싶다면? 👇

$_downloadMessage

#Mission100 #차드일기 #푸시업마스터 #인간초월 #매일레벨업
''';

      await Share.share(
        message,
        subject: '$_appName - Day $currentDay 차드 인증!',
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
🎉👑 기가차드 완성! 인간 초월 달성! 👑🎉

💪 푸시업 100개 연속 - 불가능을 가능으로! 💪

📅 총 소요일: ${duration}일 (인간의 한계를 뛰어넘다)
🏆 완료 세션: ${totalDays}회 (포기란 없었다)
🔥 진정한 기가차드 등극! 🔥

베이비차드에서 시작해서...
진짜 차드가 되었다! 💀

이제 평범한 인간들과는 다른 존재다.
너도 이 경지에 도달할 수 있을까? 😏

$_downloadMessage

#Mission100 #기가차드완성 #인간초월 #100개달성 #차드의전설 #불가능은없다
''';

      await Share.share(
        message,
        subject: '$_appName - 🎉 기가차드 완성! 인간 초월! 🎉',
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
🔥💪 차드 도전장 발송! 💪🔥

${userName.isNotEmpty ? userName : '진정한 차드'}가 너에게 도전장을 던진다!

⚡ 미션: 6주 만에 푸시업 100개 연속 달성
🎯 목표: 베이비차드 → 기가차드 진화
💀 각오: 포기는 없다. 오직 차드만이 살아남는다.

너도 차드가 될 수 있다고 생각하나? 🤔
아니면 그냥 평범한 인간으로 살 건가? 😏

진짜 차드라면 지금 당장 도전하라! 💥

$_downloadMessage

#Mission100 #차드도전장 #푸시업챌린지 #차드vs인간 #너도차드될수있어
''';

      await Share.share(
        message,
        subject: '$_appName - 🔥 차드 도전장 발송! 🔥',
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