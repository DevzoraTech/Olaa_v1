// Presentation Layer - Enhanced Full Screen Media Viewer with Swiping
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class EnhancedFullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final List<String?> localFilePaths;
  final List<String?> fileNames;
  final List<bool> isDownloaded;
  final int initialIndex;

  const EnhancedFullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.localFilePaths,
    required this.fileNames,
    required this.isDownloaded,
    this.initialIndex = 0,
  });

  @override
  State<EnhancedFullScreenImageViewer> createState() =>
      _EnhancedFullScreenImageViewerState();
}

class _EnhancedFullScreenImageViewerState
    extends State<EnhancedFullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.fileNames[_currentIndex] ?? 'Image ${_currentIndex + 1}',
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
          if (widget.imageUrls.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_currentIndex + 1} of ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Images viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return _buildImagePage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePage(int index) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: _buildImage(index),
      ),
    );
  }

  Widget _buildImage(int index) {
    // Try local file first
    if (widget.localFilePaths[index] != null) {
      final file = File(widget.localFilePaths[index]!);
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
    if (widget.imageUrls[index].isNotEmpty) {
      return Image.network(
        widget.imageUrls[index],
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
                  'Loading image ${index + 1}...',
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
                  'Failed to load image ${index + 1}',
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
}

// Enhanced Video Viewer with Swiping Support
class EnhancedFullScreenVideoViewer extends StatefulWidget {
  final List<String> videoUrls;
  final List<String?> localFilePaths;
  final List<String?> fileNames;
  final List<bool> isDownloaded;
  final int initialIndex;

  const EnhancedFullScreenVideoViewer({
    super.key,
    required this.videoUrls,
    required this.localFilePaths,
    required this.fileNames,
    required this.isDownloaded,
    this.initialIndex = 0,
  });

  @override
  State<EnhancedFullScreenVideoViewer> createState() =>
      _EnhancedFullScreenVideoViewerState();
}

class _EnhancedFullScreenVideoViewerState
    extends State<EnhancedFullScreenVideoViewer> {
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
    _initializeVideo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentVideoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrls.isNotEmpty) {
      await _loadVideo(_currentIndex);
    }
  }

  Future<void> _loadVideo(int index) async {
    // Dispose previous controller
    _currentVideoController?.dispose();

    String? videoPath;

    // Try local file first
    if (widget.localFilePaths[index] != null) {
      final file = File(widget.localFilePaths[index]!);
      if (file.existsSync()) {
        videoPath = file.path;
      }
    }

    // Fallback to network URL
    if (videoPath == null && widget.videoUrls[index].isNotEmpty) {
      videoPath = widget.videoUrls[index];
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
          widget.fileNames[_currentIndex] ?? 'Video ${_currentIndex + 1}',
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
          if (widget.videoUrls.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_currentIndex + 1} of ${widget.videoUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Videos viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                setState(() {
                  _currentIndex = index;
                  _isVideoInitialized = false;
                  _isVideoPlaying = false;
                });
                await _loadVideo(index);
              },
              itemCount: widget.videoUrls.length,
              itemBuilder: (context, index) {
                return _buildVideoPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPage(int index) {
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
