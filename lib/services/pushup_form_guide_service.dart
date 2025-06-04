import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/pushup_form_guide.dart';

/// 푸시업 폼 가이드 데이터를 관리하는 서비스
class PushupFormGuideService {
  static final PushupFormGuideService _instance = PushupFormGuideService._internal();
  factory PushupFormGuideService() => _instance;
  PushupFormGuideService._internal();

  static const String _dataPathKo = 'assets/data/pushup_form_guide.json';
  static const String _dataPathEn = 'assets/data/pushup_form_guide_en.json';
  
  PushupFormGuideData? _cachedDataKo;
  PushupFormGuideData? _cachedDataEn;

  /// 현재 언어에 따라 적절한 JSON 파일에서 푸시업 폼 가이드 데이터를 로드
  Future<PushupFormGuideData> loadFormGuideData(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';
    
    if (isKorean) {
      if (_cachedDataKo != null) {
        return _cachedDataKo!;
      }
      
      try {
        final String jsonString = await rootBundle.loadString(_dataPathKo);
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
        
        _cachedDataKo = _parseFormGuideData(jsonData);
        return _cachedDataKo!;
      } catch (e) {
        // JSON 로드 실패 시 하드코딩된 데이터 사용
        _cachedDataKo = _getHardcodedData();
        return _cachedDataKo!;
      }
    } else {
      if (_cachedDataEn != null) {
        return _cachedDataEn!;
      }
      
      try {
        final String jsonString = await rootBundle.loadString(_dataPathEn);
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
        
        _cachedDataEn = _parseFormGuideData(jsonData);
        return _cachedDataEn!;
      } catch (e) {
        // JSON 로드 실패 시 하드코딩된 데이터 사용 (영어)
        _cachedDataEn = _getHardcodedDataEn();
        return _cachedDataEn!;
      }
    }
  }

  /// JSON 데이터를 PushupFormGuideData 객체로 파싱
  PushupFormGuideData _parseFormGuideData(Map<String, dynamic> jsonData) {
    final List<FormStep> formSteps = (jsonData['formSteps'] as List)
        .map((stepJson) {
          final step = stepJson as Map<String, dynamic>;
          return FormStep(
            stepNumber: step['stepNumber'] as int,
            title: step['title'] as String,
            description: step['description'] as String,
            imagePath: step['imagePath'] as String,
            keyPoints: List<String>.from(step['keyPoints'] as List),
            animationPath: step['animationPath'] as String?,
            videoUrl: step['videoUrl'] as String?,
            videoAssetPath: step['videoAssetPath'] as String?,
            videoDescription: step['videoDescription'] as String?,
          );
        })
        .toList();

    final List<CommonMistake> commonMistakes = (jsonData['commonMistakes'] as List)
        .map((mistakeJson) {
          final mistake = mistakeJson as Map<String, dynamic>;
          return CommonMistake(
            title: mistake['title'] as String,
            description: mistake['description'] as String,
            wrongImagePath: mistake['wrongImagePath'] as String,
            correctImagePath: mistake['correctImagePath'] as String,
            severity: mistake['severity'] as String,
            corrections: List<String>.from(mistake['corrections'] as List),
          );
        })
        .toList();

    final List<PushupVariation> variations = (jsonData['variations'] as List)
        .map((variationJson) {
          final variation = variationJson as Map<String, dynamic>;
          return PushupVariation(
            name: variation['name'] as String,
            description: variation['description'] as String,
            difficulty: variation['difficulty'] as String,
            imagePath: variation['imagePath'] as String,
            instructions: List<String>.from(variation['instructions'] as List),
            benefits: List<String>.from(variation['benefits'] as List),
          );
        })
        .toList();

    final List<ImprovementTip> improvementTips = (jsonData['improvementTips'] as List)
        .map((tipJson) {
          final tip = tipJson as Map<String, dynamic>;
          return ImprovementTip(
            category: tip['category'] as String,
            title: tip['title'] as String,
            description: tip['description'] as String,
            iconName: tip['iconName'] as String,
            actionItems: List<String>.from(tip['actionItems'] as List),
          );
        })
        .toList();

    final List<QuizQuestion> quizQuestions = (jsonData['quizQuestions'] as List? ?? [])
        .map((quizJson) {
          final quiz = quizJson as Map<String, dynamic>;
          return QuizQuestion(
            question: quiz['question'] as String,
            options: List<String>.from(quiz['options'] as List),
            correctAnswerIndex: quiz['correctAnswerIndex'] as int,
            explanation: quiz['explanation'] as String,
            category: quiz['category'] as String,
          );
        })
        .toList();

    return PushupFormGuideData(
      formSteps: formSteps,
      commonMistakes: commonMistakes,
      variations: variations,
      improvementTips: improvementTips,
      quizQuestions: quizQuestions,
    );
  }

