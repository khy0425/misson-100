# 🚀 AAB 빌드 및 광고 설정 가이드

## 📋 개요

이 가이드는 Mission: 100 앱의 Android App Bundle (AAB) 빌드와 광고 설정에 대한 완전한 설명서입니다.

## 🎯 광고 시스템 구조

### 광고 ID 설정
- **실제 광고 ID**: `ca-app-pub-1075071967728463~6042582986` (앱 ID)
- **배너 광고**: `ca-app-pub-1075071967728463/9498612269`
- **전면 광고**: `ca-app-pub-1075071967728463/7039728635`
- **테스트 광고**: Google 제공 테스트 ID 사용

### 광고 모드 결정 로직

```
1. 환경 변수 우선순위:
   - FORCE_TEST_ADS=true → 강제 테스트 광고
   - FORCE_REAL_ADS=true → 강제 실제 광고

2. BuildConfig 기반 결정:
   - AAB_BUILD=true → 실제 광고 사용 (디버그 모드여도)
   - 일반 빌드 → 릴리즈 모드에서만 실제 광고

3. 기본값: 테스트 광고 사용
```

## 🔧 빌드 명령어

### 1. 일반 디버그 빌드 (테스트 광고)
```bash
flutter build appbundle --debug
```

### 2. AAB 디버그 빌드 (실제 광고)
```bash
flutter build appbundle --dart-define=AAB_BUILD=true --debug
```

### 3. 릴리즈 빌드 (실제 광고)
```bash
flutter build appbundle --release
```

### 4. 환경 변수를 이용한 강제 설정
```bash
# 강제 테스트 광고
flutter build appbundle --dart-define=FORCE_TEST_ADS=true --debug

# 강제 실제 광고
flutter build appbundle --dart-define=FORCE_REAL_ADS=true --debug
```

## 📱 실행 시 로그 확인

앱 실행 시 다음과 같은 로그가 출력됩니다:

```
🔧 빌드 설정 정보:
   isAABBuild: true/false
   isReleaseMode: true/false
   isProfileMode: true/false
   isDebugMode: true/false
   shouldUseRealAds: true/false
   buildMode: debug/profile/release

🔔 광고 서비스 초기화
📊 광고 모드: AAB_BUILD/RELEASE/DEBUG/FORCE_TEST/FORCE_REAL
🎯 배너 광고 ID: ca-app-pub-1075071967728463/9498612269
🎯 전면 광고 ID: ca-app-pub-1075071967728463/7039728635
🧪 테스트 광고 사용: true/false
🚀 AAB 빌드: true/false
💰 실제 광고 사용: true/false
```

## 🎨 위젯 사용법

### AdBannerWidget 사용
```dart
// 자동으로 BuildConfig에 따라 광고 모드 결정
const AdBannerWidget(
  adSize: AdSize.banner,
  showOnError: true,
),

// 명시적으로 AAB 모드 사용 (하위 호환성)
const AdBannerWidget(
  adSize: AdSize.banner,
  useAABMode: true, // 실제 광고 강제 사용
),
```

### 전면 광고 사용
```dart
// 자동으로 BuildConfig에 따라 광고 모드 결정
await AdService.instance.showInterstitialAd();

// 명시적으로 AAB 모드 사용 (하위 호환성)
await AdService.instance.showInterstitialAd(useAABMode: true);
```

## 🔍 디버깅 및 문제 해결

### 1. 광고가 표시되지 않는 경우
- 로그에서 광고 ID 확인
- 네트워크 연결 상태 확인
- Google Mobile Ads SDK 초기화 상태 확인

### 2. 테스트 광고가 계속 나오는 경우
- BuildConfig.shouldUseRealAds 값 확인
- 환경 변수 설정 확인
- 빌드 명령어에 `--dart-define=AAB_BUILD=true` 포함 여부 확인

### 3. 실제 광고가 의도치 않게 나오는 경우
- 환경 변수에 FORCE_REAL_ADS=true 설정되어 있는지 확인
- 릴리즈 모드로 빌드되었는지 확인

## 📝 파일 구조

```
lib/
├── services/
│   └── ad_service.dart          # 광고 서비스 메인 로직
├── widgets/
│   └── ad_banner_widget.dart    # 배너 광고 위젯
├── utils/
│   └── build_config.dart        # 빌드 설정 관리
└── main.dart                    # 앱 초기화 및 빌드 정보 로깅
```

## 🎯 출시 체크리스트

### AAB 빌드 전 확인사항
- [ ] 실제 AdMob 계정 설정 완료
- [ ] 광고 단위 ID 정확성 확인
- [ ] `android/app/src/main/AndroidManifest.xml`에 올바른 앱 ID 설정
- [ ] 테스트 디바이스에서 실제 광고 표시 확인

### AAB 빌드 명령어
```bash
# 최종 출시용 AAB 빌드
flutter build appbundle --release
```

### 업로드 전 최종 확인
- [ ] AAB 파일 크기 적절성 확인
- [ ] 실제 디바이스에서 광고 정상 동작 확인
- [ ] 앱 성능 및 메모리 사용량 확인

## 🚨 주의사항

1. **테스트 광고 절대 출시 금지**: 실제 광고 ID가 설정되었는지 반드시 확인
2. **환경 변수 관리**: 개발 환경에서만 FORCE_* 변수 사용
3. **빌드 설정 검증**: 로그를 통해 항상 광고 모드 확인
4. **네트워크 권한**: 인터넷 연결이 필요한 광고 특성상 권한 확인 필수

## 📞 문의 및 지원

광고 설정이나 AAB 빌드 관련 문제가 있을 경우:
1. 로그에서 BuildConfig 정보 확인
2. AdService 디버그 정보 확인
3. Google Mobile Ads SDK 공식 문서 참조

---

**마지막 업데이트**: $(date)
**빌드 테스트 완료**: ✅ AAB 디버그 빌드 성공 