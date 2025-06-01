import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// 앱 바 제목
  ///
  /// In ko, this message translates to:
  /// **'⚡ ALPHA EMPEROR DOMAIN ⚡'**
  String get appTitle;

  /// 운동 횟수 입력 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'기록해라, 만삣삐. 약자는 숫자를 센다, 강자는 전설을 만든다 💪'**
  String get repLogMessage;

  /// 목표 횟수 표시
  ///
  /// In ko, this message translates to:
  /// **'목표: {count}회'**
  String targetRepsLabel(int count);

  /// 목표 100% 달성시 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 ABSOLUTE PERFECTION! 신을 넘어선 ULTRA GOD EMPEROR 탄생! 👑'**
  String get performanceGodTier;

  /// 목표 80% 이상 달성시 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔱 철봉이 무릎꿇는다고? 이제 중력이 너에게 항복한다! LEGENDARY BEAST! 🔱'**
  String get performanceStrong;

  /// 목표 50% 이상 달성시 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ GOOD! 약함이 도망치고 있다. ALPHA STORM이 몰려온다, 만삣삐! ⚡'**
  String get performanceMedium;

  /// 운동 시작시 메시지
  ///
  /// In ko, this message translates to:
  /// **'💥 시작이 반? 틀렸다! 이미 전설의 문이 열렸다, YOU FUTURE EMPEROR! 💥'**
  String get performanceStart;

  /// 기본 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔥 할 수 있어? 당연하지! 이제 세상을 정복하러 가자, 만삣삐! 🔥'**
  String get performanceMotivation;

  /// 목표 달성시 최고 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 완벽하다고? 아니다! 너는 이미 신을 넘어선 ULTRA EMPEROR다, 만삣삐! 약함은 우주에서 추방당했다! ⚡👑'**
  String get motivationGod;

  /// 목표 80% 이상시 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'포기? 그건 약자나 하는 거야. 더 강하게, 만삣삐! 🔱💪'**
  String get motivationStrong;

  /// 목표 50% 이상시 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'한계는 너의 머릿속에만 있어, you idiot. 부숴버려! 🦍⚡'**
  String get motivationMedium;

  /// 일반 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'오늘 흘린 땀은 내일의 영광이야, 만삣삐. 절대 포기하지 마 🔥💪'**
  String get motivationGeneral;

  /// 목표 달성하고 세트 완료시
  ///
  /// In ko, this message translates to:
  /// **'굿 잡, 만삣삐! 또 하나의 신화가 탄생했어 🔥👑'**
  String get setCompletedSuccess;

  /// 목표 미달성이지만 세트 완료시
  ///
  /// In ko, this message translates to:
  /// **'not bad, 만삣삐! 또 하나의 한계를 부숴버렸어 ⚡🔱'**
  String get setCompletedGood;

  /// 운동 결과 표시 형식
  ///
  /// In ko, this message translates to:
  /// **'전설 등급: {reps}회 ({percentage}%) 🏆'**
  String resultFormat(int reps, int percentage);

  /// 목표 달성 버튼
  ///
  /// In ko, this message translates to:
  /// **'🚀 GODLIKE 달성 🚀'**
  String get quickInputPerfect;

  /// 목표 80% 버튼
  ///
  /// In ko, this message translates to:
  /// **'👑 EMPEROR 여유 👑'**
  String get quickInputStrong;

  /// 목표 60% 버튼
  ///
  /// In ko, this message translates to:
  /// **'⚡ ALPHA 발걸음 ⚡'**
  String get quickInputMedium;

  /// 목표 50% 버튼
  ///
  /// In ko, this message translates to:
  /// **'🔥 LEGENDARY 함성 🔥'**
  String get quickInputStart;

  /// 목표 초과 버튼
  ///
  /// In ko, this message translates to:
  /// **'💥 LIMIT DESTROYER 💥'**
  String get quickInputBeast;

  /// 휴식시간 제목
  ///
  /// In ko, this message translates to:
  /// **'강자들의 재충전 타임, 만삣삐 ⚡'**
  String get restTimeTitle;

  /// 휴식 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'쉬는 것도 성장이야. 다음은 더 파괴적으로 가자, 만삣삐 🦍'**
  String get restMessage;

  /// 휴식 건너뛰기 버튼
  ///
  /// In ko, this message translates to:
  /// **'휴식? 약자나 해라, 만삣삐! 다음 희생양 가져와!'**
  String get skipRestButton;

  /// 마지막 세트 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'굿 잡! 우주 정복 완료!'**
  String get nextSetButton;

  /// 다음 세트 진행 버튼
  ///
  /// In ko, this message translates to:
  /// **'다음 희생양을 가져와라, 만삣삐!'**
  String get nextSetContinue;

  /// 세트 진행 중 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'네 몸은 네가 명령하는 대로 따를 뿐이야, you idiot! 🔱'**
  String get guidanceMessage;

  /// 마지막 세트 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'전설 등극, 만삣삐!'**
  String get completeSetButton;

  /// 일반 세트 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'또 하나 박살내기!'**
  String get completeSetContinue;

  /// 종료 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'전투에서 후퇴하겠어, 만삣삐?'**
  String get exitDialogTitle;

  /// 종료 다이얼로그 내용
  ///
  /// In ko, this message translates to:
  /// **'전사는 절대 전투 중에 포기하지 않아!\n너의 정복이 사라질 거야, you idiot!'**
  String get exitDialogMessage;

  /// 계속하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'계속 싸운다, 만삣삐!'**
  String get exitDialogContinue;

  /// 종료하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'후퇴한다...'**
  String get exitDialogRetreat;

  /// 운동 완료 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'🔥 굿 잡, 만삣삐! 야수 모드 완료! 👑'**
  String get workoutCompleteTitle;

  /// 운동 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'{title} 완전 파괴!\n총 파워 해방: {totalReps}회! you did it! ⚡'**
  String workoutCompleteMessage(String title, int totalReps);

  /// 운동 완료 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'레전드다, 만삣삐!'**
  String get workoutCompleteButton;

  /// 세트 표시 형식
  ///
  /// In ko, this message translates to:
  /// **'SET {current}/{total}'**
  String setFormat(int current, int total);

  /// 레벨 선택 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'💪 레벨 체크'**
  String get levelSelectionTitle;

  /// 레벨 선택 헤더
  ///
  /// In ko, this message translates to:
  /// **'🏋️‍♂️ 너의 레벨을 선택해라, 만삣삐!'**
  String get levelSelectionHeader;

  /// 레벨 선택 설명
  ///
  /// In ko, this message translates to:
  /// **'현재 푸시업 최대 횟수에 맞는 레벨을 선택해라!\n6주 후 목표 달성을 위한 맞춤 프로그램이 제공된다!'**
  String get levelSelectionDescription;

  /// 초보자 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'초보자'**
  String get rookieLevelTitle;

  /// 초급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 6개 미만 - 기초부터 차근차근'**
  String get rookieLevelSubtitle;

  /// 초보자 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'천천히 시작하는 차드'**
  String get rookieLevelDescription;

  /// 초급 특징 1
  ///
  /// In ko, this message translates to:
  /// **'무릎 푸시업부터 시작'**
  String get rookieFeature1;

  /// 초급 특징 2
  ///
  /// In ko, this message translates to:
  /// **'폼 교정 중심 훈련'**
  String get rookieFeature2;

  /// 초급 특징 3
  ///
  /// In ko, this message translates to:
  /// **'점진적 강도 증가'**
  String get rookieFeature3;

  /// 초급 특징 4
  ///
  /// In ko, this message translates to:
  /// **'기초 체력 향상'**
  String get rookieFeature4;

  /// 중급자 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'중급자'**
  String get risingLevelTitle;

  /// 중급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 6-10개 - 차드로 성장 중'**
  String get risingLevelSubtitle;

  /// 중급자 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'성장하는 차드'**
  String get risingLevelDescription;

  /// 중급 특징 1
  ///
  /// In ko, this message translates to:
  /// **'표준 푸시업 마스터'**
  String get risingFeature1;

  /// 중급 특징 2
  ///
  /// In ko, this message translates to:
  /// **'다양한 변형 훈련'**
  String get risingFeature2;

  /// 중급 특징 3
  ///
  /// In ko, this message translates to:
  /// **'근지구력 향상'**
  String get risingFeature3;

  /// 중급 특징 4
  ///
  /// In ko, this message translates to:
  /// **'체계적 진급 프로그램'**
  String get risingFeature4;

  /// 고급자 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'고급자'**
  String get alphaLevelTitle;

  /// 고급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 11개 이상 - 이미 차드의 자질'**
  String get alphaLevelSubtitle;

  /// 고급자 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'궁극의 차드'**
  String get alphaLevelDescription;

  /// 고급 특징 1
  ///
  /// In ko, this message translates to:
  /// **'고급 변형 푸시업'**
  String get alphaFeature1;

  /// 고급 특징 2
  ///
  /// In ko, this message translates to:
  /// **'폭발적 파워 훈련'**
  String get alphaFeature2;

  /// 고급 특징 3
  ///
  /// In ko, this message translates to:
  /// **'플라이오메트릭 운동'**
  String get alphaFeature3;

  /// 고급 특징 4
  ///
  /// In ko, this message translates to:
  /// **'기가차드 완성 코스'**
  String get alphaFeature4;

  /// 초급 짧은 이름
  ///
  /// In ko, this message translates to:
  /// **'푸시'**
  String get rookieShort;

  /// 중급 짧은 이름
  ///
  /// In ko, this message translates to:
  /// **'알파 지망생'**
  String get risingShort;

  /// 고급 짧은 이름
  ///
  /// In ko, this message translates to:
  /// **'차드'**
  String get alphaShort;

  /// 최고급 짧은 이름
  ///
  /// In ko, this message translates to:
  /// **'기가차드'**
  String get gigaShort;

  /// 홈 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'💥 ALPHA EMPEROR COMMAND CENTER 💥'**
  String get homeTitle;

  /// 홈 화면 환영 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔥 WELCOME,\nFUTURE EMPEROR! 🔥\n정복의 시간이다, 만삣삐!'**
  String get welcomeMessage;

  /// 일일 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ 오늘도 LEGENDARY\nBEAST MODE로\n세상을 압도해라! ⚡'**
  String get dailyMotivation;

  /// 오늘 운동 시작 버튼
  ///
  /// In ko, this message translates to:
  /// **'🚀 오늘의 DOMINATION 시작! 🚀'**
  String get startTodayWorkout;

  /// 주간 진행 상황 제목
  ///
  /// In ko, this message translates to:
  /// **'👑 EMPEROR\'S CONQUEST PROGRESS 👑'**
  String get weekProgress;

  /// 진행 상황 상세
  ///
  /// In ko, this message translates to:
  /// **'{week}주차 - {totalDays}일 중 {completedDays}일 완료'**
  String progressWeekDay(int week, int totalDays, int completedDays);

  /// 하단 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔥 매일 조금씩? 틀렸다! 매일 LEGENDARY LEVEL UP이다, 만삣삐! 💪'**
  String get bottomMotivation;

  /// 운동 시작 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ ALPHA SYSTEM ERROR! 재시도하라, 만삣삐: {error} ⚡'**
  String workoutStartError(String error);

  /// 일반 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'🦁 일시적 장애물 발견! 진짜 EMPEROR는 다시 도전한다, 만삣삐! 🦁'**
  String get errorGeneral;

  /// 데이터베이스 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'💥 데이터 요새에 문제 발생! TECH CHAD가 복구 중이다! 💥'**
  String get errorDatabase;

  /// 네트워크 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'🌪️ 네트워크 연결을 확인하라! ALPHA CONNECTION 필요하다! 🌪️'**
  String get errorNetwork;

  /// 데이터 없음 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔱 데이터를 찾을 수 없다! 새로운 전설을 만들 시간이다, 만삣삐! 🔱'**
  String get errorNotFound;

  /// 운동 완료 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 WORKOUT DOMINATION COMPLETE! 또 하나의 LEGENDARY ACHIEVEMENT 달성! 🚀'**
  String get successWorkoutCompleted;

  /// 프로필 저장 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'👑 EMPEROR PROFILE SAVED! 너의 전설이 기록되었다, 만삣삐! 👑'**
  String get successProfileSaved;

  /// 설정 저장 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ ALPHA SETTINGS LOCKED! 완벽한 설정으로 무장 완료! ⚡'**
  String get successSettingsSaved;

  /// 첫 운동 시작 메시지
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 운동을 시작합니다! 화이팅!'**
  String get firstWorkoutMessage;

  /// 주차 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'주차 완료! 축하드립니다!'**
  String get weekCompletedMessage;

  /// 프로그램 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'프로그램 완료! 정말 대단합니다!'**
  String get programCompletedMessage;

  /// 연속 운동 시작 메시지
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 시작!'**
  String get streakStartMessage;

  /// 연속 운동 지속 메시지
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 계속 중!'**
  String get streakContinueMessage;

  /// 연속 운동 중단 메시지
  ///
  /// In ko, this message translates to:
  /// **'연속 운동이 끊어졌습니다'**
  String get streakBrokenMessage;

  /// 수면모자 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'수면모자 Chad'**
  String get chadTitleSleepy;

  /// 기본 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'기본 Chad'**
  String get chadTitleBasic;

  /// 커피 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'커피 Chad'**
  String get chadTitleCoffee;

  /// 정면 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'정면 Chad'**
  String get chadTitleFront;

  /// 썬글 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'썬글 Chad'**
  String get chadTitleCool;

  /// 눈빨 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'눈빨 Chad'**
  String get chadTitleLaser;

  /// 더블 차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'더블 Chad'**
  String get chadTitleDouble;

  /// 초급 차드 이름
  ///
  /// In ko, this message translates to:
  /// **'Rookie Chad'**
  String get levelNameRookie;

  /// 중급 차드 이름
  ///
  /// In ko, this message translates to:
  /// **'Rising Chad'**
  String get levelNameRising;

  /// 고급 차드 이름
  ///
  /// In ko, this message translates to:
  /// **'Alpha Chad'**
  String get levelNameAlpha;

  /// 최고급 차드 이름
  ///
  /// In ko, this message translates to:
  /// **'기가 차드'**
  String get levelNameGiga;

  /// 초급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'🔥 푸시업 여정을 시작하는 미래의 EMPEROR다.\n꾸준한 연습으로 LEGENDARY BEAST로 진화할 수 있어, 만삣삐! 🔥'**
  String get levelDescRookie;

  /// 중급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'⚡ 기본기를 갖춘 상승하는 ALPHA CHAD다.\n더 높은 목표를 향해 DOMINATING 중이야, 만삣삐! ⚡'**
  String get levelDescRising;

  /// 고급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'👑 상당한 실력을 갖춘 ALPHA EMPEROR다.\n이미 많은 LEGENDARY ACHIEVEMENTS를 이루었어, 만삣삐! 👑'**
  String get levelDescAlpha;

  /// 최고급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'🚀 최고 수준의 ULTRA GIGA CHAD EMPEROR다.\n놀라운 GODLIKE POWER를 가지고 있어, 만삣삐! 🚀'**
  String get levelDescGiga;

  /// 초급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔥 모든 EMPEROR는 여기서 시작한다!\n6주 후 MIND-BLOWING TRANSFORMATION을 경험하라, 만삣삐! 🔥'**
  String get levelMotivationRookie;

  /// 중급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ EXCELLENT START다!\n더 강한 ALPHA BEAST가 되어라, 만삣삐! ⚡'**
  String get levelMotivationRising;

  /// 고급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'👑 OUTSTANDING PERFORMANCE다!\n100개 목표까지 DOMINATE하라, FXXK LIMITS! 👑'**
  String get levelMotivationAlpha;

  /// 최고급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 이미 강력한 GIGA CHAD군!\n완벽한 100개를 향해 CONQUER THE UNIVERSE, 만삣삐! 🚀'**
  String get levelMotivationGiga;

  /// 초급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'🔥 목표: 6주 후 연속 100개 푸시업 ABSOLUTE DOMINATION! 🔥'**
  String get levelGoalRookie;

  /// 중급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ 목표: 더 강한 ALPHA CHAD로 LEGENDARY EVOLUTION! ⚡'**
  String get levelGoalRising;

  /// 고급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'👑 목표: 완벽한 폼으로 100개 PERFECT EXECUTION! 👑'**
  String get levelGoalAlpha;

  /// 최고급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 목표: ULTIMATE CHAD MASTER로 UNIVERSE DOMINATION! 🚀'**
  String get levelGoalGiga;

  /// 마지막 세트 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'궁극의 승리 차지하라!'**
  String get workoutButtonUltimate;

  /// 일반 세트 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'이 세트를 정복하라, 만삣삐!'**
  String get workoutButtonConquer;

  /// 동기부여 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'🔥 진짜 ALPHA는 변명 따위 불태워버린다, FXXK THE WEAKNESS! 🔥'**
  String get motivationMessage1;

  /// 동기부여 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'⚡ 차드처럼 정복하고, 시그마처럼 지배하라! 휴식도 전략이다 ⚡'**
  String get motivationMessage2;

  /// 동기부여 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'💪 모든 푸시업이 너를 GOD TIER로 끌어올린다, 만삣삐! 💪'**
  String get motivationMessage3;

  /// 동기부여 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'⚡ 차드 에너지 100% 충전 완료! 이제 세상을 평정하라! ⚡'**
  String get motivationMessage4;

  /// 동기부여 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'🚀 차드 진화가 아니다! 이제 LEGEND TRANSFORMATION이다, FXXK YEAH! 🚀'**
  String get motivationMessage5;

  /// 동기부여 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'👑 차드 모드? 그딴 건 지났다. 지금은 EMPEROR MODE: ACTIVATED! 👑'**
  String get motivationMessage6;

  /// 동기부여 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'🌪️ 이렇게 전설들이 탄생한다, 만삣삐! 역사가 너를 기억할 것이다! 🌪️'**
  String get motivationMessage7;

  /// 동기부여 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'⚡ 차드 파워가 아니다... 이제 ALPHA LIGHTNING이 몸을 관통한다! ⚡'**
  String get motivationMessage8;

  /// 동기부여 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'🔱 차드 변신 완료! 이제 ULTIMATE APEX PREDATOR로 진화했다! 🔱'**
  String get motivationMessage9;

  /// 동기부여 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'🦁 차드 브라더후드? 아니다! ALPHA EMPIRE의 황제에게 경배하라, 만삣삐! 🦁'**
  String get motivationMessage10;

  /// 완료 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'🔥 바로 그거다! ABSOLUTE DOMINATION, FXXK YEAH! 🔥'**
  String get completionMessage1;

  /// 완료 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'⚡ 오늘 ALPHA STORM이 몰아쳤다, 만삣삐! 세상이 떨고 있어! ⚡'**
  String get completionMessage2;

  /// 완료 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'👑 차드에 가까워진 게 아니다... 이제 차드를 넘어섰다! 👑'**
  String get completionMessage3;

  /// 완료 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'🚀 차드답다고? 틀렸다! 이제 LEGENDARY BEAST MODE다, YOU MONSTER! 🚀'**
  String get completionMessage4;

  /// 완료 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'⚡ 차드 에너지 레벨: ∞ 무한대 돌파! 우주가 경배한다! ⚡'**
  String get completionMessage5;

  /// 완료 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'🦁 존경? 그딴 건 지났다! 이제 온 세상이 너에게 절한다, 만삣삐! 🦁'**
  String get completionMessage6;

  /// 완료 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'🔱 차드가 승인했다고? 아니다! GOD TIER가 탄생을 인정했다! 🔱'**
  String get completionMessage7;

  /// 완료 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'🌪️ 차드 게임 레벨업? 틀렸다! ALPHA DIMENSION을 정복했다, FXXK BEAST! 🌪️'**
  String get completionMessage8;

  /// 완료 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'💥 순수한 차드 퍼포먼스가 아니다... 이제 PURE LEGENDARY DOMINANCE! 💥'**
  String get completionMessage9;

  /// 완료 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'👑 차드의 하루? 아니다! EMPEROR OF ALPHAS의 제국 건설 완료, 만삣삐! 👑'**
  String get completionMessage10;

  /// 격려 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'🔥 ALPHA도 시련이 있다, 만삣삐! 하지만 그게 너를 더 강하게 만든다! 🔥'**
  String get encouragementMessage1;

  /// 격려 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'⚡ 내일은 LEGENDARY COMEBACK의 날이다! 세상이 너의 부활을 보게 될 것이다! ⚡'**
  String get encouragementMessage2;

  /// 격려 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'👑 진짜 EMPEROR는 절대 굴복하지 않는다, FXXK THE LIMITS! 👑'**
  String get encouragementMessage3;

  /// 격려 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'🚀 이건 그냥 ULTIMATE BOSS FIGHT 모드야! 너는 이미 승리했다! 🚀'**
  String get encouragementMessage4;

  /// 격려 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'🦁 진짜 APEX PREDATOR는 더 강해져서 돌아온다, 만삣삐! 🦁'**
  String get encouragementMessage5;

  /// 격려 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'🔱 ALPHA 정신은 불멸이다! 우주가 끝나도 너는 살아남는다! 🔱'**
  String get encouragementMessage6;

  /// 격려 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'⚡ 아직 LEGEND TRANSFORMATION 진행 중이다, YOU ABSOLUTE UNIT! ⚡'**
  String get encouragementMessage7;

  /// 격려 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'🌪️ EPIC COMEBACK STORM이 몰려온다! 세상이 너의 복귀를 떨며 기다린다! 🌪️'**
  String get encouragementMessage8;

  /// 격려 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'💥 모든 EMPEROR는 시련을 통과한다, 만삣삐! 이게 바로 왕의 길이다! 💥'**
  String get encouragementMessage9;

  /// 격려 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'👑 ALPHA 회복력이 아니다... 이제 IMMORTAL PHOENIX POWER다, FXXK YEAH! 👑'**
  String get encouragementMessage10;

  /// 차드 레벨 0 메시지 - 수면모자차드
  ///
  /// In ko, this message translates to:
  /// **'🛌 잠에서 깨어나라, 미래의 차드여! 여정이 시작된다!'**
  String get chadMessage0;

  /// 차드 레벨 1 메시지 - 기본차드
  ///
  /// In ko, this message translates to:
  /// **'😎 기본기가 탄탄해지고 있어! 진짜 차드의 시작이야!'**
  String get chadMessage1;

  /// 차드 레벨 2 메시지 - 커피차드
  ///
  /// In ko, this message translates to:
  /// **'☕ 에너지가 넘쳐흘러! 커피보다 강한 힘이 생겼어!'**
  String get chadMessage2;

  /// 차드 레벨 3 메시지 - 정면차드
  ///
  /// In ko, this message translates to:
  /// **'🔥 정면돌파! 어떤 장애물도 막을 수 없다!'**
  String get chadMessage3;

  /// 차드 레벨 4 메시지 - 썬글차드
  ///
  /// In ko, this message translates to:
  /// **'🕶️ 쿨함이 몸에 배었어! 진정한 알파의 모습이야!'**
  String get chadMessage4;

  /// 차드 레벨 5 메시지 - 눈빔차드
  ///
  /// In ko, this message translates to:
  /// **'⚡ 눈빛만으로도 세상을 바꿀 수 있어! 전설의 시작!'**
  String get chadMessage5;

  /// 차드 레벨 6 메시지 - 더블차드
  ///
  /// In ko, this message translates to:
  /// **'👑 최고의 차드 완성! 더블 파워로 우주를 정복하라!'**
  String get chadMessage6;

  /// 튜토리얼 메인 타이틀
  ///
  /// In ko, this message translates to:
  /// **'🔥 ALPHA EMPEROR PUSHUP DOJO 🔥'**
  String get tutorialTitle;

  /// 튜토리얼 서브타이틀
  ///
  /// In ko, this message translates to:
  /// **'진짜 EMPEROR는 자세부터 다르다, 만삣삐! 💪'**
  String get tutorialSubtitle;

  /// 홈에서 튜토리얼로 가는 버튼
  ///
  /// In ko, this message translates to:
  /// **'💥 PUSHUP MASTER 되기 💥'**
  String get tutorialButton;

  /// 초급 난이도
  ///
  /// In ko, this message translates to:
  /// **'🔥 FUTURE EMPEROR - 시작하는 ALPHA들 🔥'**
  String get difficultyBeginner;

  /// 중급 난이도
  ///
  /// In ko, this message translates to:
  /// **'⚡ ALPHA RISING - 성장하는 BEAST들 ⚡'**
  String get difficultyIntermediate;

  /// 고급 난이도
  ///
  /// In ko, this message translates to:
  /// **'👑 EMPEROR MODE - 강력한 CHAD들 👑'**
  String get difficultyAdvanced;

  /// 극한 난이도
  ///
  /// In ko, this message translates to:
  /// **'🚀 ULTRA GIGA CHAD - 전설의 GODLIKE 영역 🚀'**
  String get difficultyExtreme;

  /// 타겟 근육 - 가슴
  ///
  /// In ko, this message translates to:
  /// **'가슴'**
  String get targetMuscleChest;

  /// 타겟 근육 - 삼두근
  ///
  /// In ko, this message translates to:
  /// **'삼두근'**
  String get targetMuscleTriceps;

  /// 타겟 근육 - 어깨
  ///
  /// In ko, this message translates to:
  /// **'어깨'**
  String get targetMuscleShoulders;

  /// 타겟 근육 - 코어
  ///
  /// In ko, this message translates to:
  /// **'코어'**
  String get targetMuscleCore;

  /// 타겟 근육 - 전신
  ///
  /// In ko, this message translates to:
  /// **'전신'**
  String get targetMuscleFull;

  /// 회당 칼로리 소모량
  ///
  /// In ko, this message translates to:
  /// **'{calories}kcal/회'**
  String caloriesPerRep(int calories);

  /// 튜토리얼 상세 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'💥 EMPEROR 자세 MASTER하기 💥'**
  String get tutorialDetailTitle;

  /// 효과 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🚀 이렇게 LEGENDARY BEAST가 된다 🚀'**
  String get benefitsSection;

  /// 실행 방법 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'⚡ EMPEROR EXECUTION 방법 ⚡'**
  String get instructionsSection;

  /// 일반적인 실수 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'❌ 약자들의 PATHETIC 실수들 ❌'**
  String get mistakesSection;

  /// 호흡법 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🌪️ ALPHA EMPEROR 호흡법 🌪️'**
  String get breathingSection;

  /// 차드 격려 메시지 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🔥 EMPEROR\'S ULTIMATE WISDOM 🔥'**
  String get chadMotivationSection;

  /// 기본 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'기본 푸시업'**
  String get pushupStandardName;

  /// 기본 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'모든 차드의 시작점. 완벽한 기본기가 진짜 강함이다, 만삣삐!'**
  String get pushupStandardDesc;

  /// 기본 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 가슴근육 전체 발달\\n• 삼두근과 어깨 강화\\n• 기본 체력 향상\\n• 모든 푸시업의 기초가 된다, you idiot!'**
  String get pushupStandardBenefits;

  /// 기본 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 플랭크 자세로 시작한다, 만삣삐\\n2. 손은 어깨 너비로 벌려라\\n3. 몸은 일직선으로 유지해라, 흐트러지지 말고\\n4. 가슴이 바닥에 닿을 때까지 내려가라\\n5. 강하게 밀어올려라, 차드답게!'**
  String get pushupStandardInstructions;

  /// 기본 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 엉덩이가 위로 솟음 - 약자들이나 하는 짓이야\\n• 가슴을 끝까지 내리지 않음\\n• 목을 앞으로 빼고 함\\n• 손목이 어깨보다 앞에 위치\\n• 일정한 속도를 유지하지 않음, fxxk idiot!'**
  String get pushupStandardMistakes;

  /// 기본 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'내려갈 때 숨을 마시고, 올라올 때 강하게 내뱉어라. 호흡이 파워다, 만삣삐!'**
  String get pushupStandardBreathing;

  /// 표준 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🔥 기본이 제일 어렵다고? 틀렸다! 완벽한 폼 하나가 세상을 정복한다, 만삣삐! MASTER THE BASICS! 🔥'**
  String get pushupStandardChad;

  /// 무릎 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'무릎 푸시업'**
  String get pushupKneeName;

  /// 무릎 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'차드 여정의 첫 걸음. 부끄러워하지 마라, 모든 전설은 여기서 시작된다!'**
  String get pushupKneeDesc;

  /// 무릎 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 기본 근력 향상\\n• 올바른 푸시업 폼 학습\\n• 어깨와 팔 안정성 강화\\n• 기본 푸시업으로의 단계적 진행'**
  String get pushupKneeBenefits;

  /// 무릎 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 무릎을 바닥에 대고 시작하라\\n2. 발목을 들어올려라\\n3. 상체는 기본 푸시업과 동일하게\\n4. 무릎에서 머리까지 일직선 유지\\n5. 천천히 확실하게 움직여라, 만삣삐!'**
  String get pushupKneeInstructions;

  /// 무릎 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 엉덩이가 뒤로 빠짐\\n• 무릎 위치가 너무 앞쪽\\n• 상체만 움직이고 코어 사용 안 함\\n• 너무 빠르게 동작함'**
  String get pushupKneeMistakes;

  /// 무릎 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'부드럽고 꾸준한 호흡으로 시작해라. 급하게 하지 마라, 만삣삐!'**
  String get pushupKneeBreathing;

  /// 무릎 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'⚡ 시작이 반? 아니다! 이미 ALPHA JOURNEY가 시작됐다! 무릎 푸시업도 EMPEROR의 길이다! ⚡'**
  String get pushupKneeChad;

  /// 인클라인 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'인클라인 푸시업'**
  String get pushupInclineName;

  /// 인클라인 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'높은 곳에 손을 올리고 하는 푸시업. 계단을 올라가듯 차드로 진화한다!'**
  String get pushupInclineDesc;

  /// 인클라인 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 부담을 줄여 폼 완성\\n• 하부 가슴근육 강화\\n• 어깨 안정성 향상\\n• 기본 푸시업으로의 징검다리'**
  String get pushupInclineBenefits;

  /// 인클라인 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 벤치나 의자에 손을 올려라\\n2. 몸을 비스듬히 기울여라\\n3. 발가락부터 머리까지 일직선\\n4. 높을수록 쉬워진다, 만삣삐\\n5. 점차 낮은 곳으로 도전해라!'**
  String get pushupInclineInstructions;

  /// 인클라인 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 엉덩이가 위로 솟음\\n• 손목에 과도한 체중\\n• 불안정한 지지대 사용\\n• 각도를 너무 급하게 낮춤'**
  String get pushupInclineMistakes;

  /// 인클라인 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'각도가 편해진 만큼 호흡도 편안하게. 하지만 집중력은 최고로, you idiot!'**
  String get pushupInclineBreathing;

  /// 인클라인 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🚀 높이는 조절하고 강도는 MAX! 20개 완벽 수행하면 GOD TIER 입장권 획득이다, 만삣삐! 🚀'**
  String get pushupInclineChad;

  /// 와이드 그립 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'와이드 그립 푸시업'**
  String get pushupWideGripName;

  /// 와이드 그립 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'손 간격을 넓혀서 가슴을 더 넓게 만드는 푸시업. 차드의 가슴판을 키운다!'**
  String get pushupWideGripDesc;

  /// 와이드 그립 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 가슴 바깥쪽 근육 집중 발달\\n• 어깨 안정성 향상\\n• 가슴 넓이 확장\\n• 상체 전체적인 균형 발달'**
  String get pushupWideGripBenefits;

  /// 와이드 그립 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 손을 어깨보다 1.5배 넓게 벌려라\\n2. 손가락은 약간 바깥쪽을 향하게\\n3. 가슴이 바닥에 닿을 때까지\\n4. 팔꿈치는 45도 각도 유지\\n5. 넓은 가슴으로 밀어올려라, 만삣삐!'**
  String get pushupWideGripInstructions;

  /// 와이드 그립 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 손을 너무 넓게 벌림\\n• 팔꿈치가 완전히 바깥쪽\\n• 어깨에 무리가 가는 자세\\n• 가슴을 충분히 내리지 않음'**
  String get pushupWideGripMistakes;

  /// 와이드 그립 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'넓은 가슴으로 깊게 숨쉬어라. 가슴이 확장되는 걸 느껴라, you idiot!'**
  String get pushupWideGripBreathing;

  /// 와이드 그립 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🦁 넓은 가슴? 아니다! 이제 LEGENDARY GORILLA CHEST를 만들어라! 와이드 그립으로 세상을 압도하라! 🦁'**
  String get pushupWideGripChad;

  /// 다이아몬드 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'다이아몬드 푸시업'**
  String get pushupDiamondName;

  /// 다이아몬드 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'손가락으로 다이아몬드를 만들어 하는 푸시업. 삼두근을 다이아몬드처럼 단단하게!'**
  String get pushupDiamondDesc;

  /// 다이아몬드 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 삼두근 집중 강화\\n• 가슴 안쪽 근육 발달\\n• 팔 전체 근력 향상\\n• 코어 안정성 증가'**
  String get pushupDiamondBenefits;

  /// 다이아몬드 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 엄지와 검지로 다이아몬드 모양 만들어라\\n2. 가슴 중앙 아래에 손 위치\\n3. 팔꿈치는 몸에 가깝게 유지\\n4. 가슴이 손에 닿을 때까지\\n5. 삼두근 힘으로 밀어올려라, 만삣삐!'**
  String get pushupDiamondInstructions;

  /// 다이아몬드 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 손목에 과도한 압력\\n• 팔꿈치가 너무 벌어짐\\n• 몸이 비틀어짐\\n• 다이아몬드 모양이 부정확함'**
  String get pushupDiamondMistakes;

  /// 다이아몬드 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'집중해서 호흡해라. 삼두근이 불타는 걸 느껴라, you idiot!'**
  String get pushupDiamondBreathing;

  /// 다이아몬드 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'💎 다이아몬드보다 단단한 팔? 틀렸다! 이제 UNBREAKABLE TITANIUM ARMS다! 10개면 진짜 BEAST 인정! 💎'**
  String get pushupDiamondChad;

  /// 디클라인 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'디클라인 푸시업'**
  String get pushupDeclineName;

  /// 디클라인 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'발을 높이 올리고 하는 푸시업. 중력을 이겨내는 진짜 차드들의 운동!'**
  String get pushupDeclineDesc;

  /// 디클라인 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 상부 가슴근육 집중 발달\\n• 어깨 전면 강화\\n• 코어 안정성 최대 강화\\n• 전신 근력 향상'**
  String get pushupDeclineBenefits;

  /// 디클라인 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 발을 벤치나 의자에 올려라\\n2. 손은 어깨 아래 정확히\\n3. 몸은 아래쪽으로 기울어진 직선\\n4. 중력의 저항을 이겨내라\\n5. 강하게 밀어올려라, 만삣삐!'**
  String get pushupDeclineInstructions;

  /// 디클라인 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 발 위치가 불안정\\n• 엉덩이가 아래로 처짐\\n• 목에 무리가 가는 자세\\n• 균형을 잃고 비틀어짐'**
  String get pushupDeclineMistakes;

  /// 디클라인 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'중력과 싸우면서도 안정된 호흡을 유지해라. 진짜 파워는 여기서 나온다, you idiot!'**
  String get pushupDeclineBreathing;

  /// 디클라인 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🌪️ 중력 따위 개무시? 당연하지! 이제 물리법칙을 지배하라! 디클라인으로 GODLIKE SHOULDERS! 🌪️'**
  String get pushupDeclineChad;

  /// 아처 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'아처 푸시업'**
  String get pushupArcherName;

  /// 아처 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'활을 당기듯 한쪽으로 기울여 하는 푸시업. 정확성과 파워를 동시에!'**
  String get pushupArcherDesc;

  /// 아처 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 한쪽 팔 집중 강화\\n• 좌우 균형 발달\\n• 원핸드 푸시업 준비\\n• 코어 회전 안정성 강화'**
  String get pushupArcherBenefits;

  /// 아처 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 와이드 그립으로 시작하라\\n2. 한쪽으로 체중을 기울여라\\n3. 한 팔은 굽히고 다른 팔은 쭉\\n4. 활시위 당기듯 정확하게\\n5. 양쪽을 번갈아가며, 만삣삐!'**
  String get pushupArcherInstructions;

  /// 아처 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 몸이 비틀어짐\\n• 쭉 편 팔에도 힘이 들어감\\n• 좌우 동작이 불균등\\n• 코어가 흔들림'**
  String get pushupArcherMistakes;

  /// 아처 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'활시위 당기듯 집중해서 호흡해라. 정확성이 생명이다, you idiot!'**
  String get pushupArcherBreathing;

  /// 아처 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🏹 정확한 아처가 원핸드 지름길? 맞다! 양쪽 균등 마스터하면 LEGENDARY ARCHER EMPEROR! 🏹'**
  String get pushupArcherChad;

  /// 파이크 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'파이크 푸시업'**
  String get pushupPikeName;

  /// 파이크 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'역삼각형 자세로 하는 푸시업. 어깨를 바위로 만드는 차드의 비밀!'**
  String get pushupPikeDesc;

  /// 파이크 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 어깨 전체 근육 강화\\n• 핸드스탠드 푸시업 준비\\n• 상체 수직 힘 발달\\n• 코어와 균형감 향상'**
  String get pushupPikeBenefits;

  /// 파이크 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 다운독 자세로 시작하라\\n2. 엉덩이를 최대한 위로\\n3. 머리가 바닥에 가까워질 때까지\\n4. 어깨 힘으로만 밀어올려라\\n5. 역삼각형을 유지하라, 만삣삐!'**
  String get pushupPikeInstructions;

  /// 파이크 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 엉덩이가 충분히 올라가지 않음\\n• 팔꿈치가 옆으로 벌어짐\\n• 머리로만 지탱하려 함\\n• 발 위치가 너무 멀거나 가까움'**
  String get pushupPikeMistakes;

  /// 파이크 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'거꾸로 된 자세에서도 안정된 호흡. 어깨에 집중해라, you idiot!'**
  String get pushupPikeBreathing;

  /// 파이크 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'⚡ 파이크 마스터하면 핸드스탠드? 당연하지! 어깨 EMPEROR로 진화하라, 만삣삐! ⚡'**
  String get pushupPikeChad;

  /// 박수 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'박수 푸시업'**
  String get pushupClapName;

  /// 박수 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'폭발적인 힘으로 박수를 치는 푸시업. 진짜 파워는 여기서 증명된다!'**
  String get pushupClapDesc;

  /// 박수 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 폭발적인 근력 발달\\n• 전신 파워 향상\\n• 순간 반응속도 증가\\n• 진짜 차드의 증명'**
  String get pushupClapBenefits;

  /// 박수 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 기본 푸시업 자세로 시작\\n2. 폭발적으로 밀어올려라\\n3. 공중에서 박수를 쳐라\\n4. 안전하게 착지하라\\n5. 연속으로 도전해라, 만삣삐!'**
  String get pushupClapInstructions;

  /// 박수 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 충분한 높이로 올라가지 않음\\n• 착지할 때 손목 부상 위험\\n• 폼이 흐트러짐\\n• 무리한 연속 시도'**
  String get pushupClapMistakes;

  /// 박수 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'폭발할 때 강하게 내뱉고, 착지 후 빠르게 호흡 정리. 리듬이 중요하다, you idiot!'**
  String get pushupClapBreathing;

  /// 박수 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'👏 박수 푸시업은 파워의 증명? 아니다! 이제 EXPLOSIVE THUNDER POWER의 표현이다! 👏'**
  String get pushupClapChad;

  /// 원핸드 푸시업 이름
  ///
  /// In ko, this message translates to:
  /// **'원핸드 푸시업'**
  String get pushupOneArmName;

  /// 원핸드 푸시업 설명
  ///
  /// In ko, this message translates to:
  /// **'한 손으로만 하는 궁극의 푸시업. 기가 차드만이 도달할 수 있는 영역!'**
  String get pushupOneArmDesc;

  /// 원핸드 푸시업 효과
  ///
  /// In ko, this message translates to:
  /// **'• 궁극의 상체 근력\\n• 완벽한 코어 컨트롤\\n• 전신 균형과 조정력\\n• 기가 차드의 완성'**
  String get pushupOneArmBenefits;

  /// 원핸드 푸시업 실행법
  ///
  /// In ko, this message translates to:
  /// **'1. 다리를 넓게 벌려 균형잡아라\\n2. 한 손은 등 뒤로\\n3. 코어에 모든 힘을 집중\\n4. 천천히 확실하게\\n5. 기가 차드의 자격을 증명하라!'**
  String get pushupOneArmInstructions;

  /// 원핸드 푸시업 일반적인 실수
  ///
  /// In ko, this message translates to:
  /// **'• 다리가 너무 좁음\\n• 몸이 비틀어지며 회전\\n• 반대 손으로 지탱\\n• 무리한 도전으로 부상'**
  String get pushupOneArmMistakes;

  /// 원핸드 푸시업 호흡법
  ///
  /// In ko, this message translates to:
  /// **'깊고 안정된 호흡으로 집중력을 최고조로. 모든 에너지를 하나로, you idiot!'**
  String get pushupOneArmBreathing;

  /// 원핸드 푸시업 차드 조언
  ///
  /// In ko, this message translates to:
  /// **'🚀 원핸드는 차드 완성형? 틀렸다! 이제 ULTIMATE APEX GOD EMPEROR 탄생이다, FXXK YEAH! 🚀'**
  String get pushupOneArmChad;

  /// 레벨 선택 요청 버튼
  ///
  /// In ko, this message translates to:
  /// **'🔥 레벨을 선택하라, FUTURE EMPEROR! 🔥'**
  String get selectLevelButton;

  /// 선택한 레벨로 시작하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'💥 {level}로 EMPEROR JOURNEY 시작! 💥'**
  String startWithLevel(String level);

  /// 프로필 생성 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'🚀 EMPEROR PROFILE CREATION COMPLETE! ({sessions}개 DOMINATION SESSION 준비됨, 만삣삐!) 🚀'**
  String profileCreated(int sessions);

  /// 프로필 생성 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚡ PROFILE CREATION FAILED! 다시 도전하라, ALPHA! 오류: {error} ⚡'**
  String profileCreationError(String error);

  /// 첫 번째 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'차드 여정의 시작'**
  String get achievementFirstJourney;

  /// 첫 번째 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 푸쉬업을 완료하다'**
  String get achievementFirstJourneyDesc;

  /// 완벽한 세트 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'완벽한 첫 세트'**
  String get achievementPerfectSet;

  /// 완벽한 세트 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'목표를 100% 달성한 세트를 완료하다'**
  String get achievementPerfectSetDesc;

  /// 100회 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'센츄리온'**
  String get achievementCenturion;

  /// 100회 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'총 100회의 푸쉬업을 달성하다'**
  String get achievementCenturionDesc;

  /// 7일 연속 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'주간 전사'**
  String get achievementWeekWarrior;

  /// 7일 연속 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'7일 연속으로 운동하다'**
  String get achievementWeekWarriorDesc;

  /// 어려운 난이도 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'강철 의지'**
  String get achievementIronWill;

  /// 어려운 난이도 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'한 번에 200개를 달성했습니다'**
  String get achievementIronWillDesc;

  /// 빠른 완료 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'스피드 데몬'**
  String get achievementSpeedDemon;

  /// 빠른 완료 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'5분 이내에 50개를 완료했습니다'**
  String get achievementSpeedDemonDesc;

  /// 1000회 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'푸쉬업 마스터'**
  String get achievementPushupMaster;

  /// 1000회 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'총 1000회의 푸쉬업을 달성하다'**
  String get achievementPushupMasterDesc;

  /// 30일 연속 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'일관성의 왕'**
  String get achievementConsistency;

  /// 30일 연속 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'30일 연속으로 운동하다'**
  String get achievementConsistencyDesc;

  /// 목표 초과 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'야수 모드'**
  String get achievementBeastMode;

  /// 목표 초과 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'목표를 150% 초과 달성하다'**
  String get achievementBeastModeDesc;

  /// 5000회 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'마라토너'**
  String get achievementMarathoner;

  /// 5000회 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'총 5000회의 푸쉬업을 달성하다'**
  String get achievementMarathonerDesc;

  /// 10000회 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'전설'**
  String get achievementLegend;

  /// 10000회 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'총 10000회의 푸쉬업을 달성하다'**
  String get achievementLegendDesc;

  /// 완벽한 세트 10개 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'완벽주의자'**
  String get achievementPerfectionist;

  /// 완벽한 세트 10개 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'완벽한 세트를 10개 달성하다'**
  String get achievementPerfectionistDesc;

  /// 아침 운동 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'얼리버드'**
  String get achievementEarlyBird;

  /// 아침 운동 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'오전 7시 이전에 5번 운동했습니다'**
  String get achievementEarlyBirdDesc;

  /// 밤 운동 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'올빼미'**
  String get achievementNightOwl;

  /// 밤 운동 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'오후 10시 이후에 5번 운동했습니다'**
  String get achievementNightOwlDesc;

  /// 목표 초과 5회 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'초과달성자'**
  String get achievementOverachiever;

  /// 목표 초과 5회 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'목표의 150%를 5번 달성했습니다'**
  String get achievementOverachieverDesc;

  /// 긴 운동 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'지구력 왕'**
  String get achievementEndurance;

  /// 긴 운동 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'30분 이상 운동하다'**
  String get achievementEnduranceDesc;

  /// 다양한 푸쉬업 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'다양성의 달인'**
  String get achievementVariety;

  /// 다양한 푸쉬업 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'5가지 다른 푸쉬업 타입을 완료하다'**
  String get achievementVarietyDesc;

  /// 100일 연속 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'헌신'**
  String get achievementDedication;

  /// 100일 연속 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'100일 연속으로 운동하다'**
  String get achievementDedicationDesc;

  /// 최고 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'궁극의 차드'**
  String get achievementUltimate;

  /// 최고 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'모든 업적을 달성하다'**
  String get achievementUltimateDesc;

  /// 신 모드 업적 제목
  ///
  /// In ko, this message translates to:
  /// **'신 모드'**
  String get achievementGodMode;

  /// 신 모드 업적 설명
  ///
  /// In ko, this message translates to:
  /// **'한 세션에서 500회 이상 달성하다'**
  String get achievementGodModeDesc;

  /// 일반 등급
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get achievementRarityCommon;

  /// 레어 등급
  ///
  /// In ko, this message translates to:
  /// **'레어'**
  String get achievementRarityRare;

  /// 에픽 등급
  ///
  /// In ko, this message translates to:
  /// **'에픽'**
  String get achievementRarityEpic;

  /// 전설 등급
  ///
  /// In ko, this message translates to:
  /// **'전설'**
  String get achievementRarityLegendary;

  /// 신화 등급
  ///
  /// In ko, this message translates to:
  /// **'신화'**
  String get achievementRarityMythic;

  /// 홈 탭
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// 달력 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'달력'**
  String get calendar;

  /// 업적 탭
  ///
  /// In ko, this message translates to:
  /// **'업적'**
  String get achievements;

  /// 통계 탭
  ///
  /// In ko, this message translates to:
  /// **'통계'**
  String get statistics;

  /// 설정 탭
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// YouTube Shorts 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'차드 쇼츠 🔥'**
  String get chadShorts;

  /// 설정 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'⚙️ 차드 설정'**
  String get settingsTitle;

  /// 설정 화면 부제목
  ///
  /// In ko, this message translates to:
  /// **'당신의 차드 여정을 커스터마이즈하세요'**
  String get settingsSubtitle;

  /// 운동 설정 섹션
  ///
  /// In ko, this message translates to:
  /// **'💪 운동 설정'**
  String get workoutSettings;

  /// 알림 설정 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 알림 설정'**
  String get notificationSettings;

  /// 외형 설정 섹션
  ///
  /// In ko, this message translates to:
  /// **'🎨 외형 설정'**
  String get appearanceSettings;

  /// 데이터 관리 섹션
  ///
  /// In ko, this message translates to:
  /// **'💾 데이터 관리'**
  String get dataSettings;

  /// 앱 정보 섹션
  ///
  /// In ko, this message translates to:
  /// **'ℹ️ 앱 정보'**
  String get aboutSettings;

  /// 난이도 설정
  ///
  /// In ko, this message translates to:
  /// **'난이도 설정'**
  String get difficultySettings;

  /// 푸시 알림 설정
  ///
  /// In ko, this message translates to:
  /// **'푸시 알림'**
  String get pushNotifications;

  /// 푸시 알림 설명
  ///
  /// In ko, this message translates to:
  /// **'💥 모든 알림을 받아라! 도망칠 곳은 없다!'**
  String get pushNotificationsDesc;

  /// 업적 알림 설정
  ///
  /// In ko, this message translates to:
  /// **'업적 알림'**
  String get achievementNotifications;

  /// 업적 알림 설명
  ///
  /// In ko, this message translates to:
  /// **'🏆 새로운 업적 달성 시 너의 승리를 알려준다!'**
  String get achievementNotificationsDesc;

  /// 운동 리마인더 설정
  ///
  /// In ko, this message translates to:
  /// **'운동 리마인더'**
  String get workoutReminders;

  /// 운동 리마인더 설명
  ///
  /// In ko, this message translates to:
  /// **'💀 매일 너를 깨워서 운동시켜줄 거야! 도망갈 생각 마라!'**
  String get workoutRemindersDesc;

  /// 리마인더 시간 설정
  ///
  /// In ko, this message translates to:
  /// **'⏰ 리마인더 시간'**
  String get reminderTime;

  /// 리마인더 시간 설명
  ///
  /// In ko, this message translates to:
  /// **'⚡ 너의 운명이 결정되는 시간을 정해라!'**
  String get reminderTimeDesc;

  /// 다크 모드 설정
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get darkMode;

  /// 다크 모드 설명
  ///
  /// In ko, this message translates to:
  /// **'🌙 진짜 차드는 어둠 속에서도 강하다'**
  String get darkModeDesc;

  /// 언어 설정
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageSettings;

  /// 데이터 백업
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업'**
  String get dataBackup;

  /// 데이터 백업 설명
  ///
  /// In ko, this message translates to:
  /// **'💾 너의 차드 전설을 영원히 보존한다!'**
  String get dataBackupDesc;

  /// 데이터 복원
  ///
  /// In ko, this message translates to:
  /// **'데이터 복원'**
  String get dataRestore;

  /// 데이터 복원 설명
  ///
  /// In ko, this message translates to:
  /// **'백업된 데이터를 복원합니다'**
  String get dataRestoreDesc;

  /// 데이터 초기화
  ///
  /// In ko, this message translates to:
  /// **'데이터 초기화'**
  String get dataReset;

  /// 데이터 초기화 설명
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터를 삭제합니다'**
  String get dataResetDesc;

  /// 버전 정보
  ///
  /// In ko, this message translates to:
  /// **'버전 정보'**
  String get versionInfo;

  /// 버전 정보 설명
  ///
  /// In ko, this message translates to:
  /// **'Mission: 100 v1.0.0'**
  String get versionInfoDesc;

  /// 개발자 정보
  ///
  /// In ko, this message translates to:
  /// **'개발자 정보'**
  String get developerInfo;

  /// 개발자 정보 설명
  ///
  /// In ko, this message translates to:
  /// **'차드가 되는 여정을 함께하세요'**
  String get developerInfoDesc;

  /// Send feedback button
  ///
  /// In ko, this message translates to:
  /// **'📧 피드백 보내기'**
  String get sendFeedback;

  /// 피드백 보내기 설명
  ///
  /// In ko, this message translates to:
  /// **'💬 너의 의견을 들려달라! 차드들의 목소리가 필요하다!'**
  String get sendFeedbackDesc;

  /// 일반 등급
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get common;

  /// 레어 등급
  ///
  /// In ko, this message translates to:
  /// **'레어'**
  String get rare;

  /// 에픽 등급
  ///
  /// In ko, this message translates to:
  /// **'에픽'**
  String get epic;

  /// 레전더리 등급
  ///
  /// In ko, this message translates to:
  /// **'레전더리'**
  String get legendary;

  /// 획득한 업적 탭
  ///
  /// In ko, this message translates to:
  /// **'획득한 업적 ({count})'**
  String unlockedAchievements(int count);

  /// 미획득 업적 탭
  ///
  /// In ko, this message translates to:
  /// **'미획득 업적 ({count})'**
  String lockedAchievements(int count);

  /// 업적 없음 제목
  ///
  /// In ko, this message translates to:
  /// **'아직 획득한 업적이 없습니다'**
  String get noAchievementsYet;

  /// 업적 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동을 시작해서 첫 번째 업적을 획득해보세요!'**
  String get startWorkoutForAchievements;

  /// 모든 업적 획득 제목
  ///
  /// In ko, this message translates to:
  /// **'모든 업적을 획득했습니다!'**
  String get allAchievementsUnlocked;

  /// 모든 업적 획득 메시지
  ///
  /// In ko, this message translates to:
  /// **'축하합니다! 진정한 차드가 되셨습니다! 🎉'**
  String get congratulationsChad;

  /// 업적 화면 배너 텍스트
  ///
  /// In ko, this message translates to:
  /// **'업적을 달성해서 차드가 되자! 🏆'**
  String get achievementsBannerText;

  /// 총 경험치 라벨
  ///
  /// In ko, this message translates to:
  /// **'총 경험치'**
  String get totalExperience;

  /// 운동 기록 없음 제목
  ///
  /// In ko, this message translates to:
  /// **'아직 운동 기록이 없어!'**
  String get noWorkoutRecords;

  /// 첫 운동 시작 메시지
  ///
  /// In ko, this message translates to:
  /// **'첫 운동을 시작하고\\n차드의 전설을 만들어보자! 🔥'**
  String get startFirstWorkout;

  /// 통계 로딩 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드의 통계를 불러오는 중...'**
  String get loadingStatistics;

  /// 총 운동 횟수
  ///
  /// In ko, this message translates to:
  /// **'총 운동 횟수'**
  String get totalWorkouts;

  /// 운동 횟수 형식
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String workoutCount(int count);

  /// 총 운동 횟수 부제목
  ///
  /// In ko, this message translates to:
  /// **'차드가 된 날들!'**
  String get chadDays;

  /// 총 푸시업 개수
  ///
  /// In ko, this message translates to:
  /// **'총 푸시업'**
  String get totalPushups;

  /// 푸시업 개수 형식
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String pushupsCount(int count);

  /// 총 푸시업 부제목
  ///
  /// In ko, this message translates to:
  /// **'진짜 차드 파워!'**
  String get realChadPower;

  /// 평균 달성률
  ///
  /// In ko, this message translates to:
  /// **'평균 달성률'**
  String get averageCompletion;

  /// 달성률 퍼센트 형식
  ///
  /// In ko, this message translates to:
  /// **'{percentage}%'**
  String completionPercentage(int percentage);

  /// 평균 달성률 부제목
  ///
  /// In ko, this message translates to:
  /// **'완벽한 수행!'**
  String get perfectExecution;

  /// 이번 달 운동 횟수
  ///
  /// In ko, this message translates to:
  /// **'이번 달 운동'**
  String get thisMonthWorkouts;

  /// 이번 달 운동 부제목
  ///
  /// In ko, this message translates to:
  /// **'꾸준한 차드!'**
  String get consistentChad;

  /// 현재 연속 운동일
  ///
  /// In ko, this message translates to:
  /// **'현재 연속'**
  String get currentStreak;

  /// 연속 일수 형식
  ///
  /// In ko, this message translates to:
  /// **'{days}일'**
  String streakDays(int days);

  /// 최고 연속 운동일
  ///
  /// In ko, this message translates to:
  /// **'최고 기록'**
  String get bestRecord;

  /// 최근 운동 기록 제목
  ///
  /// In ko, this message translates to:
  /// **'최근 운동 기록'**
  String get recentWorkouts;

  /// 운동 기록 형식
  ///
  /// In ko, this message translates to:
  /// **'{reps}개 • {percentage}% 달성'**
  String repsAchieved(int reps, int percentage);

  /// 통계 화면 배너 텍스트
  ///
  /// In ko, this message translates to:
  /// **'차드의 성장을 확인하라! 📊'**
  String get checkChadGrowth;

  /// 선택된 날짜의 운동 기록
  ///
  /// In ko, this message translates to:
  /// **'{month}/{day} 운동 기록'**
  String workoutRecordForDate(int month, int day);

  /// 선택된 날짜에 운동 기록 없음
  ///
  /// In ko, this message translates to:
  /// **'이 날에는 운동 기록이 없습니다'**
  String get noWorkoutRecordForDate;

  /// 달력 화면 배너 텍스트
  ///
  /// In ko, this message translates to:
  /// **'꾸준함이 차드의 힘! 📅'**
  String get calendarBannerText;

  /// 운동 기록 로딩 실패 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 기록을 불러오는 중 오류가 발생했습니다: {error}'**
  String workoutHistoryLoadError(String error);

  /// Completed status
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get completed;

  /// 현재 횟수 표시 텍스트
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get current;

  /// 목표 횟수의 절반 빠른 입력 버튼
  ///
  /// In ko, this message translates to:
  /// **'절반'**
  String get half;

  /// 목표 횟수 초과 빠른 입력 버튼
  ///
  /// In ko, this message translates to:
  /// **'초과'**
  String get exceed;

  /// 목표 횟수 라벨
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get target;

  /// YouTube 영상 로딩 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드 영상 로딩 중... 🔥'**
  String get loadingChadVideos;

  /// 영상 로딩 실패 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'영상 로딩 오류: {error}'**
  String videoLoadError(String error);

  /// 다시 시도 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get tryAgain;

  /// 좋아요 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'좋아요'**
  String get like;

  /// 공유 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// 저장 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// 운동 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get workout;

  /// 좋아요 액션 메시지
  ///
  /// In ko, this message translates to:
  /// **'좋아요! 💪'**
  String get likeMessage;

  /// 공유 액션 메시지
  ///
  /// In ko, this message translates to:
  /// **'공유 중 📤'**
  String get shareMessage;

  /// 저장 액션 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장됨 📌'**
  String get saveMessage;

  /// 운동 시작 액션 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 시작! 🔥'**
  String get workoutStartMessage;

  /// 스와이프 힌트 텍스트
  ///
  /// In ko, this message translates to:
  /// **'위로 스와이프하여 다음 영상'**
  String get swipeUpHint;

  /// 팔굽혀펴기 해시태그
  ///
  /// In ko, this message translates to:
  /// **'#팔굽혀펴기'**
  String get pushupHashtag;

  /// 차드 해시태그
  ///
  /// In ko, this message translates to:
  /// **'#차드'**
  String get chadHashtag;

  /// Perfect pushup form title
  ///
  /// In ko, this message translates to:
  /// **'완벽한 푸시업 자세'**
  String get perfectPushupForm;

  /// 영상 제목 2
  ///
  /// In ko, this message translates to:
  /// **'팔굽혀펴기 변형 동작 🔥'**
  String get pushupVariations;

  /// 영상 제목 3
  ///
  /// In ko, this message translates to:
  /// **'차드의 비밀 ⚡'**
  String get chadSecrets;

  /// 영상 제목 4
  ///
  /// In ko, this message translates to:
  /// **'팔굽혀펴기 100개 도전 🎯'**
  String get pushup100Challenge;

  /// 영상 제목 5
  ///
  /// In ko, this message translates to:
  /// **'홈트 팔굽혀펴기 🏠'**
  String get homeWorkoutPushups;

  /// 영상 제목 6
  ///
  /// In ko, this message translates to:
  /// **'근력의 비밀 💯'**
  String get strengthSecrets;

  /// 영상 설명 1
  ///
  /// In ko, this message translates to:
  /// **'올바른 팔굽혀펴기 자세로 효과적인 운동'**
  String get correctPushupFormDesc;

  /// 영상 설명 2
  ///
  /// In ko, this message translates to:
  /// **'다양한 팔굽혀펴기 변형으로 근육 자극'**
  String get variousPushupStimulation;

  /// 영상 설명 3
  ///
  /// In ko, this message translates to:
  /// **'진정한 차드가 되는 마인드셋'**
  String get trueChadMindset;

  /// 영상 설명 4
  ///
  /// In ko, this message translates to:
  /// **'팔굽혀펴기 100개를 향한 도전 정신'**
  String get challengeSpirit100;

  /// 영상 설명 5
  ///
  /// In ko, this message translates to:
  /// **'집에서 할 수 있는 완벽한 운동'**
  String get perfectHomeWorkout;

  /// 영상 설명 6
  ///
  /// In ko, this message translates to:
  /// **'꾸준한 운동으로 근력 향상'**
  String get consistentStrengthImprovement;

  /// Cancel button text
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// 삭제 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// 확인 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// 한국어 언어 옵션
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get korean;

  /// 영어 언어 옵션
  ///
  /// In ko, this message translates to:
  /// **'영어'**
  String get english;

  /// 가슴 근육군
  ///
  /// In ko, this message translates to:
  /// **'가슴'**
  String get chest;

  /// 삼두 근육군
  ///
  /// In ko, this message translates to:
  /// **'삼두'**
  String get triceps;

  /// 어깨 근육군
  ///
  /// In ko, this message translates to:
  /// **'어깨'**
  String get shoulders;

  /// 코어 근육군
  ///
  /// In ko, this message translates to:
  /// **'코어'**
  String get core;

  /// 전신 근육군
  ///
  /// In ko, this message translates to:
  /// **'전신'**
  String get fullBody;

  /// 휴식 시간 설정
  ///
  /// In ko, this message translates to:
  /// **'휴식 시간 설정'**
  String get restTimeSettings;

  /// 휴식 시간 설명
  ///
  /// In ko, this message translates to:
  /// **'세트 간 휴식 시간 설정'**
  String get restTimeDesc;

  /// 사운드 설정
  ///
  /// In ko, this message translates to:
  /// **'사운드 설정'**
  String get soundSettings;

  /// 사운드 설정 설명
  ///
  /// In ko, this message translates to:
  /// **'운동 효과음 활성화'**
  String get soundSettingsDesc;

  /// 진동 설정
  ///
  /// In ko, this message translates to:
  /// **'진동 설정'**
  String get vibrationSettings;

  /// 진동 설정 설명
  ///
  /// In ko, this message translates to:
  /// **'진동 피드백 활성화'**
  String get vibrationSettingsDesc;

  /// 데이터 관리
  ///
  /// In ko, this message translates to:
  /// **'데이터 관리'**
  String get dataManagement;

  /// 데이터 관리 설명
  ///
  /// In ko, this message translates to:
  /// **'운동 기록 백업 및 복원'**
  String get dataManagementDesc;

  /// 앱 정보
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// 앱 정보 설명
  ///
  /// In ko, this message translates to:
  /// **'버전 정보 및 개발자 정보'**
  String get appInfoDesc;

  /// 초 단위
  ///
  /// In ko, this message translates to:
  /// **'초'**
  String get seconds;

  /// 분 단위
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get minutes;

  /// 동기부여 메시지 설정
  ///
  /// In ko, this message translates to:
  /// **'동기부여 메시지'**
  String get motivationMessages;

  /// 동기부여 메시지 설명
  ///
  /// In ko, this message translates to:
  /// **'운동 중 동기부여 메시지 표시'**
  String get motivationMessagesDesc;

  /// 다음 세트 자동 시작 설정
  ///
  /// In ko, this message translates to:
  /// **'다음 세트 자동 시작'**
  String get autoStartNextSet;

  /// 다음 세트 자동 시작 설명
  ///
  /// In ko, this message translates to:
  /// **'휴식 후 자동으로 다음 세트 시작'**
  String get autoStartNextSetDesc;

  /// Privacy policy title
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// Privacy policy description
  ///
  /// In ko, this message translates to:
  /// **'개인정보 보호 및 처리 방침을 확인'**
  String get privacyPolicyDesc;

  /// Terms of service menu title
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// Terms of service description
  ///
  /// In ko, this message translates to:
  /// **'앱 사용시 약관 확인'**
  String get termsOfServiceDesc;

  /// 오픈소스 라이선스
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get openSourceLicenses;

  /// 오픈소스 라이선스 설명
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스 보기'**
  String get openSourceLicensesDesc;

  /// 초기화 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터 초기화'**
  String get resetConfirmTitle;

  /// 초기화 확인 다이얼로그 메시지
  ///
  /// In ko, this message translates to:
  /// **'정말로 모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'**
  String get resetConfirmMessage;

  /// 데이터 초기화 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'정말로 모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'**
  String get dataResetConfirm;

  /// 데이터 초기화 준비 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터 초기화 기능은 곧 제공될 예정입니다.'**
  String get dataResetComingSoon;

  /// 초기화 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터가 성공적으로 초기화되었습니다'**
  String get resetSuccess;

  /// 백업 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업이 성공적으로 완료되었습니다'**
  String get backupSuccess;

  /// 복원 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터 복원이 성공적으로 완료되었습니다'**
  String get restoreSuccess;

  /// 시간 선택기 제목
  ///
  /// In ko, this message translates to:
  /// **'시간 선택'**
  String get selectTime;

  /// 현재 난이도 표시
  ///
  /// In ko, this message translates to:
  /// **'현재: {difficulty} - {description}'**
  String currentDifficulty(String difficulty, String description);

  /// 현재 언어 표시
  ///
  /// In ko, this message translates to:
  /// **'현재: {language}'**
  String currentLanguage(String language);

  /// 다크 모드 활성화 메시지
  ///
  /// In ko, this message translates to:
  /// **'다크 모드가 활성화되었습니다'**
  String get darkModeEnabled;

  /// 라이트 모드 활성화 메시지
  ///
  /// In ko, this message translates to:
  /// **'라이트 모드가 활성화되었습니다'**
  String get lightModeEnabled;

  /// 언어 변경 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'언어가 {language}로 변경되었습니다!'**
  String languageChanged(String language);

  /// 난이도 변경 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'난이도가 {difficulty}로 변경되었습니다!'**
  String difficultyChanged(String difficulty);

  /// 데이터 백업 준비 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업 기능이 곧 추가됩니다!'**
  String get dataBackupComingSoon;

  /// 데이터 복원 준비 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터 복원 기능이 곧 추가됩니다!'**
  String get dataRestoreComingSoon;

  /// 피드백 준비 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'피드백 기능이 곧 추가됩니다!'**
  String get feedbackComingSoon;

  /// 리마인더 시간 변경 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'리마인더 시간이 {time}으로 변경되었습니다!'**
  String reminderTimeChanged(String time);

  /// 알림 권한 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'🔔 알림 권한 필요'**
  String get notificationPermissionRequired;

  /// 알림 권한 다이얼로그 메시지
  ///
  /// In ko, this message translates to:
  /// **'푸시 알림을 받으려면 알림 권한이 필요합니다.'**
  String get notificationPermissionMessage;

  /// 알림 권한 기능 목록
  ///
  /// In ko, this message translates to:
  /// **'• 운동 리마인더\n• 업적 달성 알림\n• 동기부여 메시지'**
  String get notificationPermissionFeatures;

  /// 알림 권한 요청 메시지
  ///
  /// In ko, this message translates to:
  /// **'설정에서 알림 권한을 허용해주세요.'**
  String get notificationPermissionRequest;

  /// 설정으로 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get goToSettings;

  /// 준비 중 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'🚀 Coming Soon'**
  String get comingSoon;

  /// 난이도 설정 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'💪 난이도 설정'**
  String get difficultySettingsTitle;

  /// Notification permission granted message
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 허용되었습니다! 🎉'**
  String get notificationPermissionGranted;

  /// 설정 배너 광고 텍스트
  ///
  /// In ko, this message translates to:
  /// **'차드의 설정을 맞춤화하세요! ⚙️'**
  String get settingsBannerText;

  /// 빌드 정보
  ///
  /// In ko, this message translates to:
  /// **'빌드: {buildNumber}'**
  String buildInfo(String buildNumber);

  /// 버전 및 빌드 정보
  ///
  /// In ko, this message translates to:
  /// **'버전 {version}+{buildNumber}'**
  String versionAndBuild(String version, String buildNumber);

  /// 사랑으로 제작 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드를 위해 ❤️로 제작'**
  String get madeWithLove;

  /// 차드 여정 참여 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드가 되는 여정에 동참하세요'**
  String get joinChadJourney;

  /// 차드 여정 응원 메시지
  ///
  /// In ko, this message translates to:
  /// **'당신의 차드 여정을 응원합니다! 🔥'**
  String get supportChadJourney;

  /// 언어 선택 메시지
  ///
  /// In ko, this message translates to:
  /// **'사용할 언어를 선택해주세요'**
  String get selectLanguage;

  /// 진행도 라벨
  ///
  /// In ko, this message translates to:
  /// **'진행도'**
  String get progress;

  /// 설명 라벨
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get description;

  /// 업적 진행도 퍼센트
  ///
  /// In ko, this message translates to:
  /// **'{percentage}% 완료'**
  String percentComplete(int percentage);

  /// 한국어 언어명
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get koreanLanguage;

  /// 영어 언어명
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// 알림 권한 허용 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'🎉 알림 권한이 허용되었습니다! 차드 여정을 시작하세요!'**
  String get notificationPermissionGrantedMessage;

  /// 알림 권한 거부 메시지
  ///
  /// In ko, this message translates to:
  /// **'⚠️ 알림 권한이 필요합니다. 설정에서 허용해주세요.'**
  String get notificationPermissionDeniedMessage;

  /// 알림 권한 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'권한 요청 중 오류가 발생했습니다.'**
  String get notificationPermissionErrorMessage;

  /// 알림 권한 나중에 설정 메시지
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정에서 알림을 허용할 수 있습니다.'**
  String get notificationPermissionLaterMessage;

  /// 권한 요청 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'🔐 권한이 필요해요'**
  String get permissionsRequired;

  /// 권한 요청 설명
  ///
  /// In ko, this message translates to:
  /// **'Mission 100에서 최고의 경험을 위해\n다음 권한들이 필요합니다:'**
  String get permissionsDescription;

  /// 알림 권한 제목
  ///
  /// In ko, this message translates to:
  /// **'🔔 알림 권한'**
  String get notificationPermissionTitle;

  /// 알림 권한 설명
  ///
  /// In ko, this message translates to:
  /// **'운동 리마인더와 업적 알림을 받기 위해 필요합니다'**
  String get notificationPermissionDesc;

  /// 저장소 권한 제목
  ///
  /// In ko, this message translates to:
  /// **'📁 저장소 권한'**
  String get storagePermissionTitle;

  /// 저장소 권한 설명
  ///
  /// In ko, this message translates to:
  /// **'운동 데이터 백업 및 복원을 위해 필요합니다'**
  String get storagePermissionDesc;

  /// 권한 허용 버튼
  ///
  /// In ko, this message translates to:
  /// **'권한 허용하기'**
  String get allowPermissions;

  /// 권한 건너뛰기 버튼
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정하기'**
  String get skipPermissions;

  /// 권한 혜택 제목
  ///
  /// In ko, this message translates to:
  /// **'이 권한들을 허용하면:'**
  String get permissionBenefits;

  /// 알림 혜택 1
  ///
  /// In ko, this message translates to:
  /// **'💪 매일 운동 리마인더'**
  String get notificationBenefit1;

  /// 알림 혜택 2
  ///
  /// In ko, this message translates to:
  /// **'🏆 업적 달성 축하 알림'**
  String get notificationBenefit2;

  /// 알림 혜택 3
  ///
  /// In ko, this message translates to:
  /// **'🔥 동기부여 메시지'**
  String get notificationBenefit3;

  /// 저장소 혜택 1
  ///
  /// In ko, this message translates to:
  /// **'📁 운동 데이터 안전 백업'**
  String get storageBenefit1;

  /// 저장소 혜택 2
  ///
  /// In ko, this message translates to:
  /// **'🔄 기기 변경 시 데이터 복원'**
  String get storageBenefit2;

  /// 저장소 혜택 3
  ///
  /// In ko, this message translates to:
  /// **'💾 데이터 손실 방지'**
  String get storageBenefit3;

  /// 이미 권한 요청한 경우 메시지
  ///
  /// In ko, this message translates to:
  /// **'이미 권한을 요청했습니다.\n설정에서 수동으로 허용해주세요.'**
  String get permissionAlreadyRequested;

  /// 영상 열기 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'영상을 열 수 없습니다. YouTube 앱을 확인해주세요.'**
  String get videoCannotOpen;

  /// 광고 라벨
  ///
  /// In ko, this message translates to:
  /// **'광고'**
  String get advertisement;

  /// 차드 레벨 라벨
  ///
  /// In ko, this message translates to:
  /// **'차드 레벨'**
  String get chadLevel;

  /// 진행률 시각화 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'진행률 시각화'**
  String get progressVisualization;

  /// 주간 목표 라벨
  ///
  /// In ko, this message translates to:
  /// **'주간 목표'**
  String get weeklyGoal;

  /// 월간 목표 라벨
  ///
  /// In ko, this message translates to:
  /// **'월간 목표'**
  String get monthlyGoal;

  /// 연속 운동 진행률 라벨
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 진행률'**
  String get streakProgress;

  /// 운동 차트 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 차트'**
  String get workoutChart;

  /// 일 단위
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get days;

  /// 월간 진행률 제목
  ///
  /// In ko, this message translates to:
  /// **'월간 진행률'**
  String get monthlyProgress;

  /// 이번 달 라벨
  ///
  /// In ko, this message translates to:
  /// **'이번 달'**
  String get thisMonth;

  /// 운동 기록이 없는 날 메시지
  ///
  /// In ko, this message translates to:
  /// **'이 날에는 운동 기록이 없습니다'**
  String get noWorkoutThisDay;

  /// 범례 제목
  ///
  /// In ko, this message translates to:
  /// **'범례'**
  String get legend;

  /// 완벽한 운동 완료
  ///
  /// In ko, this message translates to:
  /// **'완벽'**
  String get perfect;

  /// 좋은 운동 완료
  ///
  /// In ko, this message translates to:
  /// **'좋음'**
  String get good;

  /// 보통 운동 완료
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get okay;

  /// 부족한 운동 완료
  ///
  /// In ko, this message translates to:
  /// **'부족'**
  String get poor;

  /// 주간 필터 옵션
  ///
  /// In ko, this message translates to:
  /// **'주간'**
  String get weekly;

  /// 월간 필터 옵션
  ///
  /// In ko, this message translates to:
  /// **'월간'**
  String get monthly;

  /// 연간 필터 옵션
  ///
  /// In ko, this message translates to:
  /// **'연간'**
  String get yearly;

  /// 운동 횟수 단위
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get times;

  /// 개수 단위
  ///
  /// In ko, this message translates to:
  /// **'개'**
  String get count;

  /// 운동 기록이 없을 때 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 기록이 없습니다'**
  String get noWorkoutHistory;

  /// 차트 데이터가 없을 때 메시지
  ///
  /// In ko, this message translates to:
  /// **'차트 데이터가 없습니다'**
  String get noChartData;

  /// 파이 차트 데이터가 없을 때 메시지
  ///
  /// In ko, this message translates to:
  /// **'파이 차트 데이터가 없습니다'**
  String get noPieChartData;

  /// 날짜 표시용 월 단위
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get month;

  /// 일일 운동 알림 설정
  ///
  /// In ko, this message translates to:
  /// **'일일 운동 알림'**
  String get dailyWorkoutReminder;

  /// 연속 운동 격려 설정
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 격려'**
  String get streakEncouragement;

  /// 연속 운동 격려 설정 부제목
  ///
  /// In ko, this message translates to:
  /// **'3일 연속 운동 시 격려 메시지'**
  String get streakEncouragementSubtitle;

  /// 알림 설정 실패 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'알림 설정에 실패했습니다'**
  String get notificationSetupFailed;

  /// 연속 운동 알림 설정 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 격려 알림이 설정되었습니다!'**
  String get streakNotificationSet;

  /// 일일 알림 설정 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'매일 {time}에 운동 알림이 설정되었습니다!'**
  String dailyNotificationSet(Object time);

  /// 일일 알림 설정 부제목
  ///
  /// In ko, this message translates to:
  /// **'매일 정해진 시간에 운동 알림'**
  String get dailyReminderSubtitle;

  /// 광고가 없을 때 표시되는 대체 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드가 되는 여정을 함께하세요! 💪'**
  String get adFallbackMessage;

  /// 테스트 광고 메시지
  ///
  /// In ko, this message translates to:
  /// **'테스트 광고 - 피트니스 앱'**
  String get testAdMessage;

  /// 업적 달성 축하 다이얼로그 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드의 힘을 느꼈다! 💪'**
  String get achievementCelebrationMessage;

  /// 운동 화면 광고 대체 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드의 힘을 느껴라! 💪'**
  String get workoutScreenAdMessage;

  /// 업적 화면 광고 대체 메시지
  ///
  /// In ko, this message translates to:
  /// **'업적을 달성해서 차드가 되자! 🏆'**
  String get achievementScreenAdMessage;

  /// 기본 푸시업 튜토리얼 조언
  ///
  /// In ko, this message translates to:
  /// **'기본이 제일 중요하다, 만삣삐!'**
  String get tutorialAdviceBasic;

  /// 시작 튜토리얼 조언
  ///
  /// In ko, this message translates to:
  /// **'시작이 반이다!'**
  String get tutorialAdviceStart;

  /// 자세 튜토리얼 조언
  ///
  /// In ko, this message translates to:
  /// **'완벽한 자세가 완벽한 차드를 만든다!'**
  String get tutorialAdviceForm;

  /// 꾸준함 튜토리얼 조언
  ///
  /// In ko, this message translates to:
  /// **'꾸준함이 차드 파워의 열쇠다!'**
  String get tutorialAdviceConsistency;

  /// 쉬움 난이도
  ///
  /// In ko, this message translates to:
  /// **'쉬움'**
  String get difficultyEasy;

  /// 보통 난이도
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get difficultyMedium;

  /// 어려움 난이도
  ///
  /// In ko, this message translates to:
  /// **'어려움'**
  String get difficultyHard;

  /// 전문가 난이도
  ///
  /// In ko, this message translates to:
  /// **'전문가'**
  String get difficultyExpert;

  /// 년월일 한국어 날짜 형식
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일'**
  String dateFormatYearMonthDay(int year, int month, int day);

  /// Common rarity level
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get rarityCommon;

  /// Rare rarity level
  ///
  /// In ko, this message translates to:
  /// **'레어'**
  String get rarityRare;

  /// Epic rarity level
  ///
  /// In ko, this message translates to:
  /// **'에픽'**
  String get rarityEpic;

  /// Legendary rarity level
  ///
  /// In ko, this message translates to:
  /// **'레전더리'**
  String get rarityLegendary;

  /// No description provided for @achievementUltimateMotivation.
  ///
  /// In ko, this message translates to:
  /// **'당신은 궁극의 차드입니다! 🌟'**
  String get achievementUltimateMotivation;

  /// No description provided for @achievementFirst50Title.
  ///
  /// In ko, this message translates to:
  /// **'첫 50개 돌파'**
  String get achievementFirst50Title;

  /// No description provided for @achievementFirst50Desc.
  ///
  /// In ko, this message translates to:
  /// **'한 번의 운동에서 50개를 달성했습니다'**
  String get achievementFirst50Desc;

  /// No description provided for @achievementFirst50Motivation.
  ///
  /// In ko, this message translates to:
  /// **'50개 돌파! 차드의 기반이 단단해지고 있습니다! 🎊'**
  String get achievementFirst50Motivation;

  /// No description provided for @achievementFirst100SingleTitle.
  ///
  /// In ko, this message translates to:
  /// **'한 번에 100개'**
  String get achievementFirst100SingleTitle;

  /// No description provided for @achievementFirst100SingleDesc.
  ///
  /// In ko, this message translates to:
  /// **'한 번의 운동에서 100개를 달성했습니다'**
  String get achievementFirst100SingleDesc;

  /// No description provided for @achievementFirst100SingleMotivation.
  ///
  /// In ko, this message translates to:
  /// **'한 번에 100개! 진정한 파워 차드! 💥'**
  String get achievementFirst100SingleMotivation;

  /// No description provided for @achievementStreak3Title.
  ///
  /// In ko, this message translates to:
  /// **'3일 연속 차드'**
  String get achievementStreak3Title;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In ko, this message translates to:
  /// **'3일 연속 운동을 완료했습니다'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak3Motivation.
  ///
  /// In ko, this message translates to:
  /// **'꾸준함이 차드를 만듭니다! 🔥'**
  String get achievementStreak3Motivation;

  /// No description provided for @achievementStreak7Title.
  ///
  /// In ko, this message translates to:
  /// **'주간 차드'**
  String get achievementStreak7Title;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In ko, this message translates to:
  /// **'7일 연속 운동을 완료했습니다'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak7Motivation.
  ///
  /// In ko, this message translates to:
  /// **'일주일을 정복한 진정한 차드! 💪'**
  String get achievementStreak7Motivation;

  /// No description provided for @achievementStreak14Title.
  ///
  /// In ko, this message translates to:
  /// **'2주 마라톤 차드'**
  String get achievementStreak14Title;

  /// No description provided for @achievementStreak14Desc.
  ///
  /// In ko, this message translates to:
  /// **'14일 연속 운동을 완료했습니다'**
  String get achievementStreak14Desc;

  /// No description provided for @achievementStreak14Motivation.
  ///
  /// In ko, this message translates to:
  /// **'끈기의 왕! 차드 중의 차드! 🏃‍♂️'**
  String get achievementStreak14Motivation;

  /// No description provided for @achievementStreak30Title.
  ///
  /// In ko, this message translates to:
  /// **'월간 궁극 차드'**
  String get achievementStreak30Title;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In ko, this message translates to:
  /// **'30일 연속 운동을 완료했습니다'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementStreak30Motivation.
  ///
  /// In ko, this message translates to:
  /// **'이제 당신은 차드의 왕입니다! 👑'**
  String get achievementStreak30Motivation;

  /// No description provided for @achievementStreak60Title.
  ///
  /// In ko, this message translates to:
  /// **'2개월 레전드 차드'**
  String get achievementStreak60Title;

  /// No description provided for @achievementStreak60Desc.
  ///
  /// In ko, this message translates to:
  /// **'60일 연속 운동을 완료했습니다'**
  String get achievementStreak60Desc;

  /// No description provided for @achievementStreak60Motivation.
  ///
  /// In ko, this message translates to:
  /// **'2개월 연속! 당신은 레전드입니다! 🏅'**
  String get achievementStreak60Motivation;

  /// No description provided for @achievementStreak100Title.
  ///
  /// In ko, this message translates to:
  /// **'100일 신화 차드'**
  String get achievementStreak100Title;

  /// No description provided for @achievementStreak100Desc.
  ///
  /// In ko, this message translates to:
  /// **'100일 연속 운동을 완료했습니다'**
  String get achievementStreak100Desc;

  /// No description provided for @achievementStreak100Motivation.
  ///
  /// In ko, this message translates to:
  /// **'100일 연속! 당신은 살아있는 신화입니다! 🌟'**
  String get achievementStreak100Motivation;

  /// No description provided for @achievementTotal50Title.
  ///
  /// In ko, this message translates to:
  /// **'첫 50개 총합'**
  String get achievementTotal50Title;

  /// No description provided for @achievementTotal50Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 50개의 푸시업을 완료했습니다'**
  String get achievementTotal50Desc;

  /// No description provided for @achievementTotal50Motivation.
  ///
  /// In ko, this message translates to:
  /// **'첫 50개! 차드의 새싹이 자라고 있습니다! 🌱'**
  String get achievementTotal50Motivation;

  /// No description provided for @achievementTotal100Title.
  ///
  /// In ko, this message translates to:
  /// **'첫 100개 돌파'**
  String get achievementTotal100Title;

  /// No description provided for @achievementTotal100Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 100개의 푸시업을 완료했습니다'**
  String get achievementTotal100Desc;

  /// No description provided for @achievementTotal100Motivation.
  ///
  /// In ko, this message translates to:
  /// **'첫 100개 돌파! 차드의 기반 완성! 💯'**
  String get achievementTotal100Motivation;

  /// No description provided for @achievementTotal250Title.
  ///
  /// In ko, this message translates to:
  /// **'250 차드'**
  String get achievementTotal250Title;

  /// No description provided for @achievementTotal250Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 250개의 푸시업을 완료했습니다'**
  String get achievementTotal250Desc;

  /// No description provided for @achievementTotal250Motivation.
  ///
  /// In ko, this message translates to:
  /// **'250개! 꾸준함의 결과! 🎯'**
  String get achievementTotal250Motivation;

  /// No description provided for @achievementTotal500Title.
  ///
  /// In ko, this message translates to:
  /// **'500 차드'**
  String get achievementTotal500Title;

  /// No description provided for @achievementTotal500Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 500개의 푸시업을 완료했습니다'**
  String get achievementTotal500Desc;

  /// No description provided for @achievementTotal500Motivation.
  ///
  /// In ko, this message translates to:
  /// **'500개 돌파! 중급 차드 달성! 🚀'**
  String get achievementTotal500Motivation;

  /// No description provided for @achievementTotal1000Title.
  ///
  /// In ko, this message translates to:
  /// **'1000 메가 차드'**
  String get achievementTotal1000Title;

  /// No description provided for @achievementTotal1000Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 1000개의 푸시업을 완료했습니다'**
  String get achievementTotal1000Desc;

  /// No description provided for @achievementTotal1000Motivation.
  ///
  /// In ko, this message translates to:
  /// **'1000개 돌파! 메가 차드 달성! ⚡'**
  String get achievementTotal1000Motivation;

  /// No description provided for @achievementTotal2500Title.
  ///
  /// In ko, this message translates to:
  /// **'2500 슈퍼 차드'**
  String get achievementTotal2500Title;

  /// No description provided for @achievementTotal2500Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 2500개의 푸시업을 완료했습니다'**
  String get achievementTotal2500Desc;

  /// No description provided for @achievementTotal2500Motivation.
  ///
  /// In ko, this message translates to:
  /// **'2500개! 슈퍼 차드의 경지에 도달! 🔥'**
  String get achievementTotal2500Motivation;

  /// No description provided for @achievementTotal5000Title.
  ///
  /// In ko, this message translates to:
  /// **'5000 울트라 차드'**
  String get achievementTotal5000Title;

  /// No description provided for @achievementTotal5000Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 5000개의 푸시업을 완료했습니다'**
  String get achievementTotal5000Desc;

  /// No description provided for @achievementTotal5000Motivation.
  ///
  /// In ko, this message translates to:
  /// **'5000개! 당신은 울트라 차드입니다! 🌟'**
  String get achievementTotal5000Motivation;

  /// No description provided for @achievementTotal10000Title.
  ///
  /// In ko, this message translates to:
  /// **'10000 갓 차드'**
  String get achievementTotal10000Title;

  /// No description provided for @achievementTotal10000Desc.
  ///
  /// In ko, this message translates to:
  /// **'총 10000개의 푸시업을 완료했습니다'**
  String get achievementTotal10000Desc;

  /// No description provided for @achievementTotal10000Motivation.
  ///
  /// In ko, this message translates to:
  /// **'10000개! 당신은 차드의 신입니다! 👑'**
  String get achievementTotal10000Motivation;

  /// No description provided for @achievementPerfect3Title.
  ///
  /// In ko, this message translates to:
  /// **'완벽한 트리플'**
  String get achievementPerfect3Title;

  /// No description provided for @achievementPerfect3Desc.
  ///
  /// In ko, this message translates to:
  /// **'3번의 완벽한 운동을 달성했습니다'**
  String get achievementPerfect3Desc;

  /// No description provided for @achievementPerfect3Motivation.
  ///
  /// In ko, this message translates to:
  /// **'완벽한 트리플! 정확성의 차드! 🎯'**
  String get achievementPerfect3Motivation;

  /// No description provided for @achievementPerfect5Title.
  ///
  /// In ko, this message translates to:
  /// **'완벽주의 차드'**
  String get achievementPerfect5Title;

  /// No description provided for @achievementPerfect5Desc.
  ///
  /// In ko, this message translates to:
  /// **'5번의 완벽한 운동을 달성했습니다'**
  String get achievementPerfect5Desc;

  /// No description provided for @achievementPerfect5Motivation.
  ///
  /// In ko, this message translates to:
  /// **'완벽을 추구하는 진정한 차드! ⭐'**
  String get achievementPerfect5Motivation;

  /// No description provided for @achievementPerfect10Title.
  ///
  /// In ko, this message translates to:
  /// **'마스터 차드'**
  String get achievementPerfect10Title;

  /// No description provided for @achievementPerfect10Desc.
  ///
  /// In ko, this message translates to:
  /// **'10번의 완벽한 운동을 달성했습니다'**
  String get achievementPerfect10Desc;

  /// No description provided for @achievementPerfect10Motivation.
  ///
  /// In ko, this message translates to:
  /// **'완벽의 마스터! 차드 중의 차드! 🏆'**
  String get achievementPerfect10Motivation;

  /// No description provided for @achievementPerfect20Title.
  ///
  /// In ko, this message translates to:
  /// **'완벽 레전드'**
  String get achievementPerfect20Title;

  /// No description provided for @achievementPerfect20Desc.
  ///
  /// In ko, this message translates to:
  /// **'20번의 완벽한 운동을 달성했습니다'**
  String get achievementPerfect20Desc;

  /// No description provided for @achievementPerfect20Motivation.
  ///
  /// In ko, this message translates to:
  /// **'20번 완벽! 당신은 완벽의 화신입니다! 💎'**
  String get achievementPerfect20Motivation;

  /// No description provided for @achievementTutorialExplorerTitle.
  ///
  /// In ko, this message translates to:
  /// **'탐구하는 차드'**
  String get achievementTutorialExplorerTitle;

  /// No description provided for @achievementTutorialExplorerDesc.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 푸시업 튜토리얼을 확인했습니다'**
  String get achievementTutorialExplorerDesc;

  /// No description provided for @achievementTutorialExplorerMotivation.
  ///
  /// In ko, this message translates to:
  /// **'지식이 차드의 첫 번째 힘입니다! 🔍'**
  String get achievementTutorialExplorerMotivation;

  /// No description provided for @achievementTutorialStudentTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습하는 차드'**
  String get achievementTutorialStudentTitle;

  /// No description provided for @achievementTutorialStudentDesc.
  ///
  /// In ko, this message translates to:
  /// **'5개의 푸시업 튜토리얼을 확인했습니다'**
  String get achievementTutorialStudentDesc;

  /// No description provided for @achievementTutorialStudentMotivation.
  ///
  /// In ko, this message translates to:
  /// **'다양한 기술을 배우는 진정한 차드! 📚'**
  String get achievementTutorialStudentMotivation;

  /// No description provided for @achievementTutorialMasterTitle.
  ///
  /// In ko, this message translates to:
  /// **'푸시업 마스터'**
  String get achievementTutorialMasterTitle;

  /// No description provided for @achievementTutorialMasterDesc.
  ///
  /// In ko, this message translates to:
  /// **'모든 푸시업 튜토리얼을 확인했습니다'**
  String get achievementTutorialMasterDesc;

  /// No description provided for @achievementTutorialMasterMotivation.
  ///
  /// In ko, this message translates to:
  /// **'모든 기술을 마스터한 푸시업 박사! 🎓'**
  String get achievementTutorialMasterMotivation;

  /// No description provided for @achievementEarlyBirdTitle.
  ///
  /// In ko, this message translates to:
  /// **'새벽 차드'**
  String get achievementEarlyBirdTitle;

  /// No description provided for @achievementEarlyBirdMotivation.
  ///
  /// In ko, this message translates to:
  /// **'새벽을 정복한 얼리버드 차드! 🌅'**
  String get achievementEarlyBirdMotivation;

  /// No description provided for @achievementNightOwlTitle.
  ///
  /// In ko, this message translates to:
  /// **'야행성 차드'**
  String get achievementNightOwlTitle;

  /// No description provided for @achievementNightOwlMotivation.
  ///
  /// In ko, this message translates to:
  /// **'밤에도 포기하지 않는 올빼미 차드! 🦉'**
  String get achievementNightOwlMotivation;

  /// No description provided for @achievementWeekendWarriorTitle.
  ///
  /// In ko, this message translates to:
  /// **'주말 전사'**
  String get achievementWeekendWarriorTitle;

  /// No description provided for @achievementWeekendWarriorDesc.
  ///
  /// In ko, this message translates to:
  /// **'주말에 꾸준히 운동하는 차드'**
  String get achievementWeekendWarriorDesc;

  /// No description provided for @achievementWeekendWarriorMotivation.
  ///
  /// In ko, this message translates to:
  /// **'주말에도 멈추지 않는 전사! ⚔️'**
  String get achievementWeekendWarriorMotivation;

  /// No description provided for @achievementLunchBreakTitle.
  ///
  /// In ko, this message translates to:
  /// **'점심시간 차드'**
  String get achievementLunchBreakTitle;

  /// No description provided for @achievementLunchBreakDesc.
  ///
  /// In ko, this message translates to:
  /// **'점심시간(12-2시)에 5번 운동했습니다'**
  String get achievementLunchBreakDesc;

  /// No description provided for @achievementLunchBreakMotivation.
  ///
  /// In ko, this message translates to:
  /// **'점심시간도 놓치지 않는 효율적인 차드! 🍽️'**
  String get achievementLunchBreakMotivation;

  /// No description provided for @achievementSpeedDemonTitle.
  ///
  /// In ko, this message translates to:
  /// **'스피드 데몬'**
  String get achievementSpeedDemonTitle;

  /// No description provided for @achievementSpeedDemonMotivation.
  ///
  /// In ko, this message translates to:
  /// **'번개 같은 속도! 스피드의 차드! 💨'**
  String get achievementSpeedDemonMotivation;

  /// No description provided for @achievementEnduranceKingTitle.
  ///
  /// In ko, this message translates to:
  /// **'지구력의 왕'**
  String get achievementEnduranceKingTitle;

  /// No description provided for @achievementEnduranceKingDesc.
  ///
  /// In ko, this message translates to:
  /// **'30분 이상 운동을 지속했습니다'**
  String get achievementEnduranceKingDesc;

  /// No description provided for @achievementEnduranceKingMotivation.
  ///
  /// In ko, this message translates to:
  /// **'30분 지속! 지구력의 왕! ⏰'**
  String get achievementEnduranceKingMotivation;

  /// No description provided for @achievementComebackKidTitle.
  ///
  /// In ko, this message translates to:
  /// **'컴백 키드'**
  String get achievementComebackKidTitle;

  /// No description provided for @achievementComebackKidDesc.
  ///
  /// In ko, this message translates to:
  /// **'7일 이상 쉰 후 다시 운동을 시작했습니다'**
  String get achievementComebackKidDesc;

  /// No description provided for @achievementComebackKidMotivation.
  ///
  /// In ko, this message translates to:
  /// **'포기하지 않는 마음! 컴백의 차드! 🔄'**
  String get achievementComebackKidMotivation;

  /// No description provided for @achievementOverachieverTitle.
  ///
  /// In ko, this message translates to:
  /// **'목표 초과 달성자'**
  String get achievementOverachieverTitle;

  /// No description provided for @achievementOverachieverMotivation.
  ///
  /// In ko, this message translates to:
  /// **'목표를 뛰어넘는 오버어치버! 📈'**
  String get achievementOverachieverMotivation;

  /// No description provided for @achievementDoubleTroubleTitle.
  ///
  /// In ko, this message translates to:
  /// **'더블 트러블'**
  String get achievementDoubleTroubleTitle;

  /// No description provided for @achievementDoubleTroubleDesc.
  ///
  /// In ko, this message translates to:
  /// **'목표의 200%를 달성했습니다'**
  String get achievementDoubleTroubleDesc;

  /// No description provided for @achievementDoubleTroubleMotivation.
  ///
  /// In ko, this message translates to:
  /// **'목표의 2배! 더블 트러블 차드! 🎪'**
  String get achievementDoubleTroubleMotivation;

  /// No description provided for @achievementConsistencyMasterTitle.
  ///
  /// In ko, this message translates to:
  /// **'일관성의 마스터'**
  String get achievementConsistencyMasterTitle;

  /// No description provided for @achievementConsistencyMasterDesc.
  ///
  /// In ko, this message translates to:
  /// **'10일 연속 목표를 정확히 달성했습니다'**
  String get achievementConsistencyMasterDesc;

  /// No description provided for @achievementConsistencyMasterMotivation.
  ///
  /// In ko, this message translates to:
  /// **'정확한 목표 달성! 일관성의 마스터! 🎯'**
  String get achievementConsistencyMasterMotivation;

  /// No description provided for @achievementLevel5Title.
  ///
  /// In ko, this message translates to:
  /// **'레벨 5 차드'**
  String get achievementLevel5Title;

  /// No description provided for @achievementLevel5Desc.
  ///
  /// In ko, this message translates to:
  /// **'레벨 5에 도달했습니다'**
  String get achievementLevel5Desc;

  /// No description provided for @achievementLevel5Motivation.
  ///
  /// In ko, this message translates to:
  /// **'레벨 5 달성! 중급 차드의 시작! 🌟'**
  String get achievementLevel5Motivation;

  /// No description provided for @achievementLevel10Title.
  ///
  /// In ko, this message translates to:
  /// **'레벨 10 차드'**
  String get achievementLevel10Title;

  /// No description provided for @achievementLevel10Desc.
  ///
  /// In ko, this message translates to:
  /// **'레벨 10에 도달했습니다'**
  String get achievementLevel10Desc;

  /// No description provided for @achievementLevel10Motivation.
  ///
  /// In ko, this message translates to:
  /// **'레벨 10! 고급 차드의 경지! 🏅'**
  String get achievementLevel10Motivation;

  /// No description provided for @achievementLevel20Title.
  ///
  /// In ko, this message translates to:
  /// **'레벨 20 차드'**
  String get achievementLevel20Title;

  /// No description provided for @achievementLevel20Desc.
  ///
  /// In ko, this message translates to:
  /// **'레벨 20에 도달했습니다'**
  String get achievementLevel20Desc;

  /// No description provided for @achievementLevel20Motivation.
  ///
  /// In ko, this message translates to:
  /// **'레벨 20! 차드 중의 왕! 👑'**
  String get achievementLevel20Motivation;

  /// No description provided for @achievementMonthlyWarriorTitle.
  ///
  /// In ko, this message translates to:
  /// **'월간 전사'**
  String get achievementMonthlyWarriorTitle;

  /// No description provided for @achievementMonthlyWarriorDesc.
  ///
  /// In ko, this message translates to:
  /// **'한 달에 20일 이상 운동했습니다'**
  String get achievementMonthlyWarriorDesc;

  /// No description provided for @achievementMonthlyWarriorMotivation.
  ///
  /// In ko, this message translates to:
  /// **'한 달 20일! 월간 전사 차드! 📅'**
  String get achievementMonthlyWarriorMotivation;

  /// No description provided for @achievementSeasonalChampionTitle.
  ///
  /// In ko, this message translates to:
  /// **'시즌 챔피언'**
  String get achievementSeasonalChampionTitle;

  /// No description provided for @achievementSeasonalChampionDesc.
  ///
  /// In ko, this message translates to:
  /// **'3개월 연속 월간 목표를 달성했습니다'**
  String get achievementSeasonalChampionDesc;

  /// No description provided for @achievementSeasonalChampionMotivation.
  ///
  /// In ko, this message translates to:
  /// **'3개월 연속! 시즌 챔피언! 🏆'**
  String get achievementSeasonalChampionMotivation;

  /// No description provided for @achievementVarietySeekerTitle.
  ///
  /// In ko, this message translates to:
  /// **'다양성 추구자'**
  String get achievementVarietySeekerTitle;

  /// No description provided for @achievementVarietySeekerDesc.
  ///
  /// In ko, this message translates to:
  /// **'5가지 다른 푸시업 타입을 시도했습니다'**
  String get achievementVarietySeekerDesc;

  /// No description provided for @achievementVarietySeekerMotivation.
  ///
  /// In ko, this message translates to:
  /// **'다양함을 추구하는 창의적 차드! 🎨'**
  String get achievementVarietySeekerMotivation;

  /// No description provided for @achievementAllRounderTitle.
  ///
  /// In ko, this message translates to:
  /// **'올라운더'**
  String get achievementAllRounderTitle;

  /// No description provided for @achievementAllRounderDesc.
  ///
  /// In ko, this message translates to:
  /// **'모든 푸시업 타입을 시도했습니다'**
  String get achievementAllRounderDesc;

  /// No description provided for @achievementAllRounderMotivation.
  ///
  /// In ko, this message translates to:
  /// **'모든 타입 마스터! 올라운더 차드! 🌈'**
  String get achievementAllRounderMotivation;

  /// No description provided for @achievementIronWillTitle.
  ///
  /// In ko, this message translates to:
  /// **'강철 의지'**
  String get achievementIronWillTitle;

  /// No description provided for @achievementIronWillMotivation.
  ///
  /// In ko, this message translates to:
  /// **'200개 한 번에! 강철 같은 의지! 🔩'**
  String get achievementIronWillMotivation;

  /// No description provided for @achievementUnstoppableForceTitle.
  ///
  /// In ko, this message translates to:
  /// **'멈출 수 없는 힘'**
  String get achievementUnstoppableForceTitle;

  /// No description provided for @achievementUnstoppableForceDesc.
  ///
  /// In ko, this message translates to:
  /// **'한 번에 300개를 달성했습니다'**
  String get achievementUnstoppableForceDesc;

  /// No description provided for @achievementUnstoppableForceMotivation.
  ///
  /// In ko, this message translates to:
  /// **'300개! 당신은 멈출 수 없는 힘입니다! 🌪️'**
  String get achievementUnstoppableForceMotivation;

  /// No description provided for @achievementLegendaryBeastTitle.
  ///
  /// In ko, this message translates to:
  /// **'레전더리 비스트'**
  String get achievementLegendaryBeastTitle;

  /// No description provided for @achievementLegendaryBeastDesc.
  ///
  /// In ko, this message translates to:
  /// **'한 번에 500개를 달성했습니다'**
  String get achievementLegendaryBeastDesc;

  /// No description provided for @achievementLegendaryBeastMotivation.
  ///
  /// In ko, this message translates to:
  /// **'500개! 당신은 레전더리 비스트입니다! 🐉'**
  String get achievementLegendaryBeastMotivation;

  /// No description provided for @achievementMotivatorTitle.
  ///
  /// In ko, this message translates to:
  /// **'동기부여자'**
  String get achievementMotivatorTitle;

  /// No description provided for @achievementMotivatorDesc.
  ///
  /// In ko, this message translates to:
  /// **'앱을 30일 이상 사용했습니다'**
  String get achievementMotivatorDesc;

  /// No description provided for @achievementMotivatorMotivation.
  ///
  /// In ko, this message translates to:
  /// **'30일 사용! 진정한 동기부여자! 💡'**
  String get achievementMotivatorMotivation;

  /// No description provided for @achievementDedicationMasterTitle.
  ///
  /// In ko, this message translates to:
  /// **'헌신의 마스터'**
  String get achievementDedicationMasterTitle;

  /// No description provided for @achievementDedicationMasterDesc.
  ///
  /// In ko, this message translates to:
  /// **'앱을 100일 이상 사용했습니다'**
  String get achievementDedicationMasterDesc;

  /// No description provided for @achievementDedicationMasterMotivation.
  ///
  /// In ko, this message translates to:
  /// **'100일 헌신! 당신은 헌신의 마스터입니다! 🎖️'**
  String get achievementDedicationMasterMotivation;

  /// GitHub repository link
  ///
  /// In ko, this message translates to:
  /// **'GitHub 저장소'**
  String get githubRepository;

  /// Send feedback via email
  ///
  /// In ko, this message translates to:
  /// **'이메일로 피드백 보내기'**
  String get feedbackEmail;

  /// Developer contact information
  ///
  /// In ko, this message translates to:
  /// **'개발자 연락처'**
  String get developerContact;

  /// Open GitHub repository
  ///
  /// In ko, this message translates to:
  /// **'GitHub에서 소스코드 보기'**
  String get openGithub;

  /// Send feedback via email
  ///
  /// In ko, this message translates to:
  /// **'이메일로 의견을 보내주세요'**
  String get emailFeedback;

  /// Cannot open email app error
  ///
  /// In ko, this message translates to:
  /// **'이메일 앱을 열 수 없습니다'**
  String get cannotOpenEmail;

  /// Cannot open GitHub error
  ///
  /// In ko, this message translates to:
  /// **'GitHub을 열 수 없습니다'**
  String get cannotOpenGithub;

  /// App version
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get appVersion;

  /// Built with Flutter
  ///
  /// In ko, this message translates to:
  /// **'Flutter로 제작됨'**
  String get builtWithFlutter;

  /// 7 consecutive days challenge title
  ///
  /// In ko, this message translates to:
  /// **'7일 연속 운동'**
  String get challenge7DaysTitle;

  /// 7 consecutive days challenge description
  ///
  /// In ko, this message translates to:
  /// **'7일 동안 연속으로 운동하기'**
  String get challenge7DaysDescription;

  /// 7 consecutive days challenge detailed description
  ///
  /// In ko, this message translates to:
  /// **'하루도 빠짐없이 7일 동안 연속으로 운동을 완료하세요. 매일 최소 1세트 이상 운동해야 합니다.'**
  String get challenge7DaysDetailedDescription;

  /// 50 single session challenge title
  ///
  /// In ko, this message translates to:
  /// **'50개 한번에'**
  String get challenge50SingleTitle;

  /// 50 single session challenge description
  ///
  /// In ko, this message translates to:
  /// **'한 번의 운동에서 50개 팔굽혀펴기'**
  String get challenge50SingleDescription;

  /// 50 single session challenge detailed description
  ///
  /// In ko, this message translates to:
  /// **'쉬지 않고 한 번에 50개의 팔굽혀펴기를 완료하세요. 중간에 멈추면 처음부터 다시 시작해야 합니다.'**
  String get challenge50SingleDetailedDescription;

  /// 100 cumulative challenge title
  ///
  /// In ko, this message translates to:
  /// **'100개 챌린지'**
  String get challenge100CumulativeTitle;

  /// 100 cumulative challenge description
  ///
  /// In ko, this message translates to:
  /// **'총 100개 팔굽혀펴기 달성'**
  String get challenge100CumulativeDescription;

  /// 100 cumulative challenge detailed description
  ///
  /// In ko, this message translates to:
  /// **'여러 세션에 걸쳐 총 100개의 팔굽혀펴기를 완료하세요.'**
  String get challenge100CumulativeDetailedDescription;

  /// 200 cumulative challenge title
  ///
  /// In ko, this message translates to:
  /// **'200개 챌린지'**
  String get challenge200CumulativeTitle;

  /// 200 cumulative challenge description
  ///
  /// In ko, this message translates to:
  /// **'총 200개 팔굽혀펴기 달성'**
  String get challenge200CumulativeDescription;

  /// 200 cumulative challenge detailed description
  ///
  /// In ko, this message translates to:
  /// **'여러 세션에 걸쳐 총 200개의 팔굽혀펴기를 완료하세요. 100개 챌린지를 완료한 후에 도전할 수 있습니다.'**
  String get challenge200CumulativeDetailedDescription;

  /// 14 consecutive days challenge title
  ///
  /// In ko, this message translates to:
  /// **'14일 연속 운동'**
  String get challenge14DaysTitle;

  /// 14 consecutive days challenge description
  ///
  /// In ko, this message translates to:
  /// **'14일 동안 연속으로 운동하기'**
  String get challenge14DaysDescription;

  /// 14 consecutive days challenge detailed description
  ///
  /// In ko, this message translates to:
  /// **'하루도 빠짐없이 14일 동안 연속으로 운동을 완료하세요. 7일 연속 챌린지를 완료한 후에 도전할 수 있습니다.'**
  String get challenge14DaysDetailedDescription;

  /// Consecutive warrior badge reward
  ///
  /// In ko, this message translates to:
  /// **'연속 운동 전사 배지'**
  String get challengeRewardConsecutiveWarrior;

  /// Power lifter badge reward
  ///
  /// In ko, this message translates to:
  /// **'파워 리프터 배지'**
  String get challengeRewardPowerLifter;

  /// Century club badge reward
  ///
  /// In ko, this message translates to:
  /// **'센추리 클럽 배지'**
  String get challengeRewardCenturyClub;

  /// Ultimate champion badge reward
  ///
  /// In ko, this message translates to:
  /// **'궁극의 챔피언 배지'**
  String get challengeRewardUltimateChampion;

  /// Dedication master badge reward
  ///
  /// In ko, this message translates to:
  /// **'헌신의 마스터 배지'**
  String get challengeRewardDedicationMaster;

  /// Points reward
  ///
  /// In ko, this message translates to:
  /// **'{points} 포인트'**
  String challengeRewardPoints(String points);

  /// Advanced stats feature unlock reward
  ///
  /// In ko, this message translates to:
  /// **'고급 통계 기능 해금'**
  String get challengeRewardAdvancedStats;

  /// Days unit for challenges
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get challengeUnitDays;

  /// Reps unit for challenges
  ///
  /// In ko, this message translates to:
  /// **'개'**
  String get challengeUnitReps;

  /// Challenge status: available
  ///
  /// In ko, this message translates to:
  /// **'도전 가능'**
  String get challengeStatusAvailable;

  /// Challenge status: active
  ///
  /// In ko, this message translates to:
  /// **'진행 중'**
  String get challengeStatusActive;

  /// Challenge status: completed
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get challengeStatusCompleted;

  /// Challenge status: failed
  ///
  /// In ko, this message translates to:
  /// **'실패'**
  String get challengeStatusFailed;

  /// Challenge status: locked
  ///
  /// In ko, this message translates to:
  /// **'잠김'**
  String get challengeStatusLocked;

  /// Challenge difficulty: easy
  ///
  /// In ko, this message translates to:
  /// **'쉬움'**
  String get challengeDifficultyEasy;

  /// Challenge difficulty: medium
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get challengeDifficultyMedium;

  /// Challenge difficulty: hard
  ///
  /// In ko, this message translates to:
  /// **'어려움'**
  String get challengeDifficultyHard;

  /// Challenge difficulty: extreme
  ///
  /// In ko, this message translates to:
  /// **'극한'**
  String get challengeDifficultyExtreme;

  /// Challenge type: consecutive days
  ///
  /// In ko, this message translates to:
  /// **'연속 일수'**
  String get challengeTypeConsecutiveDays;

  /// Challenge type: single session
  ///
  /// In ko, this message translates to:
  /// **'단일 세션'**
  String get challengeTypeSingleSession;

  /// Challenge type: cumulative
  ///
  /// In ko, this message translates to:
  /// **'누적'**
  String get challengeTypeCumulative;

  /// Challenges screen title
  ///
  /// In ko, this message translates to:
  /// **'챌린지'**
  String get challengesTitle;

  /// Available challenges tab
  ///
  /// In ko, this message translates to:
  /// **'도전 가능'**
  String get challengesAvailable;

  /// Active challenges tab
  ///
  /// In ko, this message translates to:
  /// **'진행 중'**
  String get challengesActive;

  /// Completed challenges tab
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get challengesCompleted;

  /// Start challenge button
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get challengeStartButton;

  /// Abandon challenge button
  ///
  /// In ko, this message translates to:
  /// **'포기하기'**
  String get challengeAbandonButton;

  /// Restart challenge button
  ///
  /// In ko, this message translates to:
  /// **'다시 시작'**
  String get challengeRestartButton;

  /// Challenge progress
  ///
  /// In ko, this message translates to:
  /// **'진행률: {progress}%'**
  String challengeProgress(int progress);

  /// Challenge estimated duration
  ///
  /// In ko, this message translates to:
  /// **'예상 기간: {duration}일'**
  String challengeEstimatedDuration(int duration);

  /// Challenge rewards section
  ///
  /// In ko, this message translates to:
  /// **'보상'**
  String get challengeRewards;

  /// Challenge completed message
  ///
  /// In ko, this message translates to:
  /// **'챌린지 완료!'**
  String get challengeCompleted;

  /// Challenge failed message
  ///
  /// In ko, this message translates to:
  /// **'챌린지 실패'**
  String get challengeFailed;

  /// Challenge started message
  ///
  /// In ko, this message translates to:
  /// **'챌린지 시작!'**
  String get challengeStarted;

  /// Challenge abandoned message
  ///
  /// In ko, this message translates to:
  /// **'챌린지 포기됨'**
  String get challengeAbandoned;

  /// Challenge prerequisites not met message
  ///
  /// In ko, this message translates to:
  /// **'전제 조건이 충족되지 않았습니다'**
  String get challengePrerequisitesNotMet;

  /// Challenge already active message
  ///
  /// In ko, this message translates to:
  /// **'이미 활성화된 챌린지가 있습니다'**
  String get challengeAlreadyActive;

  /// Hint for consecutive days challenges
  ///
  /// In ko, this message translates to:
  /// **'매일 꾸준히 운동하세요! 하루라도 빠뜨리면 처음부터 다시 시작해야 합니다.'**
  String get challengeHintConsecutiveDays;

  /// Hint for single session challenges
  ///
  /// In ko, this message translates to:
  /// **'한 번에 목표 개수를 달성하세요! 중간에 쉬면 안 됩니다.'**
  String get challengeHintSingleSession;

  /// Hint for cumulative challenges
  ///
  /// In ko, this message translates to:
  /// **'여러 번에 걸쳐 목표를 달성하세요. 꾸준히 하면 됩니다!'**
  String get challengeHintCumulative;

  /// Send friend challenge button
  ///
  /// In ko, this message translates to:
  /// **'💀 친구에게 차드 도전장 발송! 💀'**
  String get sendFriendChallenge;

  /// Refresh button
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get refresh;

  /// Achieved status
  ///
  /// In ko, this message translates to:
  /// **'달성'**
  String get achieved;

  /// Share button
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get shareButton;

  /// Today's mission
  ///
  /// In ko, this message translates to:
  /// **'오늘의 미션'**
  String get todayMission;

  /// Today's target label
  ///
  /// In ko, this message translates to:
  /// **'오늘의 목표:'**
  String get todayTarget;

  /// Set format with number and reps
  ///
  /// In ko, this message translates to:
  /// **'{number}세트: {reps}회'**
  String setFormat2(int number, int reps);

  /// Completed workout format
  ///
  /// In ko, this message translates to:
  /// **'완료됨: {reps}회 ({sets}세트)'**
  String completedFormat(int reps, int sets);

  /// Total workout format
  ///
  /// In ko, this message translates to:
  /// **'총 {reps}회 ({sets}세트)'**
  String totalFormat(int reps, int sets);

  /// Today's workout completed message
  ///
  /// In ko, this message translates to:
  /// **'오늘 운동 완료됨! 🎉'**
  String get todayWorkoutCompleted;

  /// Rest prevention message
  ///
  /// In ko, this message translates to:
  /// **'잠깐! 너 진짜 쉴거야?'**
  String get justWait;

  /// Progress tracking title
  ///
  /// In ko, this message translates to:
  /// **'진행률 추적'**
  String get progressTracking;

  /// Sleepy hat chad name
  ///
  /// In ko, this message translates to:
  /// **'수면모자 Chad'**
  String get sleepyHatChad;

  /// Journey starting chad description
  ///
  /// In ko, this message translates to:
  /// **'여정을 시작하는 Chad입니다.\n아직 잠이 덜 깬 상태지만 곧 깨어날 것입니다!'**
  String get journeyStartingChad;

  /// 주차/일차 표시 형식
  ///
  /// In ko, this message translates to:
  /// **'{week}주차 {day}일차'**
  String weekDayFormat(int week, int day);

  /// Perfect notification permission status
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 완벽!'**
  String get notificationPermissionPerfect;

  /// Basic notification permission
  ///
  /// In ko, this message translates to:
  /// **'기본 알림 권한'**
  String get basicNotificationPermission;

  /// Exact notification permission
  ///
  /// In ko, this message translates to:
  /// **'정확한 알림 권한'**
  String get exactNotificationPermission;

  /// Congratulations message for permissions
  ///
  /// In ko, this message translates to:
  /// **'축하합니다! 모든 권한이 완벽하게 설정되었습니다! 🎉'**
  String get congratulationsMessage;

  /// Workout day notification
  ///
  /// In ko, this message translates to:
  /// **'운동일 전용 알림'**
  String get workoutDayNotification;

  /// Chad evolution complete notification
  ///
  /// In ko, this message translates to:
  /// **'Chad 진화 완료 알림'**
  String get chadEvolutionCompleteNotification;

  /// Chad evolution preview notification
  ///
  /// In ko, this message translates to:
  /// **'Chad 진화 예고 알림'**
  String get chadEvolutionPreviewNotification;

  /// Chad evolution quarantine notification
  ///
  /// In ko, this message translates to:
  /// **'Chad 진화 격리 알림'**
  String get chadEvolutionQuarantineNotification;

  /// Theme color setting
  ///
  /// In ko, this message translates to:
  /// **'테마 색상'**
  String get themeColor;

  /// Font size setting
  ///
  /// In ko, this message translates to:
  /// **'폰트 크기'**
  String get fontSize;

  /// Animation effect setting
  ///
  /// In ko, this message translates to:
  /// **'애니메이션 효과'**
  String get animationEffect;

  /// High contrast mode setting
  ///
  /// In ko, this message translates to:
  /// **'고대비 모드'**
  String get highContrastMode;

  /// Backup management title
  ///
  /// In ko, this message translates to:
  /// **'백업 관리'**
  String get backupManagement;

  /// Backup management description
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업, 복원 및 자동 백업 설정을 관리합니다.'**
  String get backupManagementDesc;

  /// Level reset title
  ///
  /// In ko, this message translates to:
  /// **'레벨 리셋'**
  String get levelReset;

  /// Level reset description
  ///
  /// In ko, this message translates to:
  /// **'모든 진행 상황을 초기화하고 처음부터 시작합니다.'**
  String get levelResetDesc;

  /// License information title
  ///
  /// In ko, this message translates to:
  /// **'라이선스 정보'**
  String get licenseInfo;

  /// License information description
  ///
  /// In ko, this message translates to:
  /// **'앱에서 사용된 라이선스 정보..'**
  String get licenseInfoDesc;

  /// 오늘의 미션 제목
  ///
  /// In ko, this message translates to:
  /// **'오늘의 미션'**
  String get todayMissionTitle;

  /// 오늘의 목표 제목
  ///
  /// In ko, this message translates to:
  /// **'오늘의 목표'**
  String get todayGoalTitle;

  /// 세트 수 및 횟수 표시 형식
  ///
  /// In ko, this message translates to:
  /// **'{setCount}세트 × {repsCount}회'**
  String setRepsFormat(int setCount, int repsCount);

  /// 완료된 횟수 형식
  ///
  /// In ko, this message translates to:
  /// **'완료: {completed}회'**
  String completedRepsFormat(int completed);

  /// 총 횟수 형식
  ///
  /// In ko, this message translates to:
  /// **'총 {total}회'**
  String totalRepsFormat(int total);

  /// Checking permission status message
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 상태를 확인하고 있습니다'**
  String get notificationPermissionCheckingStatus;

  /// Notification permission needed status
  ///
  /// In ko, this message translates to:
  /// **'❌ 알림 권한 필요'**
  String get notificationPermissionNeeded;

  /// Exact alarm permission label
  ///
  /// In ko, this message translates to:
  /// **'정확한 알람 권한'**
  String get exactAlarmPermission;

  /// Allow notification permission button
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 허용하기'**
  String get allowNotificationPermission;

  /// Set exact alarm permission button
  ///
  /// In ko, this message translates to:
  /// **'정확한 알람 권한 설정하기'**
  String get setExactAlarmPermission;

  /// Required permission label
  ///
  /// In ko, this message translates to:
  /// **'필수'**
  String get requiredLabel;

  /// Recommended permission label
  ///
  /// In ko, this message translates to:
  /// **'권장'**
  String get recommendedLabel;

  /// Permission activated status
  ///
  /// In ko, this message translates to:
  /// **'활성화됨'**
  String get activatedStatus;

  /// Theme color setting description
  ///
  /// In ko, this message translates to:
  /// **'앱의 메인 색상을 변경합니다 (현재: {color})'**
  String themeColorDesc(String color);

  /// Font scale setting title
  ///
  /// In ko, this message translates to:
  /// **'글자 크기'**
  String get fontScale;

  /// Font scale setting description
  ///
  /// In ko, this message translates to:
  /// **'앱 전체의 텍스트 크기를 조정합니다'**
  String get fontScaleDesc;

  /// Animation effects setting title
  ///
  /// In ko, this message translates to:
  /// **'애니메이션 효과'**
  String get animationsEnabled;

  /// Animation effects setting description
  ///
  /// In ko, this message translates to:
  /// **'앱 전체의 애니메이션 효과를 켜거나 끕니다'**
  String get animationsEnabledDesc;

  /// High contrast mode setting description
  ///
  /// In ko, this message translates to:
  /// **'시각적 접근성을 위한 고대비 모드를 활성화합니다'**
  String get highContrastModeDesc;

  /// Level reset confirmation dialog title
  ///
  /// In ko, this message translates to:
  /// **'레벨 리셋 확인'**
  String get levelResetConfirm;

  /// URL not available dialog title
  ///
  /// In ko, this message translates to:
  /// **'페이지 준비 중'**
  String get urlNotAvailableTitle;

  /// URL not available dialog message
  ///
  /// In ko, this message translates to:
  /// **'{page} 페이지는 아직 준비되지 않았습니다. 향후 업데이트에서 제공될 예정입니다.'**
  String urlNotAvailableMessage(String page);

  /// Open in browser button text
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 열기'**
  String get openInBrowser;

  /// OK button text
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// 로딩 중 표시 텍스트
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loadingText;

  /// 새로고침 버튼
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get refreshButton;

  /// 데이터 로딩 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터를 불러오는 중 오류가 발생했습니다'**
  String get errorLoadingData;

  /// 다시 시도 버튼
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retryButton;

  /// 사용자 프로필 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'사용자 프로필이 없습니다'**
  String get noUserProfile;

  /// 초기 테스트 완료 안내
  ///
  /// In ko, this message translates to:
  /// **'초기 테스트를 완료하여 프로필을 생성해주세요'**
  String get completeInitialTest;

  /// 수면모자 차드 진화 상태
  ///
  /// In ko, this message translates to:
  /// **'수면모자 Chad'**
  String get sleepyChadEvolution;

  /// 여정을 시작하는 차드 진화 상태
  ///
  /// In ko, this message translates to:
  /// **'여정을 시작하는 Chad'**
  String get journeyChadEvolution;

  /// 세트 수 및 횟수 표시 형식
  ///
  /// In ko, this message translates to:
  /// **'세트 × 횟수'**
  String get setRepsDisplayFormat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