  /// 하드코딩된 데이터 (JSON 로드 실패 시 백업용)
  PushupFormGuideData _getHardcodedData() {
    return PushupFormGuideData(
      formSteps: getFormSteps(),
      commonMistakes: getCommonMistakes(),
      variations: getVariations(),
      improvementTips: getImprovementTips(),
      quizQuestions: getQuizQuestions(),
    );
  }

  /// 올바른 푸시업 자세의 단계별 가이드를 반환
  List<FormStep> getFormSteps() {
    return [
      const FormStep(
        stepNumber: 1,
        title: '시작 자세',
        description: '플랭크 자세로 시작하여 손과 발의 위치를 정확히 설정합니다.',
        imagePath: 'assets/images/form_guide/step1_start_position.png',
        keyPoints: [
          '손은 어깨 바로 아래 위치',
          '손가락은 앞을 향하게',
          '발은 어깨 너비로 벌림',
          '몸은 일직선 유지',
        ],
      ),
      const FormStep(
        stepNumber: 2,
        title: '하강 동작',
        description: '팔꿈치를 구부리며 천천히 몸을 아래로 내립니다.',
        imagePath: 'assets/images/form_guide/step2_descending.png',
        keyPoints: [
          '팔꿈치는 45도 각도로 구부림',
          '가슴이 바닥에 거의 닿을 때까지',
          '코어 근육 긴장 유지',
          '호흡은 내려가면서 들이마시기',
        ],
      ),
      const FormStep(
        stepNumber: 3,
        title: '최하점 자세',
        description: '가슴이 바닥에 거의 닿는 최하점에서 잠시 정지합니다.',
        imagePath: 'assets/images/form_guide/step3_bottom_position.png',
        keyPoints: [
          '가슴과 바닥 사이 주먹 하나 간격',
          '몸의 일직선 유지',
          '어깨와 손목 정렬',
          '1-2초간 정지',
        ],
      ),
      const FormStep(
        stepNumber: 4,
        title: '상승 동작',
        description: '팔을 펴며 시작 자세로 돌아갑니다.',
        imagePath: 'assets/images/form_guide/step4_ascending.png',
        keyPoints: [
          '팔을 힘차게 펴기',
          '코어 근육으로 몸 지지',
          '호흡은 올라가면서 내쉬기',
          '팔꿈치 완전히 펴기',
        ],
      ),
      const FormStep(
        stepNumber: 5,
        title: '완료 자세',
        description: '시작 자세로 완전히 돌아와 다음 반복을 준비합니다.',
        imagePath: 'assets/images/form_guide/step5_finish_position.png',
        keyPoints: [
          '팔꿈치 완전히 펴진 상태',
          '몸의 일직선 유지',
          '어깨 안정화',
          '다음 반복 준비',
        ],
      ),
    ];
  }

