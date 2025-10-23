// Presentation Layer - Full Screen Media Viewers
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FullScreenImageViewer extends StatefulWidget {
  final String? imageUrl;
  final String? localFilePath;
  final String? fileName;
  final bool isDownloaded;

  const FullScreenImageViewer({
    super.key,
    this.imageUrl,
    this.localFilePath,
    this.fileName,
    this.isDownloaded = false,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
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
          widget.fileName ?? 'Image',
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
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child:
              widget.isDownloaded && widget.localFilePath != null
                  ? Image.file(
                    File(widget.localFilePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        widget.imageUrl ?? '',
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 64,
                            ),
                          );
                        },
                      );
                    },
                  )
                  : Image.network(
                    widget.imageUrl ?? '',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

class FullScreenVideoViewer extends StatefulWidget {
  final VideoPlayerController? videoController;
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final bool isDownloaded;
  final bool isVideoInitialized;

  const FullScreenVideoViewer({
    super.key,
    this.videoController,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    this.isDownloaded = false,
    this.isVideoInitialized = false,
  });

  @override
  State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  VideoPlayerController? _fullScreenController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeFullScreenVideo();
  }

  @override
  void dispose() {
    // Always pause video when leaving full-screen, regardless of current state
    if (_fullScreenController != null) {
      _fullScreenController!.pause();
      print('DEBUG: Video paused on full-screen dispose');
    }
    // Remove listener before disposing controller
    _fullScreenController?.removeListener(_videoListener);
    _fullScreenController?.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (mounted && _fullScreenController != null) {
      setState(() {
        _isPlaying = _fullScreenController!.value.isPlaying;
      });
    }
  }

  Future<void> _initializeFullScreenVideo() async {
    try {
      // Check if widget is still mounted before starting
      if (!mounted) return;

      String? videoPath;

      // Use local file if available, otherwise use network URL
      if (widget.localFilePath != null &&
          File(widget.localFilePath!).existsSync()) {
        videoPath = widget.localFilePath!;
      } else if (widget.fileUrl != null) {
        videoPath = widget.fileUrl!;
      }

      if (videoPath != null) {
        // Create new controller for full screen
        if (widget.localFilePath != null &&
            File(widget.localFilePath!).existsSync()) {
          _fullScreenController = VideoPlayerController.file(File(videoPath));
        } else {
          _fullScreenController = VideoPlayerController.networkUrl(
            Uri.parse(videoPath),
          );
        }

        await _fullScreenController!.initialize();
        _fullScreenController!.setLooping(false);

        // Check if still mounted after async operation
        if (!mounted) {
          _fullScreenController?.dispose();
          return;
        }

        setState(() {
          _isInitialized = true;
        });

        // Add listener for video state changes
        _fullScreenController!.addListener(_videoListener);

        // Auto-hide controls after 3 seconds
        _hideControlsAfterDelay();
      }
    } catch (e) {
      print('ERROR: Failed to initialize full screen video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_fullScreenController != null) {
      if (_isPlaying) {
        _fullScreenController!.pause();
      } else {
        _fullScreenController!.play();
        _hideControlsAfterDelay();
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        // Handle system back button/swipe gesture
        if (didPop && _fullScreenController != null) {
          _fullScreenController!.pause();
          print('DEBUG: Video paused on system back gesture');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar:
            _showControls
                ? AppBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () {
                      // Always pause video before going back, regardless of current state
                      if (_fullScreenController != null) {
                        _fullScreenController!.pause();
                        print('DEBUG: Video paused on back button press');
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    widget.fileName ?? 'Video',
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        // TODO: Add share functionality
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : null,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // Video player
              if (_isInitialized && _fullScreenController != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _fullScreenController!.value.aspectRatio,
                    child: VideoPlayer(_fullScreenController!),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),

              // Controls overlay
              if (_showControls)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),

              // Progress bar and info
              if (_showControls && _fullScreenController != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Progress bar
                        VideoProgressIndicator(
                          _fullScreenController!,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.grey[300]!,
                            backgroundColor: Colors.grey[600]!,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Video info row
                        Row(
                          children: [
                            const Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.fileName ?? 'Video File',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${_formatDuration(_fullScreenController!.value.position)} / ${_formatDuration(_fullScreenController!.value.duration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
