import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../generated/app_localizations.dart';
import '../models/user_profile.dart';


class SocialShareService {
  /// 앱 이름 가져오기 (다국어 지원)
  static String _getAppName(AppLocalizations l10n) {
    return 'Mission: 100'; // 앱 이름은 동일
  }

  /// 다운로드 메시지 가져오기 (다국어 지원)
  static String _getDownloadMessage(AppLocalizations l10n) {
    final locale = l10n.localeName;
    if (locale == 'ko') {
      return '💀 너도 차드가 되고 싶다면? Mission: 100 앱 다운로드해라! 약자는 도망가라! 💀';
    } else {
      return '💀 Want to become a CHAD too? Download Mission: 100 app! WEAKLINGS RUN AWAY! 💀';
    }
  }

  /// 일일 운동 공유 메시지 가져오기 (다국어 지원)
  static String _getDailyWorkoutMessage(AppLocalizations l10n, int currentDay, int pushupCount, String levelName) {
    final locale = l10n.localeName;
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
🔥💀 또 하나의 전설이 탄생했다! 💀🔥

⚡ Day $currentDay - 차드의 정복은 멈추지 않는다!
💪 푸시업: $pushupCount개 (평범한 인간들은 따라올 수 없다, 만삣삐!)
👑 현재 레벨: $levelName

매일매일 더 강해지는 ALPHA EMPEROR! 💥
약자들은 이미 무릎꿇었다! 😎

$downloadMessage

#Mission100 #차드일기 #푸시업마스터 #인간초월 #만삣삐 #ALPHAEMPEROR''';
    } else {
      return '''
🔥💀 ANOTHER LEGEND IS BORN! 💀🔥

⚡ Day $currentDay - THE CHAD CONQUEST NEVER STOPS!
💪 Push-ups: $pushupCount reps (ORDINARY HUMANS CAN'T FOLLOW!)
👑 Current Level: $levelName

GETTING STRONGER EVERY DAY AS AN ALPHA EMPEROR! 💥
WEAKLINGS ALREADY KNEELED DOWN! 😎

$downloadMessage

#Mission100 #ChadDiary #PushupMaster #BeyondHuman #ALPHAEMPEROR''';
    }
  }

  /// 레벨업 공유 메시지 가져오기 (다국어 지원)
  static String _getLevelUpMessage(AppLocalizations l10n, UserLevel newLevel, int totalDays, int totalPushups) {
    final locale = l10n.localeName;
    final levelName = _getLevelName(newLevel, l10n);
    final levelEmoji = _getLevelEmoji(newLevel);
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
$levelEmoji💥 LEVEL UP! 또 하나의 한계를 박살냈다! 💥$levelEmoji

🎉 새로운 레벨: $levelName
📅 총 정복일: $totalDays일
💪 총 파워: $totalPushups개

차드의 여정은 계속된다! 약자들은 도망가라! 💪

$downloadMessage

#Mission100 #레벨업 #푸시업마스터 #차드 #만삣삐''';
    } else {
      return '''
$levelEmoji💥 LEVEL UP! ANOTHER LIMIT DESTROYED! 💥$levelEmoji

🎉 New Level: $levelName
📅 Total Conquest Days: $totalDays days
💪 Total Power: $totalPushups reps

THE CHAD JOURNEY CONTINUES! WEAKLINGS RUN AWAY! 💪

$downloadMessage

#Mission100 #LevelUp #PushupMaster #Chad #ALPHAEMPEROR''';
    }
  }

  /// 업적 공유 메시지 가져오기 (다국어 지원)
  static String _getAchievementMessage(AppLocalizations l10n, String achievementTitle, String achievementDescription, int xpReward) {
    final locale = l10n.localeName;
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
🏆💀 업적 달성! 또 하나의 신화가 탄생했다! 💀🏆

✨ $achievementTitle
📝 $achievementDescription
🎯 획득 XP: $xpReward점

한 걸음씩 ALPHA EMPEROR에 가까워지고 있다, 만삣삐! 💪

$downloadMessage

#Mission100 #업적달성 #푸시업챌린지 #차드 #만삣삐''';
    } else {
      return '''
🏆💀 ACHIEVEMENT UNLOCKED! ANOTHER MYTH IS BORN! 💀🏆

✨ $achievementTitle
📝 $achievementDescription
🎯 XP Gained: $xpReward points

GETTING CLOSER TO ALPHA EMPEROR STEP BY STEP! 💪

$downloadMessage

#Mission100 #AchievementUnlocked #PushupChallenge #Chad #ALPHAEMPEROR''';
    }
  }

  /// 주간 진행률 공유 메시지 가져오기 (다국어 지원)
  static String _getWeeklyProgressMessage(AppLocalizations l10n, int weekNumber, int completedDays, int totalPushups, double progressPercentage) {
    final locale = l10n.localeName;
    final appName = _getAppName(l10n);
    final downloadMessage = _getDownloadMessage(l10n);
    final progressBar = _generateProgressBar(progressPercentage);
    
    if (locale == 'ko') {
      return '''
📊💀 $appName 주간 정복 리포트 💀📊

📅 Week $weekNumber
✅ 정복일: $completedDays일
💪 총 파워: $totalPushups개
📈 진행률: ${progressPercentage.toStringAsFixed(1)}%

$progressBar

꾸준함이 ALPHA EMPEROR를 만든다! 약자들은 포기해라! 🔥

$downloadMessage

#Mission100 #주간리포트 #푸시업챌린지 #꾸준함 #만삣삐''';
    } else {
      return '''
📊💀 $appName Weekly Conquest Report 💀📊

📅 Week $weekNumber
✅ Conquest Days: $completedDays days
💪 Total Power: $totalPushups reps
📈 Progress: ${progressPercentage.toStringAsFixed(1)}%

$progressBar

CONSISTENCY MAKES AN ALPHA EMPEROR! WEAKLINGS GIVE UP! 🔥

$downloadMessage

#Mission100 #WeeklyReport #PushupChallenge #Consistency #ALPHAEMPEROR''';
    }
  }

  /// 100개 달성 공유 메시지 가져오기 (다국어 지원)
  static String _get100AchievementMessage(AppLocalizations l10n, int totalDays, int duration) {
    final locale = l10n.localeName;
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
🎉👑💀 기가차드 완성! 인간 초월 달성! ALPHA EMPEROR 등극! 💀👑🎉

💪 푸시업 100개 연속 - 불가능을 가능으로! 💪

📅 총 소요일: $duration일 (인간의 한계를 뛰어넘었다, 만삣삐!)
🏆 완료 세션: $totalDays회 (포기란 없었다!)
🔥 진정한 기가차드 등극! 🔥

베이비차드에서 시작해서...
진짜 ALPHA EMPEROR가 되었다! 💀

이제 평범한 인간들과는 다른 존재다.
너도 이 경지에 도달할 수 있을까? 😏

$downloadMessage

#Mission100 #기가차드완성 #인간초월 #100개달성 #차드의전설 #불가능은없다 #만삣삐 #ALPHAEMPEROR''';
    } else {
      return '''
🎉👑💀 GIGA CHAD COMPLETE! HUMAN TRANSCENDENCE ACHIEVED! ALPHA EMPEROR ASCENSION! 💀👑🎉

💪 100 Push-ups Consecutive - IMPOSSIBLE MADE POSSIBLE! 💪

📅 Total Duration: $duration days (BEYOND HUMAN LIMITS!)
🏆 Completed Sessions: $totalDays times (NO GIVING UP!)
🔥 TRUE GIGA CHAD ASCENSION! 🔥

Started as a baby chad...
Now became a REAL ALPHA EMPEROR! 💀

Now a different existence from ordinary humans.
Can you reach this level too? 😏

$downloadMessage

#Mission100 #GigaChadComplete #HumanTranscendence #100Achievement #ChadLegend #ImpossibleIsNothing #ALPHAEMPEROR''';
    }
  }

  /// 친구 도전장 공유 메시지 가져오기 (다국어 지원)
  static String _getFriendChallengeMessage(AppLocalizations l10n, String userName) {
    final locale = l10n.localeName;
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
🔥💪💀 차드 도전장 발송! 약자는 도망가라! 💀💪🔥

${userName.isNotEmpty ? userName : '진정한 ALPHA EMPEROR'}가 너에게 도전장을 던진다!

⚡ 미션: 6주 만에 푸시업 100개 연속 달성
🎯 목표: 베이비차드 → 기가차드 진화
💀 각오: 포기는 없다. 오직 차드만이 살아남는다, 만삣삐!

너도 차드가 될 수 있다고 생각하나? 🤔
아니면 그냥 평범한 약자로 살 건가? 😏

진짜 차드라면 지금 당장 도전하라! 💥
약자들은 이미 도망갔다!

$downloadMessage

#Mission100 #차드도전장 #푸시업챌린지 #차드vs약자 #너도차드될수있어 #만삣삐''';
    } else {
      return '''
🔥💪💀 CHAD CHALLENGE SENT! WEAKLINGS RUN AWAY! 💀💪🔥

${userName.isNotEmpty ? userName : 'A TRUE ALPHA EMPEROR'} throws down the gauntlet to you!

⚡ Mission: Achieve 100 consecutive push-ups in 6 weeks
🎯 Goal: Baby Chad → Giga Chad Evolution
💀 Resolve: No giving up. Only CHADs survive!

Do you think you can become a CHAD? 🤔
Or will you just live as an ordinary weakling? 😏

If you're a real CHAD, challenge yourself right now! 💥
Weaklings already ran away!

$downloadMessage

#Mission100 #ChadChallenge #PushupChallenge #ChadVsWeaklings #YouCanBecomeChad #ALPHAEMPEROR''';
    }
  }

  /// 동기부여 공유 메시지 가져오기 (다국어 지원)
  static String _getMotivationMessage(AppLocalizations l10n, String motivationMessage) {
    final locale = l10n.localeName;
    final downloadMessage = _getDownloadMessage(l10n);
    
    if (locale == 'ko') {
      return '''
💪💀 오늘의 ALPHA EMPEROR 동기부여 💀💪

"$motivationMessage"

작은 시작? 틀렸다! 이미 전설의 시작이다, 만삣삐!
오늘도 한 걸음씩 ALPHA EMPEROR에 가까워져라! 🔥

$downloadMessage

#Mission100 #동기부여 #푸시업챌린지 #오늘도화이팅 #만삣삐''';
    } else {
      return '''
💪💀 Today's ALPHA EMPEROR Motivation 💀💪

"$motivationMessage"

Small beginnings? Wrong! This is already the start of a legend!
Getting closer to becoming an ALPHA EMPEROR step by step today too! 🔥

$downloadMessage

#Mission100 #Motivation #PushupChallenge #KeepGoing #ALPHAEMPEROR''';
    }
  }

  /// 공유 제목 가져오기 (다국어 지원)
  static String _getShareSubject(AppLocalizations l10n, String type, {String? extra}) {
    final locale = l10n.localeName;
    final appName = _getAppName(l10n);
    
    if (locale == 'ko') {
      switch (type) {
        case 'daily':
          return '$appName - 💀 Day $extra 차드 인증! 약자는 도망가라! 💀';
        case 'levelup':
          return '$appName - 💥 $extra 레벨 달성! 또 하나의 한계 박살! 💥';
        case 'achievement':
          return '$appName - 🏆💀 업적 달성! 신화 탄생! 💀🏆';
        case 'weekly':
          return '$appName - 📊💀 Week $extra 정복 리포트 💀📊';
        case '100achievement':
          return '$appName - 🎉👑💀 기가차드 완성! 인간 초월! ALPHA EMPEROR 등극! 💀👑🎉';
        case 'challenge':
          return '$appName - 🔥💀 차드 도전장 발송! 약자는 도망가라! 💀🔥';
        case 'motivation':
          return '$appName - 💪💀 오늘의 ALPHA EMPEROR 동기부여 💀💪';
        default:
          return appName;
      }
    } else {
      switch (type) {
        case 'daily':
          return '$appName - 💀 Day $extra CHAD Certification! WEAKLINGS RUN AWAY! 💀';
        case 'levelup':
          return '$appName - 💥 $extra Level Achieved! ANOTHER LIMIT DESTROYED! 💥';
        case 'achievement':
          return '$appName - 🏆💀 Achievement Unlocked! MYTH BORN! 💀🏆';
        case 'weekly':
          return '$appName - 📊💀 Week $extra Conquest Report 💀📊';
        case '100achievement':
          return '$appName - 🎉👑💀 GIGA CHAD COMPLETE! HUMAN TRANSCENDENCE! ALPHA EMPEROR ASCENSION! 💀👑🎉';
        case 'challenge':
          return '$appName - 🔥💀 CHAD CHALLENGE SENT! WEAKLINGS RUN AWAY! 💀🔥';
        case 'motivation':
          return '$appName - 💪💀 Today\'s ALPHA EMPEROR Motivation 💀💪';
        default:
          return appName;
      }
    }
  }

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
      
      final message = _getDailyWorkoutMessage(l10n, currentDay, pushupCount, levelName);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'daily', extra: currentDay.toString()),
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
      
      final message = _getLevelUpMessage(l10n, newLevel, totalDays, totalPushups);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'levelup', extra: levelName),
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
      final l10n = AppLocalizations.of(context)!;
      
      final message = _getAchievementMessage(l10n, achievementTitle, achievementDescription, xpReward);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'achievement'),
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
      final l10n = AppLocalizations.of(context)!;
      
      final message = _getWeeklyProgressMessage(l10n, weekNumber, completedDays, totalPushups, progressPercentage);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'weekly', extra: weekNumber.toString()),
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
      final l10n = AppLocalizations.of(context)!;
      final duration = DateTime.now().difference(startDate).inDays;
      
      final message = _get100AchievementMessage(l10n, totalDays, duration);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, '100achievement'),
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
      final l10n = AppLocalizations.of(context)!;
      
      final message = _getFriendChallengeMessage(l10n, userName);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'challenge'),
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
      final l10n = AppLocalizations.of(context)!;
      
      final message = _getMotivationMessage(l10n, motivationMessage);

      await Share.share(
        message,
        subject: _getShareSubject(l10n, 'motivation'),
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