  /// 일반적인 푸시업 실수들을 반환
  List<CommonMistake> getCommonMistakes() {
    return [
      const CommonMistake(
        title: '엉덩이가 너무 높이 올라감',
        description: '엉덩이를 높이 들면 코어 근육 사용이 줄어들고 효과가 떨어집니다.',
        wrongImagePath: 'assets/images/mistakes/high_hips_wrong.png',
        correctImagePath: 'assets/images/mistakes/high_hips_correct.png',
        severity: 'high',
        corrections: [
          '코어 근육을 긴장시켜 몸을 일직선으로 유지',
          '거울을 보며 자세 확인',
          '플랭크 자세 연습으로 기본기 다지기',
        ],
      ),
      const CommonMistake(
        title: '엉덩이가 너무 아래로 처짐',
        description: '엉덩이가 처지면 허리에 무리가 가고 부상 위험이 증가합니다.',
        wrongImagePath: 'assets/images/mistakes/sagging_hips_wrong.png',
        correctImagePath: 'assets/images/mistakes/sagging_hips_correct.png',
        severity: 'high',
        corrections: [
          '복근과 둔근을 동시에 수축',
          '허리 중립 자세 유지',
          '코어 강화 운동 병행',
        ],
      ),
      const CommonMistake(
        title: '팔꿈치가 너무 벌어짐',
        description: '팔꿈치를 90도로 벌리면 어깨에 무리가 가고 부상 위험이 높아집니다.',
        wrongImagePath: 'assets/images/mistakes/wide_elbows_wrong.png',
        correctImagePath: 'assets/images/mistakes/wide_elbows_correct.png',
        severity: 'medium',
        corrections: [
          '팔꿈치를 몸에 가깝게 유지 (45도 각도)',
          '어깨날 안정화',
          '삼두근 강화 운동',
        ],
      ),
      const CommonMistake(
        title: '목이 앞으로 나옴',
        description: '목을 앞으로 빼면 목과 어깨에 긴장이 생기고 자세가 무너집니다.',
        wrongImagePath: 'assets/images/mistakes/forward_head_wrong.png',
        correctImagePath: 'assets/images/mistakes/forward_head_correct.png',
        severity: 'medium',
        corrections: [
          '목을 중립 위치에 유지',
          '시선은 바닥을 향하게',
          '목 스트레칭으로 유연성 개선',
        ],
      ),
      const CommonMistake(
        title: '가동범위가 부족함',
        description: '충분히 내려가지 않으면 근육 발달 효과가 크게 떨어집니다.',
        wrongImagePath: 'assets/images/mistakes/partial_range_wrong.png',
        correctImagePath: 'assets/images/mistakes/partial_range_correct.png',
        severity: 'medium',
        corrections: [
          '가슴이 바닥에 거의 닿을 때까지 내려가기',
          '천천히 컨트롤하며 동작',
          '유연성 향상을 위한 스트레칭',
        ],
      ),
    ];
  }

  /// 난이도별 푸시업 변형을 반환
  List<PushupVariation> getVariations() {
    return [
      const PushupVariation(
        name: '무릎 푸시업',
        description: '무릎을 바닥에 대고 하는 초보자용 푸시업',
        difficulty: 'beginner',
        imagePath: 'assets/images/variations/knee_pushup.png',
        instructions: [
          '무릎을 바닥에 대고 시작',
          '손은 어깨 바로 아래 위치',
          '무릎부터 머리까지 일직선 유지',
          '천천히 가슴을 바닥 쪽으로',
        ],
        benefits: [
          '기본 자세 익히기에 좋음',
          '상체 근력 점진적 발달',
          '부상 위험 낮음',
        ],
      ),
      const PushupVariation(
        name: '인클라인 푸시업',
        description: '벤치나 계단을 이용한 경사 푸시업',
        difficulty: 'beginner',
        imagePath: 'assets/images/variations/incline_pushup.png',
        instructions: [
          '벤치나 계단에 손을 올림',
          '발은 바닥에 고정',
          '몸을 경사지게 유지',
          '일반 푸시업과 동일한 동작',
        ],
        benefits: [
          '강도 조절 가능',
          '정확한 자세 연습',
          '점진적 난이도 증가',
        ],
      ),
      const PushupVariation(
        name: '다이아몬드 푸시업',
        description: '손을 다이아몬드 모양으로 모은 고난도 푸시업',
        difficulty: 'advanced',
        imagePath: 'assets/images/variations/diamond_pushup.png',
        instructions: [
          '양손을 가슴 아래에서 다이아몬드 모양으로',
          '엄지와 검지로 삼각형 만들기',
          '팔꿈치를 몸에 가깝게 유지',
          '천천히 컨트롤하며 동작',
        ],
        benefits: [
          '삼두근 집중 강화',
          '코어 안정성 향상',
          '상급자 근력 발달',
        ],
      ),
      const PushupVariation(
        name: '원암 푸시업',
        description: '한 팔로만 하는 최고 난이도 푸시업',
        difficulty: 'advanced',
        imagePath: 'assets/images/variations/one_arm_pushup.png',
        instructions: [
          '한 손은 등 뒤로',
          '다리를 넓게 벌려 균형 유지',
          '몸의 회전 최소화',
          '극도로 천천히 동작',
        ],
        benefits: [
          '최고 수준의 근력 발달',
          '균형감각 향상',
          '정신력 강화',
        ],
      ),
    ];
  }

