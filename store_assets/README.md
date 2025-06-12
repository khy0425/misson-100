# Google Play Store Graphics Assets

## 파일 설명

### 1. App Icon (app_icon.svg)
- **크기**: 512x512px
- **형식**: SVG (PNG로 변환 필요)
- **설명**: Google Play Store용 앱 아이콘
- **디자인 요소**:
  - Chad 실루엣과 근육 정의
  - 금색 그라데이션 배경 (앱 테마 색상)
  - "100" 및 "PUSH" 텍스트
  - 덤벨 그래픽 요소
  - 파워풀한 느낌의 장식 요소들

### 2. Feature Graphic (feature_graphic.svg)
- **크기**: 1024x500px
- **형식**: SVG (JPG/PNG로 변환 필요)
- **설명**: Google Play Store 메인 배너 그래픽
- **디자인 요소**:
  - "PUSHUP MASTER" 메인 타이틀
  - "100개의 푸쉬업으로 최강 Chad가 되어라!" 부제목
  - Chad 실루엣과 덤벨 그래픽
  - 앱의 핵심 특징 강조 (6주 프로그램, 개인 맞춤형, Chad 진화)
  - 다크/골드 테마 배경

## SVG를 PNG/JPG로 변환하는 방법

### 방법 1: 온라인 컨버터 사용
1. https://cloudconvert.com/svg-to-png 방문
2. SVG 파일 업로드
3. 해상도 설정:
   - App Icon: 512x512px
   - Feature Graphic: 1024x500px
4. 다운로드

### 방법 2: Inkscape 사용 (권장)
```bash
# App Icon 변환
inkscape --export-png=app_icon.png --export-width=512 --export-height=512 app_icon.svg

# Feature Graphic 변환
inkscape --export-png=feature_graphic.png --export-width=1024 --export-height=500 feature_graphic.svg
```

### 방법 3: ImageMagick 사용
```bash
# App Icon 변환
magick convert -background none -size 512x512 app_icon.svg app_icon.png

# Feature Graphic 변환
magick convert -background none -size 1024x500 feature_graphic.svg feature_graphic.png
```

## Google Play Store 요구사항

### App Icon
- **필수 크기**: 512x512px
- **형식**: 32-bit PNG (alpha 채널 포함)
- **파일 크기**: 1MB 이하
- **디자인 가이드라인**:
  - 단순하고 읽기 쉬운 디자인
  - 작은 크기에서도 식별 가능
  - 브랜드 색상 사용
  - 텍스트 최소화

### Feature Graphic
- **필수 크기**: 1024x500px
- **형식**: JPG 또는 24-bit PNG (alpha 채널 없음)
- **파일 크기**: 1MB 이하
- **디자인 가이드라인**:
  - 앱의 핵심 기능 강조
  - 고품질 그래픽
  - 읽기 쉬운 텍스트
  - 브랜드 일관성

## 브랜딩 가이드라인

### 색상 팔레트
- **주색상**: #FFB000 (금색)
- **부색상**: #FF6B35 (주황색)
- **강조색**: #E53E3E (빨간색)
- **배경**: #000000 ~ #1a1a1a (다크)
- **텍스트**: #FFFFFF (흰색)

### 폰트
- **제목**: Arial Black, Bold
- **본문**: Arial, Medium/Regular
- **강조**: Bold/Heavy weights

### 테마
- Chad/GigaChad 컨셉
- 강인함과 파워 표현
- 피트니스/운동 테마
- 100개 푸쉬업 목표 강조

## 다음 단계
1. SVG 파일들을 적절한 형식으로 변환
2. Google Play Console에 업로드
3. A/B 테스트를 위한 대안 버전 고려
4. 사용자 피드백 수집 및 개선

## 파일 체크리스트
- [ ] app_icon.png (512x512px, PNG)
- [ ] feature_graphic.png/jpg (1024x500px)
- [ ] 파일 크기 확인 (각각 1MB 이하)
- [ ] 품질 확인 (선명도, 색상 정확도)
- [ ] 다양한 화면에서 테스트 