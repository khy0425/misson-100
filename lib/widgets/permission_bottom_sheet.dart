import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 권한 요청을 위한 하단 시트 다이얼로그
class PermissionBottomSheet extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final List<String> benefits;
  final VoidCallback? onAccept;
  final VoidCallback? onDeny;

  const PermissionBottomSheet({
    super.key,
    required this.permission,
    required this.title,
    required this.description,
    required this.benefits,
    this.onAccept,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 핸들
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 아이콘
                Row(
                  children: [
                    _getPermissionIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 설명
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 혜택 목록
                if (benefits.isNotEmpty) ...[
                  const Text(
                    '허용하면 다음 기능을 이용할 수 있습니다:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                const SizedBox(height: 24),
                
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          onDeny?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '나중에',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          onAccept?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPermissionColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          '허용',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // 안전 바닥 여백
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 권한 유형에 따른 아이콘 반환
  Widget _getPermissionIcon() {
    switch (permission) {
      case Permission.notification:
        return const Icon(
          Icons.notifications_active,
          color: Colors.orange,
          size: 28,
        );
      case Permission.storage:
        return const Icon(
          Icons.folder,
          color: Colors.blue,
          size: 28,
        );
      default:
        return const Icon(
          Icons.security,
          color: Colors.grey,
          size: 28,
        );
    }
  }

  /// 권한 유형에 따른 색상 반환
  Color _getPermissionColor() {
    switch (permission) {
      case Permission.notification:
        return Colors.orange;
      case Permission.storage:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 알림 권한 요청 시트 표시
  static Future<bool?> showNotificationPermissionSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PermissionBottomSheet(
        permission: Permission.notification,
        title: '🔔 알림 허용',
        description: '운동 알림을 받기 위해 알림 권한이 필요합니다.',
        benefits: [
          '일일 운동 리마인더',
          '목표 달성 축하 알림',
          '연속 기록 유지 알림',
          '새로운 도전과제 알림',
        ],
      ),
    );
  }

  /// 백업 권한 요청 시트 표시
  static Future<bool?> showBackupPermissionSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PermissionBottomSheet(
        permission: Permission.storage,
        title: '💾 백업 기능',
        description: '운동 데이터를 안전하게 백업하기 위해 저장소 접근이 필요합니다.',
        benefits: [
          '운동 기록 자동 백업',
          '기기 변경 시 데이터 복원',
          '데이터 손실 방지',
          '안전한 데이터 보관',
        ],
      ),
    );
  }

  /// 저장소 권한 요청 시트 표시
  static Future<bool?> showStoragePermissionSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PermissionBottomSheet(
        permission: Permission.storage,
        title: '📁 저장소 접근',
        description: '운동 데이터 백업/복원을 위해 저장소 접근 권한이 필요합니다.',
        benefits: [
          '운동 기록 백업',
          '데이터 복원',
          '운동 사진 저장',
          '공유 기능 활용',
        ],
      ),
    );
  }
}

/// 권한 요청 결과를 저장하는 서비스
class PermissionRequestStorage {
  static const String _keyPrefix = 'permission_request_';
  
  /// 권한 요청 결과 저장
  static Future<void> savePermissionRequest({
    required Permission permission,
    required bool granted,
    required DateTime requestTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionKey = '${_keyPrefix}${permission.toString()}';
      
      final requestData = {
        'granted': granted,
        'requestTime': requestTime.millisecondsSinceEpoch,
        'permissionType': permission.toString(),
        'saveTime': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(permissionKey, jsonEncode(requestData));
      
      debugPrint('🔐 권한 요청 저장됨: ${permission.toString()} = $granted (${requestTime.toIso8601String()})');
    } catch (e) {
      debugPrint('❌ 권한 요청 저장 실패: $e');
    }
  }
  
  /// 권한 요청 기록 조회
  static Future<Map<String, dynamic>?> getPermissionRequest(Permission permission) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionKey = '${_keyPrefix}${permission.toString()}';
      final requestDataString = prefs.getString(permissionKey);
      
      if (requestDataString != null) {
        final requestData = jsonDecode(requestDataString) as Map<String, dynamic>;
        return {
          'found': true,
          'granted': requestData['granted'] as bool,
          'requestTime': DateTime.fromMillisecondsSinceEpoch(requestData['requestTime'] as int),
          'saveTime': DateTime.fromMillisecondsSinceEpoch(requestData['saveTime'] as int),
          'permissionType': requestData['permissionType'] as String,
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 권한 요청 기록 조회 실패: $e');
      return null;
    }
  }

  /// 모든 권한 요청 기록 삭제
  static Future<void> clearAllPermissionRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix)).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      debugPrint('🔐 모든 권한 요청 기록 삭제 완료: ${keys.length}개');
    } catch (e) {
      debugPrint('❌ 권한 요청 기록 삭제 실패: $e');
    }
  }

  /// 특정 권한 요청 기록 삭제
  static Future<void> clearPermissionRequest(Permission permission) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionKey = '${_keyPrefix}${permission.toString()}';
      await prefs.remove(permissionKey);
      
      debugPrint('🔐 권한 요청 기록 삭제됨: ${permission.toString()}');
    } catch (e) {
      debugPrint('❌ 권한 요청 기록 삭제 실패: $e');
    }
  }
} 