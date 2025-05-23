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
  /// **'⚡ 알파 전장 ⚡'**
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
  /// **'굿 잡, 만삣삐! 신의 영역 도달했다 👑'**
  String get performanceGodTier;

  /// 목표 80% 이상 달성시 메시지
  ///
  /// In ko, this message translates to:
  /// **'철봉이 무릎꿇는 소리 들리냐? 더 강하게 가자 🔱'**
  String get performanceStrong;

  /// 목표 50% 이상 달성시 메시지
  ///
  /// In ko, this message translates to:
  /// **'not bad, 만삣삐. 약함이 도망가고 있어 ⚡'**
  String get performanceMedium;

  /// 운동 시작시 메시지
  ///
  /// In ko, this message translates to:
  /// **'시작이 반이다, you idiot. 전설의 첫 걸음 🦍'**
  String get performanceStart;

  /// 기본 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'할 수 있어, 만삣삐. 그냥 해버려 🔥'**
  String get performanceMotivation;

  /// 목표 달성시 최고 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'완벽하다, 만삣삐. 너의 근육이 신급 도달했어. 약함은 이미 떠났다. ⚡👑'**
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
  /// **'신급 달성'**
  String get quickInputPerfect;

  /// 목표 80% 버튼
  ///
  /// In ko, this message translates to:
  /// **'강자의 여유'**
  String get quickInputStrong;

  /// 목표 60% 버튼
  ///
  /// In ko, this message translates to:
  /// **'거인의 발걸음'**
  String get quickInputMedium;

  /// 목표 50% 버튼
  ///
  /// In ko, this message translates to:
  /// **'시작의 함성'**
  String get quickInputStart;

  /// 목표 초과 버튼
  ///
  /// In ko, this message translates to:
  /// **'한계 파괴'**
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

  /// 초급 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'초급 (푸시 시작)'**
  String get rookieLevelTitle;

  /// 초급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 6개 미만 - 기초부터 차근차근'**
  String get rookieLevelSubtitle;

  /// 초급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'아직 푸시업이 어렵다고? 괜찮다! 모든 차드의 시작은 여기부터다, 만삣삐!'**
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

  /// 중급 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'중급 (알파 지망생)'**
  String get risingLevelTitle;

  /// 중급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 6-10개 - 차드로 성장 중'**
  String get risingLevelSubtitle;

  /// 중급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'기본기는 있다! 이제 진짜 차드가 되기 위한 훈련을 시작하자, 만삣삐!'**
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

  /// 고급 레벨 제목
  ///
  /// In ko, this message translates to:
  /// **'고급 (차드 영역)'**
  String get alphaLevelTitle;

  /// 고급 레벨 부제목
  ///
  /// In ko, this message translates to:
  /// **'푸시업 11개 이상 - 이미 차드의 자질'**
  String get alphaLevelSubtitle;

  /// 고급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'벌써 이 정도라고? 진짜 차드의 길에 한 발 걸쳤구나! 기가차드까지 달려보자!'**
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
  /// **'Chad Dashboard'**
  String get homeTitle;

  /// 홈 화면 환영 메시지
  ///
  /// In ko, this message translates to:
  /// **'환영합니다, 만삣삐!'**
  String get welcomeMessage;

  /// 일일 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'오늘도 강해지는 하루를 시작해보세요!'**
  String get dailyMotivation;

  /// 오늘 운동 시작 버튼
  ///
  /// In ko, this message translates to:
  /// **'오늘의 워크아웃 시작'**
  String get startTodayWorkout;

  /// 주간 진행 상황 제목
  ///
  /// In ko, this message translates to:
  /// **'이번 주 진행 상황'**
  String get weekProgress;

  /// 진행 상황 상세
  ///
  /// In ko, this message translates to:
  /// **'{week}주차 - {totalDays}일 중 {completedDays}일 완료'**
  String progressWeekDay(int week, int totalDays, int completedDays);

  /// 하단 동기부여 메시지
  ///
  /// In ko, this message translates to:
  /// **'💪 매일 조금씩, 꾸준히 성장하세요!'**
  String get bottomMotivation;

  /// 운동 시작 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'워크아웃을 시작할 수 없습니다: {error}'**
  String workoutStartError(String error);

  /// 일반 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다. 다시 시도해주세요.'**
  String get errorGeneral;

  /// 데이터베이스 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터베이스 오류가 발생했습니다.'**
  String get errorDatabase;

  /// 네트워크 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요.'**
  String get errorNetwork;

  /// 데이터 없음 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'데이터를 찾을 수 없습니다.'**
  String get errorNotFound;

  /// 운동 완료 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 완료! 차드에 한 걸음 더 가까워졌습니다.'**
  String get successWorkoutCompleted;

  /// 프로필 저장 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'프로필이 저장되었습니다.'**
  String get successProfileSaved;

  /// 설정 저장 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'설정이 저장되었습니다.'**
  String get successSettingsSaved;

  /// 첫 운동 특별 메시지
  ///
  /// In ko, this message translates to:
  /// **'첫 운동을 시작하는 차드의 여정이 시작됩니다!'**
  String get firstWorkoutMessage;

  /// 주간 완료 특별 메시지
  ///
  /// In ko, this message translates to:
  /// **'한 주를 완주했습니다! 차드 파워가 상승합니다!'**
  String get weekCompletedMessage;

  /// 프로그램 완료 특별 메시지
  ///
  /// In ko, this message translates to:
  /// **'축하합니다! 진정한 기가 차드가 되었습니다!'**
  String get programCompletedMessage;

  /// 스트릭 시작 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드 스트릭이 시작되었습니다!'**
  String get streakStartMessage;

  /// 스트릭 지속 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드 스트릭이 계속됩니다!'**
  String get streakContinueMessage;

  /// 스트릭 중단 메시지
  ///
  /// In ko, this message translates to:
  /// **'스트릭이 끊어졌지만, 차드는 다시 일어납니다!'**
  String get streakBrokenMessage;

  /// 수면모자차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Sleepy Chad'**
  String get chadTitleSleepy;

  /// 기본차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Basic Chad'**
  String get chadTitleBasic;

  /// 커피차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Coffee Chad'**
  String get chadTitleCoffee;

  /// 정면차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Front Chad'**
  String get chadTitleFront;

  /// 썬글차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Cool Chad'**
  String get chadTitleCool;

  /// 눈빨차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Laser Chad'**
  String get chadTitleLaser;

  /// 더블차드 타이틀
  ///
  /// In ko, this message translates to:
  /// **'Double Chad'**
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
  /// **'푸시업 여정을 시작하는 초보 차드다.\n꾸준한 연습으로 더 강해질 수 있어, 만삣삐!'**
  String get levelDescRookie;

  /// 중급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'기본기를 갖춘 상승하는 차드다.\n더 높은 목표를 향해 나아가고 있어, 만삣삐!'**
  String get levelDescRising;

  /// 고급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'상당한 실력을 갖춘 알파 차드다.\n이미 많은 발전을 이루었어, 만삣삐!'**
  String get levelDescAlpha;

  /// 최고급 레벨 설명
  ///
  /// In ko, this message translates to:
  /// **'최고 수준의 기가 차드다.\n놀라운 실력을 가지고 있어, 만삣삐!'**
  String get levelDescGiga;

  /// 초급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'모든 차드는 여기서 시작한다!\n6주 후 놀라운 변화를 경험하라, 만삣삐!'**
  String get levelMotivationRookie;

  /// 중급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'좋은 시작이다!\n더 강한 차드가 되어라, 만삣삐!'**
  String get levelMotivationRising;

  /// 고급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'훌륭한 실력이다!\n100개 목표까지 달려라, fxxk idiot!'**
  String get levelMotivationAlpha;

  /// 최고급 격려 메시지
  ///
  /// In ko, this message translates to:
  /// **'이미 강력한 차드군!\n완벽한 100개를 향해 가라, 만삣삐!'**
  String get levelMotivationGiga;

  /// 초급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'목표: 6주 후 연속 100개 푸시업!'**
  String get levelGoalRookie;

  /// 중급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'목표: 더 강한 차드로 성장하기!'**
  String get levelGoalRising;

  /// 고급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'목표: 완벽한 폼으로 100개!'**
  String get levelGoalAlpha;

  /// 최고급 목표 메시지
  ///
  /// In ko, this message translates to:
  /// **'목표: 차드 마스터가 되기!'**
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
  /// **'진짜 차드는 변명 따위 안 만든다, fxxk idiot'**
  String get motivationMessage1;

  /// 동기부여 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'차드처럼 밀어붙이고, 시그마처럼 휴식하라'**
  String get motivationMessage2;

  /// 동기부여 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'모든 반복이 너를 차드에 가깝게 만든다'**
  String get motivationMessage3;

  /// 동기부여 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'차드 에너지가 충전되고 있다, 만삣삐'**
  String get motivationMessage4;

  /// 동기부여 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'차드로 진화하고 있어, fxxk yeah!'**
  String get motivationMessage5;

  /// 동기부여 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'차드 모드: 활성화됨 💪'**
  String get motivationMessage6;

  /// 동기부여 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'이렇게 차드들이 만들어진다, 만삣삐'**
  String get motivationMessage7;

  /// 동기부여 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'차드 파워가 흐르는 걸 느껴라'**
  String get motivationMessage8;

  /// 동기부여 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'차드 변신 진행 중이다, you idiot'**
  String get motivationMessage9;

  /// 동기부여 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'차드 브라더후드에 환영한다, 만삣삐'**
  String get motivationMessage10;

  /// 완료 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'바로 그거야, fxxk yeah!'**
  String get completionMessage1;

  /// 완료 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'오늘 차드 바이브가 강하다, 만삣삐'**
  String get completionMessage2;

  /// 완료 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'차드에 한 걸음 더 가까워졌어'**
  String get completionMessage3;

  /// 완료 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'더욱 차드답게 되고 있다, you idiot'**
  String get completionMessage4;

  /// 완료 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'차드 에너지 레벨: 상승 중 ⚡'**
  String get completionMessage5;

  /// 완료 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'존경한다. 그럴 자격이 있어, 만삣삐'**
  String get completionMessage6;

  /// 완료 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'차드가 이 운동을 승인했다'**
  String get completionMessage7;

  /// 완료 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'차드 게임을 레벨업했어, fxxk idiot'**
  String get completionMessage8;

  /// 완료 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'순수한 차드 퍼포먼스였다'**
  String get completionMessage9;

  /// 완료 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'또 다른 차드의 하루에 환영한다, 만삣삐'**
  String get completionMessage10;

  /// 격려 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'차드도 힘든 날이 있다, 만삣삐'**
  String get encouragementMessage1;

  /// 격려 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'내일은 또 다른 차드가 될 기회다'**
  String get encouragementMessage2;

  /// 격려 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'차드는 포기하지 않는다, fxxk idiot'**
  String get encouragementMessage3;

  /// 격려 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'이건 그냥 차드 트레이닝 모드야'**
  String get encouragementMessage4;

  /// 격려 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'진짜 차드는 계속 밀어붙인다, 만삣삐'**
  String get encouragementMessage5;

  /// 격려 메시지 6
  ///
  /// In ko, this message translates to:
  /// **'차드 정신은 절대 죽지 않아'**
  String get encouragementMessage6;

  /// 격려 메시지 7
  ///
  /// In ko, this message translates to:
  /// **'아직 차드의 길 위에 있어, you idiot'**
  String get encouragementMessage7;

  /// 격려 메시지 8
  ///
  /// In ko, this message translates to:
  /// **'차드 컴백이 오고 있다'**
  String get encouragementMessage8;

  /// 격려 메시지 9
  ///
  /// In ko, this message translates to:
  /// **'모든 차드는 도전에 직면한다, 만삣삐'**
  String get encouragementMessage9;

  /// 격려 메시지 10
  ///
  /// In ko, this message translates to:
  /// **'차드 회복력이 너의 힘이다, fxxk yeah!'**
  String get encouragementMessage10;

  /// 0단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'일어나야 할 때다, 만삣삐'**
  String get chadMessage0;

  /// 1단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'이제 시작이야, you idiot'**
  String get chadMessage1;

  /// 2단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'에너지가 충전됐다, fxxk yeah!'**
  String get chadMessage2;

  /// 3단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'자신감이 생겼어, 만삣삐'**
  String get chadMessage3;

  /// 4단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'이제 좀 멋져 보이는군, you idiot'**
  String get chadMessage4;

  /// 5단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드의 아우라가 느껴진다, 만삣삐'**
  String get chadMessage5;

  /// 6단계 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'진정한 기가 차드 탄생, fxxk idiot!'**
  String get chadMessage6;

  /// 튜토리얼 메인 타이틀
  ///
  /// In ko, this message translates to:
  /// **'차드 푸시업 도장'**
  String get tutorialTitle;

  /// 튜토리얼 서브타이틀
  ///
  /// In ko, this message translates to:
  /// **'진짜 차드는 자세부터 다르다, 만삣삐! 💪'**
  String get tutorialSubtitle;

  /// 홈에서 튜토리얼로 가는 버튼
  ///
  /// In ko, this message translates to:
  /// **'푸시업 마스터되기'**
  String get tutorialButton;

  /// 초급 난이도
  ///
  /// In ko, this message translates to:
  /// **'푸시 - 시작하는 만삣삐들'**
  String get difficultyBeginner;

  /// 중급 난이도
  ///
  /// In ko, this message translates to:
  /// **'알파 지망생 - 성장하는 차드들'**
  String get difficultyIntermediate;

  /// 고급 난이도
  ///
  /// In ko, this message translates to:
  /// **'차드 - 강력한 기가들'**
  String get difficultyAdvanced;

  /// 극한 난이도
  ///
  /// In ko, this message translates to:
  /// **'기가 차드 - 전설의 영역'**
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
  /// **'차드 자세 마스터하기'**
  String get tutorialDetailTitle;

  /// 효과 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'💪 이렇게 강해진다'**
  String get benefitsSection;

  /// 실행 방법 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'⚡ 차드 실행법'**
  String get instructionsSection;

  /// 일반적인 실수 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'❌ 약자들의 실수'**
  String get mistakesSection;

  /// 호흡법 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🌪️ 차드 호흡법'**
  String get breathingSection;

  /// 차드 격려 메시지 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'🔥 차드의 조언'**
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

  /// 기본 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'기본이 제일 어려운 거야, you idiot. 완벽한 폼으로 하나 하는 게 대충 열 개보다 낫다, 만삣삐!'**
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

  /// 무릎 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'시작이 반이다, you idiot! 완벽한 폼으로 무릎 푸시업부터 마스터해라. 기초가 탄탄해야 차드가 된다!'**
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

  /// 인클라인 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'높이는 조절하고 강도는 최대로! 완벽한 폼으로 20개 하면 바닥으로 내려갈 준비 완료다, 만삣삐!'**
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

  /// 와이드 그립 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'넓은 가슴은 차드의 상징이다! 와이드 그립으로 진짜 남자다운 가슴을 만들어라, 만삣삐!'**
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

  /// 다이아몬드 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'다이아몬드만큼 단단한 팔을 만들어라! 이거 10개만 완벽하게 해도 진짜 차드 인정, 만삣삐!'**
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

  /// 디클라인 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'중력따위 개무시하고 밀어올려라! 디클라인 마스터하면 어깨가 바위가 된다, 만삣삐!'**
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

  /// 아처 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'정확한 아처가 원핸드로 가는 지름길이다! 양쪽 균등하게 마스터해라, 만삣삐!'**
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

  /// 파이크 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'파이크 마스터하면 핸드스탠드도 문제없다! 어깨 차드로 진화하라, 만삣삐!'**
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

  /// 박수 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'박수 푸시업은 진짜 파워의 증명이다! 한 번이라도 성공하면 너는 이미 차드, 만삣삐!'**
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

  /// 원핸드 푸시업 차드 메시지
  ///
  /// In ko, this message translates to:
  /// **'원핸드 푸시업은 차드의 완성형이다! 이거 한 번이라도 하면 진짜 기가 차드 인정, fxxk yeah!'**
  String get pushupOneArmChad;

  /// 레벨 선택 요청 버튼
  ///
  /// In ko, this message translates to:
  /// **'레벨을 선택해라, 만삣삐!'**
  String get selectLevelButton;

  /// 선택한 레벨로 시작하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'{level}로 차드 되기 시작!'**
  String startWithLevel(String level);

  /// 프로필 생성 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'차드 프로필 생성 완료! ({sessions}개 세션 준비됨, 만삣삐!)'**
  String profileCreated(int sessions);

  /// 프로필 생성 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'프로필 생성 실패, 다시 해봐! 오류: {error}'**
  String profileCreationError(String error);
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
