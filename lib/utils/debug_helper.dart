import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DebugHelper {
  /// 모든 업적 관련 SharedPreferences 데이터 초기화
  static Future<void> clearAllAchievementData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 업적 관련 키들 완전 삭제
      await prefs.remove('last_achievement_check');
      await prefs.remove('pending_achievement_events');
      await prefs.remove('new_achievements_count');
      await prefs.remove('achievement_notifications');
      
      debugPrint('🧹 모든 업적 관련 데이터가 초기화되었습니다.');
    } catch (e) {
      debugPrint('❌ 데이터 초기화 실패: $e');
    }
  }
  
  /// 모든 SharedPreferences 데이터 확인
  static Future<void> debugSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      debugPrint('📋 현재 SharedPreferences 데이터:');
      for (final key in keys) {
        final value = prefs.get(key);
        debugPrint('  $key: $value');
      }
    } catch (e) {
      debugPrint('❌ SharedPreferences 확인 실패: $e');
    }
  }
  
  /// 특정 키의 데이터 삭제
  static Future<void> removeKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      debugPrint('🗑️ 키 삭제됨: $key');
    } catch (e) {
      debugPrint('❌ 키 삭제 실패: $e');
    }
  }
} 