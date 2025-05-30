import 'package:flutter/foundation.dart';

/// 빌드 설정 및 환경 관리 유틸리티
class BuildConfig {
  /// 현재 빌드가 AAB 모드인지 확인 (환경 변수 기반)
  static const bool isAABBuild = bool.fromEnvironment('AAB_BUILD', defaultValue: false);
  
  /// 현재 빌드가 실제 광고를 사용해야 하는지 확인
  /// 기본: 릴리즈 모드에서만 실제 광고 사용
  /// AAB 모드: 디버그 모드여도 실제 광고 사용
  static bool get shouldUseRealAds {
    // AAB 빌드인 경우 항상 실제 광고 사용
    if (isAABBuild) {
      return true;
    }
    
    // 일반 빌드인 경우 릴리즈 모드에서만 실제 광고 사용
    return kReleaseMode;
  }
  
  /// 현재 빌드 환경 정보
  static Map<String, dynamic> get buildInfo {
    return {
      'isAABBuild': isAABBuild,
      'isReleaseMode': kReleaseMode,
      'isProfileMode': kProfileMode,
      'isDebugMode': kDebugMode,
      'shouldUseRealAds': shouldUseRealAds,
      'buildMode': kReleaseMode 
          ? 'release' 
          : kProfileMode 
              ? 'profile' 
              : 'debug',
    };
  }
  
  /// 빌드 정보를 디버그 콘솔에 출력
  static void logBuildInfo() {
    debugPrint('🔧 빌드 설정 정보:');
    buildInfo.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }
} 