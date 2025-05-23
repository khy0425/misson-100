// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '⚡ ALPHA BATTLEGROUND ⚡';

  @override
  String get repLogMessage => 'WEAK RECORD NUMBERS. STRONG MAKE HISTORY 💪';

  @override
  String targetRepsLabel(int count) {
    return 'TARGET: $count REPS';
  }

  @override
  String get performanceGodTier => 'GOD MODE UNLOCKED! 👑';

  @override
  String get performanceStrong => 'IRON BOWS TO YOUR MIGHT! 🔱';

  @override
  String get performanceMedium => 'WEAKNESS FLEES FROM YOU! ⚡';

  @override
  String get performanceStart => 'LEGEND HAS BEGUN! 🦍';

  @override
  String get performanceMotivation => 'YOU CAN DO IT, JUST DO IT! 🔥';

  @override
  String get motivationGod =>
      'YOUR MUSCLES HAVE REACHED DIVINE REALM. WEAKNESS IS DEAD ⚡👑';

  @override
  String get motivationStrong =>
      'QUITTING IS EXCUSE FOR THE WEAK. GO HARDER! 🔱💪';

  @override
  String get motivationMedium =>
      'YOUR LIMITS ARE JUST YOUR THOUGHTS. DESTROY THEM! 🦍⚡';

  @override
  String get motivationGeneral =>
      'TODAY\'S SWEAT IS TOMORROW\'S GLORY. NEVER GIVE UP! 🔥💪';

  @override
  String get setCompletedSuccess => 'ANOTHER MYTH IS BORN! 🔥👑';

  @override
  String get setCompletedGood => 'ANOTHER LIMIT DESTROYED! ⚡🔱';

  @override
  String resultFormat(int reps, int percentage) {
    return 'LEGEND RANK: $reps REPS ($percentage%) 🏆';
  }

  @override
  String get quickInputPerfect => 'GOD TIER';

  @override
  String get quickInputStrong => 'ALPHA POWER';

  @override
  String get quickInputMedium => 'TITAN STEPS';

  @override
  String get quickInputStart => 'WARRIOR CRY';

  @override
  String get quickInputBeast => 'LIMIT BREAKER';

  @override
  String get restTimeTitle => 'ALPHA RECHARGE TIME ⚡';

  @override
  String get restMessage =>
      'REST IS ALSO GROWTH. NEXT WILL BE MORE DESTRUCTIVE 🦍';

  @override
  String get skipRestButton =>
      'REST? ONLY FOR THE WEAK! BRING THE NEXT VICTIM!';

  @override
  String get nextSetButton => 'UNIVERSE CONQUERED!';

  @override
  String get nextSetContinue => 'BRING THE NEXT SACRIFICE!';

  @override
  String get guidanceMessage => 'YOUR BODY OBEYS YOUR COMMANDS! 🔱';

  @override
  String get completeSetButton => 'ASCEND TO LEGEND!';

  @override
  String get completeSetContinue => 'DESTROY ANOTHER ONE!';

  @override
  String get exitDialogTitle => 'RETREAT FROM BATTLE?';

  @override
  String get exitDialogMessage =>
      'WARRIORS NEVER QUIT MID-BATTLE!\nYOUR CONQUEST WILL BE LOST!';

  @override
  String get exitDialogContinue => 'KEEP FIGHTING!';

  @override
  String get exitDialogRetreat => 'RETREAT...';

  @override
  String get workoutCompleteTitle => '🔥 BEAST MODE COMPLETED! 👑';

  @override
  String workoutCompleteMessage(String title, int totalReps) {
    return '$title COMPLETELY DESTROYED!\nTOTAL POWER UNLEASHED: $totalReps REPS! ⚡';
  }

  @override
  String get workoutCompleteButton => 'LEGENDARY!';

  @override
  String setFormat(int current, int total) {
    return 'SET $current/$total';
  }

  @override
  String get levelSelectionTitle => '💪 LEVEL CHECK';

  @override
  String get levelSelectionHeader => '🏋️‍♂️ CHOOSE YOUR LEVEL NOW!';

  @override
  String get levelSelectionDescription =>
      'Select your current max pushup count level!\nCustom 6-week program for goal achievement!';

  @override
  String get rookieLevelTitle => 'BEGINNER (STARTING PUSH)';

  @override
  String get rookieLevelSubtitle => 'Under 6 pushups - Build from basics';

  @override
  String get rookieLevelDescription =>
      'Pushups still hard? No problem! Every chad starts here!';

  @override
  String get rookieFeature1 => 'Start with knee pushups';

  @override
  String get rookieFeature2 => 'Form-focused training';

  @override
  String get rookieFeature3 => 'Gradual intensity increase';

  @override
  String get rookieFeature4 => 'Build basic fitness';

  @override
  String get risingLevelTitle => 'INTERMEDIATE (ALPHA WANNABE)';

  @override
  String get risingLevelSubtitle => '6-10 pushups - Growing into chad';

  @override
  String get risingLevelDescription =>
      'Got the basics! Time to train like a real chad!';

  @override
  String get risingFeature1 => 'Master standard pushups';

  @override
  String get risingFeature2 => 'Various training types';

  @override
  String get risingFeature3 => 'Build muscle endurance';

  @override
  String get risingFeature4 => 'Systematic progression';

  @override
  String get alphaLevelTitle => 'ADVANCED (CHAD TERRITORY)';

  @override
  String get alphaLevelSubtitle => '11+ pushups - Already chad material';

  @override
  String get alphaLevelDescription =>
      'Already this good? You\'re on the chad path! Let\'s reach giga chad!';

  @override
  String get alphaFeature1 => 'Advanced pushup variations';

  @override
  String get alphaFeature2 => 'Explosive power training';

  @override
  String get alphaFeature3 => 'Plyometric exercises';

  @override
  String get alphaFeature4 => 'Complete giga chad course';

  @override
  String get rookieShort => 'PUSH';

  @override
  String get risingShort => 'ALPHA WANNABE';

  @override
  String get alphaShort => 'CHAD';

  @override
  String get gigaShort => 'GIGA CHAD';

  @override
  String get homeTitle => 'CHAD DASHBOARD';

  @override
  String get welcomeMessage => 'WELCOME, 만삣삐!';

  @override
  String get dailyMotivation => 'START ANOTHER DAY OF GETTING STRONGER!';

  @override
  String get startTodayWorkout => 'START TODAY\'S WORKOUT';

  @override
  String get weekProgress => 'THIS WEEK\'S PROGRESS';

  @override
  String progressWeekDay(int week, int totalDays, int completedDays) {
    return 'WEEK $week - $completedDays of $totalDays DAYS COMPLETED';
  }

  @override
  String get bottomMotivation =>
      '💪 GROW LITTLE BY LITTLE, CONSISTENTLY EVERY DAY!';

  @override
  String workoutStartError(String error) {
    return 'CANNOT START WORKOUT: $error';
  }

  @override
  String get errorGeneral => 'AN ERROR OCCURRED. PLEASE TRY AGAIN.';

  @override
  String get errorDatabase => 'DATABASE ERROR OCCURRED.';

  @override
  String get errorNetwork => 'PLEASE CHECK YOUR NETWORK CONNECTION.';

  @override
  String get errorNotFound => 'DATA NOT FOUND.';

  @override
  String get successWorkoutCompleted =>
      'WORKOUT COMPLETED! ONE STEP CLOSER TO CHAD.';

  @override
  String get successProfileSaved => 'PROFILE SAVED.';

  @override
  String get successSettingsSaved => 'SETTINGS SAVED.';

  @override
  String get firstWorkoutMessage =>
      'THE CHAD JOURNEY BEGINS WITH YOUR FIRST WORKOUT!';

  @override
  String get weekCompletedMessage => 'WEEK COMPLETED! CHAD POWER ASCENDING!';

  @override
  String get programCompletedMessage =>
      'CONGRATULATIONS! YOU\'VE BECOME A TRUE GIGA CHAD!';

  @override
  String get streakStartMessage => 'CHAD STREAK HAS BEGUN!';

  @override
  String get streakContinueMessage => 'CHAD STREAK CONTINUES!';

  @override
  String get streakBrokenMessage => 'STREAK IS BROKEN, BUT CHAD RISES AGAIN!';

  @override
  String get chadTitleSleepy => 'SLEEPY CHAD';

  @override
  String get chadTitleBasic => 'BASIC CHAD';

  @override
  String get chadTitleCoffee => 'COFFEE CHAD';

  @override
  String get chadTitleFront => 'FRONT CHAD';

  @override
  String get chadTitleCool => 'COOL CHAD';

  @override
  String get chadTitleLaser => 'LASER CHAD';

  @override
  String get chadTitleDouble => 'DOUBLE CHAD';

  @override
  String get levelNameRookie => 'ROOKIE CHAD';

  @override
  String get levelNameRising => 'RISING CHAD';

  @override
  String get levelNameAlpha => 'ALPHA CHAD';

  @override
  String get levelNameGiga => 'GIGA CHAD';

  @override
  String get levelDescRookie =>
      'ROOKIE CHAD STARTING THE PUSH-UP JOURNEY.\nGET STRONGER WITH CONSISTENT PRACTICE!';

  @override
  String get levelDescRising =>
      'RISING CHAD WITH SOLID FUNDAMENTALS.\nMOVING TOWARDS HIGHER GOALS!';

  @override
  String get levelDescAlpha =>
      'ALPHA CHAD WITH CONSIDERABLE SKILLS.\nALREADY ACHIEVED GREAT PROGRESS!';

  @override
  String get levelDescGiga =>
      'ULTIMATE GIGA CHAD LEVEL.\nAMAZING SKILLS POSSESSED!';

  @override
  String get levelMotivationRookie =>
      'ALL CHADS START HERE!\nEXPERIENCE AMAZING TRANSFORMATION AFTER 6 WEEKS!';

  @override
  String get levelMotivationRising => 'GOOD START!\nBECOME A STRONGER CHAD!';

  @override
  String get levelMotivationAlpha =>
      'EXCELLENT SKILLS!\nRUN TO 100 TARGET, FXXK IDIOT!';

  @override
  String get levelMotivationGiga =>
      'ALREADY A POWERFUL CHAD!\nGO FOR PERFECT 100!';

  @override
  String get levelGoalRookie => 'GOAL: 100 CONSECUTIVE PUSH-UPS AFTER 6 WEEKS!';

  @override
  String get levelGoalRising => 'GOAL: GROW INTO A STRONGER CHAD!';

  @override
  String get levelGoalAlpha => 'GOAL: PERFECT FORM 100 REPS!';

  @override
  String get levelGoalGiga => 'GOAL: BECOME CHAD MASTER!';

  @override
  String get workoutButtonUltimate => 'CLAIM ULTIMATE VICTORY!';

  @override
  String get workoutButtonConquer => 'CONQUER THIS SET!';

  @override
  String get motivationMessage1 => 'REAL CHADS DON\'T MAKE EXCUSES, FXXK IDIOT';

  @override
  String get motivationMessage2 => 'PUSH LIKE A CHAD, REST LIKE A SIGMA';

  @override
  String get motivationMessage3 => 'EVERY REP BRINGS YOU CLOSER TO CHAD';

  @override
  String get motivationMessage4 => 'CHAD ENERGY IS BUILDING UP';

  @override
  String get motivationMessage5 => 'YOU\'RE EVOLVING INTO A CHAD, FXXK YEAH!';

  @override
  String get motivationMessage6 => 'CHAD MODE: ACTIVATED 💪';

  @override
  String get motivationMessage7 => 'THIS IS HOW CHADS ARE MADE';

  @override
  String get motivationMessage8 => 'FEEL THE CHAD POWER FLOWING';

  @override
  String get motivationMessage9 => 'CHAD TRANSFORMATION IN PROGRESS, YOU IDIOT';

  @override
  String get motivationMessage10 => 'WELCOME TO THE CHAD BROTHERHOOD';

  @override
  String get completionMessage1 =>
      'THAT\'S WHAT I\'M TALKING ABOUT, FXXK YEAH!';

  @override
  String get completionMessage2 => 'CHAD VIBES ARE STRONG TODAY';

  @override
  String get completionMessage3 => 'ANOTHER STEP CLOSER TO CHAD';

  @override
  String get completionMessage4 => 'YOU\'RE BECOMING MORE CHAD-LIKE, YOU IDIOT';

  @override
  String get completionMessage5 => 'CHAD ENERGY LEVEL: RISING ⚡';

  @override
  String get completionMessage6 => 'RESPECT. YOU EARNED IT';

  @override
  String get completionMessage7 => 'CHAD APPROVES THIS WORKOUT';

  @override
  String get completionMessage8 =>
      'YOU JUST LEVELED UP YOUR CHAD GAME, FXXK IDIOT';

  @override
  String get completionMessage9 => 'PURE CHAD PERFORMANCE RIGHT THERE';

  @override
  String get completionMessage10 => 'WELCOME TO ANOTHER DAY OF BEING CHAD';

  @override
  String get encouragementMessage1 => 'EVEN CHADS HAVE TOUGH DAYS';

  @override
  String get encouragementMessage2 => 'TOMORROW IS ANOTHER CHANCE TO BE CHAD';

  @override
  String get encouragementMessage3 => 'CHAD DOESN\'T GIVE UP, FXXK IDIOT';

  @override
  String get encouragementMessage4 => 'THIS IS JUST CHAD TRAINING MODE';

  @override
  String get encouragementMessage5 => 'REAL CHADS KEEP PUSHING';

  @override
  String get encouragementMessage6 => 'CHAD SPIRIT NEVER DIES';

  @override
  String get encouragementMessage7 =>
      'YOU\'RE STILL ON THE CHAD PATH, YOU IDIOT';

  @override
  String get encouragementMessage8 => 'CHAD COMEBACK INCOMING';

  @override
  String get encouragementMessage9 => 'EVERY CHAD FACES CHALLENGES';

  @override
  String get encouragementMessage10 =>
      'CHAD RESILIENCE IS YOUR STRENGTH, FXXK YEAH!';

  @override
  String get chadMessage0 => 'TIME TO WAKE UP';

  @override
  String get chadMessage1 => 'NOW IT BEGINS, YOU IDIOT';

  @override
  String get chadMessage2 => 'ENERGY IS CHARGED, FXXK YEAH!';

  @override
  String get chadMessage3 => 'CONFIDENCE IS BUILDING';

  @override
  String get chadMessage4 => 'NOW YOU LOOK COOL, YOU IDIOT';

  @override
  String get chadMessage5 => 'CHAD AURA IS DETECTED';

  @override
  String get chadMessage6 => 'TRUE GIGA CHAD IS BORN, FXXK IDIOT!';

  @override
  String get tutorialTitle => 'CHAD PUSHUP DOJO';

  @override
  String get tutorialSubtitle => 'REAL CHADS START WITH PERFECT FORM! 💪';

  @override
  String get tutorialButton => 'BECOME PUSHUP MASTER';

  @override
  String get difficultyBeginner => 'BEGINNER - STARTING CHADS';

  @override
  String get difficultyIntermediate => 'INTERMEDIATE - GROWING CHADS';

  @override
  String get difficultyAdvanced => 'ADVANCED - POWERFUL CHADS';

  @override
  String get difficultyExtreme => 'EXTREME - GIGA CHAD TERRITORY';

  @override
  String get targetMuscleChest => 'CHEST';

  @override
  String get targetMuscleTriceps => 'TRICEPS';

  @override
  String get targetMuscleShoulders => 'SHOULDERS';

  @override
  String get targetMuscleCore => 'CORE';

  @override
  String get targetMuscleFull => 'FULL BODY';

  @override
  String caloriesPerRep(int calories) {
    return '${calories}kcal/rep';
  }

  @override
  String get tutorialDetailTitle => 'MASTER CHAD FORM';

  @override
  String get benefitsSection => '💪 HOW YOU GET STRONGER';

  @override
  String get instructionsSection => '⚡ CHAD EXECUTION';

  @override
  String get mistakesSection => '❌ WEAKLING MISTAKES';

  @override
  String get breathingSection => '🌪️ CHAD BREATHING';

  @override
  String get chadMotivationSection => '🔥 CHAD\'S ADVICE';

  @override
  String get pushupStandardName => 'STANDARD PUSHUP';

  @override
  String get pushupStandardDesc =>
      'THE STARTING POINT OF ALL CHADS. PERFECT BASICS ARE TRUE STRENGTH!';

  @override
  String get pushupStandardBenefits =>
      '• FULL CHEST DEVELOPMENT\\n• TRICEPS AND SHOULDER STRENGTH\\n• BASIC FITNESS IMPROVEMENT\\n• FOUNDATION FOR ALL PUSHUPS, YOU IDIOT!';

  @override
  String get pushupStandardInstructions =>
      '1. START IN PLANK POSITION\\n2. HANDS SHOULDER-WIDTH APART\\n3. KEEP BODY IN STRAIGHT LINE\\n4. LOWER CHEST TO FLOOR\\n5. PUSH UP POWERFULLY, CHAD STYLE!';

  @override
  String get pushupStandardMistakes =>
      '• BUTT STICKING UP - WEAKLING MOVE\\n• NOT LOWERING CHEST FULLY\\n• NECK FORWARD\\n• WRISTS AHEAD OF SHOULDERS\\n• INCONSISTENT TEMPO, FXXK IDIOT!';

  @override
  String get pushupStandardBreathing =>
      'INHALE DOWN, EXHALE UP POWERFULLY. BREATHING IS POWER!';

  @override
  String get pushupStandardChad =>
      'BASICS ARE THE HARDEST, YOU IDIOT. ONE PERFECT REP BEATS TEN SLOPPY ONES!';

  @override
  String get pushupKneeName => 'KNEE PUSHUP';

  @override
  String get pushupKneeDesc =>
      'FIRST STEP OF CHAD JOURNEY. DON\'T BE ASHAMED, ALL LEGENDS START HERE!';

  @override
  String get pushupKneeBenefits =>
      '• BASIC STRENGTH IMPROVEMENT\\n• LEARN PROPER PUSHUP FORM\\n• SHOULDER AND ARM STABILITY\\n• PROGRESSION TO STANDARD PUSHUP';

  @override
  String get pushupKneeInstructions =>
      '1. START ON KNEES\\n2. LIFT ANKLES UP\\n3. UPPER BODY SAME AS STANDARD\\n4. STRAIGHT LINE FROM KNEES TO HEAD\\n5. MOVE SLOWLY AND SURELY!';

  @override
  String get pushupKneeMistakes =>
      '• BUTT SAGGING BACK\\n• KNEES TOO FAR FORWARD\\n• ONLY MOVING UPPER BODY\\n• MOVING TOO FAST';

  @override
  String get pushupKneeBreathing =>
      'SMOOTH, STEADY BREATHING TO START. DON\'T RUSH!';

  @override
  String get pushupKneeChad =>
      'STARTING IS HALF THE BATTLE, YOU IDIOT! MASTER KNEE PUSHUPS WITH PERFECT FORM FIRST!';

  @override
  String get pushupInclineName => 'INCLINE PUSHUP';

  @override
  String get pushupInclineDesc =>
      'HANDS ON HIGH SURFACE. CLIMB THE STAIRS TO CHAD STATUS!';

  @override
  String get pushupInclineBenefits =>
      '• REDUCED LOAD FOR FORM PERFECTION\\n• LOWER CHEST STRENGTHENING\\n• SHOULDER STABILITY\\n• BRIDGE TO STANDARD PUSHUP';

  @override
  String get pushupInclineInstructions =>
      '1. HANDS ON BENCH OR CHAIR\\n2. LEAN BODY AT ANGLE\\n3. STRAIGHT LINE TOE TO HEAD\\n4. HIGHER = EASIER\\n5. GRADUALLY GO LOWER!';

  @override
  String get pushupInclineMistakes =>
      '• BUTT STICKING UP\\n• TOO MUCH WEIGHT ON WRISTS\\n• UNSTABLE SUPPORT\\n• LOWERING ANGLE TOO QUICKLY';

  @override
  String get pushupInclineBreathing =>
      'COMFORTABLE BREATHING WITH EASIER ANGLE. BUT MAXIMUM FOCUS, YOU IDIOT!';

  @override
  String get pushupInclineChad =>
      'ADJUST HEIGHT, MAXIMIZE INTENSITY! 20 PERFECT REPS MEANS YOU\'RE READY FOR FLOOR!';

  @override
  String get pushupWideGripName => 'WIDE GRIP PUSHUP';

  @override
  String get pushupWideGripDesc =>
      'SPREAD HANDS WIDE FOR BROADER CHEST. BUILD THAT CHAD CHEST PLATE!';

  @override
  String get pushupWideGripBenefits =>
      '• OUTER CHEST FOCUS\\n• SHOULDER STABILITY\\n• CHEST WIDTH EXPANSION\\n• OVERALL UPPER BODY BALANCE';

  @override
  String get pushupWideGripInstructions =>
      '1. HANDS 1.5X SHOULDER WIDTH\\n2. FINGERS SLIGHTLY OUTWARD\\n3. CHEST TO FLOOR\\n4. ELBOWS AT 45 DEGREES\\n5. PUSH WITH WIDE CHEST!';

  @override
  String get pushupWideGripMistakes =>
      '• HANDS TOO WIDE\\n• ELBOWS COMPLETELY OUT\\n• SHOULDER STRAIN\\n• NOT LOWERING CHEST ENOUGH';

  @override
  String get pushupWideGripBreathing =>
      'BREATHE DEEP WITH WIDE CHEST. FEEL THE EXPANSION, YOU IDIOT!';

  @override
  String get pushupWideGripChad =>
      'WIDE CHEST IS CHAD SYMBOL! BUILD THAT MANLY CHEST WITH WIDE GRIP!';

  @override
  String get pushupDiamondName => 'DIAMOND PUSHUP';

  @override
  String get pushupDiamondDesc =>
      'HANDS IN DIAMOND SHAPE. MAKE TRICEPS DIAMOND-HARD!';

  @override
  String get pushupDiamondBenefits =>
      '• TRICEPS FOCUS\\n• INNER CHEST DEVELOPMENT\\n• FULL ARM STRENGTH\\n• CORE STABILITY INCREASE';

  @override
  String get pushupDiamondInstructions =>
      '1. MAKE DIAMOND WITH THUMBS AND FINGERS\\n2. HANDS BELOW CHEST CENTER\\n3. ELBOWS CLOSE TO BODY\\n4. CHEST TO HANDS\\n5. PUSH WITH TRICEPS POWER!';

  @override
  String get pushupDiamondMistakes =>
      '• EXCESSIVE WRIST PRESSURE\\n• ELBOWS TOO WIDE\\n• BODY TWISTING\\n• INACCURATE DIAMOND SHAPE';

  @override
  String get pushupDiamondBreathing =>
      'FOCUSED BREATHING. FEEL THE TRICEPS BURN, YOU IDIOT!';

  @override
  String get pushupDiamondChad =>
      'MAKE ARMS DIAMOND-HARD! 10 PERFECT REPS GETS REAL CHAD RECOGNITION!';

  @override
  String get pushupDeclineName => 'DECLINE PUSHUP';

  @override
  String get pushupDeclineDesc =>
      'FEET ELEVATED HIGH. REAL CHADS DEFEAT GRAVITY!';

  @override
  String get pushupDeclineBenefits =>
      '• UPPER CHEST FOCUS\\n• FRONT SHOULDER STRENGTHENING\\n• MAXIMUM CORE STABILITY\\n• FULL BODY STRENGTH';

  @override
  String get pushupDeclineInstructions =>
      '1. FEET ON BENCH OR CHAIR\\n2. HANDS DIRECTLY UNDER SHOULDERS\\n3. STRAIGHT LINE ANGLED DOWN\\n4. OVERCOME GRAVITY\'S RESISTANCE\\n5. PUSH UP POWERFULLY!';

  @override
  String get pushupDeclineMistakes =>
      '• UNSTABLE FOOT POSITION\\n• BUTT SAGGING DOWN\\n• NECK STRAIN\\n• LOSING BALANCE';

  @override
  String get pushupDeclineBreathing =>
      'STABLE BREATHING WHILE FIGHTING GRAVITY. REAL POWER COMES FROM HERE, YOU IDIOT!';

  @override
  String get pushupDeclineChad =>
      'IGNORE GRAVITY AND PUSH UP! MASTER DECLINE AND YOUR SHOULDERS BECOME ROCKS!';

  @override
  String get pushupArcherName => 'ARCHER PUSHUP';

  @override
  String get pushupArcherDesc =>
      'LEAN TO ONE SIDE LIKE DRAWING A BOW. ACCURACY AND POWER COMBINED!';

  @override
  String get pushupArcherBenefits =>
      '• ONE ARM FOCUS\\n• LEFT-RIGHT BALANCE\\n• ONE-ARM PUSHUP PREPARATION\\n• CORE ROTATIONAL STABILITY';

  @override
  String get pushupArcherInstructions =>
      '1. START WITH WIDE GRIP\\n2. LEAN WEIGHT TO ONE SIDE\\n3. ONE ARM BENT, OTHER STRAIGHT\\n4. PRECISE LIKE BOWSTRING\\n5. ALTERNATE BOTH SIDES!';

  @override
  String get pushupArcherMistakes =>
      '• BODY TWISTING\\n• FORCE IN STRAIGHT ARM\\n• UNEVEN LEFT-RIGHT MOVEMENT\\n• CORE SHAKING';

  @override
  String get pushupArcherBreathing =>
      'FOCUSED BREATHING LIKE DRAWING BOW. ACCURACY IS LIFE, YOU IDIOT!';

  @override
  String get pushupArcherChad =>
      'PRECISE ARCHER IS THE SHORTCUT TO ONE-ARM! MASTER BOTH SIDES EQUALLY!';

  @override
  String get pushupPikeName => 'PIKE PUSHUP';

  @override
  String get pushupPikeDesc =>
      'INVERTED TRIANGLE POSITION. CHAD\'S SECRET TO ROCK SHOULDERS!';

  @override
  String get pushupPikeBenefits =>
      '• FULL SHOULDER STRENGTHENING\\n• HANDSTAND PUSHUP PREPARATION\\n• VERTICAL UPPER BODY POWER\\n• CORE AND BALANCE IMPROVEMENT';

  @override
  String get pushupPikeInstructions =>
      '1. START IN DOWNWARD DOG\\n2. BUTT AS HIGH AS POSSIBLE\\n3. HEAD CLOSE TO FLOOR\\n4. PUSH WITH SHOULDER POWER ONLY\\n5. MAINTAIN INVERTED TRIANGLE!';

  @override
  String get pushupPikeMistakes =>
      '• BUTT NOT HIGH ENOUGH\\n• ELBOWS OUT TO SIDES\\n• SUPPORTING WITH HEAD ONLY\\n• FEET TOO FAR OR CLOSE';

  @override
  String get pushupPikeBreathing =>
      'STABLE BREATHING IN INVERTED POSITION. FOCUS ON SHOULDERS, YOU IDIOT!';

  @override
  String get pushupPikeChad =>
      'MASTER PIKE AND HANDSTAND IS NO PROBLEM! EVOLVE INTO SHOULDER CHAD!';

  @override
  String get pushupClapName => 'CLAP PUSHUP';

  @override
  String get pushupClapDesc =>
      'EXPLOSIVE POWER TO CLAP. REAL POWER IS PROVEN HERE!';

  @override
  String get pushupClapBenefits =>
      '• EXPLOSIVE STRENGTH DEVELOPMENT\\n• FULL BODY POWER\\n• INSTANT REACTION SPEED\\n• PROOF OF REAL CHAD';

  @override
  String get pushupClapInstructions =>
      '1. START IN STANDARD POSITION\\n2. EXPLODE UP\\n3. CLAP IN AIR\\n4. LAND SAFELY\\n5. TRY CONSECUTIVELY!';

  @override
  String get pushupClapMistakes =>
      '• NOT ENOUGH HEIGHT\\n• WRIST INJURY RISK ON LANDING\\n• FORM BREAKDOWN\\n• EXCESSIVE CONSECUTIVE ATTEMPTS';

  @override
  String get pushupClapBreathing =>
      'EXPLOSIVE EXHALE UP, QUICK BREATHING RESET AFTER LANDING. RHYTHM IS KEY, YOU IDIOT!';

  @override
  String get pushupClapChad =>
      'CLAP PUSHUP IS PROOF OF REAL POWER! ONE SUCCESS MAKES YOU ALREADY CHAD!';

  @override
  String get pushupOneArmName => 'ONE-ARM PUSHUP';

  @override
  String get pushupOneArmDesc =>
      'ULTIMATE PUSHUP WITH ONE HAND. ONLY GIGA CHADS CAN REACH THIS REALM!';

  @override
  String get pushupOneArmBenefits =>
      '• ULTIMATE UPPER BODY STRENGTH\\n• PERFECT CORE CONTROL\\n• FULL BODY BALANCE AND COORDINATION\\n• GIGA CHAD COMPLETION';

  @override
  String get pushupOneArmInstructions =>
      '1. SPREAD LEGS WIDE FOR BALANCE\\n2. ONE HAND BEHIND BACK\\n3. FOCUS ALL POWER IN CORE\\n4. SLOW AND SURE\\n5. PROVE YOUR GIGA CHAD QUALIFICATION!';

  @override
  String get pushupOneArmMistakes =>
      '• LEGS TOO NARROW\\n• BODY TWISTING AND ROTATING\\n• SUPPORTING WITH OTHER HAND\\n• INJURY FROM EXCESSIVE ATTEMPT';

  @override
  String get pushupOneArmBreathing =>
      'DEEP, STABLE BREATHING FOR MAXIMUM FOCUS. UNITE ALL ENERGY, YOU IDIOT!';

  @override
  String get pushupOneArmChad =>
      'ONE-ARM PUSHUP IS THE ULTIMATE CHAD FORM! DO THIS ONCE AND YOU\'RE A TRUE GIGA CHAD, FXXK YEAH!';

  @override
  String get selectLevelButton => 'CHOOSE YOUR LEVEL!';

  @override
  String startWithLevel(String level) {
    return 'START AS $level!';
  }

  @override
  String profileCreated(int sessions) {
    return 'CHAD PROFILE CREATED! ($sessions sessions ready!)';
  }

  @override
  String profileCreationError(String error) {
    return 'PROFILE CREATION FAILED! TRY AGAIN! ERROR: $error';
  }
}
