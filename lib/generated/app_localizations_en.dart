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
  String get performanceGodTier =>
      '🚀 ABSOLUTE PERFECTION! ULTRA GOD EMPEROR BEYOND GODS! 👑';

  @override
  String get performanceStrong =>
      '🔱 IRON BOWS TO YOUR MIGHT! NOW GRAVITY SURRENDERS TO YOU! LEGENDARY BEAST! 🔱';

  @override
  String get performanceMedium =>
      '⚡ GOOD! WEAKNESS IS FLEEING! ALPHA STORM INCOMING! ⚡';

  @override
  String get performanceStart =>
      '💥 BEGINNING IS HALF? WRONG! LEGEND\'S GATE ALREADY OPENED, YOU FUTURE EMPEROR! 💥';

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
  String get quickInputPerfect => '🚀 GODLIKE ACHIEVED 🚀';

  @override
  String get quickInputStrong => '👑 EMPEROR POWER 👑';

  @override
  String get quickInputMedium => '⚡ ALPHA STEPS ⚡';

  @override
  String get quickInputStart => '🔥 LEGENDARY CRY 🔥';

  @override
  String get quickInputBeast => '💥 LIMIT DESTROYER 💥';

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
  String get rookieLevelTitle => 'Rookie';

  @override
  String get rookieLevelSubtitle => 'Under 6 pushups - Build from basics';

  @override
  String get rookieLevelDescription => 'Chad who starts slowly';

  @override
  String get rookieFeature1 => 'Start with knee pushups';

  @override
  String get rookieFeature2 => 'Form-focused training';

  @override
  String get rookieFeature3 => 'Gradual intensity increase';

  @override
  String get rookieFeature4 => 'Build basic fitness';

  @override
  String get risingLevelTitle => 'Rising';

  @override
  String get risingLevelSubtitle => '6-10 pushups - Growing into chad';

  @override
  String get risingLevelDescription => 'Chad who is growing';

  @override
  String get risingFeature1 => 'Master standard pushups';

  @override
  String get risingFeature2 => 'Various training types';

  @override
  String get risingFeature3 => 'Build muscle endurance';

  @override
  String get risingFeature4 => 'Systematic progression';

  @override
  String get alphaLevelTitle => 'Alpha';

  @override
  String get alphaLevelSubtitle => '11+ pushups - Already chad material';

  @override
  String get alphaLevelDescription => 'Ultimate Chad';

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
  String get homeTitle => '💥 ALPHA EMPEROR COMMAND CENTER 💥';

  @override
  String get welcomeMessage =>
      '🔥 WELCOME, FUTURE EMPEROR! TIME FOR WORLD DOMINATION! 🔥';

  @override
  String get dailyMotivation =>
      '⚡ ANOTHER DAY OF LEGENDARY BEAST MODE! CRUSH THE UNIVERSE! ⚡';

  @override
  String get startTodayWorkout => '🚀 START TODAY\'S DOMINATION! 🚀';

  @override
  String get weekProgress => '👑 EMPEROR\'S CONQUEST PROGRESS 👑';

  @override
  String progressWeekDay(int week, int totalDays, int completedDays) {
    return 'WEEK $week - $completedDays of $totalDays DAYS COMPLETED';
  }

  @override
  String get bottomMotivation =>
      '🔥 GROW A LITTLE? WRONG! DAILY LEGENDARY LEVEL UP! 💪';

  @override
  String workoutStartError(String error) {
    return '⚡ ALPHA SYSTEM ERROR! RETRY, FUTURE EMPEROR: $error ⚡';
  }

  @override
  String get errorGeneral =>
      '🦁 TEMPORARY OBSTACLE DETECTED! REAL EMPERORS TRY AGAIN! 🦁';

  @override
  String get errorDatabase =>
      '💥 DATA FORTRESS UNDER ATTACK! TECH CHADS FIXING NOW! 💥';

  @override
  String get errorNetwork =>
      '🌪️ CHECK NETWORK CONNECTION! ALPHA CONNECTION REQUIRED! 🌪️';

  @override
  String get errorNotFound =>
      '🔱 DATA NOT FOUND! TIME TO CREATE NEW LEGENDS! 🔱';

  @override
  String get successWorkoutCompleted =>
      '🚀 WORKOUT DOMINATION COMPLETE! ANOTHER LEGENDARY ACHIEVEMENT! 🚀';

  @override
  String get successProfileSaved =>
      '👑 EMPEROR PROFILE SAVED! YOUR LEGEND IS RECORDED! 👑';

  @override
  String get successSettingsSaved =>
      '⚡ ALPHA SETTINGS LOCKED! PERFECT CONFIG ARMED! ⚡';

  @override
  String get firstWorkoutMessage =>
      '🔥 ALPHA JOURNEY BEGINS! LEGENDARY TRANSFORMATION STARTS TODAY! 🔥';

  @override
  String get weekCompletedMessage =>
      '👑 WEEK COMPLETE DOMINATION! CHAD POWER LEVEL MASSIVELY INCREASED! 👑';

  @override
  String get programCompletedMessage =>
      '🚀 CONGRATULATIONS! TRUE ULTRA GIGA CHAD EMPEROR BORN! UNIVERSE BOWS! 🚀';

  @override
  String get streakStartMessage =>
      '⚡ CHAD STREAK ACTIVATED! CONQUEST MODE ENGAGED! ⚡';

  @override
  String get streakContinueMessage =>
      '🔱 STREAK DOMINATION CONTINUES! UNSTOPPABLE ALPHA FORCE! 🔱';

  @override
  String get streakBrokenMessage =>
      '🦁 STREAK BROKEN? NO MATTER! REAL EMPERORS RETURN STRONGER! 🦁';

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
      '🔥 ROOKIE CHAD STARTING PUSHUP JOURNEY TO BECOME FUTURE EMPEROR.\nSTEADY PRACTICE EVOLVES INTO LEGENDARY BEAST! 🔥';

  @override
  String get levelDescRising =>
      '⚡ RISING CHAD WITH SOLID FUNDAMENTALS, ASCENDING ALPHA.\nDOMINATING TOWARDS HIGHER GOALS! ⚡';

  @override
  String get levelDescAlpha =>
      '👑 ALPHA CHAD WITH CONSIDERABLE ALPHA EMPEROR SKILLS.\nALREADY ACHIEVED MANY LEGENDARY ACCOMPLISHMENTS! 👑';

  @override
  String get levelDescGiga =>
      '🚀 ULTIMATE ULTRA GIGA CHAD EMPEROR LEVEL.\nPOSSESSES AMAZING GODLIKE POWER! 🚀';

  @override
  String get levelMotivationRookie =>
      '🔥 ALL EMPERORS START HERE!\nEXPERIENCE MIND-BLOWING TRANSFORMATION AFTER 6 WEEKS! 🔥';

  @override
  String get levelMotivationRising =>
      '⚡ EXCELLENT START!\nBECOME STRONGER ALPHA BEAST! ⚡';

  @override
  String get levelMotivationAlpha =>
      '👑 OUTSTANDING PERFORMANCE!\nDOMINATE TO 100 TARGET, FXXK LIMITS! 👑';

  @override
  String get levelMotivationGiga =>
      '🚀 ALREADY POWERFUL GIGA CHAD!\nCONQUER THE PERFECT 100! 🚀';

  @override
  String get levelGoalRookie =>
      '🔥 GOAL: 100 CONSECUTIVE PUSHUPS ABSOLUTE DOMINATION AFTER 6 WEEKS! 🔥';

  @override
  String get levelGoalRising =>
      '⚡ GOAL: STRONGER ALPHA CHAD LEGENDARY EVOLUTION! ⚡';

  @override
  String get levelGoalAlpha =>
      '👑 GOAL: PERFECT FORM 100 REPS PERFECT EXECUTION! 👑';

  @override
  String get levelGoalGiga =>
      '🚀 GOAL: ULTIMATE CHAD MASTER UNIVERSE DOMINATION! 🚀';

  @override
  String get workoutButtonUltimate => 'CLAIM ULTIMATE VICTORY!';

  @override
  String get workoutButtonConquer => 'CONQUER THIS SET!';

  @override
  String get motivationMessage1 =>
      '🔥 REAL ALPHAS BURN EXCUSES ALIVE, FXXK THE WEAKNESS! 🔥';

  @override
  String get motivationMessage2 =>
      '⚡ CONQUER LIKE CHAD, DOMINATE LIKE SIGMA! REST IS STRATEGY ⚡';

  @override
  String get motivationMessage3 => '💪 EVERY REP ELEVATES YOU TO GOD TIER! 💪';

  @override
  String get motivationMessage4 =>
      '⚡ CHAD ENERGY 100% CHARGED! NOW CONQUER THE WORLD! ⚡';

  @override
  String get motivationMessage5 =>
      '🚀 NOT CHAD EVOLUTION! NOW LEGEND TRANSFORMATION, FXXK YEAH! 🚀';

  @override
  String get motivationMessage6 =>
      '👑 CHAD MODE? PAST THAT! NOW EMPEROR MODE: ACTIVATED! 👑';

  @override
  String get motivationMessage7 =>
      '🌪️ THIS IS HOW LEGENDS ARE BORN! HISTORY WILL REMEMBER YOU! 🌪️';

  @override
  String get motivationMessage8 =>
      '⚡ NOT CHAD POWER... NOW ALPHA LIGHTNING FLOWS THROUGH YOUR BODY! ⚡';

  @override
  String get motivationMessage9 =>
      '🔱 CHAD TRANSFORMATION COMPLETE! NOW EVOLVED TO ULTIMATE APEX PREDATOR! 🔱';

  @override
  String get motivationMessage10 =>
      '🦁 CHAD BROTHERHOOD? NO! BOW TO THE ALPHA EMPIRE EMPEROR! 🦁';

  @override
  String get completionMessage1 =>
      '🔥 THAT\'S IT! ABSOLUTE DOMINATION, FXXK YEAH! 🔥';

  @override
  String get completionMessage2 =>
      '⚡ ALPHA STORM HIT TODAY! THE WORLD IS TREMBLING! ⚡';

  @override
  String get completionMessage3 =>
      '👑 NOT CLOSER TO CHAD... NOW SURPASSED CHAD! 👑';

  @override
  String get completionMessage4 =>
      '🚀 CHAD-LIKE? WRONG! NOW LEGENDARY BEAST MODE, YOU MONSTER! 🚀';

  @override
  String get completionMessage5 =>
      '⚡ CHAD ENERGY LEVEL: ∞ INFINITY BREAKTHROUGH! UNIVERSE BOWS! ⚡';

  @override
  String get completionMessage6 =>
      '🦁 RESPECT? PAST THAT! NOW THE WHOLE WORLD BOWS TO YOU! 🦁';

  @override
  String get completionMessage7 =>
      '🔱 CHAD APPROVES? NO! GOD TIER ACKNOWLEDGES BIRTH! 🔱';

  @override
  String get completionMessage8 =>
      '🌪️ CHAD GAME LEVEL UP? WRONG! CONQUERED ALPHA DIMENSION, FXXK BEAST! 🌪️';

  @override
  String get completionMessage9 =>
      '💥 NOT PURE CHAD PERFORMANCE... NOW PURE LEGENDARY DOMINANCE! 💥';

  @override
  String get completionMessage10 =>
      '👑 CHAD\'S DAY? NO! EMPEROR OF ALPHAS EMPIRE BUILDING COMPLETE! 👑';

  @override
  String get encouragementMessage1 =>
      '🔥 ALPHAS HAVE TRIALS TOO! BUT THAT MAKES YOU STRONGER! 🔥';

  @override
  String get encouragementMessage2 =>
      '⚡ TOMORROW IS LEGENDARY COMEBACK DAY! WORLD WILL SEE YOUR RESURRECTION! ⚡';

  @override
  String get encouragementMessage3 =>
      '👑 REAL EMPERORS NEVER SURRENDER, FXXK THE LIMITS! 👑';

  @override
  String get encouragementMessage4 =>
      '🚀 THIS IS JUST ULTIMATE BOSS FIGHT MODE! YOU ALREADY WON! 🚀';

  @override
  String get encouragementMessage5 =>
      '🦁 REAL APEX PREDATORS RETURN STRONGER! 🦁';

  @override
  String get encouragementMessage6 =>
      '🔱 ALPHA SPIRIT IS IMMORTAL! EVEN IF UNIVERSE ENDS, YOU SURVIVE! 🔱';

  @override
  String get encouragementMessage7 =>
      '⚡ STILL LEGEND TRANSFORMATION IN PROGRESS, YOU ABSOLUTE UNIT! ⚡';

  @override
  String get encouragementMessage8 =>
      '🌪️ EPIC COMEBACK STORM INCOMING! WORLD TREMBLES AWAITING YOUR RETURN! 🌪️';

  @override
  String get encouragementMessage9 =>
      '💥 ALL EMPERORS PASS THROUGH TRIALS! THIS IS THE ROYAL PATH! 💥';

  @override
  String get encouragementMessage10 =>
      '👑 NOT CHAD RESILIENCE... NOW IMMORTAL PHOENIX POWER, FXXK YEAH! 👑';

  @override
  String get chadMessage0 =>
      '🛌 Wake up, future Chad! Your journey begins now!';

  @override
  String get chadMessage1 =>
      '😎 Your basics are getting solid! This is the real start of Chad!';

  @override
  String get chadMessage2 =>
      '☕ Energy overflowing! You\'ve got power stronger than coffee!';

  @override
  String get chadMessage3 =>
      '🔥 Frontal breakthrough! No obstacle can stop you!';

  @override
  String get chadMessage4 =>
      '🕶️ Coolness is in your bones! True alpha appearance!';

  @override
  String get chadMessage5 =>
      '⚡ You can change the world with just your eyes! Legend begins!';

  @override
  String get chadMessage6 =>
      '👑 Ultimate Chad complete! Conquer the universe with double power!';

  @override
  String get tutorialTitle => '🔥 ALPHA EMPEROR PUSHUP DOJO 🔥';

  @override
  String get tutorialSubtitle => 'REAL EMPERORS START WITH DIFFERENT FORM! 💪';

  @override
  String get tutorialButton => '💥 BECOME PUSHUP MASTER 💥';

  @override
  String get difficultyBeginner => '🔥 FUTURE EMPEROR - STARTING ALPHAS 🔥';

  @override
  String get difficultyIntermediate => '⚡ ALPHA RISING - GROWING BEASTS ⚡';

  @override
  String get difficultyAdvanced => '👑 EMPEROR MODE - POWERFUL CHADS 👑';

  @override
  String get difficultyExtreme =>
      '🚀 ULTRA GIGA CHAD - LEGENDARY GODLIKE TERRITORY 🚀';

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
  String get tutorialDetailTitle => '💥 MASTER EMPEROR FORM 💥';

  @override
  String get benefitsSection => '🚀 HOW YOU BECOME LEGENDARY BEAST 🚀';

  @override
  String get instructionsSection => '⚡ EMPEROR EXECUTION METHOD ⚡';

  @override
  String get mistakesSection => '❌ WEAKLINGS\' PATHETIC MISTAKES ❌';

  @override
  String get breathingSection => '��️ ALPHA EMPEROR BREATHING 🌪️';

  @override
  String get chadMotivationSection => '🔥 EMPEROR\'S ULTIMATE WISDOM 🔥';

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
      '🔥 BASICS HARDEST? WRONG! ONE PERFECT FORM CONQUERS THE WORLD! MASTER THE BASICS! 🔥';

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
      '⚡ BEGINNING IS HALF? NO! ALPHA JOURNEY ALREADY STARTED! KNEE PUSHUPS ARE EMPEROR\'S PATH TOO! ⚡';

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
      '🚀 ADJUST HEIGHT, MAX INTENSITY! 20 PERFECT REPS = GOD TIER ENTRY TICKET! 🚀';

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
      '🦁 WIDE CHEST? NO! NOW LEGENDARY GORILLA CHEST! DOMINATE WORLD WITH WIDE GRIP! 🦁';

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
      '💎 HARDER THAN DIAMOND ARMS? WRONG! NOW UNBREAKABLE TITANIUM ARMS! 10 REPS = REAL BEAST RECOGNITION! 💎';

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
      '🌪️ IGNORE GRAVITY? SURE! NOW DOMINATE PHYSICS LAWS! DECLINE = GODLIKE SHOULDERS! 🌪️';

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
      '🏹 PRECISE ARCHER = ONE-ARM SHORTCUT? YES! MASTER BOTH SIDES = LEGENDARY ARCHER EMPEROR! 🏹';

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
      '⚡ PIKE MASTER = HANDSTAND? SURE! EVOLVE TO SHOULDER EMPEROR! ⚡';

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
      '👏 CLAP PUSHUP = POWER PROOF? NO! NOW EXPLOSIVE THUNDER POWER EXPRESSION! 👏';

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
      '🚀 ONE-ARM = CHAD COMPLETION? WRONG! NOW ULTIMATE APEX GOD EMPEROR BIRTH, FXXK YEAH! 🚀';

  @override
  String get selectLevelButton => '🔥 CHOOSE YOUR LEVEL, FUTURE EMPEROR! 🔥';

  @override
  String startWithLevel(String level) {
    return '💥 START EMPEROR JOURNEY AS $level! 💥';
  }

  @override
  String profileCreated(int sessions) {
    return '🚀 EMPEROR PROFILE CREATION COMPLETE! ($sessions DOMINATION SESSIONS READY!) 🚀';
  }

  @override
  String profileCreationError(String error) {
    return '⚡ PROFILE CREATION FAILED! TRY AGAIN, ALPHA! ERROR: $error ⚡';
  }

  @override
  String get achievementFirstJourney => 'Chad Journey Begins';

  @override
  String get achievementFirstJourneyDesc => 'Complete your first pushup';

  @override
  String get achievementPerfectSet => 'Perfect First Set';

  @override
  String get achievementPerfectSetDesc =>
      'Complete a set achieving 100% of target';

  @override
  String get achievementCenturion => 'Centurion';

  @override
  String get achievementCenturionDesc => 'Achieve a total of 100 pushups';

  @override
  String get achievementWeekWarrior => 'Week Warrior';

  @override
  String get achievementWeekWarriorDesc => 'Work out for 7 consecutive days';

  @override
  String get achievementIronWill => 'Iron Will';

  @override
  String get achievementIronWillDesc => 'Achieved 200 pushups in one go';

  @override
  String get achievementSpeedDemon => 'Speed Demon';

  @override
  String get achievementSpeedDemonDesc =>
      'Completed 50 pushups in under 5 minutes';

  @override
  String get achievementPushupMaster => 'Pushup Master';

  @override
  String get achievementPushupMasterDesc => 'Achieve a total of 1000 pushups';

  @override
  String get achievementConsistency => 'King of Consistency';

  @override
  String get achievementConsistencyDesc => 'Work out for 30 consecutive days';

  @override
  String get achievementBeastMode => 'Beast Mode';

  @override
  String get achievementBeastModeDesc => 'Exceed target by 150%';

  @override
  String get achievementMarathoner => 'Marathoner';

  @override
  String get achievementMarathonerDesc => 'Achieve a total of 5000 pushups';

  @override
  String get achievementLegend => 'Legend';

  @override
  String get achievementLegendDesc => 'Achieve a total of 10000 pushups';

  @override
  String get achievementPerfectionist => 'Perfectionist';

  @override
  String get achievementPerfectionistDesc => 'Achieve 10 perfect sets';

  @override
  String get achievementEarlyBird => 'Early Bird';

  @override
  String get achievementEarlyBirdDesc => 'Worked out 5 times before 7 AM';

  @override
  String get achievementNightOwl => 'Night Owl';

  @override
  String get achievementNightOwlDesc => 'Worked out 5 times after 10 PM';

  @override
  String get achievementOverachiever => 'Overachiever';

  @override
  String get achievementOverachieverDesc => 'Achieved 150% of goal 5 times';

  @override
  String get achievementEndurance => 'Endurance King';

  @override
  String get achievementEnduranceDesc => 'Work out for over 30 minutes';

  @override
  String get achievementVariety => 'Master of Variety';

  @override
  String get achievementVarietyDesc => 'Complete 5 different pushup types';

  @override
  String get achievementDedication => 'Dedication';

  @override
  String get achievementDedicationDesc => 'Work out for 100 consecutive days';

  @override
  String get achievementUltimate => 'Ultimate Chad';

  @override
  String get achievementUltimateDesc => 'Achieve all achievements';

  @override
  String get achievementGodMode => 'God Mode';

  @override
  String get achievementGodModeDesc => 'Achieve over 500 reps in one session';

  @override
  String get achievementRarityCommon => 'Common';

  @override
  String get achievementRarityRare => 'Rare';

  @override
  String get achievementRarityEpic => 'Epic';

  @override
  String get achievementRarityLegendary => 'Legendary';

  @override
  String get achievementRarityMythic => 'Mythic';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get achievements => 'Achievements';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get chadShorts => 'Chad Shorts 🔥';

  @override
  String get settingsTitle => '⚙️ Chad Settings';

  @override
  String get settingsSubtitle => 'Customize your Chad journey';

  @override
  String get workoutSettings => '💪 Workout Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get appearanceSettings => '🎨 Appearance Settings';

  @override
  String get dataSettings => '💾 Data Management';

  @override
  String get aboutSettings => 'ℹ️ App Info';

  @override
  String get difficultySettings => 'Difficulty Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDesc => 'Receive all app notifications';

  @override
  String get achievementNotifications => 'Achievement Notifications';

  @override
  String get achievementNotificationsDesc =>
      'Get notified when you unlock new achievements';

  @override
  String get workoutReminders => 'Workout Reminders';

  @override
  String get workoutRemindersDesc => 'Daily reminders at your set time';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get reminderTimeDesc => 'Set the time for workout notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Use dark theme';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get dataBackup => 'Data Backup';

  @override
  String get dataBackupDesc => 'Backup your workout records and achievements';

  @override
  String get dataRestore => 'Data Restore';

  @override
  String get dataRestoreDesc => 'Restore backed up data';

  @override
  String get dataReset => 'Data Reset';

  @override
  String get dataResetDesc => 'Delete all data';

  @override
  String get versionInfo => 'Version Info';

  @override
  String get versionInfoDesc => 'Mission: 100 v1.0.0';

  @override
  String get developerInfo => 'Developer Info';

  @override
  String get developerInfoDesc => 'Join the journey to become Chad';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get sendFeedbackDesc => 'Share your thoughts with us';

  @override
  String get common => 'Common';

  @override
  String get rare => 'Rare';

  @override
  String get epic => 'Epic';

  @override
  String get legendary => 'Legendary';

  @override
  String unlockedAchievements(int count) {
    return 'Unlocked Achievements ($count)';
  }

  @override
  String lockedAchievements(int count) {
    return 'Locked Achievements ($count)';
  }

  @override
  String get noAchievementsYet => 'No achievements yet';

  @override
  String get startWorkoutForAchievements =>
      'Start working out to unlock your first achievement!';

  @override
  String get allAchievementsUnlocked => 'All achievements unlocked!';

  @override
  String get congratulationsChad => 'Congratulations! You are a true Chad! 🎉';

  @override
  String get achievementsBannerText =>
      'Unlock achievements and become a Chad! 🏆';

  @override
  String get totalExperience => 'Total XP';

  @override
  String get noWorkoutRecords => 'No workout records yet!';

  @override
  String get startFirstWorkout =>
      'Start your first workout and\\ncreate your Chad legend! 🔥';

  @override
  String get loadingStatistics => 'Loading Chad\'s statistics...';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String workoutCount(int count) {
    return '$count times';
  }

  @override
  String get chadDays => 'Chad days!';

  @override
  String get totalPushups => 'Total Pushups';

  @override
  String pushupsCount(int count) {
    return '$count reps';
  }

  @override
  String get realChadPower => 'Real Chad power!';

  @override
  String get averageCompletion => 'Average Completion';

  @override
  String completionPercentage(int percentage) {
    return '$percentage%';
  }

  @override
  String get perfectExecution => 'Perfect execution!';

  @override
  String get thisMonthWorkouts => 'This Month';

  @override
  String get consistentChad => 'Consistent Chad!';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String streakDays(int days) {
    return '$days days';
  }

  @override
  String get bestRecord => 'Best Record';

  @override
  String get recentWorkouts => 'Recent Workouts';

  @override
  String repsAchieved(int reps, int percentage) {
    return '$reps reps • $percentage% achieved';
  }

  @override
  String get checkChadGrowth => 'Check Chad\'s growth! 📊';

  @override
  String workoutRecordForDate(int month, int day) {
    return '$month/$day Workout Record';
  }

  @override
  String get noWorkoutRecordForDate => 'No workout record for this date';

  @override
  String get calendarBannerText => 'Consistency is Chad power! 📅';

  @override
  String workoutHistoryLoadError(String error) {
    return 'Error loading workout history: $error';
  }

  @override
  String get completed => 'Complete!';

  @override
  String get current => 'Current';

  @override
  String get half => 'Half';

  @override
  String get exceed => 'Exceed';

  @override
  String get target => 'Target';

  @override
  String get loadingChadVideos => 'Loading Chad videos... 🔥';

  @override
  String videoLoadError(String error) {
    return 'Error loading videos: $error';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get like => 'Like';

  @override
  String get share => 'Share';

  @override
  String get save => 'Save';

  @override
  String get workout => 'Workout';

  @override
  String get likeMessage => 'Liked! 💪';

  @override
  String get shareMessage => 'Sharing 📤';

  @override
  String get saveMessage => 'Saved 📌';

  @override
  String get workoutStartMessage => 'Workout started! 🔥';

  @override
  String get swipeUpHint => 'Swipe up for next video';

  @override
  String get pushupHashtag => '#Pushup';

  @override
  String get chadHashtag => '#Chad';

  @override
  String get perfectPushupForm => 'Perfect Pushup Form 💪';

  @override
  String get pushupVariations => 'Pushup Variations 🔥';

  @override
  String get chadSecrets => 'Chad Secrets ⚡';

  @override
  String get pushup100Challenge => '100 Pushup Challenge 🎯';

  @override
  String get homeWorkoutPushups => 'Home Workout Pushups 🏠';

  @override
  String get strengthSecrets => 'Strength Secrets 💯';

  @override
  String get correctPushupFormDesc =>
      'Effective workout with proper pushup form';

  @override
  String get variousPushupStimulation =>
      'Stimulate muscles with various pushup variations';

  @override
  String get trueChadMindset => 'Mindset to become a true Chad';

  @override
  String get challengeSpirit100 => 'Challenge spirit towards 100 pushups';

  @override
  String get perfectHomeWorkout => 'Perfect workout you can do at home';

  @override
  String get consistentStrengthImprovement =>
      'Improve strength through consistent exercise';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get chest => 'Chest';

  @override
  String get triceps => 'Triceps';

  @override
  String get shoulders => 'Shoulders';

  @override
  String get core => 'Core';

  @override
  String get fullBody => 'Full Body';

  @override
  String get restTimeSettings => 'Rest Time Settings';

  @override
  String get restTimeDesc => 'Set rest time between sets';

  @override
  String get soundSettings => 'Sound Settings';

  @override
  String get soundSettingsDesc => 'Enable workout sound effects';

  @override
  String get vibrationSettings => 'Vibration Settings';

  @override
  String get vibrationSettingsDesc => 'Enable vibration feedback';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get dataManagementDesc => '운동 기록 백업 및 복원';

  @override
  String get appInfo => '앱 정보';

  @override
  String get appInfoDesc => '버전 정보 및 개발자 정보';

  @override
  String get seconds => 'seconds';

  @override
  String get minutes => 'minutes';

  @override
  String get motivationMessages => 'Motivation Messages';

  @override
  String get motivationMessagesDesc =>
      'Show motivational messages during workout';

  @override
  String get autoStartNextSet => 'Auto Start Next Set';

  @override
  String get autoStartNextSetDesc => 'Automatically start next set after rest';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc => 'View privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceDesc => 'View terms of service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get openSourceLicensesDesc => 'View open source licenses';

  @override
  String get resetConfirmTitle => 'Reset All Data';

  @override
  String get resetConfirmMessage =>
      'Are you sure you want to delete all data? This action cannot be undone.';

  @override
  String get dataResetConfirm => '정말로 모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get dataResetComingSoon => '데이터 초기화 기능은 곧 제공될 예정입니다.';

  @override
  String get resetSuccess => 'All data has been reset successfully';

  @override
  String get backupSuccess => 'Data backup completed successfully';

  @override
  String get restoreSuccess => 'Data restore completed successfully';

  @override
  String get selectTime => 'Select Time';

  @override
  String currentDifficulty(String difficulty, String description) {
    return 'Current: $difficulty - $description';
  }

  @override
  String currentLanguage(String language) {
    return 'Current: $language';
  }

  @override
  String get darkModeEnabled => 'Dark mode enabled';

  @override
  String get lightModeEnabled => 'Light mode enabled';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language!';
  }

  @override
  String difficultyChanged(String difficulty) {
    return 'Difficulty changed to $difficulty!';
  }

  @override
  String get dataBackupComingSoon => 'Data backup feature coming soon!';

  @override
  String get dataRestoreComingSoon => 'Data restore feature coming soon!';

  @override
  String get feedbackComingSoon => 'Feedback feature coming soon!';

  @override
  String reminderTimeChanged(String time) {
    return 'Reminder time changed to $time!';
  }

  @override
  String get notificationPermissionRequired =>
      '🔔 Notification Permission Required';

  @override
  String get notificationPermissionMessage =>
      'Notification permission is required to receive push notifications.';

  @override
  String get notificationPermissionFeatures =>
      '• Workout reminders\n• Achievement notifications\n• Motivational messages';

  @override
  String get notificationPermissionRequest =>
      'Please allow notification permission in settings.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get comingSoon => '🚀 Coming Soon';

  @override
  String get difficultySettingsTitle => '💪 Difficulty Settings';

  @override
  String get notificationPermissionGranted =>
      'Notification permission granted! 🎉';

  @override
  String get settingsBannerText => 'Customize Chad\'s settings! ⚙️';

  @override
  String buildInfo(String buildNumber) {
    return 'Build: $buildNumber';
  }

  @override
  String versionAndBuild(String version, String buildNumber) {
    return 'Version $version+$buildNumber';
  }

  @override
  String get madeWithLove => 'Made with ❤️ for Chad';

  @override
  String get joinChadJourney => 'Join the journey to become Chad';

  @override
  String get supportChadJourney => 'Support your Chad journey! 🔥';

  @override
  String get selectLanguage => 'Please select a language to use';

  @override
  String get progress => 'Progress';

  @override
  String get description => 'Description';

  @override
  String percentComplete(int percentage) {
    return '$percentage% complete';
  }

  @override
  String get koreanLanguage => 'Korean';

  @override
  String get englishLanguage => 'English';

  @override
  String get notificationPermissionGrantedMessage =>
      '🎉 Notification permission granted! Start your Chad journey!';

  @override
  String get notificationPermissionDeniedMessage =>
      '⚠️ Notification permission is required. Please allow it in settings.';

  @override
  String get notificationPermissionErrorMessage =>
      'An error occurred while requesting permission.';

  @override
  String get notificationPermissionLaterMessage =>
      'You can allow notifications later in settings.';

  @override
  String get videoCannotOpen =>
      'Cannot open video. Please check your YouTube app.';

  @override
  String get advertisement => 'Advertisement';

  @override
  String get chadLevel => 'Chad Level';

  @override
  String get progressVisualization => 'Progress Visualization';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get monthlyGoal => 'Monthly Goal';

  @override
  String get streakProgress => 'Streak Progress';

  @override
  String get workoutChart => 'Workout Chart';

  @override
  String get days => 'days';

  @override
  String get monthlyProgress => 'Monthly Progress';

  @override
  String get thisMonth => 'This Month';

  @override
  String get noWorkoutThisDay => 'No workout records for this day';

  @override
  String get legend => 'Legend';

  @override
  String get perfect => 'Perfect';

  @override
  String get good => 'Good';

  @override
  String get okay => 'Okay';

  @override
  String get poor => 'Poor';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get times => 'times';

  @override
  String get count => 'count';

  @override
  String get noWorkoutHistory => 'No workout history';

  @override
  String get noChartData => 'No chart data available';

  @override
  String get noPieChartData => 'No pie chart data available';

  @override
  String get month => 'month';

  @override
  String get dailyWorkoutReminder => 'Daily Workout Reminder';

  @override
  String get streakEncouragement => 'Streak Encouragement';

  @override
  String get streakEncouragementSubtitle =>
      'Encouragement message after 3 consecutive workouts';

  @override
  String get notificationSetupFailed => 'Failed to set up notification';

  @override
  String get streakNotificationSet =>
      'Streak encouragement notification has been set!';

  @override
  String dailyNotificationSet(Object time) {
    return 'Daily workout reminder set for $time!';
  }

  @override
  String get dailyReminderSubtitle => 'Daily workout reminder at set time';

  @override
  String get adFallbackMessage => 'Join the journey to become a Chad! 💪';

  @override
  String get testAdMessage => 'Test Ad - Fitness App';

  @override
  String get achievementCelebrationMessage => 'Feel the power of Chad! 💪';

  @override
  String get workoutScreenAdMessage => 'Feel the power of Chad! 💪';

  @override
  String get achievementScreenAdMessage => 'Achieve and become Chad! 🏆';

  @override
  String get tutorialAdviceBasic => 'Basics are the most important, bro!';

  @override
  String get tutorialAdviceStart => 'Starting is half the battle!';

  @override
  String get tutorialAdviceForm => 'Perfect form makes perfect Chad!';

  @override
  String get tutorialAdviceConsistency =>
      'Consistency is the key to Chad power!';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String dateFormatYearMonthDay(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get achievementUltimateMotivation => 'You are the ultimate Chad! 🌟';

  @override
  String get achievementFirst50Title => 'First 50 Breakthrough';

  @override
  String get achievementFirst50Desc =>
      'Achieved 50 pushups in a single workout';

  @override
  String get achievementFirst50Motivation =>
      '50 breakthrough! Chad\'s foundation is getting solid! 🎊';

  @override
  String get achievementFirst100SingleTitle => '100 in One Go';

  @override
  String get achievementFirst100SingleDesc =>
      'Achieved 100 pushups in a single workout';

  @override
  String get achievementFirst100SingleMotivation =>
      '100 in one go! True power Chad! 💥';

  @override
  String get achievementStreak3Title => '3-Day Streak Chad';

  @override
  String get achievementStreak3Desc =>
      'Completed workouts for 3 consecutive days';

  @override
  String get achievementStreak3Motivation => 'Consistency makes a Chad! 🔥';

  @override
  String get achievementStreak7Title => 'Weekly Chad';

  @override
  String get achievementStreak7Desc =>
      'Completed workouts for 7 consecutive days';

  @override
  String get achievementStreak7Motivation =>
      'True Chad who conquered the week! 💪';

  @override
  String get achievementStreak14Title => '2-Week Marathon Chad';

  @override
  String get achievementStreak14Desc =>
      'Completed workouts for 14 consecutive days';

  @override
  String get achievementStreak14Motivation =>
      'King of persistence! Chad among Chads! 🏃‍♂️';

  @override
  String get achievementStreak30Title => 'Monthly Ultimate Chad';

  @override
  String get achievementStreak30Desc =>
      'Completed workouts for 30 consecutive days';

  @override
  String get achievementStreak30Motivation =>
      'You are now the King of Chads! 👑';

  @override
  String get achievementStreak60Title => '2-Month Legend Chad';

  @override
  String get achievementStreak60Desc =>
      'Completed workouts for 60 consecutive days';

  @override
  String get achievementStreak60Motivation =>
      '2 months straight! You are a legend! 🏅';

  @override
  String get achievementStreak100Title => '100-Day Mythical Chad';

  @override
  String get achievementStreak100Desc =>
      'Completed workouts for 100 consecutive days';

  @override
  String get achievementStreak100Motivation =>
      '100 days straight! You are a living myth! 🌟';

  @override
  String get achievementTotal50Title => 'First 50 Total';

  @override
  String get achievementTotal50Desc => 'Completed a total of 50 pushups';

  @override
  String get achievementTotal50Motivation =>
      'First 50! Chad\'s sprout is growing! 🌱';

  @override
  String get achievementTotal100Title => 'First 100 Breakthrough';

  @override
  String get achievementTotal100Desc => 'Completed a total of 100 pushups';

  @override
  String get achievementTotal100Motivation =>
      'First 100 breakthrough! Chad\'s foundation complete! 💯';

  @override
  String get achievementTotal250Title => '250 Chad';

  @override
  String get achievementTotal250Desc => 'Completed a total of 250 pushups';

  @override
  String get achievementTotal250Motivation => '250! Result of consistency! 🎯';

  @override
  String get achievementTotal500Title => '500 Chad';

  @override
  String get achievementTotal500Desc => 'Completed a total of 500 pushups';

  @override
  String get achievementTotal500Motivation =>
      '500 breakthrough! Intermediate Chad achieved! 🚀';

  @override
  String get achievementTotal1000Title => '1000 Mega Chad';

  @override
  String get achievementTotal1000Desc => 'Completed a total of 1000 pushups';

  @override
  String get achievementTotal1000Motivation =>
      '1000 breakthrough! Mega Chad achieved! ⚡';

  @override
  String get achievementTotal2500Title => '2500 Super Chad';

  @override
  String get achievementTotal2500Desc => 'Completed a total of 2500 pushups';

  @override
  String get achievementTotal2500Motivation =>
      '2500! Reached the realm of Super Chad! 🔥';

  @override
  String get achievementTotal5000Title => '5000 Ultra Chad';

  @override
  String get achievementTotal5000Desc => 'Completed a total of 5000 pushups';

  @override
  String get achievementTotal5000Motivation =>
      '5000! You are an Ultra Chad! 🌟';

  @override
  String get achievementTotal10000Title => '10000 God Chad';

  @override
  String get achievementTotal10000Desc => 'Completed a total of 10000 pushups';

  @override
  String get achievementTotal10000Motivation =>
      '10000! You are the God of Chads! 👑';

  @override
  String get achievementPerfect3Title => 'Perfect Triple';

  @override
  String get achievementPerfect3Desc => 'Achieved 3 perfect workouts';

  @override
  String get achievementPerfect3Motivation =>
      'Perfect triple! Chad of accuracy! 🎯';

  @override
  String get achievementPerfect5Title => 'Perfectionist Chad';

  @override
  String get achievementPerfect5Desc => 'Achieved 5 perfect workouts';

  @override
  String get achievementPerfect5Motivation =>
      'True Chad who pursues perfection! ⭐';

  @override
  String get achievementPerfect10Title => 'Master Chad';

  @override
  String get achievementPerfect10Desc => 'Achieved 10 perfect workouts';

  @override
  String get achievementPerfect10Motivation =>
      'Master of perfection! Chad among Chads! 🏆';

  @override
  String get achievementPerfect20Title => 'Perfect Legend';

  @override
  String get achievementPerfect20Desc => 'Achieved 20 perfect workouts';

  @override
  String get achievementPerfect20Motivation =>
      '20 perfects! You are the embodiment of perfection! 💎';

  @override
  String get achievementTutorialExplorerTitle => 'Exploring Chad';

  @override
  String get achievementTutorialExplorerDesc =>
      'Checked the first pushup tutorial';

  @override
  String get achievementTutorialExplorerMotivation =>
      'Knowledge is Chad\'s first power! 🔍';

  @override
  String get achievementTutorialStudentTitle => 'Learning Chad';

  @override
  String get achievementTutorialStudentDesc => 'Checked 5 pushup tutorials';

  @override
  String get achievementTutorialStudentMotivation =>
      'True Chad learning various techniques! 📚';

  @override
  String get achievementTutorialMasterTitle => 'Pushup Master';

  @override
  String get achievementTutorialMasterDesc => 'Checked all pushup tutorials';

  @override
  String get achievementTutorialMasterMotivation =>
      'Pushup doctor who mastered all techniques! 🎓';

  @override
  String get achievementEarlyBirdTitle => 'Dawn Chad';

  @override
  String get achievementEarlyBirdMotivation =>
      'Early bird Chad who conquered the dawn! 🌅';

  @override
  String get achievementNightOwlTitle => 'Nocturnal Chad';

  @override
  String get achievementNightOwlMotivation =>
      'Owl Chad who never gives up even at night! 🦉';

  @override
  String get achievementWeekendWarriorTitle => 'Weekend Warrior';

  @override
  String get achievementWeekendWarriorDesc =>
      'Chad who consistently works out on weekends';

  @override
  String get achievementWeekendWarriorMotivation =>
      'Warrior who doesn\'t stop even on weekends! ⚔️';

  @override
  String get achievementLunchBreakTitle => 'Lunch Break Chad';

  @override
  String get achievementLunchBreakDesc =>
      'Worked out 5 times during lunch break (12-2 PM)';

  @override
  String get achievementLunchBreakMotivation =>
      'Efficient Chad who doesn\'t miss lunch break! 🍽️';

  @override
  String get achievementSpeedDemonTitle => 'Speed Demon';

  @override
  String get achievementSpeedDemonMotivation =>
      'Lightning speed! Chad of speed! 💨';

  @override
  String get achievementEnduranceKingTitle => 'King of Endurance';

  @override
  String get achievementEnduranceKingDesc =>
      'Sustained workout for over 30 minutes';

  @override
  String get achievementEnduranceKingMotivation =>
      '30 minutes sustained! King of endurance! ⏰';

  @override
  String get achievementComebackKidTitle => 'Comeback Kid';

  @override
  String get achievementComebackKidDesc =>
      'Restarted workout after resting for 7+ days';

  @override
  String get achievementComebackKidMotivation =>
      'Never-give-up spirit! Comeback Chad! 🔄';

  @override
  String get achievementOverachieverTitle => 'Overachiever';

  @override
  String get achievementOverachieverMotivation =>
      'Overachiever who surpasses goals! 📈';

  @override
  String get achievementDoubleTroubleTitle => 'Double Trouble';

  @override
  String get achievementDoubleTroubleDesc => 'Achieved 200% of goal';

  @override
  String get achievementDoubleTroubleMotivation =>
      'Double the goal! Double Trouble Chad! 🎪';

  @override
  String get achievementConsistencyMasterTitle => 'Master of Consistency';

  @override
  String get achievementConsistencyMasterDesc =>
      'Achieved goal exactly for 10 consecutive days';

  @override
  String get achievementConsistencyMasterMotivation =>
      'Precise goal achievement! Master of consistency! 🎯';

  @override
  String get achievementLevel5Title => 'Level 5 Chad';

  @override
  String get achievementLevel5Desc => 'Reached level 5';

  @override
  String get achievementLevel5Motivation =>
      'Level 5 achieved! Beginning of intermediate Chad! 🌟';

  @override
  String get achievementLevel10Title => 'Level 10 Chad';

  @override
  String get achievementLevel10Desc => 'Reached level 10';

  @override
  String get achievementLevel10Motivation =>
      'Level 10! Realm of advanced Chad! 🏅';

  @override
  String get achievementLevel20Title => 'Level 20 Chad';

  @override
  String get achievementLevel20Desc => 'Reached level 20';

  @override
  String get achievementLevel20Motivation => 'Level 20! King among Chads! 👑';

  @override
  String get achievementMonthlyWarriorTitle => 'Monthly Warrior';

  @override
  String get achievementMonthlyWarriorDesc => 'Worked out 20+ days in a month';

  @override
  String get achievementMonthlyWarriorMotivation =>
      '20 days a month! Monthly warrior Chad! 📅';

  @override
  String get achievementSeasonalChampionTitle => 'Seasonal Champion';

  @override
  String get achievementSeasonalChampionDesc =>
      'Achieved monthly goals for 3 consecutive months';

  @override
  String get achievementSeasonalChampionMotivation =>
      '3 months straight! Seasonal champion! 🏆';

  @override
  String get achievementVarietySeekerTitle => 'Variety Seeker';

  @override
  String get achievementVarietySeekerDesc => 'Tried 5 different pushup types';

  @override
  String get achievementVarietySeekerMotivation =>
      'Creative Chad seeking variety! 🎨';

  @override
  String get achievementAllRounderTitle => 'All-Rounder';

  @override
  String get achievementAllRounderDesc => 'Tried all pushup types';

  @override
  String get achievementAllRounderMotivation =>
      'Master of all types! All-rounder Chad! 🌈';

  @override
  String get achievementIronWillTitle => 'Iron Will';

  @override
  String get achievementIronWillMotivation =>
      '200 in one go! Iron-like will! 🔩';

  @override
  String get achievementUnstoppableForceTitle => 'Unstoppable Force';

  @override
  String get achievementUnstoppableForceDesc =>
      'Achieved 300 pushups in one go';

  @override
  String get achievementUnstoppableForceMotivation =>
      '300! You are an unstoppable force! 🌪️';

  @override
  String get achievementLegendaryBeastTitle => 'Legendary Beast';

  @override
  String get achievementLegendaryBeastDesc => 'Achieved 500 pushups in one go';

  @override
  String get achievementLegendaryBeastMotivation =>
      '500! You are a legendary beast! 🐉';

  @override
  String get achievementMotivatorTitle => 'Motivator';

  @override
  String get achievementMotivatorDesc => 'Used the app for 30+ days';

  @override
  String get achievementMotivatorMotivation =>
      '30 days of use! True motivator! 💡';

  @override
  String get achievementDedicationMasterTitle => 'Master of Dedication';

  @override
  String get achievementDedicationMasterDesc => 'Used the app for 100+ days';

  @override
  String get achievementDedicationMasterMotivation =>
      '100 days of dedication! You are the master of dedication! 🎖️';

  @override
  String get githubRepository => 'GitHub 저장소';

  @override
  String get feedbackEmail => '이메일로 피드백 보내기';

  @override
  String get developerContact => '개발자 연락처';

  @override
  String get openGithub => 'GitHub에서 소스코드 보기';

  @override
  String get emailFeedback => '이메일로 의견을 보내주세요';

  @override
  String get cannotOpenEmail => '이메일 앱을 열 수 없습니다';

  @override
  String get cannotOpenGithub => 'GitHub을 열 수 없습니다';

  @override
  String get appVersion => '앱 버전';

  @override
  String get builtWithFlutter => 'Flutter로 제작됨';
}
