import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../services/workout_program_service.dart';
import '../models/user_profile.dart';
import '../generated/app_localizations.dart';
import 'main_navigation_screen.dart';

class WorkoutScheduleSetupScreen extends StatefulWidget {
  final UserProfile userProfile;
  
  const WorkoutScheduleSetupScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<WorkoutScheduleSetupScreen> createState() => _WorkoutScheduleSetupScreenState();
}

class _WorkoutScheduleSetupScreenState extends State<WorkoutScheduleSetupScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // ?일 ?택 ?태 (??0, ??1, ... ??6)
  List<bool> _selectedDays = [true, false, true, false, true, false, false]; // 기본: ???
  
  // ?택???일 개수
  int get _selectedDaysCount => _selectedDays.where((selected) => selected).length;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _toggleDay(int dayIndex) {
    setState(() {
      _selectedDays[dayIndex] = !_selectedDays[dayIndex];
    });
    
    // 3일 미만이면 경고 (최소 3일은 선택해야 함)
    if (_selectedDaysCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must select at least 3 days! 💪',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _finishSetup() async {
    // 최소 3일 체크
    if (_selectedDaysCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need to work out at least 3 days a week to become a true champion! 💪',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    try {
      // 사용자 프로필 업데이트 (운동 요일만 저장, 알림 설정은 기본값 사용)
      final updatedProfile = widget.userProfile.copyWith(
        workoutDays: _selectedDays,
        // 알림 설정은 기본값 사용 (설정 탭에서 관리)
      );
      
      final databaseService = DatabaseService();
      await databaseService.updateUserProfile(updatedProfile);
      
      // 사용자 워크아웃 프로그램 초기화
      final workoutProgramService = WorkoutProgramService();
      final sessionsCreated = await workoutProgramService.initializeUserProgram(
        updatedProfile,
      );
      
      // 알림 설정은 설정 탭에서 관리하므로 여기서는 스케줄링하지 않음
      
      if (mounted) {
        // 설정 완료 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Setup Complete! Now the real journey begins! 🔥\n$sessionsCreated workout sessions are ready!\n💡 You can change notification settings in the Settings tab!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(
          'Workout Schedule Setup',
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ?목 ?션
                  _buildHeaderSection(),
                  
                  const SizedBox(height: 30),
                  
                  // ?동 ?일 ?택 ?션
                  _buildDaySelectionSection(),
                  
                  const SizedBox(height: 30),
                  
                  // 리마?드 ?정 ?션
                  _buildReminderSection(),
                  
                  const SizedBox(height: 40),
                  
                  // ?료 버튼
                  _buildFinishButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.primaryColor).withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(AppColors.primaryColor).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Colors.orange[700],
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                '🔥 Set Your Workout Schedule!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'To become a true champion, you need consistency!\n'
            'You must work out at least 3 days a week. 💪\n\n'
            'Choose days that fit your lifestyle,\n'
            'and block excuses with reminder notifications! 🚀',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDaySelectionSection() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: const Color(AppColors.primaryColor),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Select Workout Days (Min 3 days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(AppColors.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selected days: $_selectedDaysCount days',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _selectedDaysCount >= 3 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays[index];
            return GestureDetector(
              onTap: () => _toggleDay(index),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(AppColors.primaryColor)
                    : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                      ? const Color(AppColors.primaryColor)
                      : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Notification Settings Info',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.blue[700],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 You can change workout notification settings anytime in the Settings tab!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Default: 7 PM notifications on workout days (Mon, Wed, Fri)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedDaysCount >= 3 ? _finishSetup : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedDaysCount >= 3 
            ? const Color(AppColors.primaryColor)
            : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _selectedDaysCount >= 3 ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              color: _selectedDaysCount >= 3 ? Colors.black : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Start the Journey! 🚀',
              style: TextStyle(
                color: _selectedDaysCount >= 3 ? Colors.black : Colors.grey[400],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
