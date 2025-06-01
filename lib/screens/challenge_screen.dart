import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../models/user_profile.dart';
import '../services/challenge_service.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_progress_widget.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChallengeService _challengeService;
  
  List<Challenge> _availableChallenges = [];
  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];
  
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      _challengeService = ChallengeService();
      
      await _challengeService.initialize();
      await _loadUserProfile();
      await _loadChallenges();
    } catch (e) {
      debugPrint('Error initializing challenge service: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final databaseService = DatabaseService();
      _userProfile = await databaseService.getUserProfile();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadChallenges() async {
    if (_userProfile == null) return;
    
    try {
      final available = await _challengeService.getAvailableChallenges(_userProfile!);
      final active = _challengeService.getActiveChallenges();
      final completed = _challengeService.getCompletedChallenges();
      
      if (mounted) {
        setState(() {
          _availableChallenges = available;
          _activeChallenges = active;
          _completedChallenges = completed;
        });
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    }
  }

  Future<void> _startChallenge(String challengeId) async {
    try {
      final success = await _challengeService.startChallenge(challengeId);
      if (success) {
        await _loadChallenges();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '챌린지가 시작되었습니다! 🔥'
                  : 'Challenge started! 🔥',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '챌린지를 시작할 수 없습니다.'
                  : 'Cannot start challenge.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abandonChallenge(String challengeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '챌린지 포기'
            : 'Give Up Challenge',
        ),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '정말로 이 챌린지를 포기하시겠습니까?'
            : 'Are you sure you want to give up this challenge?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '취소'
                : 'Cancel',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '포기'
                : 'Give Up',
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _challengeService.abandonChallenge(challengeId);
        if (success) {
          await _loadChallenges();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '챌린지를 포기했습니다.'
                    : 'Challenge given up.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error abandoning challenge: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '챌린지'
            : 'Challenge',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: Localizations.localeOf(context).languageCode == 'ko'
                ? '사용 가능'
                : 'Available',
              icon: const Icon(Icons.play_arrow),
            ),
            Tab(
              text: Localizations.localeOf(context).languageCode == 'ko'
                ? '진행 중'
                : 'Active',
              icon: const Icon(Icons.timer),
            ),
            Tab(
              text: Localizations.localeOf(context).languageCode == 'ko'
                ? '완료'
                : 'Completed',
              icon: const Icon(Icons.check_circle),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableChallengesTab(),
                _buildActiveChallengesTab(),
                _buildCompletedChallengesTab(),
              ],
            ),
    );
  }

  Widget _buildAvailableChallengesTab() {
    if (_availableChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '사용 가능한 챌린지가 없습니다'
                : 'No challenges available',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '더 많은 운동을 완료하여 새로운 챌린지를 해금하세요!'
                : 'Complete more workouts to unlock new challenges!',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _availableChallenges[index];
          return ChallengeCard(
            challenge: challenge,
            onStart: () => _startChallenge(challenge.id),
            showStartButton: true,
          );
        },
      ),
    );
  }

  Widget _buildActiveChallengesTab() {
    if (_activeChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '진행 중인 챌린지가 없습니다'
                : 'No active challenges',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '새로운 챌린지를 시작해보세요!'
                : 'Start a new challenge!',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _activeChallenges[index];
          return Column(
            children: [
              ChallengeCard(
                challenge: challenge,
                onAbandon: () => _abandonChallenge(challenge.id),
                showAbandonButton: true,
              ),
              const SizedBox(height: 8),
              ChallengeProgressWidget(
                challenge: challenge,
                challengeService: _challengeService,
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompletedChallengesTab() {
    if (_completedChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '완료된 챌린지가 없습니다'
                : 'No completed challenges',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '첫 번째 챌린지를 완료해보세요!'
                : 'Complete your first challenge!',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _completedChallenges[index];
          return ChallengeCard(
            challenge: challenge,
            showCompletionDate: true,
          );
        },
      ),
    );
  }
} 