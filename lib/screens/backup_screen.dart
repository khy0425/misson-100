import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/app_localizations.dart';
import '../services/data_backup_service.dart';
import '../services/backup_scheduler.dart';

/// 백업 관리 화면
/// 백업 생성, 복원, 설정 관리 기능을 제공
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final DataBackupService _backupService = DataBackupService();
  final BackupScheduler _scheduler = BackupScheduler();
  
  BackupStatus? _backupStatus;
  bool _isLoading = false;
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  /// 백업 상태 로드
  Future<void> _loadBackupStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await _scheduler.getBackupStatus();
      setState(() => _backupStatus = status);
    } catch (e) {
      _showErrorSnackBar('백업 상태를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 수동 백업 생성
  Future<void> _createManualBackup() async {
    setState(() => _isCreatingBackup = true);
    
    try {
      final result = await _scheduler.performManualBackup();
      
      if (result.success) {
        _showSuccessSnackBar('백업이 성공적으로 생성되었습니다');
        await _loadBackupStatus();
      } else {
        _showErrorSnackBar('백업 생성 실패: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('백업 생성 중 오류 발생: $e');
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  /// 암호화된 백업 생성
  Future<void> _createEncryptedBackup() async {
    final password = await _showPasswordDialog('백업 암호화');
    if (password == null || password.isEmpty) return;
    
    setState(() => _isCreatingBackup = true);
    
    try {
      final result = await _scheduler.performManualBackup(
        password: password,
        encrypt: true,
      );
      
      if (result.success) {
        _showSuccessSnackBar('암호화된 백업이 생성되었습니다');
        await _loadBackupStatus();
      } else {
        _showErrorSnackBar('암호화된 백업 생성 실패: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('암호화된 백업 생성 중 오류 발생: $e');
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  /// 백업 파일로 내보내기
  Future<void> _exportBackup() async {
    setState(() => _isCreatingBackup = true);
    
    try {
      final filePath = await _backupService.exportBackupToFile(
        context: context,
      );
      
      if (filePath != null) {
        _showSuccessSnackBar('백업 파일이 저장되었습니다:\n$filePath');
      }
    } catch (e) {
      _showErrorSnackBar('백업 내보내기 실패: $e');
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  /// 백업 복원
  Future<void> _restoreBackup() async {
    setState(() => _isRestoringBackup = true);
    
    try {
      final context = this.context; // BuildContext를 미리 캡처
      final success = await _backupService.restoreFromBackup(
        context: context,
      );
      
      if (success) {
        _showSuccessSnackBar('백업이 성공적으로 복원되었습니다');
        await _loadBackupStatus();
      } else {
        _showErrorSnackBar('백업 복원에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('백업 복원 중 오류 발생: $e');
    } finally {
      if (mounted) setState(() => _isRestoringBackup = false);
    }
  }

  /// 자동 백업 설정 토글
  Future<void> _toggleAutoBackup(bool enabled) async {
    try {
      await _scheduler.updateBackupSettings(
        autoBackupEnabled: enabled,
      );
      
      await _loadBackupStatus();
      
      _showSuccessSnackBar(
        enabled ? '자동 백업이 활성화되었습니다' : '자동 백업이 비활성화되었습니다',
      );
    } catch (e) {
      _showErrorSnackBar('설정 변경 실패: $e');
    }
  }

  /// 백업 빈도 변경
  Future<void> _changeBackupFrequency() async {
    final frequency = await _showFrequencyDialog();
    if (frequency == null) return;
    
    try {
      await _scheduler.updateBackupSettings(frequency: frequency);
      await _loadBackupStatus();
      _showSuccessSnackBar('백업 빈도가 변경되었습니다');
    } catch (e) {
      _showErrorSnackBar('설정 변경 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).backupManagement),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBackupStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBackupContent(),
    );
  }

  Widget _buildBackupContent() {
    if (_backupStatus == null) {
      return Center(
        child: Text(AppLocalizations.of(context).errorLoadingData),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildBackupActions(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildBackupHistory(),
        ],
      ),
    );
  }

  /// 백업 상태 카드
  Widget _buildStatusCard() {
    final status = _backupStatus!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.autoBackupEnabled ? Icons.backup : Icons.backup_outlined,
                  color: status.autoBackupEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  '백업 상태',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '상태'
                : 'Status', 
              status.statusText
            ),
            if (status.lastBackupTime != null)
              _buildStatusRow(
                '마지막 백업',
                _formatDateTime(status.lastBackupTime!),
              ),
            if (status.nextBackupTime != null)
              _buildStatusRow(
                '다음 백업',
                _formatDateTime(status.nextBackupTime!),
              ),
            _buildStatusRow(
              '백업 빈도',
              _getFrequencyText(status.frequency),
            ),
            _buildStatusRow(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '암호화'
                : 'Encryption',
              status.encryptionEnabled 
                ? (Localizations.localeOf(context).languageCode == 'ko' ? '활성화' : 'Enabled')
                : (Localizations.localeOf(context).languageCode == 'ko' ? '비활성화' : 'Disabled'),
            ),
            if (status.failureCount > 0)
              _buildStatusRow(
                '실패 횟수',
                '${status.failureCount}회',
                isError: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: isError ? Colors.red : null,
              fontWeight: isError ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 백업 액션 버튼들
  Widget _buildBackupActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '백업 작업',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCreatingBackup ? null : _createManualBackup,
                    icon: _isCreatingBackup
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: const Text('백업 생성'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCreatingBackup ? null : _createEncryptedBackup,
                    icon: const Icon(Icons.lock),
                    label: const Text('암호화 백업'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCreatingBackup ? null : _exportBackup,
                    icon: const Icon(Icons.file_download),
                    label: const Text('파일로 내보내기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRestoringBackup ? null : _restoreBackup,
                    icon: _isRestoringBackup
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restore),
                    label: const Text('백업 복원'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 설정 카드
  Widget _buildSettingsCard() {
    final status = _backupStatus!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '백업 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('자동 백업'),
              subtitle: const Text('정기적으로 자동 백업을 수행합니다'),
              value: status.autoBackupEnabled,
              onChanged: _toggleAutoBackup,
            ),
            ListTile(
              title: const Text('백업 빈도'),
              subtitle: Text(_getFrequencyText(status.frequency)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changeBackupFrequency,
            ),
          ],
        ),
      ),
    );
  }

  /// 백업 히스토리 (간단한 버전)
  Widget _buildBackupHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '백업 히스토리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_backupStatus!.lastBackupTime != null)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('마지막 백업'),
                subtitle: Text(_formatDateTime(_backupStatus!.lastBackupTime!)),
                trailing: Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '성공'
                    : 'Success',
                ),
              )
            else
              const ListTile(
                leading: Icon(Icons.info, color: Colors.grey),
                title: Text('백업 기록 없음'),
                subtitle: Text('아직 백업을 생성하지 않았습니다'),
              ),
          ],
        ),
      ),
    );
  }

  /// 비밀번호 입력 다이얼로그
  Future<String?> _showPasswordDialog(String title) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: Localizations.localeOf(context).languageCode == 'ko'
              ? '비밀번호'
              : 'Password',
            hintText: Localizations.localeOf(context).languageCode == 'ko'
              ? '백업 암호화에 사용할 비밀번호를 입력하세요'
              : 'Enter password for backup encryption',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context).confirm),
          ),
        ],
      ),
    );
  }

  /// 확인 다이얼로그
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).confirm),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// 백업 빈도 선택 다이얼로그
  Future<BackupFrequency?> _showFrequencyDialog() async {
    return showDialog<BackupFrequency>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업 빈도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BackupFrequency.values.map((frequency) {
            return ListTile(
              title: Text(_getFrequencyText(frequency)),
              onTap: () => Navigator.pop(context, frequency),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// 백업 빈도 텍스트
  String _getFrequencyText(BackupFrequency frequency) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    switch (frequency) {
      case BackupFrequency.daily:
        return isKorean ? '매일' : 'Daily';
      case BackupFrequency.weekly:
        return isKorean ? '매주' : 'Weekly';
      case BackupFrequency.monthly:
        return isKorean ? '매월' : 'Monthly';
      case BackupFrequency.manual:
        return isKorean ? '수동' : 'Manual';
    }
  }

  /// 성공 스낵바
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 오류 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 