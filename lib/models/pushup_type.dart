/// 푸시업 난이도 열거형
enum PushupDifficulty {
  beginner, // 초급 - 기본, 무릎, 인클라인
  intermediate, // 중급 - 와이드, 다이아몬드
  advanced, // 고급 - 디클라인, 아처, 파이크
  extreme, // 극한 - 박수, 원핸드
}

/// 타겟 근육 열거형
enum TargetMuscle {
  chest, // 가슴
  triceps, // 삼두근
  shoulders, // 어깨
  core, // 코어
  full, // 전신
}

/// 푸시업 타입 모델
class PushupType {
  final String id;
  final String nameKey; // 국제화 키
  final String descriptionKey; // 국제화 키
  final PushupDifficulty difficulty;
  final List<TargetMuscle> targetMuscles;
  final String benefitsKey; // 국제화 키
  final String instructionsKey; // 국제화 키
  final String mistakesKey; // 국제화 키
  final String breathingKey; // 국제화 키
  final String chadMessageKey; // 기가차드 격려 메시지 키
  final String? animationAsset; // 애니메이션 파일 경로 (선택사항)
  final String? imageAsset; // 이미지 파일 경로 (선택사항)
  final int estimatedCaloriesPerRep; // 추정 소모 칼로리 (회당)
  final String youtubeVideoId; // 유튜브 영상 ID 추가

  const PushupType({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.difficulty,
    required this.targetMuscles,
    required this.benefitsKey,
    required this.instructionsKey,
    required this.mistakesKey,
    required this.breathingKey,
    required this.chadMessageKey,
    this.animationAsset,
    this.imageAsset,
    this.estimatedCaloriesPerRep = 1,
    required this.youtubeVideoId,
  });

  /// JSON에서 객체 생성
  factory PushupType.fromJson(Map<String, dynamic> json) {
    return PushupType(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      difficulty: PushupDifficulty.values.byName(json['difficulty'] as String),
      targetMuscles: (json['targetMuscles'] as List)
          .map((muscle) => TargetMuscle.values.byName(muscle as String))
          .toList(),
      benefitsKey: json['benefitsKey'] as String,
      instructionsKey: json['instructionsKey'] as String,
      mistakesKey: json['mistakesKey'] as String,
      breathingKey: json['breathingKey'] as String,
      chadMessageKey: json['chadMessageKey'] as String,
      animationAsset: json['animationAsset'] as String?,
      imageAsset: json['imageAsset'] as String?,
      estimatedCaloriesPerRep: json['estimatedCaloriesPerRep'] as int? ?? 1,
      youtubeVideoId: json['youtubeVideoId'] as String,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKey': nameKey,
      'descriptionKey': descriptionKey,
      'difficulty': difficulty.name,
      'targetMuscles': targetMuscles.map((muscle) => muscle.name).toList(),
      'benefitsKey': benefitsKey,
      'instructionsKey': instructionsKey,
      'mistakesKey': mistakesKey,
      'breathingKey': breathingKey,
      'chadMessageKey': chadMessageKey,
      'animationAsset': animationAsset,
      'imageAsset': imageAsset,
      'estimatedCaloriesPerRep': estimatedCaloriesPerRep,
      'youtubeVideoId': youtubeVideoId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushupType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PushupType(id: $id, nameKey: $nameKey, difficulty: $difficulty)';
  }
}
