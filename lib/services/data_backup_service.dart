import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/workout_history.dart';
import '../models/achievement.dart';
import 'workout_history_service.dart';
import 'achievement_service.dart';
import 'permission_service.dart';
import 'streak_service.dart';

// 백업 빈도 옵션
enum BackupFrequency {
  daily,
  weekly,
  monthly,
  manual,
}

/// 고급 데이터 백업 및 복원 서비스
/// 암호화, 스케줄링, 자동 백업 등의 기능을 제공
class DataBackupService {
  static final DataBackupService _instance = DataBackupService._internal();
  factory DataBackupService() => _instance;
  DataBackupService._internal();

  static const String _backupFileName = 'mission100_backup.json';
  static const String _encryptedBackupFileName = 'mission100_backup_encrypted.json';
  static const String _backupVersionKey = 'backup_version';
  static const String _lastBackupTimeKey = 'last_backup_time';
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _backupFrequencyKey = 'backup_frequency';
  static const String _backupEncryptionEnabledKey = 'backup_encryption_enabled';
  static const String _backupPasswordHashKey = 'backup_password_hash';
  
  // 백업 버전
  static const String currentBackupVersion = '2.0.0';
  
  /// 백업 생성 (암호화 옵션 포함)
  Future<BackupResult> createBackup({
    String? password,
    bool encrypt = false,
    String? customFileName,
  }) async {
    try {
      debugPrint('🔄 고급 백업 시작...');
      
      // 백업 데이터 수집
      final backupData = await _collectComprehensiveBackupData();
      
      // JSON 변환
      String jsonString = jsonEncode(backupData);
      
      // 암호화 처리
      if (encrypt && password != null) {
        jsonString = await _encryptBackupData(jsonString, password);
      }
      
      // 파일명 결정
      final fileName = customFileName ?? 
          (encrypt ? _encryptedBackupFileName : _backupFileName);
      
      // 백업 크기 계산
      final sizeInBytes = utf8.encode(jsonString).length;
      
      // 마지막 백업 시간 저장
      await _saveLastBackupTime();
      
      debugPrint('✅ 백업 데이터 생성 완료 (크기: ${_formatFileSize(sizeInBytes)})');
      
      return BackupResult(
        success: true,
        data: jsonString,
        fileName: fileName,
        size: sizeInBytes,
        isEncrypted: encrypt,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      debugPrint('❌ 백업 생성 실패: $e');
      return BackupResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 백업을 파일로 내보내기
  Future<String?> exportBackupToFile({
    String? password,
    bool encrypt = false,
    BuildContext? context,
  }) async {
    try {
      // 권한 체크
      if (context != null && Platform.isAndroid) {
        final hasPermission = await PermissionService.checkAndRequestStoragePermissionForBackup(context);
        if (!hasPermission) {
          debugPrint('❌ 저장소 권한이 없어 백업을 취소합니다');
          return null;
        }
      }
      
      // 백업 생성
      final backupResult = await createBackup(
        password: password,
        encrypt: encrypt,
      );
      
      if (!backupResult.success) {
        debugPrint('❌ 백업 실패: ${backupResult.error}');
        return null;
      }
      
      // 백업 데이터를 bytes로 변환
      final bytes = utf8.encode(backupResult.data!);
      
      // 파일 저장 위치 선택 (새로운 방식 - bytes 사용)
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Mission 100 백업 파일 저장',
        fileName: backupResult.fileName,
        bytes: Uint8List.fromList(bytes), // bytes 파라미터 사용
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null) {
        debugPrint('❌ 사용자가 파일 저장을 취소했습니다');
        return null;
      }
      
      debugPrint('✅ 백업 파일 저장 완료: $result');
      return result;
      
    } catch (e) {
      debugPrint('❌ 백업 파일 저장 실패: $e');
      return null;
    }
  }

  /// 백업 파일에서 데이터 복원
  Future<bool> restoreFromBackup({
    String? filePath,
    String? password,
    BuildContext? context,
  }) async {
    try {
      debugPrint('🔄 백업 복원 시작...');
      
      String? backupData;
      
      if (filePath != null) {
        // 파일 경로가 제공된 경우
        final file = File(filePath);
        if (!await file.exists()) {
          debugPrint('❌ 파일이 존재하지 않습니다: $filePath');
          return false;
        }
        backupData = await file.readAsString();
      } else {
        // 파일 선택 다이얼로그
        if (context != null && Platform.isAndroid) {
          final hasPermission = await PermissionService.checkAndRequestStoragePermissionForBackup(context);
          if (!hasPermission) {
            debugPrint('❌ 저장소 권한이 없어 복원을 취소합니다');
            return false;
          }
        }
        
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
        backupData = await file.readAsString();
      }
      
      // 암호화된 백업인지 확인 및 복호화
      if (password != null) {
        backupData = await _decryptBackupData(backupData, password);
        if (backupData == null) {
          debugPrint('❌ 백업 복호화 실패 - 잘못된 비밀번호');
          return false;
        }
      }
      
      // JSON 파싱
      final backupMap = jsonDecode(backupData) as Map<String, dynamic>;
      
      // 백업 데이터 유효성 검사
      if (!_validateBackupData(backupMap)) {
        debugPrint('❌ 유효하지 않은 백업 파일입니다');
        return false;
      }
      
      // 데이터 복원
      await _restoreBackupData(backupMap);
      
      debugPrint('✅ 백업 복원 완료');
      return true;
      
    } catch (e) {
      debugPrint('❌ 백업 복원 실패: $e');
      return false;
    }
  }

  /// 포괄적인 백업 데이터 수집
  Future<Map<String, dynamic>> _collectComprehensiveBackupData() async {
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
    
    // 스트릭 데이터
    final streakService = StreakService();
    final streakStatus = await streakService.getStreakStatus();
    final unlockedMilestones = await streakService.getUnlockedMilestones();
    
    return {
      'version': currentBackupVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0', // 앱 버전 정보
      'deviceInfo': await _getDeviceInfo(),
      'preferences': prefsData,
      'workoutRecords': workoutData,
      'achievements': achievementData,
      'streakData': {
        'status': streakStatus,
        'unlockedMilestones': unlockedMilestones.toList(),
      },
      'metadata': {
        'totalWorkouts': workoutRecords.length,
        'totalAchievements': achievements.length,
        'backupSize': 0, // 나중에 계산
      },
    };
  }

  /// 백업 데이터 암호화
  Future<String> _encryptBackupData(String data, String password) async {
    try {
      // 비밀번호에서 키 생성 (PBKDF2 사용)
      final passwordBytes = utf8.encode(password);
      final salt = List<int>.generate(16, (i) => DateTime.now().millisecondsSinceEpoch % 256);
      
      // 간단한 키 파생 (실제로는 PBKDF2를 사용해야 함)
      final keyBytes = sha256.convert(passwordBytes + salt).bytes;
      final key = encrypt.Key(Uint8List.fromList(keyBytes.take(32).toList()));
      final iv = encrypt.IV.fromSecureRandom(16);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      // 데이터 암호화
      final encrypted = encrypter.encrypt(data, iv: iv);
      
      // 암호화된 데이터와 메타데이터 결합
      final encryptedData = {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
        'salt': base64.encode(salt),
        'algorithm': 'AES-256-CBC',
      };
      
      return jsonEncode(encryptedData);
    } catch (e) {
      throw Exception('암호화 실패: $e');
    }
  }

  /// 백업 데이터 복호화
  Future<String?> _decryptBackupData(String encryptedData, String password) async {
    try {
      final encryptedMap = jsonDecode(encryptedData) as Map<String, dynamic>;
      
      final encryptedText = encryptedMap['encrypted'] as String;
      final ivBase64 = encryptedMap['iv'] as String;
      final saltBase64 = encryptedMap['salt'] as String;
      
      final iv = encrypt.IV.fromBase64(ivBase64);
      final salt = base64.decode(saltBase64);
      
      // 키 재생성
      final passwordBytes = utf8.encode(password);
      final keyBytes = sha256.convert(passwordBytes + salt).bytes;
      final key = encrypt.Key(Uint8List.fromList(keyBytes.take(32).toList()));
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('복호화 오류: $e');
      return null;
    }
  }

  /// 백업 데이터 유효성 검사
  bool _validateBackupData(Map<String, dynamic> data) {
    final requiredKeys = [
      'version',
      'timestamp',
      'preferences',
      'workoutRecords',
      'achievements',
    ];
    
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        debugPrint('❌ 필수 키 누락: $key');
        return false;
      }
    }
    
    // 버전 호환성 검사
    final version = data['version'] as String?;
    if (version == null || !_isVersionCompatible(version)) {
      debugPrint('❌ 호환되지 않는 백업 버전: $version');
      return false;
    }
    
    return true;
  }

