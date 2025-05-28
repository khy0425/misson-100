/// 푸시업 폼 가이드 단계를 나타내는 모델
class FormStep {
  final int stepNumber;
  final String title;
  final String description;
  final String imagePath;
  final List<String> keyPoints;
  final String? animationPath;
  final String? videoUrl;
  final String? videoAssetPath;
  final String? videoDescription;

  const FormStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.keyPoints,
    this.animationPath,
    this.videoUrl,
    this.videoAssetPath,
    this.videoDescription,
  });
}

/// 일반적인 실수를 나타내는 모델
class CommonMistake {
  final String title;
  final String description;
  final String wrongImagePath;
  final String correctImagePath;
  final List<String> corrections;
  final String severity; // 'high', 'medium', 'low'

  const CommonMistake({
    required this.title,
    required this.description,
    required this.wrongImagePath,
    required this.correctImagePath,
    required this.corrections,
    required this.severity,
  });
}

/// 푸시업 변형을 나타내는 모델
class PushupVariation {
  final String name;
  final String description;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String imagePath;
  final List<String> instructions;
  final List<String> benefits;

  const PushupVariation({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.imagePath,
    required this.instructions,
    required this.benefits,
  });
}

/// 개선 팁을 나타내는 모델
class ImprovementTip {
  final String category;
  final String title;
  final String description;
  final String iconName;
  final List<String> actionItems;

  const ImprovementTip({
    required this.category,
    required this.title,
    required this.description,
    required this.iconName,
    required this.actionItems,
  });
}

/// 퀴즈 질문을 나타내는 모델
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category; // 'form', 'mistakes', 'variations', 'tips'

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
  });
}

/// 퀴즈 결과를 나타내는 모델
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final List<bool> answerResults;
  final double scorePercentage;

  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answerResults,
    required this.scorePercentage,
  });
}

/// 푸시업 폼 가이드 전체 데이터를 관리하는 모델
class PushupFormGuideData {
  final List<FormStep> formSteps;
  final List<CommonMistake> commonMistakes;
  final List<PushupVariation> variations;
  final List<ImprovementTip> improvementTips;
  final List<QuizQuestion> quizQuestions;

  const PushupFormGuideData({
    required this.formSteps,
    required this.commonMistakes,
    required this.variations,
    required this.improvementTips,
    this.quizQuestions = const [],
  });
} 