import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static const String _storagePermissionAskedKey = 'storage_permission_asked';
  static const String _notificationPermissionAskedKey = 'notification_permission_asked';
  
  /// 앱 시작 시 필요한 권한들을 체크하고 요청
  static Future<void> checkInitialPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;
    
    try {
      debugPrint('🔐 앱 시작 시 권한 체크 시작...');
      
      // 알림 권한 체크 (Android 13+)
      await _checkNotificationPermission(context);
      
      // 저장소 권한 체크 (필요한 경우에만)
      await _checkStoragePermissionIfNeeded(context);
      
    } catch (e) {
      debugPrint('❌ 초기 권한 체크 실패: $e');
    }
  }
  
  /// 알림 권한 체크 및 요청
  static Future<void> _checkNotificationPermission(BuildContext context) async {
    try {
      final androidInfo = await _getAndroidInfo();
      
      // Android 13 이상에서만 알림 권한 필요
      if (androidInfo.version.sdkInt >= 33) {
        final prefs = await SharedPreferences.getInstance();
        final hasAskedBefore = prefs.getBool(_notificationPermissionAskedKey) ?? false;
        
        if (!hasAskedBefore) {
          final status = await Permission.notification.status;
          
          if (!status.isGranted) {
            final shouldRequest = await _showNotificationPermissionDialog(context);
            
            if (shouldRequest) {
              await Permission.notification.request();
            }
          }
          
          await prefs.setBool(_notificationPermissionAskedKey, true);
        }
      }
    } catch (e) {
      debugPrint('❌ 알림 권한 체크 실패: $e');
    }
  }
  
  /// 저장소 권한 체크 (필요한 경우에만)
  static Future<void> _checkStoragePermissionIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAskedBefore = prefs.getBool(_storagePermissionAskedKey) ?? false;
      
      if (!hasAskedBefore) {
        debugPrint('📱 저장소 권한 요청 중...');
        
        final androidInfo = await _getAndroidInfo();
        
        // Android 13+ (API 33+)에서는 파일 선택기 사용을 권장
        if (androidInfo.version.sdkInt >= 33) {
          debugPrint('📱 Android 13+ 감지 - 파일 선택기 사용');
          await prefs.setBool(_storagePermissionAskedKey, true);
          return;
        }
        
        // Android 12 이하에서만 저장소 권한 요청
        if (context.mounted) {
          final shouldRequest = await _showStoragePermissionDialog(context);
          
          if (shouldRequest) {
            debugPrint('📱 저장소 권한 요청 시작...');
            await Permission.storage.request();
            debugPrint('📱 저장소 권한 요청 완료');
          }
        }
        
        await prefs.setBool(_storagePermissionAskedKey, true);
      }
    } catch (e) {
      debugPrint('❌ 저장소 권한 체크 실패: $e');
      
      // 오류 발생 시에도 다시 요청하지 않도록 플래그 설정
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_storagePermissionAskedKey, true);
      } catch (prefsError) {
        debugPrint('❌ SharedPreferences 저장 실패: $prefsError');
      }
    }
  }
  
  /// 알림 권한 요청 다이얼로그
  static Future<bool> _showNotificationPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange),
              SizedBox(width: 8),
              Text('🔔 알림 허용'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운동 알림을 받기 위해 알림 권한이 필요합니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• 일일 운동 리마인더',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• 목표 달성 축하',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• 연속 기록 유지 알림',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '나중에',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('허용'),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// 저장소 권한 요청 다이얼로그
  static Future<bool> _showStoragePermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.folder, color: Colors.blue),
              SizedBox(width: 8),
              Text('📁 저장소 접근'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운동 데이터 백업/복원을 위해 저장소 접근 권한이 필요합니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.backup, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• 운동 기록 백업',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.restore, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• 데이터 복원',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '💡 Android 13+에서는 파일 선택기를 사용하므로 이 권한이 필요하지 않습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '나중에',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('허용'),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// 저장소 권한 요청
  static Future<PermissionStatus> requestStoragePermission() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    
    try {
      debugPrint('📱 저장소 권한 요청 중...');
      
      final androidInfo = await _getAndroidInfo();
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - 파일 선택기 사용으로 권한 불필요
        debugPrint('📱 Android 13+ 감지 - 파일 선택기 사용');
        return PermissionStatus.granted;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - MANAGE_EXTERNAL_STORAGE 권한 시도
        debugPrint('📱 Android 11-12 감지 - MANAGE_EXTERNAL_STORAGE 권한 요청');
        final manageStatus = await Permission.manageExternalStorage.status;
        
        if (!manageStatus.isGranted) {
          final result = await Permission.manageExternalStorage.request();
          if (result.isGranted) {
            return result;
          }
        } else {
          return manageStatus;
        }
        
        // MANAGE_EXTERNAL_STORAGE가 거부되면 일반 저장소 권한으로 폴백
        return await Permission.storage.request();
      } else {
        // Android 10 이하 - 일반 저장소 권한
        debugPrint('📱 Android 10 이하 감지 - 일반 저장소 권한 요청');
        return await Permission.storage.request();
      }
    } catch (e) {
      debugPrint('❌ 저장소 권한 요청 실패: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// 현재 저장소 권한 상태 확인
  static Future<PermissionStatus> getStoragePermissionStatus() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    
    try {
      final androidInfo = await _getAndroidInfo();
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 33) {
        // Android 13+ - 파일 선택기 사용으로 권한 불필요
        return PermissionStatus.granted;
      } else if (sdkInt >= 30) {
        // Android 11-12 - MANAGE_EXTERNAL_STORAGE 우선 확인
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          return manageStatus;
        }
        // 없으면 일반 저장소 권한 확인
        return await Permission.storage.status;
      } else {
        // Android 10 이하 - 일반 저장소 권한
        return await Permission.storage.status;
      }
    } catch (e) {
      debugPrint('❌ 권한 상태 확인 실패: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// 백업/복원 시 권한 체크 및 재요청
  static Future<bool> checkAndRequestStoragePermissionForBackup(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    
    try {
      final androidInfo = await _getAndroidInfo();
      final sdkInt = androidInfo.version.sdkInt;
      
      // Android 13+ 에서는 파일 선택기 사용으로 권한 불필요
      if (sdkInt >= 33) {
        debugPrint('📱 Android 13+ - 파일 선택기 사용으로 권한 체크 생략');
        return true;
      }
      
      final status = await getStoragePermissionStatus();
      
      if (status.isGranted) {
        return true;
      }
      
      // 권한이 없는 경우 재요청 다이얼로그 표시
      final shouldRequest = await _showBackupPermissionDialog(context);
      
      if (!shouldRequest) {
        return false;
      }
      
      // 권한 재요청
      final newStatus = await requestStoragePermission();
      
      if (!newStatus.isGranted) {
        // 권한이 거부된 경우 설정으로 이동 안내
        await _showPermissionDeniedDialog(context);
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ 백업용 권한 체크 실패: $e');
      return false;
    }
  }
  
  /// 백업/복원용 권한 요청 다이얼로그
  static Future<bool> _showBackupPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: Colors.orange),
            SizedBox(width: 8),
            Text('저장소 권한 필요'),
          ],
        ),
        content: const Text(
          '데이터 백업 및 복원 기능을 사용하려면\n저장소 접근 권한이 필요합니다.\n\n'
          '권한을 허용하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('권한 허용'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// 권한 거부 시 설정 이동 안내 다이얼로그
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('권한 필요'),
          ],
        ),
        content: const Text(
          '저장소 권한이 거부되었습니다.\n\n'
          '백업/복원 기능을 사용하려면 설정에서\n수동으로 권한을 허용해주세요.\n\n'
          '설정 > 앱 > Mission 100 > 권한 > 저장소',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }
  
  /// Android 정보 가져오기
  static Future<AndroidDeviceInfo> _getAndroidInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.androidInfo;
  }
  
  /// 권한 상태를 사용자 친화적 문자열로 변환
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '허용됨';
      case PermissionStatus.denied:
        return '거부됨';
      case PermissionStatus.restricted:
        return '제한됨';
      case PermissionStatus.limited:
        return '제한적 허용';
      case PermissionStatus.permanentlyDenied:
        return '영구 거부됨';
      default:
        return '알 수 없음';
    }
  }
  
  /// 알림 권한 상태 확인
  static Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final androidInfo = await _getAndroidInfo();
      
      // Android 13 미만에서는 알림 권한이 자동으로 허용됨
      if (androidInfo.version.sdkInt < 33) {
        return true;
      }
      
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ 알림 권한 상태 확인 실패: $e');
      return false;
    }
  }
  
  /// 알림 권한 요청
  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final androidInfo = await _getAndroidInfo();
      
      // Android 13 미만에서는 알림 권한이 자동으로 허용됨
      if (androidInfo.version.sdkInt < 33) {
        return true;
      }
      
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ 알림 권한 요청 실패: $e');
      return false;
    }
  }
} 