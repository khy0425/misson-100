import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/workout_history.dart';
import '../models/achievement.dart';
import 'workout_history_service.dart';
import 'achievement_service.dart';

class DataService {
  static const String _backupFileName = 'mission100_backup.json';
  
  /// 데이터 백업
  static Future<String?> backupData() async {
    try {
      debugPrint('🔄 데이터 백업 시작...');
      
      // 권한 확인
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          debugPrint('❌ 저장소 권한이 거부되었습니다');
          return null;
        }
      }
      
      // 백업할 데이터 수집
      final backupData = await _collectBackupData();
      
      // JSON으로 변환
      final jsonString = jsonEncode(backupData);
      
      // 파일 저장 위치 선택
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Mission 100 백업 파일 저장',
        fileName: _backupFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null) {
        debugPrint('❌ 사용자가 파일 저장을 취소했습니다');
        return null;
      }
      
      // 파일 저장
      final file = File(result);
      await file.writeAsString(jsonString);
      
      debugPrint('✅ 백업 완료: ${file.path}');
      return file.path;
      
    } catch (e) {
      debugPrint('❌ 백업 실패: $e');
      return null;
    }
  }
  
  /// 데이터 복원
  static Future<bool> restoreData() async {
    try {
      debugPrint('🔄 데이터 복원 시작...');
      
      // 백업 파일 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Mission 100 백업 파일 선택',
      );
      
      if (result == null || result.files.isEmpty) {
        debugPrint('❌ 파일이 선택되지 않았습니다');
        return false;
      }
      
      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        debugPrint('❌ 파일이 존재하지 않습니다');
        return false;
      }
      
      // 파일 읽기
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 데이터 유효성 검사
      if (!_validateBackupData(backupData)) {
        debugPrint('❌ 유효하지 않은 백업 파일입니다');
        return false;
      }
      
      // 데이터 복원
      await _restoreBackupData(backupData);
      
      debugPrint('✅ 복원 완료');
      return true;
      
    } catch (e) {
      debugPrint('❌ 복원 실패: $e');
      return false;
    }
  }
  
  /// 모든 데이터 초기화
  static Future<bool> resetAllData() async {
    try {
      debugPrint('🔄 데이터 초기화 시작...');
      
      // SharedPreferences 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 운동 기록 초기화
      await WorkoutHistoryService.clearAllRecords();
      
      // 업적 초기화
      await AchievementService.resetAchievementDatabase();
      
      debugPrint('✅ 모든 데이터 초기화 완료');
      return true;
      
    } catch (e) {
      debugPrint('❌ 데이터 초기화 실패: $e');
      return false;
    }
  }
  
  /// 백업할 데이터 수집
  static Future<Map<String, dynamic>> _collectBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // SharedPreferences 데이터
    final prefsData = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      prefsData[key] = value;
    }
    
    // 운동 기록 데이터
    final workoutRecords = await WorkoutHistoryService.getAllWorkouts();
    final workoutData = workoutRecords.map((record) => record.toMap()).toList();
    
    // 업적 데이터
    final achievements = await AchievementService.getAllAchievements();
    final achievementData = achievements.map((achievement) => achievement.toMap()).toList();
    
    return {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'preferences': prefsData,
      'workoutRecords': workoutData,
      'achievements': achievementData,
    };
  }
  
  /// 백업 데이터 유효성 검사
  static bool _validateBackupData(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('timestamp') &&
           data.containsKey('preferences') &&
           data.containsKey('workoutRecords') &&
           data.containsKey('achievements');
  }
  
  /// 백업 데이터 복원
  static Future<void> _restoreBackupData(Map<String, dynamic> data) async {
    // 기존 데이터 초기화
    await resetAllData();
    
    // SharedPreferences 복원
    final prefs = await SharedPreferences.getInstance();
    final prefsData = data['preferences'] as Map<String, dynamic>;
    
    for (final entry in prefsData.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
    
    // 운동 기록 복원
    final workoutData = data['workoutRecords'] as List<dynamic>;
    for (final recordData in workoutData) {
      final record = WorkoutHistory.fromMap(recordData as Map<String, dynamic>);
      await WorkoutHistoryService.saveWorkoutHistory(record);
    }
    
    // 업적 복원
    final achievementData = data['achievements'] as List<dynamic>;
    for (final achData in achievementData) {
      final achievement = Achievement.fromMap(achData as Map<String, dynamic>);
      await AchievementService.saveAchievement(achievement);
    }
  }
  
  /// 백업 파일 크기 계산
  static Future<String> getBackupSize() async {
    try {
      final backupData = await _collectBackupData();
      final jsonString = jsonEncode(backupData);
      final sizeInBytes = utf8.encode(jsonString).length;
      
      if (sizeInBytes < 1024) {
        return '${sizeInBytes}B';
      } else if (sizeInBytes < 1024 * 1024) {
        return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
      } else {
        return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      return '알 수 없음';
    }
  }
  
  /// 마지막 백업 시간 가져오기
  static Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('last_backup_time');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      debugPrint('마지막 백업 시간 조회 실패: $e');
    }
    return null;
  }
  
  /// 마지막 백업 시간 저장
  static Future<void> saveLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_time', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('마지막 백업 시간 저장 실패: $e');
    }
  }
} 