@echo off
echo 릴리즈 키스토어 생성 중...
echo.
echo 다음 정보를 입력해주세요:
echo - 키스토어 비밀번호 (예: your_keystore_password)
echo - 키 별칭 (예: mission100)
echo - 키 비밀번호 (예: your_key_password)
echo - 본인 이름
echo - 조직 단위 (예: Development Team)
echo - 조직 이름 (예: Mission100 Company)
echo - 도시
echo - 시/도
echo - 국가 코드 (예: KR)
echo.

keytool -genkey -v -keystore app-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mission100

echo.
echo 키스토어 생성 완료!
echo 생성된 파일: android/app-release.jks
echo.
echo 이제 android/key.properties 파일을 확인하고 필요시 수정하세요.
pause 