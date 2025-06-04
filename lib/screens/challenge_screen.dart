import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
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
              content: Text(AppLocalizations.of(context)!.challengeStarted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.challengeCannotStart),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ko'
                ? '오류가 발생했습니다.'
                : 'An error occurred.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abandonChallenge(String challengeId) async {
    final success = await _challengeService.quitChallenge(challengeId);
    if (success) {
      setState(() {
        _activeChallenges.removeWhere((c) => c.id == challengeId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.challengeAbandoned)),
      );
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
        title: Text(AppLocalizations.of(context)!.challengeTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: '${AppLocalizations.of(context)!.challengesAvailable} (${_availableChallenges.length})',
              icon: const Icon(Icons.play_arrow),
            ),
            Tab(
              text: '${AppLocalizations.of(context)!.challengesActive} (${_activeChallenges.length})',
              icon: const Icon(Icons.timer),
            ),
            Tab(
              text: '${AppLocalizations.of(context)!.challengeTabCompleted} (${_completedChallenges.length})',
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
              AppLocalizations.of(context)!.noChallengesAvailable,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.unlockMoreChallenges,
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
            onTap: () => _startChallenge(challenge.id),
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
              AppLocalizations.of(context)!.noActiveChallenges,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.startNewChallenge,
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
                onTap: () => _abandonChallenge(challenge.id),
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
              AppLocalizations.of(context)!.noCompletedChallenges,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.completeFirstChallenge,
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