// Presentation Layer - Universal Media Viewer with Swiping
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';

class UniversalMediaViewer extends StatefulWidget {
  final List<Message> mediaMessages;
  final int initialIndex;

  const UniversalMediaViewer({
    super.key,
    required this.mediaMessages,
    this.initialIndex = 0,
  });

  @override
  State<UniversalMediaViewer> createState() => _UniversalMediaViewerState();
}

class _UniversalMediaViewerState extends State<UniversalMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _currentVideoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _showVideoControls = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeCurrentMedia();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentVideoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCurrentMedia() async {
    final currentMessage = widget.mediaMessages[_currentIndex];
    if (currentMessage.type == MessageType.video) {
      await _loadVideo(_currentIndex);
    }
  }

  Future<void> _loadVideo(int index) async {
    // Dispose previous controller
    _currentVideoController?.dispose();

    final message = widget.mediaMessages[index];
    String? videoPath;

    // Try local file first
    if (message.localFilePath != null) {
      final file = File(message.localFilePath!);
      if (file.existsSync()) {
        videoPath = file.path;
      }
    }

    // Fallback to network URL
    if (videoPath == null &&
        message.fileUrl != null &&
        message.fileUrl!.isNotEmpty) {
      videoPath = message.fileUrl;
    }

    if (videoPath != null) {
      _currentVideoController = VideoPlayerController.networkUrl(
        Uri.parse(videoPath),
      );

      try {
        await _currentVideoController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
      } catch (e) {
        print('Error initializing video: $e');
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMessage = widget.mediaMessages[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: Text(
          currentMessage.fileName ?? 'Media ${_currentIndex + 1}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add share functionality
            },
            icon: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Page indicator
          if (widget.mediaMessages.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_currentIndex + 1} of ${widget.mediaMessages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Media viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                setState(() {
                  _currentIndex = index;
                  _isVideoInitialized = false;
                  _isVideoPlaying = false;
                });
                await _initializeCurrentMedia();
              },
              itemCount: widget.mediaMessages.length,
              itemBuilder: (context, index) {
                return _buildMediaPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPage(int index) {
    final message = widget.mediaMessages[index];

    switch (message.type) {
      case MessageType.image:
        return _buildImagePage(message);
      case MessageType.video:
        return _buildVideoPage(message);
      default:
        return const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 64),
        );
    }
  }

  Widget _buildImagePage(Message message) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: _buildImage(message),
      ),
    );
  }

  Widget _buildImage(Message message) {
    // Try local file first
    if (message.localFilePath != null) {
      final file = File(message.localFilePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }

    // Fallback to network image
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return Image.network(
        message.fileUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading image...',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
    }

    return const Center(
      child: Icon(Icons.image, color: Colors.white, size: 64),
    );
  }

  Widget _buildVideoPage(Message message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showVideoControls = !_showVideoControls;
        });
      },
      child: Stack(
        children: [
          // Video player
          Center(
            child:
                _isVideoInitialized && _currentVideoController != null
                    ? AspectRatio(
                      aspectRatio: _currentVideoController!.value.aspectRatio,
                      child: VideoPlayer(_currentVideoController!),
                    )
                    : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
          ),

          // Video controls
          if (_showVideoControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_isVideoInitialized &&
                            _currentVideoController != null) {
                          setState(() {
                            if (_isVideoPlaying) {
                              _currentVideoController!.pause();
                            } else {
                              _currentVideoController!.play();
                            }
                            _isVideoPlaying = !_isVideoPlaying;
                          });
                        }
                      },
                      icon: Icon(
                        _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_currentVideoController != null) {
                          final currentPosition =
                              _currentVideoController!.value.position;
                          final newPosition =
                              currentPosition - const Duration(seconds: 10);
                          _currentVideoController!.seekTo(newPosition);
                        }
                      },
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_currentVideoController != null) {
                          final currentPosition =
                              _currentVideoController!.value.position;
                          final newPosition =
                              currentPosition + const Duration(seconds: 10);
                          _currentVideoController!.seekTo(newPosition);
                        }
                      },
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

