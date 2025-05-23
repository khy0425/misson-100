// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '⚡ 알파 전장 ⚡';

  @override
  String get repLogMessage => '기록해라, 만삣삐. 약자는 숫자를 센다, 강자는 전설을 만든다 💪';

  @override
  String targetRepsLabel(int count) {
    return '목표: $count회';
  }

  @override
  String get performanceGodTier => '굿 잡, 만삣삐! 신의 영역 도달했다 👑';

  @override
  String get performanceStrong => '철봉이 무릎꿇는 소리 들리냐? 더 강하게 가자 🔱';

  @override
  String get performanceMedium => 'not bad, 만삣삐. 약함이 도망가고 있어 ⚡';

  @override
  String get performanceStart => '시작이 반이다, you idiot. 전설의 첫 걸음 🦍';

  @override
  String get performanceMotivation => '할 수 있어, 만삣삐. 그냥 해버려 🔥';

  @override
  String get motivationGod => '완벽하다, 만삣삐. 너의 근육이 신급 도달했어. 약함은 이미 떠났다. ⚡👑';

  @override
  String get motivationStrong => '포기? 그건 약자나 하는 거야. 더 강하게, 만삣삐! 🔱💪';

  @override
  String get motivationMedium => '한계는 너의 머릿속에만 있어, you idiot. 부숴버려! 🦍⚡';

  @override
  String get motivationGeneral => '오늘 흘린 땀은 내일의 영광이야, 만삣삐. 절대 포기하지 마 🔥💪';

  @override
  String get setCompletedSuccess => '굿 잡, 만삣삐! 또 하나의 신화가 탄생했어 🔥👑';

  @override
  String get setCompletedGood => 'not bad, 만삣삐! 또 하나의 한계를 부숴버렸어 ⚡🔱';

  @override
  String resultFormat(int reps, int percentage) {
    return '전설 등급: $reps회 ($percentage%) 🏆';
  }

  @override
  String get quickInputPerfect => '신급 달성';

  @override
  String get quickInputStrong => '강자의 여유';

  @override
  String get quickInputMedium => '거인의 발걸음';

  @override
  String get quickInputStart => '시작의 함성';

  @override
  String get quickInputBeast => '한계 파괴';

  @override
  String get restTimeTitle => '강자들의 재충전 타임, 만삣삐 ⚡';

  @override
  String get restMessage => '쉬는 것도 성장이야. 다음은 더 파괴적으로 가자, 만삣삐 🦍';

  @override
  String get skipRestButton => '휴식? 약자나 해라, 만삣삐! 다음 희생양 가져와!';

  @override
  String get nextSetButton => '굿 잡! 우주 정복 완료!';

  @override
  String get nextSetContinue => '다음 희생양을 가져와라, 만삣삐!';

  @override
  String get guidanceMessage => '네 몸은 네가 명령하는 대로 따를 뿐이야, you idiot! 🔱';

  @override
  String get completeSetButton => '전설 등극, 만삣삐!';

  @override
  String get completeSetContinue => '또 하나 박살내기!';

  @override
  String get exitDialogTitle => '전투에서 후퇴하겠어, 만삣삐?';

  @override
  String get exitDialogMessage =>
      '전사는 절대 전투 중에 포기하지 않아!\n너의 정복이 사라질 거야, you idiot!';

  @override
  String get exitDialogContinue => '계속 싸운다, 만삣삐!';

  @override
  String get exitDialogRetreat => '후퇴한다...';

  @override
  String get workoutCompleteTitle => '🔥 굿 잡, 만삣삐! 야수 모드 완료! 👑';

  @override
  String workoutCompleteMessage(String title, int totalReps) {
    return '$title 완전 파괴!\n총 파워 해방: $totalReps회! you did it! ⚡';
  }

  @override
  String get workoutCompleteButton => '레전드다, 만삣삐!';

  @override
  String setFormat(int current, int total) {
    return 'SET $current/$total';
  }

  @override
  String get levelSelectionTitle => '💪 레벨 체크';

  @override
  String get levelSelectionHeader => '🏋️‍♂️ 너의 레벨을 선택해라, 만삣삐!';

  @override
  String get levelSelectionDescription =>
      '현재 푸시업 최대 횟수에 맞는 레벨을 선택해라!\n6주 후 목표 달성을 위한 맞춤 프로그램이 제공된다!';

  @override
  String get rookieLevelTitle => '초급 (푸시 시작)';

  @override
  String get rookieLevelSubtitle => '푸시업 6개 미만 - 기초부터 차근차근';

  @override
  String get rookieLevelDescription =>
      '아직 푸시업이 어렵다고? 괜찮다! 모든 차드의 시작은 여기부터다, 만삣삐!';

  @override
  String get rookieFeature1 => '무릎 푸시업부터 시작';

  @override
  String get rookieFeature2 => '폼 교정 중심 훈련';

  @override
  String get rookieFeature3 => '점진적 강도 증가';

  @override
  String get rookieFeature4 => '기초 체력 향상';

  @override
  String get risingLevelTitle => '중급 (알파 지망생)';

  @override
  String get risingLevelSubtitle => '푸시업 6-10개 - 차드로 성장 중';

  @override
  String get risingLevelDescription =>
      '기본기는 있다! 이제 진짜 차드가 되기 위한 훈련을 시작하자, 만삣삐!';

  @override
  String get risingFeature1 => '표준 푸시업 마스터';

  @override
  String get risingFeature2 => '다양한 변형 훈련';

  @override
  String get risingFeature3 => '근지구력 향상';

  @override
  String get risingFeature4 => '체계적 진급 프로그램';

  @override
  String get alphaLevelTitle => '고급 (차드 영역)';

  @override
  String get alphaLevelSubtitle => '푸시업 11개 이상 - 이미 차드의 자질';

  @override
  String get alphaLevelDescription =>
      '벌써 이 정도라고? 진짜 차드의 길에 한 발 걸쳤구나! 기가차드까지 달려보자!';

  @override
  String get alphaFeature1 => '고급 변형 푸시업';

  @override
  String get alphaFeature2 => '폭발적 파워 훈련';

  @override
  String get alphaFeature3 => '플라이오메트릭 운동';

  @override
  String get alphaFeature4 => '기가차드 완성 코스';

  @override
  String get rookieShort => '푸시';

  @override
  String get risingShort => '알파 지망생';

  @override
  String get alphaShort => '차드';

  @override
  String get gigaShort => '기가차드';

  @override
  String get homeTitle => 'Chad Dashboard';

  @override
  String get welcomeMessage => '환영합니다, 만삣삐!';

  @override
  String get dailyMotivation => '오늘도 강해지는 하루를 시작해보세요!';

  @override
  String get startTodayWorkout => '오늘의 워크아웃 시작';

  @override
  String get weekProgress => '이번 주 진행 상황';

  @override
  String progressWeekDay(int week, int totalDays, int completedDays) {
    return '$week주차 - $totalDays일 중 $completedDays일 완료';
  }

  @override
  String get bottomMotivation => '💪 매일 조금씩, 꾸준히 성장하세요!';

  @override
  String workoutStartError(String error) {
    return '워크아웃을 시작할 수 없습니다: $error';
  }

  @override
  String get errorGeneral => '오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get errorDatabase => '데이터베이스 오류가 발생했습니다.';

  @override
  String get errorNetwork => '네트워크 연결을 확인해주세요.';

  @override
  String get errorNotFound => '데이터를 찾을 수 없습니다.';

  @override
  String get successWorkoutCompleted => '운동 완료! 차드에 한 걸음 더 가까워졌습니다.';

  @override
  String get successProfileSaved => '프로필이 저장되었습니다.';

  @override
  String get successSettingsSaved => '설정이 저장되었습니다.';

  @override
  String get firstWorkoutMessage => '첫 운동을 시작하는 차드의 여정이 시작됩니다!';

  @override
  String get weekCompletedMessage => '한 주를 완주했습니다! 차드 파워가 상승합니다!';

  @override
  String get programCompletedMessage => '축하합니다! 진정한 기가 차드가 되었습니다!';

  @override
  String get streakStartMessage => '차드 스트릭이 시작되었습니다!';

  @override
  String get streakContinueMessage => '차드 스트릭이 계속됩니다!';

  @override
  String get streakBrokenMessage => '스트릭이 끊어졌지만, 차드는 다시 일어납니다!';

  @override
  String get chadTitleSleepy => 'Sleepy Chad';

  @override
  String get chadTitleBasic => 'Basic Chad';

  @override
  String get chadTitleCoffee => 'Coffee Chad';

  @override
  String get chadTitleFront => 'Front Chad';

  @override
  String get chadTitleCool => 'Cool Chad';

  @override
  String get chadTitleLaser => 'Laser Chad';

  @override
  String get chadTitleDouble => 'Double Chad';

  @override
  String get levelNameRookie => 'Rookie Chad';

  @override
  String get levelNameRising => 'Rising Chad';

  @override
  String get levelNameAlpha => 'Alpha Chad';

  @override
  String get levelNameGiga => '기가 차드';

  @override
  String get levelDescRookie =>
      '푸시업 여정을 시작하는 초보 차드다.\n꾸준한 연습으로 더 강해질 수 있어, 만삣삐!';

  @override
  String get levelDescRising => '기본기를 갖춘 상승하는 차드다.\n더 높은 목표를 향해 나아가고 있어, 만삣삐!';

  @override
  String get levelDescAlpha => '상당한 실력을 갖춘 알파 차드다.\n이미 많은 발전을 이루었어, 만삣삐!';

  @override
  String get levelDescGiga => '최고 수준의 기가 차드다.\n놀라운 실력을 가지고 있어, 만삣삐!';

  @override
  String get levelMotivationRookie =>
      '모든 차드는 여기서 시작한다!\n6주 후 놀라운 변화를 경험하라, 만삣삐!';

  @override
  String get levelMotivationRising => '좋은 시작이다!\n더 강한 차드가 되어라, 만삣삐!';

  @override
  String get levelMotivationAlpha => '훌륭한 실력이다!\n100개 목표까지 달려라, fxxk idiot!';

  @override
  String get levelMotivationGiga => '이미 강력한 차드군!\n완벽한 100개를 향해 가라, 만삣삐!';

  @override
  String get levelGoalRookie => '목표: 6주 후 연속 100개 푸시업!';

  @override
  String get levelGoalRising => '목표: 더 강한 차드로 성장하기!';

  @override
  String get levelGoalAlpha => '목표: 완벽한 폼으로 100개!';

  @override
  String get levelGoalGiga => '목표: 차드 마스터가 되기!';

  @override
  String get workoutButtonUltimate => '궁극의 승리 차지하라!';

  @override
  String get workoutButtonConquer => '이 세트를 정복하라, 만삣삐!';

  @override
  String get motivationMessage1 => '진짜 차드는 변명 따위 안 만든다, fxxk idiot';

  @override
  String get motivationMessage2 => '차드처럼 밀어붙이고, 시그마처럼 휴식하라';

  @override
  String get motivationMessage3 => '모든 반복이 너를 차드에 가깝게 만든다';

  @override
  String get motivationMessage4 => '차드 에너지가 충전되고 있다, 만삣삐';

  @override
  String get motivationMessage5 => '차드로 진화하고 있어, fxxk yeah!';

  @override
  String get motivationMessage6 => '차드 모드: 활성화됨 💪';

  @override
  String get motivationMessage7 => '이렇게 차드들이 만들어진다, 만삣삐';

  @override
  String get motivationMessage8 => '차드 파워가 흐르는 걸 느껴라';

  @override
  String get motivationMessage9 => '차드 변신 진행 중이다, you idiot';

  @override
  String get motivationMessage10 => '차드 브라더후드에 환영한다, 만삣삐';

  @override
  String get completionMessage1 => '바로 그거야, fxxk yeah!';

  @override
  String get completionMessage2 => '오늘 차드 바이브가 강하다, 만삣삐';

  @override
  String get completionMessage3 => '차드에 한 걸음 더 가까워졌어';

  @override
  String get completionMessage4 => '더욱 차드답게 되고 있다, you idiot';

  @override
  String get completionMessage5 => '차드 에너지 레벨: 상승 중 ⚡';

  @override
  String get completionMessage6 => '존경한다. 그럴 자격이 있어, 만삣삐';

  @override
  String get completionMessage7 => '차드가 이 운동을 승인했다';

  @override
  String get completionMessage8 => '차드 게임을 레벨업했어, fxxk idiot';

  @override
  String get completionMessage9 => '순수한 차드 퍼포먼스였다';

  @override
  String get completionMessage10 => '또 다른 차드의 하루에 환영한다, 만삣삐';

  @override
  String get encouragementMessage1 => '차드도 힘든 날이 있다, 만삣삐';

  @override
  String get encouragementMessage2 => '내일은 또 다른 차드가 될 기회다';

  @override
  String get encouragementMessage3 => '차드는 포기하지 않는다, fxxk idiot';

  @override
  String get encouragementMessage4 => '이건 그냥 차드 트레이닝 모드야';

  @override
  String get encouragementMessage5 => '진짜 차드는 계속 밀어붙인다, 만삣삐';

  @override
  String get encouragementMessage6 => '차드 정신은 절대 죽지 않아';

  @override
  String get encouragementMessage7 => '아직 차드의 길 위에 있어, you idiot';

  @override
  String get encouragementMessage8 => '차드 컴백이 오고 있다';

  @override
  String get encouragementMessage9 => '모든 차드는 도전에 직면한다, 만삣삐';

  @override
  String get encouragementMessage10 => '차드 회복력이 너의 힘이다, fxxk yeah!';

  @override
  String get chadMessage0 => '일어나야 할 때다, 만삣삐';

  @override
  String get chadMessage1 => '이제 시작이야, you idiot';

  @override
  String get chadMessage2 => '에너지가 충전됐다, fxxk yeah!';

  @override
  String get chadMessage3 => '자신감이 생겼어, 만삣삐';

  @override
  String get chadMessage4 => '이제 좀 멋져 보이는군, you idiot';

  @override
  String get chadMessage5 => '차드의 아우라가 느껴진다, 만삣삐';

  @override
  String get chadMessage6 => '진정한 기가 차드 탄생, fxxk idiot!';

  @override
  String get tutorialTitle => '차드 푸시업 도장';

  @override
  String get tutorialSubtitle => '진짜 차드는 자세부터 다르다, 만삣삐! 💪';

  @override
  String get tutorialButton => '푸시업 마스터되기';

  @override
  String get difficultyBeginner => '푸시 - 시작하는 만삣삐들';

  @override
  String get difficultyIntermediate => '알파 지망생 - 성장하는 차드들';

  @override
  String get difficultyAdvanced => '차드 - 강력한 기가들';

  @override
  String get difficultyExtreme => '기가 차드 - 전설의 영역';

  @override
  String get targetMuscleChest => '가슴';

  @override
  String get targetMuscleTriceps => '삼두근';

  @override
  String get targetMuscleShoulders => '어깨';

  @override
  String get targetMuscleCore => '코어';

  @override
  String get targetMuscleFull => '전신';

  @override
  String caloriesPerRep(int calories) {
    return '${calories}kcal/회';
  }

  @override
  String get tutorialDetailTitle => '차드 자세 마스터하기';

  @override
  String get benefitsSection => '💪 이렇게 강해진다';

  @override
  String get instructionsSection => '⚡ 차드 실행법';

  @override
  String get mistakesSection => '❌ 약자들의 실수';

  @override
  String get breathingSection => '🌪️ 차드 호흡법';

  @override
  String get chadMotivationSection => '🔥 차드의 조언';

  @override
  String get pushupStandardName => '기본 푸시업';

  @override
  String get pushupStandardDesc => '모든 차드의 시작점. 완벽한 기본기가 진짜 강함이다, 만삣삐!';

  @override
  String get pushupStandardBenefits =>
      '• 가슴근육 전체 발달\\n• 삼두근과 어깨 강화\\n• 기본 체력 향상\\n• 모든 푸시업의 기초가 된다, you idiot!';

  @override
  String get pushupStandardInstructions =>
      '1. 플랭크 자세로 시작한다, 만삣삐\\n2. 손은 어깨 너비로 벌려라\\n3. 몸은 일직선으로 유지해라, 흐트러지지 말고\\n4. 가슴이 바닥에 닿을 때까지 내려가라\\n5. 강하게 밀어올려라, 차드답게!';

  @override
  String get pushupStandardMistakes =>
      '• 엉덩이가 위로 솟음 - 약자들이나 하는 짓이야\\n• 가슴을 끝까지 내리지 않음\\n• 목을 앞으로 빼고 함\\n• 손목이 어깨보다 앞에 위치\\n• 일정한 속도를 유지하지 않음, fxxk idiot!';

  @override
  String get pushupStandardBreathing =>
      '내려갈 때 숨을 마시고, 올라올 때 강하게 내뱉어라. 호흡이 파워다, 만삣삐!';

  @override
  String get pushupStandardChad =>
      '기본이 제일 어려운 거야, you idiot. 완벽한 폼으로 하나 하는 게 대충 열 개보다 낫다, 만삣삐!';

  @override
  String get pushupKneeName => '무릎 푸시업';

  @override
  String get pushupKneeDesc => '차드 여정의 첫 걸음. 부끄러워하지 마라, 모든 전설은 여기서 시작된다!';

  @override
  String get pushupKneeBenefits =>
      '• 기본 근력 향상\\n• 올바른 푸시업 폼 학습\\n• 어깨와 팔 안정성 강화\\n• 기본 푸시업으로의 단계적 진행';

  @override
  String get pushupKneeInstructions =>
      '1. 무릎을 바닥에 대고 시작하라\\n2. 발목을 들어올려라\\n3. 상체는 기본 푸시업과 동일하게\\n4. 무릎에서 머리까지 일직선 유지\\n5. 천천히 확실하게 움직여라, 만삣삐!';

  @override
  String get pushupKneeMistakes =>
      '• 엉덩이가 뒤로 빠짐\\n• 무릎 위치가 너무 앞쪽\\n• 상체만 움직이고 코어 사용 안 함\\n• 너무 빠르게 동작함';

  @override
  String get pushupKneeBreathing => '부드럽고 꾸준한 호흡으로 시작해라. 급하게 하지 마라, 만삣삐!';

  @override
  String get pushupKneeChad =>
      '시작이 반이다, you idiot! 완벽한 폼으로 무릎 푸시업부터 마스터해라. 기초가 탄탄해야 차드가 된다!';

  @override
  String get pushupInclineName => '인클라인 푸시업';

  @override
  String get pushupInclineDesc => '높은 곳에 손을 올리고 하는 푸시업. 계단을 올라가듯 차드로 진화한다!';

  @override
  String get pushupInclineBenefits =>
      '• 부담을 줄여 폼 완성\\n• 하부 가슴근육 강화\\n• 어깨 안정성 향상\\n• 기본 푸시업으로의 징검다리';

  @override
  String get pushupInclineInstructions =>
      '1. 벤치나 의자에 손을 올려라\\n2. 몸을 비스듬히 기울여라\\n3. 발가락부터 머리까지 일직선\\n4. 높을수록 쉬워진다, 만삣삐\\n5. 점차 낮은 곳으로 도전해라!';

  @override
  String get pushupInclineMistakes =>
      '• 엉덩이가 위로 솟음\\n• 손목에 과도한 체중\\n• 불안정한 지지대 사용\\n• 각도를 너무 급하게 낮춤';

  @override
  String get pushupInclineBreathing =>
      '각도가 편해진 만큼 호흡도 편안하게. 하지만 집중력은 최고로, you idiot!';

  @override
  String get pushupInclineChad =>
      '높이는 조절하고 강도는 최대로! 완벽한 폼으로 20개 하면 바닥으로 내려갈 준비 완료다, 만삣삐!';

  @override
  String get pushupWideGripName => '와이드 그립 푸시업';

  @override
  String get pushupWideGripDesc => '손 간격을 넓혀서 가슴을 더 넓게 만드는 푸시업. 차드의 가슴판을 키운다!';

  @override
  String get pushupWideGripBenefits =>
      '• 가슴 바깥쪽 근육 집중 발달\\n• 어깨 안정성 향상\\n• 가슴 넓이 확장\\n• 상체 전체적인 균형 발달';

  @override
  String get pushupWideGripInstructions =>
      '1. 손을 어깨보다 1.5배 넓게 벌려라\\n2. 손가락은 약간 바깥쪽을 향하게\\n3. 가슴이 바닥에 닿을 때까지\\n4. 팔꿈치는 45도 각도 유지\\n5. 넓은 가슴으로 밀어올려라, 만삣삐!';

  @override
  String get pushupWideGripMistakes =>
      '• 손을 너무 넓게 벌림\\n• 팔꿈치가 완전히 바깥쪽\\n• 어깨에 무리가 가는 자세\\n• 가슴을 충분히 내리지 않음';

  @override
  String get pushupWideGripBreathing =>
      '넓은 가슴으로 깊게 숨쉬어라. 가슴이 확장되는 걸 느껴라, you idiot!';

  @override
  String get pushupWideGripChad =>
      '넓은 가슴은 차드의 상징이다! 와이드 그립으로 진짜 남자다운 가슴을 만들어라, 만삣삐!';

  @override
  String get pushupDiamondName => '다이아몬드 푸시업';

  @override
  String get pushupDiamondDesc => '손가락으로 다이아몬드를 만들어 하는 푸시업. 삼두근을 다이아몬드처럼 단단하게!';

  @override
  String get pushupDiamondBenefits =>
      '• 삼두근 집중 강화\\n• 가슴 안쪽 근육 발달\\n• 팔 전체 근력 향상\\n• 코어 안정성 증가';

  @override
  String get pushupDiamondInstructions =>
      '1. 엄지와 검지로 다이아몬드 모양 만들어라\\n2. 가슴 중앙 아래에 손 위치\\n3. 팔꿈치는 몸에 가깝게 유지\\n4. 가슴이 손에 닿을 때까지\\n5. 삼두근 힘으로 밀어올려라, 만삣삐!';

  @override
  String get pushupDiamondMistakes =>
      '• 손목에 과도한 압력\\n• 팔꿈치가 너무 벌어짐\\n• 몸이 비틀어짐\\n• 다이아몬드 모양이 부정확함';

  @override
  String get pushupDiamondBreathing => '집중해서 호흡해라. 삼두근이 불타는 걸 느껴라, you idiot!';

  @override
  String get pushupDiamondChad =>
      '다이아몬드만큼 단단한 팔을 만들어라! 이거 10개만 완벽하게 해도 진짜 차드 인정, 만삣삐!';

  @override
  String get pushupDeclineName => '디클라인 푸시업';

  @override
  String get pushupDeclineDesc => '발을 높이 올리고 하는 푸시업. 중력을 이겨내는 진짜 차드들의 운동!';

  @override
  String get pushupDeclineBenefits =>
      '• 상부 가슴근육 집중 발달\\n• 어깨 전면 강화\\n• 코어 안정성 최대 강화\\n• 전신 근력 향상';

  @override
  String get pushupDeclineInstructions =>
      '1. 발을 벤치나 의자에 올려라\\n2. 손은 어깨 아래 정확히\\n3. 몸은 아래쪽으로 기울어진 직선\\n4. 중력의 저항을 이겨내라\\n5. 강하게 밀어올려라, 만삣삐!';

  @override
  String get pushupDeclineMistakes =>
      '• 발 위치가 불안정\\n• 엉덩이가 아래로 처짐\\n• 목에 무리가 가는 자세\\n• 균형을 잃고 비틀어짐';

  @override
  String get pushupDeclineBreathing =>
      '중력과 싸우면서도 안정된 호흡을 유지해라. 진짜 파워는 여기서 나온다, you idiot!';

  @override
  String get pushupDeclineChad =>
      '중력따위 개무시하고 밀어올려라! 디클라인 마스터하면 어깨가 바위가 된다, 만삣삐!';

  @override
  String get pushupArcherName => '아처 푸시업';

  @override
  String get pushupArcherDesc => '활을 당기듯 한쪽으로 기울여 하는 푸시업. 정확성과 파워를 동시에!';

  @override
  String get pushupArcherBenefits =>
      '• 한쪽 팔 집중 강화\\n• 좌우 균형 발달\\n• 원핸드 푸시업 준비\\n• 코어 회전 안정성 강화';

  @override
  String get pushupArcherInstructions =>
      '1. 와이드 그립으로 시작하라\\n2. 한쪽으로 체중을 기울여라\\n3. 한 팔은 굽히고 다른 팔은 쭉\\n4. 활시위 당기듯 정확하게\\n5. 양쪽을 번갈아가며, 만삣삐!';

  @override
  String get pushupArcherMistakes =>
      '• 몸이 비틀어짐\\n• 쭉 편 팔에도 힘이 들어감\\n• 좌우 동작이 불균등\\n• 코어가 흔들림';

  @override
  String get pushupArcherBreathing =>
      '활시위 당기듯 집중해서 호흡해라. 정확성이 생명이다, you idiot!';

  @override
  String get pushupArcherChad => '정확한 아처가 원핸드로 가는 지름길이다! 양쪽 균등하게 마스터해라, 만삣삐!';

  @override
  String get pushupPikeName => '파이크 푸시업';

  @override
  String get pushupPikeDesc => '역삼각형 자세로 하는 푸시업. 어깨를 바위로 만드는 차드의 비밀!';

  @override
  String get pushupPikeBenefits =>
      '• 어깨 전체 근육 강화\\n• 핸드스탠드 푸시업 준비\\n• 상체 수직 힘 발달\\n• 코어와 균형감 향상';

  @override
  String get pushupPikeInstructions =>
      '1. 다운독 자세로 시작하라\\n2. 엉덩이를 최대한 위로\\n3. 머리가 바닥에 가까워질 때까지\\n4. 어깨 힘으로만 밀어올려라\\n5. 역삼각형을 유지하라, 만삣삐!';

  @override
  String get pushupPikeMistakes =>
      '• 엉덩이가 충분히 올라가지 않음\\n• 팔꿈치가 옆으로 벌어짐\\n• 머리로만 지탱하려 함\\n• 발 위치가 너무 멀거나 가까움';

  @override
  String get pushupPikeBreathing => '거꾸로 된 자세에서도 안정된 호흡. 어깨에 집중해라, you idiot!';

  @override
  String get pushupPikeChad => '파이크 마스터하면 핸드스탠드도 문제없다! 어깨 차드로 진화하라, 만삣삐!';

  @override
  String get pushupClapName => '박수 푸시업';

  @override
  String get pushupClapDesc => '폭발적인 힘으로 박수를 치는 푸시업. 진짜 파워는 여기서 증명된다!';

  @override
  String get pushupClapBenefits =>
      '• 폭발적인 근력 발달\\n• 전신 파워 향상\\n• 순간 반응속도 증가\\n• 진짜 차드의 증명';

  @override
  String get pushupClapInstructions =>
      '1. 기본 푸시업 자세로 시작\\n2. 폭발적으로 밀어올려라\\n3. 공중에서 박수를 쳐라\\n4. 안전하게 착지하라\\n5. 연속으로 도전해라, 만삣삐!';

  @override
  String get pushupClapMistakes =>
      '• 충분한 높이로 올라가지 않음\\n• 착지할 때 손목 부상 위험\\n• 폼이 흐트러짐\\n• 무리한 연속 시도';

  @override
  String get pushupClapBreathing =>
      '폭발할 때 강하게 내뱉고, 착지 후 빠르게 호흡 정리. 리듬이 중요하다, you idiot!';

  @override
  String get pushupClapChad =>
      '박수 푸시업은 진짜 파워의 증명이다! 한 번이라도 성공하면 너는 이미 차드, 만삣삐!';

  @override
  String get pushupOneArmName => '원핸드 푸시업';

  @override
  String get pushupOneArmDesc => '한 손으로만 하는 궁극의 푸시업. 기가 차드만이 도달할 수 있는 영역!';

  @override
  String get pushupOneArmBenefits =>
      '• 궁극의 상체 근력\\n• 완벽한 코어 컨트롤\\n• 전신 균형과 조정력\\n• 기가 차드의 완성';

  @override
  String get pushupOneArmInstructions =>
      '1. 다리를 넓게 벌려 균형잡아라\\n2. 한 손은 등 뒤로\\n3. 코어에 모든 힘을 집중\\n4. 천천히 확실하게\\n5. 기가 차드의 자격을 증명하라!';

  @override
  String get pushupOneArmMistakes =>
      '• 다리가 너무 좁음\\n• 몸이 비틀어지며 회전\\n• 반대 손으로 지탱\\n• 무리한 도전으로 부상';

  @override
  String get pushupOneArmBreathing =>
      '깊고 안정된 호흡으로 집중력을 최고조로. 모든 에너지를 하나로, you idiot!';

  @override
  String get pushupOneArmChad =>
      '원핸드 푸시업은 차드의 완성형이다! 이거 한 번이라도 하면 진짜 기가 차드 인정, fxxk yeah!';

  @override
  String get selectLevelButton => '레벨을 선택해라, 만삣삐!';

  @override
  String startWithLevel(String level) {
    return '$level로 차드 되기 시작!';
  }

  @override
  String profileCreated(int sessions) {
    return '차드 프로필 생성 완료! ($sessions개 세션 준비됨, 만삣삐!)';
  }

  @override
  String profileCreationError(String error) {
    return '프로필 생성 실패, 다시 해봐! 오류: $error';
  }
}
