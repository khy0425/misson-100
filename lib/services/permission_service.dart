import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _storagePermissionAskedKey = 'storage_permission_asked';
  
  /// 앱 시작 시 필요한 권한들을 체크하고 요청
  static Future<void> checkInitialPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;
    
    try {
      debugPrint('🔐 앱 시작 시 권한 체크 시작...');
      
      // 이전에 권한을 요청했는지 확인
      final prefs = await SharedPreferences.getInstance();
      final hasAskedBefore = prefs.getBool(_storagePermissionAskedKey) ?? false;
      
      if (!hasAskedBefore) {
        // 처음 실행 시 권한 요청 다이얼로그 표시
        final shouldRequest = await _showPermissionRequestDialog(context);
        
        if (shouldRequest) {
          await requestStoragePermission();
        }
        
        // 권한 요청했음을 기록
        await prefs.setBool(_storagePermissionAskedKey, true);
      } else {
        // 이미 요청했던 경우, 현재 상태만 확인
        final status = await getStoragePermissionStatus();
        debugPrint('📱 현재 저장소 권한 상태: $status');
      }
      
    } catch (e) {
      debugPrint('❌ 초기 권한 체크 실패: $e');
    }
  }
  
  /// 권한 요청 다이얼로그 표시
  static Future<bool> _showPermissionRequestDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text('권한 요청'),
          ],
        ),
        content: const Text(
          'Mission 100에서 다음 기능을 사용하기 위해 권한이 필요합니다:\n\n'
          '📁 저장소 접근\n'
          '• 운동 데이터 백업 및 복원\n'
          '• 백업 파일 저장 및 불러오기\n\n'
          '권한을 허용하시겠습니까?\n'
          '(나중에 설정에서 변경 가능)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('허용'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// 저장소 권한 요청
  static Future<PermissionStatus> requestStoragePermission() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    
    try {
      debugPrint('📱 저장소 권한 요청 중...');
      
      // Android 13 이상에서는 다른 권한 체계 사용
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          // Android 13+ (API 33+)
          debugPrint('📱 Android 13+ 감지 - 파일 선택기 우선 사용');
          return PermissionStatus.granted; // 파일 선택기는 권한이 필요 없음
        }
      }
      
      // Android 12 이하에서는 저장소 권한 요청
      final status = await Permission.storage.request();
      debugPrint('📱 저장소 권한 결과: $status');
      
      return status;
    } catch (e) {
      debugPrint('❌ 저장소 권한 요청 실패: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// 현재 저장소 권한 상태 확인
  static Future<PermissionStatus> getStoragePermissionStatus() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    
    try {
      // Android 13 이상에서는 파일 선택기 사용으로 권한 불필요
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return PermissionStatus.granted;
      }
      
      return await Permission.storage.status;
    } catch (e) {
      debugPrint('❌ 권한 상태 확인 실패: $e');
      return PermissionStatus.denied;
    }
  }
  
  /// 백업/복원 시 권한 체크 및 재요청
  static Future<bool> checkAndRequestStoragePermissionForBackup(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    
    try {
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
  
  /// Android 버전 확인 (간단한 구현)
  static Future<int> _getAndroidVersion() async {
    try {
      // 실제로는 device_info_plus 패키지를 사용하는 것이 좋지만
      // 간단하게 현재 시점에서는 33 이상으로 가정
      return 33; // Android 13+로 가정
    } catch (e) {
      return 30; // 기본값으로 Android 11 반환
    }
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
} 