  /// 백업 데이터 복원
  Future<void> _restoreBackupData(Map<String, dynamic> data) async {
    // 기존 데이터 초기화
    await _clearAllData();
    
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
    
    // 스트릭 데이터 복원 (버전 2.0.0 이상)
    if (data.containsKey('streakData')) {
      final streakData = data['streakData'] as Map<String, dynamic>;
      // 스트릭 서비스 복원 로직 구현 필요
      debugPrint('스트릭 데이터 복원: ${streakData.keys}');
    }
  }

  /// 모든 데이터 초기화
  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await WorkoutHistoryService.clearAllRecords();
    await AchievementService.resetAchievementDatabase();
    
    // 스트릭 데이터 초기화
    final streakService = StreakService();
    await streakService.resetStreak();
  }

  /// 버전 호환성 검사
  bool _isVersionCompatible(String version) {
    // 현재는 모든 버전을 호환으로 처리
    // 향후 버전별 호환성 로직 구현
    return true;
  }

  /// 디바이스 정보 수집
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 파일 크기 포맷팅
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 마지막 백업 시간 저장
  Future<void> _saveLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupTimeKey, DateTime.now().toIso8601String());
  }

  /// 마지막 백업 시간 가져오기
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastBackupTimeKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// 백업 설정 저장
  Future<void> saveBackupSettings({
    bool? autoBackupEnabled,
    BackupFrequency? frequency,
    bool? encryptionEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (autoBackupEnabled != null) {
      await prefs.setBool(_autoBackupEnabledKey, autoBackupEnabled);
    }
    
    if (frequency != null) {
      await prefs.setString(_backupFrequencyKey, frequency.name);
    }
    
    if (encryptionEnabled != null) {
      await prefs.setBool(_backupEncryptionEnabledKey, encryptionEnabled);
    }
  }

  /// 백업 설정 가져오기
  Future<BackupSettings> getBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final autoBackupEnabled = prefs.getBool(_autoBackupEnabledKey) ?? false;
    final frequencyString = prefs.getString(_backupFrequencyKey) ?? 'weekly';
    final encryptionEnabled = prefs.getBool(_backupEncryptionEnabledKey) ?? false;
    
    BackupFrequency frequency;
    try {
      frequency = BackupFrequency.values.firstWhere(
        (e) => e.name == frequencyString,
      );
    } catch (e) {
      frequency = BackupFrequency.weekly;
    }
    
    return BackupSettings(
      autoBackupEnabled: autoBackupEnabled,
      frequency: frequency,
      encryptionEnabled: encryptionEnabled,
    );
  }
}

/// 백업 결과 클래스
class BackupResult {
  final bool success;
  final String? data;
  final String? fileName;
  final int? size;
  final bool? isEncrypted;
  final DateTime? timestamp;
  final String? error;

  BackupResult({
    required this.success,
    this.data,
    this.fileName,
    this.size,
    this.isEncrypted,
    this.timestamp,
    this.error,
  });
}

/// 백업 설정 클래스
class BackupSettings {
  final bool autoBackupEnabled;
  final BackupFrequency frequency;
  final bool encryptionEnabled;

  BackupSettings({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.encryptionEnabled,
  });
} 