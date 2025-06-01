import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../generated/app_localizations.dart';

/// 푸시업 폼 가이드용 커스텀 비디오 플레이어 위젯
class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? assetPath;
  final bool autoPlay;
  final bool showControls;
  final double aspectRatio;
  final String placeholderText;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.assetPath,
    this.autoPlay = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    this.placeholderText = '비디오 시연',
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl || 
        oldWidget.assetPath != widget.assetPath) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // 기존 컨트롤러 정리
    await _controller?.dispose();
    
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
    });

    // 비디오 소스가 없으면 플레이스홀더 표시
    if (widget.videoUrl == null && widget.assetPath == null) {
      return;
    }

    try {
      // 비디오 컨트롤러 초기화
      if (widget.videoUrl != null) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      } else if (widget.assetPath != null) {
        _controller = VideoPlayerController.asset(widget.assetPath!);
      }

      if (_controller != null) {
        await _controller!.initialize();
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });

          // 자동 재생 설정
          if (widget.autoPlay) {
            _controller!.play();
          }

          // 비디오 완료 시 처음으로 되돌리기
          _controller!.addListener(() {
            if (_controller!.value.position >= _controller!.value.duration) {
              _controller!.seekTo(Duration.zero);
              _controller!.pause();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _seekTo(double value) {
    if (_controller != null && _isInitialized) {
      final duration = _controller!.value.duration;
      final position = duration * value;
      _controller!.seekTo(position);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4DABF7), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: _buildVideoContent(),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    // 에러 상태
    if (_hasError) {
      return _buildErrorWidget();
    }

    // 비디오 소스가 없는 경우 플레이스홀더
    if (widget.videoUrl == null && widget.assetPath == null) {
      return _buildPlaceholder();
    }

    // 로딩 중
    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    // 비디오 플레이어
    return GestureDetector(
      onTap: widget.showControls ? _toggleControls : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 비디오
          VideoPlayer(_controller!),
          
          // 컨트롤 오버레이
          if (widget.showControls && _showControls)
            _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Semantics(
      label: Localizations.localeOf(context).languageCode == 'ko'
        ? '${widget.placeholderText} 플레이스홀더. 비디오가 준비되지 않았습니다.'
        : '${widget.placeholderText} placeholder. Video is not ready.',
      child: Container(
        color: const Color(0xFF2A2A2A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              excludeSemantics: true,
              child: const Icon(
                Icons.play_circle_outline,
                color: Color(0xFF4DABF7),
                size: 48,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.placeholderText,
              style: const TextStyle(
                color: Color(0xFF4DABF7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF4DABF7),
          ),
          const SizedBox(height: 8),
          Text(
            Localizations.localeOf(context).languageCode == 'ko'
              ? '비디오 로딩 중...'
              : 'Loading video...',
            style: const TextStyle(
              color: Color(0xFF4DABF7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFFF6B6B),
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            Localizations.localeOf(context).languageCode == 'ko'
              ? '비디오를 불러올 수 없습니다'
              : 'Unable to load video',
            style: const TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 14,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _initializeVideo,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(AppLocalizations.of(context)!.retryButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DABF7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          // 상단 컨트롤 (풀스크린 버튼 등)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    // 풀스크린 기능 (추후 구현)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(Localizations.localeOf(context).languageCode == 'ko'
                          ? '풀스크린 기능은 추후 구현 예정입니다.'
                          : 'Fullscreen feature will be implemented later.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
                        // 중앙 재생/일시정지 버튼
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: _controller!.value.isPlaying 
                      ? (Localizations.localeOf(context).languageCode == 'ko'
                          ? '비디오 일시정지'
                          : 'Pause video')
                      : (Localizations.localeOf(context).languageCode == 'ko'
                          ? '비디오 재생'
                          : 'Play video'),
                    child: IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _controller!.value.isPlaying 
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
          
          // 하단 컨트롤 (진행률, 시간)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 진행률 슬라이더
                ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, VideoPlayerValue value, child) {
                    final progress = value.duration.inMilliseconds > 0
                        ? value.position.inMilliseconds / value.duration.inMilliseconds
                        : 0.0;
                    
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF4DABF7),
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                        thumbColor: const Color(0xFF4DABF7),
                        overlayColor: const Color(0xFF4DABF7).withValues(alpha: 0.2),
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: _seekTo,
                      ),
                    );
                  },
                ),
                
                // 시간 표시
                ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, VideoPlayerValue value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 