  /// 개선 팁들을 반환
  List<ImprovementTip> getImprovementTips() {
    return [
      const ImprovementTip(
        category: '호흡법',
        title: '올바른 호흡 패턴',
        description: '호흡을 통해 운동 효과를 극대화하고 지구력을 향상시킵니다.',
        iconName: 'air',
        actionItems: [
          '내려갈 때 천천히 들이마시기',
          '올라갈 때 힘차게 내쉬기',
          '호흡을 멈추지 않기',
          '리듬감 있게 호흡하기',
        ],
      ),
      const ImprovementTip(
        category: '근력 향상',
        title: '점진적 과부하',
        description: '단계적으로 강도를 높여 지속적인 근력 발달을 도모합니다.',
        iconName: 'trending_up',
        actionItems: [
          '주당 2-3회씩 횟수 증가',
          '더 어려운 변형으로 진행',
          '세트 수 점진적 증가',
          '휴식 시간 단축',
        ],
      ),
      const ImprovementTip(
        category: '회복',
        title: '적절한 휴식과 회복',
        description: '충분한 휴식을 통해 근육 성장과 부상 예방을 도모합니다.',
        iconName: 'bedtime',
        actionItems: [
          '운동 후 48시간 휴식',
          '충분한 수면 (7-8시간)',
          '스트레칭과 마사지',
          '영양 섭취 신경쓰기',
        ],
      ),
      const ImprovementTip(
        category: '동기부여',
        title: '목표 설정과 추적',
        description: '명확한 목표와 기록을 통해 지속적인 동기를 유지합니다.',
        iconName: 'flag',
        actionItems: [
          '단기/장기 목표 설정',
          '운동 일지 작성',
          '진전 사항 사진 촬영',
          '성취 축하하기',
        ],
      ),
    ];
  }

  /// 퀴즈 질문들을 반환
  List<QuizQuestion> getQuizQuestions() {
    return [
      const QuizQuestion(
        question: '올바른 푸시업 시작 자세에서 손의 위치는?',
        options: [
          '어깨보다 넓게',
          '어깨 바로 아래',
          '어깨보다 좁게',
          '가슴 중앙에',
        ],
        correctAnswerIndex: 1,
        explanation: '손은 어깨 바로 아래에 위치해야 안정적인 자세를 유지할 수 있습니다.',
        category: 'form',
      ),
      const QuizQuestion(
        question: '푸시업 중 가장 흔한 실수는?',
        options: [
          '팔꿈치가 너무 벌어짐',
          '엉덩이가 너무 높이 올라감',
          '목이 앞으로 나옴',
          '가동범위가 부족함',
        ],
        correctAnswerIndex: 1,
        explanation: '엉덩이가 높이 올라가면 코어 근육 사용이 줄어들고 운동 효과가 떨어집니다.',
        category: 'mistakes',
      ),
      const QuizQuestion(
        question: '초보자에게 가장 적합한 푸시업 변형은?',
        options: [
          '다이아몬드 푸시업',
          '원암 푸시업',
          '무릎 푸시업',
          '클랩 푸시업',
        ],
        correctAnswerIndex: 2,
        explanation: '무릎 푸시업은 부상 위험이 낮고 기본 자세를 익히기에 좋습니다.',
        category: 'variations',
      ),
      const QuizQuestion(
        question: '푸시업 시 올바른 호흡법은?',
        options: [
          '내려갈 때 내쉬고, 올라갈 때 들이마시기',
          '내려갈 때 들이마시고, 올라갈 때 내쉬기',
          '계속 숨을 참기',
          '빠르게 호흡하기',
        ],
        correctAnswerIndex: 1,
        explanation: '내려갈 때 들이마시고 올라갈 때 내쉬는 것이 올바른 호흡법입니다.',
        category: 'tips',
      ),
      const QuizQuestion(
        question: '푸시업에서 팔꿈치의 올바른 각도는?',
        options: [
          '90도로 완전히 벌리기',
          '45도 각도로 몸에 가깝게',
          '완전히 몸에 붙이기',
          '각도는 상관없음',
        ],
        correctAnswerIndex: 1,
        explanation: '팔꿈치를 45도 각도로 유지하면 어깨 부상을 예방하고 효과적인 운동이 가능합니다.',
        category: 'form',
      ),
    ];
  }

