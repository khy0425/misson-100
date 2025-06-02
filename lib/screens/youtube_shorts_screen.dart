import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../utils/constants.dart';
import '../generated/app_localizations.dart';

class YoutubeShortsScreen extends StatefulWidget {
  const YoutubeShortsScreen({super.key});

  @override
  State<YoutubeShortsScreen> createState() => _YoutubeShortsScreenState();
}

class _YoutubeShortsScreenState extends State<YoutubeShortsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  // 푸쉬업 관련 유튜브 영상 ID들 (실제 운동 영상들)
  final List<String> _videoIds = [
    'IODxDxX7oi4', // 푸쉬업 기본 자세
    'R08gYyypGto', // 푸쉬업 변형 동작
    'pkygEzWOYiM', // 완벽한 푸쉬업 가이드
    'Eh00_rniF8E', // 푸쉬업 100개 도전
    'mmwlaVBMtlg', // 푸쉬업 운동법
    'bt5b9x9N0KU', // 홈트레이닝 푸쉬업
  ];
  
  List<String> _getVideoTitles(BuildContext context) {
    return [
      AppLocalizations.of(context)!.perfectPushupForm,
      AppLocalizations.of(context)!.pushupVariations,
      AppLocalizations.of(context)!.chadSecrets,
      AppLocalizations.of(context)!.pushup100Challenge,
      AppLocalizations.of(context)!.homeWorkoutPushups,
      AppLocalizations.of(context)!.strengthSecrets,
    ];
  }
  
  List<String> _getVideoDescriptions(BuildContext context) {
    return [
      AppLocalizations.of(context)!.correctPushupFormDesc,
      AppLocalizations.of(context)!.variousPushupStimulation,
      AppLocalizations.of(context)!.trueChadMindset,
      AppLocalizations.of(context)!.challengeSpirit100,
      AppLocalizations.of(context)!.perfectHomeWorkout,
      AppLocalizations.of(context)!.consistentStrengthImprovement,
    ];
  }

  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      _controllers = _videoIds.map((videoId) {
        return YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true, // 자동 재생
            mute: false,
            loop: true, // 반복 재생
            enableCaption: false,
            hideControls: true, // 컨트롤 완전히 숨기기
            controlsVisibleAtStart: false,
            disableDragSeek: true, // 드래그로 탐색 비활성화
            forceHD: false,
            useHybridComposition: true,
          ),
        );
      }).toList();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    // 모든 영상 일시정지
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index) {
        _controllers[i].pause();
      }
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // 현재 영상만 재생
    _controllers[index].play();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.chadShorts,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(AppColors.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loadingChadVideos,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.videoLoadError(_errorMessage!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _initializeControllers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(AppColors.primaryColor),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.tryAgain,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: _videoIds.length,
                  itemBuilder: (context, index) {
                    return _buildVideoPage(index);
                  },
                ),
    );
  }

  Widget _buildVideoPage(int index) {
    return Stack(
      children: [
        // 유튜브 플레이어
        Center(
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controllers[index],
              showVideoProgressIndicator: false, // 진행률 표시줄 숨기기
              progressIndicatorColor: const Color(AppColors.primaryColor),
              progressColors: const ProgressBarColors(
                playedColor: Color(AppColors.primaryColor),
                handleColor: Color(AppColors.accentColor),
              ),
              onReady: () {
                if (index == _currentIndex) {
                  _controllers[index].play();
                }
              },
              onEnded: (metaData) {
                // 영상이 끝나면 자동으로 반복 재생
                _controllers[index].seekTo(Duration.zero);
                _controllers[index].play();
              },
            ),
            builder: (context, player) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                child: player,
              );
            },
          ),
        ),

        // 오른쪽 액션 버튼들
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                label: AppLocalizations.of(context)!.like,
                onTap: () => _showSnackBar(AppLocalizations.of(context)!.likeMessage),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share,
                label: AppLocalizations.of(context)!.share,
                onTap: () => _showSnackBar(AppLocalizations.of(context)!.shareMessage),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.bookmark_border,
                label: AppLocalizations.of(context)!.save,
                onTap: () => _showSnackBar(AppLocalizations.of(context)!.saveMessage),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.fitness_center,
                label: AppLocalizations.of(context)!.workout,
                onTap: () => _showSnackBar(AppLocalizations.of(context)!.workoutStartMessage),
              ),
            ],
          ),
        ),

        // 하단 정보
        Positioned(
          left: 16,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getVideoTitles(context)[index % _getVideoTitles(context).length],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getVideoDescriptions(context)[index % _getVideoDescriptions(context).length],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.pushupHashtag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.chadHashtag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 페이지 인디케이터
        Positioned(
          right: 8,
          top: 100,
          child: Column(
            children: List.generate(_videoIds.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                width: 4,
                height: index == _currentIndex ? 20 : 8,
                decoration: BoxDecoration(
                  color: index == _currentIndex 
                      ? const Color(AppColors.primaryColor)
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),

        // 스와이프 힌트 (첫 번째 영상에서만 표시)
        if (_currentIndex == 0)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.swipe_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.swipeUpHint,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(AppColors.primaryColor),
        duration: const Duration(seconds: 1),
      ),
    );
  }
} 