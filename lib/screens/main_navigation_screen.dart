import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../utils/debug_helper.dart';
import '../services/achievement_service.dart';
import '../services/chad_evolution_service.dart';
import '../widgets/chad_evolution_animation.dart';

import '../services/workout_history_service.dart';
import '../services/permission_service.dart';
import '../services/ad_service.dart';
import '../widgets/achievement_celebration_dialog.dart';
import '../widgets/multiple_achievements_dialog.dart';
import '../models/achievement.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'achievements_screen.dart';
import 'challenge_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const AchievementsScreen(),
    const ChallengeScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNavigationScreen();
  }

  Future<void> _initializeNavigationScreen() async {
    try {
      debugPrint('🚀 메인 네비게이션 화면 초기화 시작');
      
      // 화면 로드 완료 후 업적 이벤트 확인
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 300));
        await _checkPendingAchievementEvents();
        
        // 업적 서비스 콜백 설정
        AchievementService.setGlobalContext(context);
        
        AchievementService.setOnAchievementUnlocked(() {
          if (mounted) {
            debugPrint('🎯 업적 달성 콜백 호출 - 데이터만 새로고침 (다이얼로그는 워크아웃 완료 시에만)');
            _refreshAllData();
            // 업적 다이얼로그는 워크아웃 완료 다이얼로그에서 처리하므로 여기서는 표시하지 않음
          }
        });
        
        AchievementService.setOnStatsUpdated(() {
          if (mounted) {
            _refreshAllData();
          }
        });
        
        // 운동 기록 저장 시 달력 업데이트 콜백 설정
        WorkoutHistoryService.addOnWorkoutSavedCallback(() {
          if (mounted) {
            _refreshAllData();
          }
        });
      });
      
      debugPrint('✅ 메인 네비게이션 화면 초기화 완료');
    } catch (e) {
      debugPrint('❌ 메인 네비게이션 화면 초기화 실패: $e');
    }
  }

  /// 모든 화면 데이터 새로고침 (업적 달성 시 호출)
  Future<void> _refreshAllData() async {
    try {
      // 업적 이벤트 다시 확인
      _checkPendingAchievementEvents();
      
      // 현재 선택된 화면에 따라 데이터 새로고침
      if (_selectedIndex == 0) {
        // 홈 화면 새로고침 (필요시 구현)
      } else if (_selectedIndex == 1) {
        // 달력 화면 새로고침 (필요시 구현)
      } else if (_selectedIndex == 2) {
        // 업적 화면 새로고침 (필요시 구현)
      } else if (_selectedIndex == 3) {
        // 챌린지 화면 새로고침 (필요시 구현)
      } else if (_selectedIndex == 4) {
        // 통계 화면 새로고침 (필요시 구현)
      }
      
      // 상태 업데이트로 UI 새로고침
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('데이터 새로고침 오류: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // 화면 전환 시 데이터만 새로고침 (업적 다이얼로그는 워크아웃에서만 표시)
    if (index == 0) { // 홈 화면
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _refreshAllData();
        }
      });
    }
  }

  // 대기 중인 업적 달성 이벤트 확인 및 다이얼로그 표시
  Future<void> _checkPendingAchievementEvents() async {
    try {
      // 잠시 대기 후 확인 (화면이 완전히 로드된 후)
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final events = await AchievementService.getPendingAchievementEvents();
      debugPrint('🎯 대기 중인 업적 이벤트: ${events.length}개');
      
      if (events.isNotEmpty && mounted) {
        // 다중 업적 달성 시 통합 다이얼로그 표시
        if (events.length > 1) {
          debugPrint('🎉 다중 업적 달성 감지: ${events.length}개 - 통합 다이얼로그 표시');
          
          // 모든 이벤트를 Achievement 객체로 변환
          final List<Achievement> achievements = [];
          for (final event in events) {
            final achievement = _createAchievementFromEvent(event);
            if (achievement != null) {
              achievements.add(achievement);
            }
          }
          
          if (achievements.isNotEmpty) {
            // 통합 다이얼로그 표시
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => MultipleAchievementsDialog(
                achievements: achievements,
                onDismiss: () async {
                  // 모든 이벤트 클리어
                  await AchievementService.clearPendingAchievementEvents();
                  debugPrint('✅ 모든 업적 이벤트 클리어 완료');
                },
              ),
            );
          }
        } else {
          // 단일 업적 달성 시 개별 다이얼로그 표시
          final event = events.first;
          debugPrint('🏆 단일 업적 이벤트 처리: ${event}');
          
          final achievement = _createAchievementFromEvent(event);
          if (achievement != null) {
            debugPrint('✨ 개별 업적 다이얼로그 표시: ${achievement.titleKey}');
            
            // 개별 다이얼로그 표시
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AchievementCelebrationDialog(
                achievement: achievement,
                onDismiss: () {
                  // 표시된 이벤트 제거 후 다음 이벤트 확인
                  _removeFirstEventAndCheckNext();
                },
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 업적 이벤트 확인 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

  // 이벤트 데이터에서 Achievement 객체 생성
  Achievement? _createAchievementFromEvent(Map<String, dynamic> event) {
    try {
      final achievementId = event['id'] as String? ?? '';
      final titleKey = event['titleKey'] as String? ?? 'achievementDefaultTitle';
      final descriptionKey = event['descriptionKey'] as String? ?? 'achievementDefaultDesc';
      final motivationKey = event['motivationKey'] as String? ?? 'achievementDefaultMotivation';
      final rarityStr = event['rarity'] as String? ?? 'common';
      final xpReward = event['xpReward'] as int? ?? 0;
      final typeStr = event['type'] as String? ?? 'first';
      final targetValue = event['targetValue'] as int? ?? 1;
      
      // 업적 타입 파싱
      AchievementType type = AchievementType.first;
      try {
        type = AchievementType.values.firstWhere(
          (t) => t.toString().split('.').last == typeStr,
          orElse: () => AchievementType.first,
        );
      } catch (e) {
        debugPrint('⚠️ 업적 타입 파싱 실패: $typeStr, 기본값 사용');
      }
      
      // Achievement 객체 생성
      return Achievement(
        id: achievementId,
        titleKey: titleKey,
        descriptionKey: descriptionKey,
        motivationKey: motivationKey,
        type: type,
        rarity: _parseRarity(rarityStr),
        targetValue: targetValue,
        xpReward: xpReward,
        icon: _getAchievementIcon(type),
      );
    } catch (e) {
      debugPrint('❌ Achievement 객체 생성 실패: $e');
      return null;
    }
  }

  // 업적 타입에 따른 아이콘 반환
  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.first:
        return Icons.star;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.volume:
        return Icons.flag;
      case AchievementType.perfect:
        return Icons.emoji_events;
      case AchievementType.special:
        return Icons.fitness_center;
      case AchievementType.challenge:
        return Icons.emoji_events;
      default:
        return Icons.emoji_events;
    }
  }

  // 첫 번째 이벤트 제거 후 다음 이벤트 확인
  Future<void> _removeFirstEventAndCheckNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList('pending_achievement_events') ?? [];
      
      if (events.isNotEmpty) {
        events.removeAt(0); // 첫 번째 이벤트 제거
        await prefs.setStringList('pending_achievement_events', events);
        
        // 남은 이벤트가 있으면 다음 이벤트 표시
        if (events.isNotEmpty && mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          _checkPendingAchievementEvents();
        }
      }
    } catch (e) {
      print('이벤트 제거 오류: $e');
    }
  }

  // 레어도 문자열을 enum으로 변환
  AchievementRarity _parseRarity(String rarityStr) {
    switch (rarityStr.toLowerCase()) {
      case 'rare':
        return AchievementRarity.rare;
      case 'epic':
        return AchievementRarity.epic;
      case 'legendary':
        return AchievementRarity.legendary;
      default:
        return AchievementRarity.common;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ChadEvolutionService>(
      builder: (context, chadService, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 메인 화면들
              IndexedStack(index: _selectedIndex, children: _screens),
              
              // Chad 진화 애니메이션 오버레이
              if (chadService.showEvolutionAnimation &&
                  chadService.evolutionFromChad != null &&
                  chadService.evolutionToChad != null)
                ChadEvolutionAnimation(
                  fromChad: chadService.evolutionFromChad!,
                  toChad: chadService.evolutionToChad!,
                  onAnimationComplete: () {
                    chadService.completeEvolutionAnimation();
                  },
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: _buildCustomBottomNavBar(isDark),
          ),
        );
      },
    );
  }

  Widget _buildCustomBottomNavBar(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 70,
      margin: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(AppColors.backgroundDark)
            : const Color(AppColors.backgroundLight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -3),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, l10n.home),
          _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, l10n.calendar),
          _buildNavItem(2, Icons.emoji_events_outlined, Icons.emoji_events, l10n.achievements),
          _buildNavItem(3, Icons.emoji_events_outlined, Icons.emoji_events, l10n.challengeTitle),
          _buildNavItem(4, Icons.analytics_outlined, Icons.analytics, l10n.statistics),
          _buildNavItem(5, Icons.settings_outlined, Icons.settings, l10n.settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(AppColors.primaryColor).withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected 
                      ? const Color(AppColors.primaryColor)
                      : Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? const Color(AppColors.primaryColor)
                      : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
