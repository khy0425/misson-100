@echo off
echo 🚀 Mission: 100 릴리즈 빌드 시작...
echo.

echo 📝 1단계: 의존성 업데이트
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 의존성 업데이트 실패
    pause
    exit /b 1
)

echo 🧹 2단계: 빌드 캐시 정리
call flutter clean
if %errorlevel% neq 0 (
    echo ❌ 캐시 정리 실패
    pause
    exit /b 1
)

echo 📝 3단계: 의존성 재설치
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 의존성 재설치 실패
    pause
    exit /b 1
)

echo 🔍 4단계: 코드 분석
call flutter analyze
if %errorlevel% neq 0 (
    echo ⚠️ 코드 분석에서 경고 발견 (계속 진행)
)

echo 🔐 5단계: 키스토어 확인
if not exist "android\app-release.jks" (
    echo ❌ 키스토어 파일이 없습니다!
    echo android\create_keystore.bat를 실행하여 키스토어를 먼저 생성하세요.
    pause
    exit /b 1
)

if not exist "android\key.properties" (
    echo ❌ key.properties 파일이 없습니다!
    echo android\key.properties 파일을 확인하고 키스토어 정보를 입력하세요.
    pause
    exit /b 1
)

echo 🏗️ 6단계: AAB (Android App Bundle) 빌드
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ AAB 빌드 실패
    pause
    exit /b 1
)

echo 📦 7단계: APK 빌드
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ APK 빌드 실패
    pause
    exit /b 1
)

echo.
echo ✅ 빌드 완료!
echo.
echo 📱 생성된 파일:
echo - AAB: build\app\outputs\bundle\release\app-release.aab (Google Play 업로드용)
echo - APK: build\app\outputs\flutter-apk\app-release.apk (직접 설치용)
echo.
echo 🎯 Google Play Console에 app-release.aab 파일을 업로드하세요!
echo.
pause 