  /// 전체 푸시업 폼 가이드 데이터를 반환
  PushupFormGuideData getFormGuideData() {
    return PushupFormGuideData(
      formSteps: getFormSteps(),
      commonMistakes: getCommonMistakes(),
      variations: getVariations(),
      improvementTips: getImprovementTips(),
      quizQuestions: getQuizQuestions(),
    );
  }

  /// 난이도별 색상을 반환
  static int getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 0xFF51CF66; // 초록색
      case 'intermediate':
        return 0xFFFFD43B; // 노란색
      case 'advanced':
        return 0xFFFF6B6B; // 빨간색
      default:
        return 0xFF4DABF7; // 기본 파란색
    }
  }

  /// 심각도별 색상을 반환
  static int getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 0xFFFF6B6B; // 빨간색
      case 'medium':
        return 0xFFFFD43B; // 노란색
      case 'low':
        return 0xFF51CF66; // 초록색
      default:
        return 0xFF4DABF7; // 기본 파란색
    }
  }

  /// 하드코딩된 데이터 (영어)
  PushupFormGuideData _getHardcodedDataEn() {
    return PushupFormGuideData(
      formSteps: getFormStepsEn(),
      commonMistakes: getCommonMistakesEn(),
      variations: getVariationsEn(),
      improvementTips: getImprovementTipsEn(),
      quizQuestions: getQuizQuestionsEn(),
    );
  }

  /// 영어용 올바른 푸시업 자세의 단계별 가이드를 반환
  List<FormStep> getFormStepsEn() {
    return [
      const FormStep(
        stepNumber: 1,
        title: 'Starting Position',
        description: 'Start in a plank position and set the correct positions for your hands and feet.',
        imagePath: 'assets/images/form_guide/step1_start_position.png',
        keyPoints: [
          'Hands directly under shoulders',
          'Fingers pointing forward',
          'Feet shoulder-width apart',
          'Keep body in straight line',
        ],
      ),
      const FormStep(
        stepNumber: 2,
        title: 'Descending Motion',
        description: 'Bend your elbows and slowly lower your body down.',
        imagePath: 'assets/images/form_guide/step2_descending.png',
        keyPoints: [
          'Bend elbows at 45-degree angle',
          'Lower until chest nearly touches floor',
          'Keep core muscles tight',
          'Inhale while descending',
        ],
      ),
      const FormStep(
        stepNumber: 3,
        title: 'Bottom Position',
        description: 'Pause briefly at the bottom position where your chest nearly touches the floor.',
        imagePath: 'assets/images/form_guide/step3_bottom_position.png',
        keyPoints: [
          'Fist-width gap between chest and floor',
          'Maintain straight body line',
          'Keep shoulders and wrists aligned',
          'Hold for 1-2 seconds',
        ],
      ),
      const FormStep(
        stepNumber: 4,
        title: 'Ascending Motion',
        description: 'Push back up to the starting position by extending your arms.',
        imagePath: 'assets/images/form_guide/step4_ascending.png',
        keyPoints: [
          'Push up powerfully',
          'Support body with core muscles',
          'Exhale while ascending',
          'Fully extend elbows',
        ],
      ),
      const FormStep(
        stepNumber: 5,
        title: 'Finish Position',
        description: 'Return completely to starting position and prepare for the next repetition.',
        imagePath: 'assets/images/form_guide/step5_finish_position.png',
        keyPoints: [
          'Elbows fully extended',
          'Maintain straight body line',
          'Stabilize shoulders',
          'Prepare for next rep',
        ],
      ),
    ];
  }

  /// 영어용 일반적인 푸시업 실수들을 반환
  List<CommonMistake> getCommonMistakesEn() {
    return [
      const CommonMistake(
        title: 'Hips too high',
        description: 'Raising your hips too high reduces core muscle engagement and decreases effectiveness.',
        wrongImagePath: 'assets/images/mistakes/high_hips_wrong.png',
        correctImagePath: 'assets/images/mistakes/high_hips_correct.png',
        severity: 'high',
        corrections: [
          'Engage core muscles to maintain straight line',
          'Check posture in mirror',
          'Practice plank position to build foundation',
        ],
      ),
      const CommonMistake(
        title: 'Sagging hips',
        description: 'Sagging hips puts strain on the lower back and increases injury risk.',
        wrongImagePath: 'assets/images/mistakes/sagging_hips_wrong.png',
        correctImagePath: 'assets/images/mistakes/sagging_hips_correct.png',
        severity: 'high',
        corrections: [
          'Contract abs and glutes simultaneously',
          'Maintain neutral spine position',
          'Include core strengthening exercises',
        ],
      ),
      const CommonMistake(
        title: 'Elbows flared too wide',
        description: 'Flaring elbows to 90 degrees puts stress on shoulders and increases injury risk.',
        wrongImagePath: 'assets/images/mistakes/wide_elbows_wrong.png',
        correctImagePath: 'assets/images/mistakes/wide_elbows_correct.png',
        severity: 'medium',
        corrections: [
          'Keep elbows close to body (45-degree angle)',
          'Stabilize shoulder blades',
          'Strengthen triceps',
        ],
      ),
      const CommonMistake(
        title: 'Head forward',
        description: 'Pushing your head forward creates tension in neck and shoulders and breaks proper form.',
        wrongImagePath: 'assets/images/mistakes/forward_head_wrong.png',
        correctImagePath: 'assets/images/mistakes/forward_head_correct.png',
        severity: 'medium',
        corrections: [
          'Keep neck in neutral position',
          'Look down at floor',
          'Improve neck flexibility with stretching',
        ],
      ),
      const CommonMistake(
        title: 'Partial range of motion',
        description: 'Not lowering enough significantly reduces muscle development benefits.',
        wrongImagePath: 'assets/images/mistakes/partial_range_wrong.png',
        correctImagePath: 'assets/images/mistakes/partial_range_correct.png',
        severity: 'medium',
        corrections: [
          'Lower until chest nearly touches floor',
          'Control movement slowly',
          'Improve flexibility with stretching',
        ],
      ),
    ];
  }

  /// 영어용 난이도별 푸시업 변형을 반환
  List<PushupVariation> getVariationsEn() {
    return [
      const PushupVariation(
        name: 'Knee Push-ups',
        description: 'Beginner push-ups performed with knees on the ground',
        difficulty: 'beginner',
        imagePath: 'assets/images/variations/knee_pushup.png',
        instructions: [
          'Start with knees on ground',
          'Hands directly under shoulders',
          'Keep straight line from knees to head',
          'Slowly lower chest toward floor',
        ],
        benefits: [
          'Great for learning proper form',
          'Gradual upper body strength development',
          'Lower injury risk',
        ],
      ),
      const PushupVariation(
        name: 'Incline Push-ups',
        description: 'Push-ups using bench or stairs for elevation',
        difficulty: 'beginner',
        imagePath: 'assets/images/variations/incline_pushup.png',
        instructions: [
          'Place hands on bench or stairs',
          'Keep feet on ground',
          'Maintain angled body position',
          'Perform same motion as regular push-ups',
        ],
        benefits: [
          'Adjustable intensity',
          'Perfect form practice',
          'Progressive difficulty increase',
        ],
      ),
      const PushupVariation(
        name: 'Diamond Push-ups',
        description: 'Advanced push-ups with hands in diamond shape',
        difficulty: 'advanced',
        imagePath: 'assets/images/variations/diamond_pushup.png',
        instructions: [
          'Form diamond shape with hands under chest',
          'Create triangle with thumbs and index fingers',
          'Keep elbows close to body',
          'Control movement slowly',
        ],
        benefits: [
          'Intense tricep strengthening',
          'Improved core stability',
          'Advanced strength development',
        ],
      ),
      const PushupVariation(
        name: 'One-Arm Push-ups',
        description: 'Maximum difficulty push-ups using only one arm',
        difficulty: 'advanced',
        imagePath: 'assets/images/variations/one_arm_pushup.png',
        instructions: [
          'Place one hand behind back',
          'Spread legs wide for balance',
          'Minimize body rotation',
          'Move extremely slowly',
        ],
        benefits: [
          'Maximum strength development',
          'Improved balance',
          'Mental toughness building',
        ],
      ),
    ];
  }

  /// 영어용 개선 팁들을 반환
  List<ImprovementTip> getImprovementTipsEn() {
    return [
      const ImprovementTip(
        category: 'Breathing',
        title: 'Proper Breathing Pattern',
        description: 'Maximize exercise effectiveness and improve endurance through proper breathing.',
        iconName: 'air',
        actionItems: [
          'Inhale slowly while going down',
          'Exhale powerfully while going up',
          'Never hold your breath',
          'Maintain rhythmic breathing',
        ],
      ),
      const ImprovementTip(
        category: 'Strength',
        title: 'Progressive Overload',
        description: 'Gradually increase intensity for continuous strength development.',
        iconName: 'trending_up',
        actionItems: [
          'Increase reps by 2-3 per week',
          'Progress to harder variations',
          'Gradually increase sets',
          'Reduce rest time',
        ],
      ),
      const ImprovementTip(
        category: 'Recovery',
        title: 'Proper Rest and Recovery',
        description: 'Promote muscle growth and prevent injury through adequate rest.',
        iconName: 'bedtime',
        actionItems: [
          '48-hour rest after workouts',
          'Get adequate sleep (7-8 hours)',
          'Include stretching and massage',
          'Focus on nutrition',
        ],
      ),
      const ImprovementTip(
        category: 'Motivation',
        title: 'Goal Setting and Tracking',
        description: 'Maintain consistent motivation through clear goals and progress tracking.',
        iconName: 'flag',
        actionItems: [
          'Set short/long-term goals',
          'Keep workout journal',
          'Take progress photos',
          'Celebrate achievements',
        ],
      ),
    ];
  }

  /// 영어용 퀴즈 질문들을 반환
  List<QuizQuestion> getQuizQuestionsEn() {
    return [
      const QuizQuestion(
        question: 'Where should your hands be positioned in the correct push-up starting position?',
        options: [
          'Wider than shoulders',
          'Directly under shoulders',
          'Narrower than shoulders',
          'At chest center',
        ],
        correctAnswerIndex: 1,
        explanation: 'Hands should be directly under shoulders to maintain stable form.',
        category: 'form',
      ),
      const QuizQuestion(
        question: 'What is the most common push-up mistake?',
        options: [
          'Elbows flared too wide',
          'Hips too high',
          'Head forward',
          'Partial range of motion',
        ],
        correctAnswerIndex: 1,
        explanation: 'Raising hips too high reduces core muscle engagement and decreases exercise effectiveness.',
        category: 'mistakes',
      ),
      const QuizQuestion(
        question: 'Which push-up variation is most suitable for beginners?',
        options: [
          'Diamond push-ups',
          'One-arm push-ups',
          'Knee push-ups',
          'Clap push-ups',
        ],
        correctAnswerIndex: 2,
        explanation: 'Knee push-ups have lower injury risk and are great for learning proper form.',
        category: 'variations',
      ),
      const QuizQuestion(
        question: 'What is the correct breathing technique for push-ups?',
        options: [
          'Exhale going down, inhale going up',
          'Inhale going down, exhale going up',
          'Hold breath throughout',
          'Breathe rapidly',
        ],
        correctAnswerIndex: 1,
        explanation: 'Inhaling while going down and exhaling while going up is the correct breathing technique.',
        category: 'tips',
      ),
      const QuizQuestion(
        question: 'What is the correct elbow angle in push-ups?',
        options: [
          '90 degrees fully flared',
          '45 degrees close to body',
          'Completely against body',
          'Angle doesn\'t matter',
        ],
        correctAnswerIndex: 1,
        explanation: 'Keeping elbows at 45 degrees prevents shoulder injury and enables effective exercise.',
        category: 'form',
      ),
    ];
  }
} 