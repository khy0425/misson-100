import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/initial_test_screen.dart';
import 'screens/home_screen.dart';
import 'providers/locale_provider.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 광고 서비스 초기화
  await AdService.initialize();

  runApp(ProviderScope(child: Mission100App()));
}

class Mission100App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locale, // 동적 언어 설정
      home: SplashScreen(),
      routes: {
        '/initial-test': (context) => InitialTestScreen(),
        '/home': (context) => HomeScreen(),
        // TODO: 추후 다른 화면들 추가
      },
      localizationsDelegates: [
        AppLocalizations.localizationsDelegates,
      ].expand((x) => x).toList(),
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

// 임시 스플래시 화면 (추후 별도 파일로 분리)
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeShort = ref.watch(localeShortProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(AppColors.chadGradient[0]),
              Color(AppColors.chadGradient[1]),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 언어 토글 버튼 (상단 우측)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingM),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(localeProvider.notifier).toggleLocale();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingM,
                        vertical: AppConstants.paddingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, size: 16),
                        SizedBox(width: 4),
                        Text(
                          localeShort,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeS,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 기존 콘텐츠
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 차드 이미지
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXL,
                          ),
                          child: Image.asset(
                            'assets/images/수면모자차드.jpg',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusXL,
                                  ),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // 앱 타이틀 (영문 고정)
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mission: 100', // 영문 고정
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeXXL,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingS),
                          Text(
                            AppConstants.appSubtitle,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeL,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingM),
                          Text(
                            AppConstants.appSlogan,
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeM,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // 시작 버튼
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/initial-test');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(AppColors.primaryColor),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingXL,
                                vertical: AppConstants.paddingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusL,
                                ),
                              ),
                              elevation: AppConstants.elevationM,
                            ),
                            child: Text(
                              'Start for Chad', // 영문 고정
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: AppConstants.paddingL),
                          Text(
                            'Real Chads don\'t make excuses',
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeS,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
