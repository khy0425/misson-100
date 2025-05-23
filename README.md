# 🔥 Mission: 100 - Chad Push-up Master

**From Zero to Chad in 6 Weeks**

기가차드 밈을 기반으로 한 개인화된 푸쉬업 훈련 앱입니다. 초급자도 6주 만에 100개 푸쉬업을 달성할 수 있는 맞춤형 프로그램을 제공합니다.

## 📱 앱 특징

### 🎯 개인화된 레벨 시스템
- **초급 레벨 (Rookie Chad)**: 5개 이하 → 100개 달성
- **중급 레벨 (Rising Chad)**: 6-10개 → 100개 달성  
- **고급 레벨 (Alpha Chad)**: 11-20개 → 100개 달성
- **마스터 레벨 (Giga Chad)**: 21개 이상 → 100개+ 달성

### 💪 6주 완성 프로그램
- 주 3일 운동 (총 18회 세션)
- 세트별 상세한 목표 제공
- 점진적 강도 증가 시스템
- 개인 능력에 맞는 맞춤형 루틴

### 🚀 기가차드 진화 시스템
- 7단계 차드 진화 (수면모자차드 → 더블차드)
- 주차별 새로운 차드 이미지 언락
- 실시간 격려 메시지 및 밈 요소

## 🎨 사용된 차드 이미지

현재 프로젝트에 포함된 기가차드 이미지들:

- 🛌 **수면모자차드.jpg** - 시작 단계
- 😎 **기본차드.jpg** - 1주차 완료  
- ☕ **커피차드.jpg** - 2주차 완료
- 🔥 **정면차드.jpg** - 3주차 완료
- 🕶️ **썬글차드.jpg** - 4주차 완료
- ⚡ **눈빨차드.jpg** - 5주차 완료
- 👑 **더블차드.jpg** - 6주차 완료 (진정한 기가차드)

## 🛠️ 기술 스택

- **Framework**: Flutter 3.x
- **상태관리**: Riverpod
- **로컬 DB**: SQLite (sqflite)
- **알림**: flutter_local_notifications
- **차트**: fl_chart
- **애니메이션**: Lottie (추후 추가)

## 📦 주요 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  sqflite: ^2.3.0
  flutter_local_notifications: ^16.0.0
  fl_chart: ^0.64.0
  path: ^1.8.0
  shared_preferences: ^2.2.0
```

## 🚀 시작하기

### 1. 저장소 클론
```bash
git clone <repository-url>
cd mission100
```

### 2. 의존성 설치
```powershell
flutter pub get
```

### 3. 앱 실행
```powershell
flutter run
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── user_profile.dart
│   ├── workout_session.dart
│   └── progress.dart
├── providers/                # Riverpod 상태 관리
│   ├── user_provider.dart
│   ├── workout_provider.dart
│   └── progress_provider.dart
├── services/                 # 비즈니스 로직
│   ├── database_service.dart
│   ├── notification_service.dart
│   └── workout_service.dart
├── screens/                  # UI 화면
│   ├── home/
│   ├── workout/
│   ├── progress/
│   ├── settings/
│   └── onboarding/
├── widgets/                  # 재사용 가능한 위젯
│   ├── chad_avatar.dart
│   ├── workout_card.dart
│   └── progress_chart.dart
└── utils/                    # 유틸리티
    ├── constants.dart
    ├── theme.dart
    └── workout_data.dart

assets/
└── images/
    ├── 수면모자차드.jpg
    ├── 기본차드.jpg
    ├── 커피차드.jpg
    ├── 정면차드.jpg
    ├── 썬글차드.jpg
    ├── 눈빨차드.jpg
    └── 더블차드.jpg
```

## 💾 데이터베이스 스키마

### UserProfile 테이블
```sql
CREATE TABLE user_profile (
    id INTEGER PRIMARY KEY,
    level TEXT NOT NULL,
    initial_max_reps INTEGER NOT NULL,
    start_date TEXT NOT NULL,
    chad_level INTEGER DEFAULT 0,
    reminder_enabled BOOLEAN DEFAULT FALSE,
    reminder_time TEXT
);
```

### WorkoutSession 테이블
```sql
CREATE TABLE workout_session (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    week INTEGER NOT NULL,
    day INTEGER NOT NULL,
    target_reps TEXT NOT NULL,
    completed_reps TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    total_reps INTEGER DEFAULT 0,
    total_time INTEGER DEFAULT 0
);
```

## 📊 훈련 프로그램 예시

### Week 1 - 초급 레벨
- **Day 1**: 2-3-2-2 (5세트)
- **Day 2**: 6-6-4-4 (5세트) 
- **Day 3**: 8-10-7-7 (5세트)

### Week 6 - 초급 레벨 (최종)
- **Day 1**: 25-40-20-15 (5세트)
- **Day 2**: 14-20-15-15 (7세트)
- **Day 3**: 13-22-17-17 (7세트)

*총합 100개 이상 달성!*

## 🎮 핵심 기능

### 1. 초기 레벨 테스트
- 앱 첫 실행 시 "연속으로 몇 개 할 수 있나요?" 테스트
- 결과에 따라 자동으로 적절한 레벨 배정

### 2. 개인화된 운동 화면
- 세트별 목표 횟수 표시
- 실시간 카운터 및 체크
- 세트 간 휴식 타이머 (60-120초)

### 3. 진행률 추적
- 주차별 성장 그래프
- 총 누적 푸쉬업 개수
- 목표 달성률 시각화

### 4. 동기부여 시스템
- 차드 진화 단계별 새로운 이미지
- 격려 메시지 및 밈 요소
- 연속 운동일 스트릭 시스템

## 🔔 알림 기능

- 운동 시간 리마인더
- 격려 메시지 푸시 알림
- 연속 운동 스트릭 알림

## 📈 개발 로드맵

### Phase 1 (MVP) - 4주
- [x] PRD 및 설계 완료
- [ ] 기본 앱 구조 설정
- [ ] 초기 레벨 테스트 구현
- [ ] 6주 훈련 프로그램 데이터
- [ ] 기본 운동 트래킹 UI
- [ ] 차드 진화 시스템

### Phase 2 - 2주  
- [ ] 상세한 진행률 분석
- [ ] 알림 시스템
- [ ] 데이터 백업/복원
- [ ] UI/UX 개선

### Phase 3 - 2주
- [ ] 추가 챌린지 모드
- [ ] 애니메이션 및 사운드 효과
- [ ] 성능 최적화
- [ ] 앱스토어 배포 준비

## 🎯 성공 지표

- **사용자 유지율**: 6주 프로그램 완주율 70% 이상
- **목표 달성률**: 초급 사용자의 80% 이상이 100개 달성
- **사용자 만족도**: 앱스토어 평점 4.5점 이상

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참고하세요.

## 📞 연락처

프로젝트 링크: [https://github.com/yourusername/mission100](https://github.com/yourusername/mission100)

---

**"Push Your Limits, Embrace Your Inner Chad"** 💪

*Every rep counts, every Chad matters. 6주 후 거울 속에 진정한 차드가 있을 것입니다.*
