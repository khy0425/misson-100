class AppConstants {
  // 앱 정보
  static const String appName = '💥 Mission: 100 💥';
  static const String appSubtitle = '🚀 ALPHA EMPEROR Pushup Master 🚀';
  static const String appSlogan =
      '⚡ From Zero to ULTRA GIGA CHAD EMPEROR in 6 Weeks ⚡';

  // 운동 프로그램 관련
  static const int totalWeeks = 6;
  static const int daysPerWeek = 3;
  static const int totalWorkoutDays = totalWeeks * daysPerWeek; // 18일

  // 차드 레벨 관련
  static const int maxChadLevel = 6;

  // 알림 관련
  static const String notificationChannelId = 'workout_reminders';
  static const String notificationChannelName = 'Workout Reminders';
  static const String notificationChannelDesc =
      'Notifications for workout reminders and motivation';

  // 공유 프리퍼런스 키
  static const String keyFirstLaunch = 'first_launch';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyThemeMode = 'theme_mode';
  static const String keyRestTimerDuration = 'rest_timer_duration';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyNotificationTime = 'notification_time';

  // 기본값들
  static const int defaultRestTime = 60; // 초
  static const String defaultNotificationTime = '19:00'; // 오후 7시

  // 애니메이션 지속시간
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // 패딩 및 마진
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // 둥근 모서리
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // 폰트 크기
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 32.0;

  // 아이콘 크기
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // 버튼 크기
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // 그림자
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // 정규식
  static const String timePattern = r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$';

  // 메시지 키들 - 실제 메시지는 AppLocalizations에서 가져올 것
  static const String errorGeneralKey = 'errorGeneral';
  static const String errorDatabaseKey = 'errorDatabase';
  static const String errorNetworkKey = 'errorNetwork';
  static const String errorNotFoundKey = 'errorNotFound';

  static const String successWorkoutCompletedKey = 'successWorkoutCompleted';
  static const String successProfileSavedKey = 'successProfileSaved';
  static const String successSettingsSavedKey = 'successSettingsSaved';

  // URL들 (추후 필요 시)
  static const String githubUrl = 'https://github.com/yourusername/mission100';
  static const String supportEmail = 'support@mission100chad.com';
}

// 앱 색상 정의
class AppColors {
  // 기본 브랜드 색상 - 기가차드 테마 (검정/금색 기반)
  static const int primaryColor = 0xFFFFB000; // 금색 (Chad의 상징색)
  static const int secondaryColor = 0xFFFF6B35; // 주황/빨강 (파워풀한 느낌)
  static const int accentColor = 0xFFE53E3E; // 빨간색 (강렬함)

  // 배경 색상 - 라이트/다크 테마 구분
  static const int backgroundLight = 0xFFF5F5F5; // 밝은 회색 (라이트 테마)
  static const int backgroundDark = 0xFF000000; // 순수 검정 (다크 테마)
  static const int surfaceLight = 0xFFFFFFFF; // 흰색 (라이트 테마)
  static const int surfaceDark = 0xFF0F0F0F; // 매우 어두운 회색 (다크 테마)

  // 텍스트 색상 - 라이트/다크 테마 구분
  static const int textPrimaryLight = 0xFF212121; // 어두운 회색 (라이트 테마)
  static const int textPrimaryDark = 0xFFFFFFFF; // 흰색 (다크 테마)
  static const int textSecondaryLight = 0xFF757575; // 중간 회색 (라이트 테마)
  static const int textSecondaryDark = 0xFFBDBDBD; // 밝은 회색 (다크 테마)

  // 상태별 색상 - Chad 테마에 맞게 조정
  static const int successColor = 0xFFFFB000; // 금색 (성공)
  static const int warningColor = 0xFFFF8C42; // 주황색 (경고)
  static const int errorColor = 0xFFE53E3E; // 빨간색 (에러)
  static const int infoColor = 0xFF4DABF7; // 밝은 파란색 (정보)

  // 차드 레벨별 색상 - 더 강렬하고 Chad다운 색상
  static const int rookieColor = 0xFF4DABF7; // 파란색 (초보)
  static const int risingColor = 0xFF51CF66; // 초록색 (상승)
  static const int alphaColor = 0xFFFFB000; // 금색 (알파)
  static const int gigaColor = 0xFFE53E3E; // 빨간색 (기가)

  // 그라데이션 색상 - Chad 테마
  static const List<int> chadGradient = [0xFF000000, 0xFF1A1A1A]; // 검정 그라데이션
  static const List<int> fireGradient = [0xFFE53E3E, 0xFFFF6B35]; // 불타는 빨간색
  static const List<int> goldGradient = [0xFFFFB000, 0xFFFFD700]; // 금색 그라데이션
  static const List<int> successGradient = [0xFFFFB000, 0xFFFFD700]; // 성공 금색
}

// 차드 관련 상수
class ChadConstants {
  // 차드 진화 조건 (완료된 주차 기준)
  static const Map<int, int> evolutionThresholds = {
    0: 0, // 시작 - 수면모자차드
    1: 1, // 1주차 완료 - 기본차드
    2: 2, // 2주차 완료 - 커피차드
    3: 3, // 3주차 완료 - 정면차드
    4: 4, // 4주차 완료 - 썬글차드
    5: 5, // 5주차 완료 - 눈빨차드
    6: 6, // 6주차 완료 - 더블차드
  };

  // 차드 타이틀 키들 (AppLocalizations에서 가져오기 위함)
  static const List<String> chadTitleKeys = [
    'chadTitleSleepy', // 수면모자차드
    'chadTitleBasic', // 기본차드
    'chadTitleCoffee', // 커피차드
    'chadTitleFront', // 정면차드
    'chadTitleCool', // 썬글차드
    'chadTitleLaser', // 눈빨차드
    'chadTitleDouble', // 더블차드
  ];

  // 특별 이벤트 메시지 키들 (AppLocalizations에서 가져오기 위함)
  static const String firstWorkoutMessageKey = 'firstWorkoutMessage';
  static const String weekCompletedMessageKey = 'weekCompletedMessage';
  static const String programCompletedMessageKey = 'programCompletedMessage';

  // 스트릭 관련 메시지 키들 (AppLocalizations에서 가져오기 위함)
  static const String streakStartMessageKey = 'streakStartMessage';
  static const String streakContinueMessageKey = 'streakContinueMessage';
  static const String streakBrokenMessageKey = 'streakBrokenMessage';
}
