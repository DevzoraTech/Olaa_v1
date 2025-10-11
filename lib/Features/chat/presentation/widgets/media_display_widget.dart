// Presentation Layer - Media Display Widget
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:io';

class MediaDisplayWidget extends StatefulWidget {
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final bool isMe;
  final String? content;
  final bool isDownloaded;
  final bool isDownloading;
  final double downloadProgress;
  final Function()? onDownloadPressed;

  const MediaDisplayWidget({
    super.key,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    required this.isMe,
    this.content,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.onDownloadPressed,
  });

  @override
  State<MediaDisplayWidget> createState() => _MediaDisplayWidgetState();
}

class _MediaDisplayWidgetState extends State<MediaDisplayWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _showVideoControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideoIfNeeded() {
    if (_isVideoFile()) {
      _initializeVideoPlayer();
    }
  }

  bool _isVideoFile() {
    final fileName = widget.fileName ?? '';
    final extension = fileName.split('.').last.toLowerCase();
    return ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension);
  }

  bool _isImageFile() {
    final fileName = widget.fileName ?? '';
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      String? videoPath;

      // Use local file if available, otherwise use network URL
      if (widget.localFilePath != null &&
          File(widget.localFilePath!).existsSync()) {
        videoPath = widget.localFilePath!;
        print('DEBUG: Using local video file: $videoPath');
      } else if (widget.fileUrl != null) {
        videoPath = widget.fileUrl!;
        print('DEBUG: Using network video URL: $videoPath');
      }

      if (videoPath != null) {
        _videoController = VideoPlayerController.file(File(videoPath));

        await _videoController!.initialize();

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }

        print('DEBUG: Video player initialized successfully');
      }
    } catch (e) {
      print('ERROR: Failed to initialize video player: $e');
    }
  }

  void _toggleVideoPlayPause() {
    if (_videoController != null) {
      if (_isVideoPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  void _toggleVideoControls() {
    setState(() {
      _showVideoControls = !_showVideoControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isImageFile()) {
      return _buildImageDisplay();
    } else if (_isVideoFile()) {
      return _buildVideoDisplay();
    } else {
      return _buildGenericFileDisplay();
    }
  }

  Widget _buildImageDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: 280,
            maxHeight: 400,
            minHeight: 200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Check if file is downloaded
                if (widget.isDownloaded && widget.localFilePath != null)
                  // Clear image display
                  Image.file(
                    File(widget.localFilePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to network if local file fails
                      return Image.network(
                        widget.fileUrl ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildErrorDisplay('Failed to load image');
                        },
                      );
                    },
                  )
                else
                  // Blurry image display with download button
                  _buildBlurryImagePreview(),
              ],
            ),
          ),
        ),
        // Caption if available
        if (widget.content != null && widget.content!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.content!,
            style: TextStyle(
              fontSize: 14,
              color: widget.isMe ? Colors.white : Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: 280,
            maxHeight: 400,
            minHeight: 200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Check if file is downloaded
                if (widget.isDownloaded && widget.localFilePath != null)
                  // Clear video display with player
                  GestureDetector(
                    onTap: _toggleVideoControls,
                    child: Stack(
                      children: [
                        // Video player
                        if (_isVideoInitialized && _videoController != null)
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Loading video...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Video controls overlay
                        if (_showVideoControls || !_isVideoPlaying)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: Center(
                              child: GestureDetector(
                                onTap: _toggleVideoPlayPause,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isVideoPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Video info overlay
                        if (_showVideoControls)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.fileName ?? 'Video',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(
                                      _videoController?.value.duration ??
                                          Duration.zero,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  // Blurry video display with download button
                  _buildBlurryVideoPreview(),
              ],
            ),
          ),
        ),
        // Caption if available
        if (widget.content != null && widget.content!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.content!,
            style: TextStyle(
              fontSize: 14,
              color: widget.isMe ? Colors.white : Colors.grey[800],
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenericFileDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (widget.isMe ? Colors.white : Colors.grey[100]!).withOpacity(
          0.3,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (widget.isMe ? Colors.white : Colors.grey[300]!).withOpacity(
            0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (widget.isMe ? Colors.white : Colors.grey[200]!)
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(widget.fileName ?? ''),
                  color: (widget.isMe ? Colors.white : Colors.grey[600]!)
                      .withOpacity(0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName ?? 'Unknown file',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (widget.isMe ? Colors.white : Colors.grey[800]!)
                            .withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String message) {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildBlurryImagePreview() {
    return Stack(
      children: [
        // Blurry background image
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Image.network(
            widget.fileUrl ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 48,
                ),
              );
            },
          ),
        ),
        // Download button in center
        Center(
          child: GestureDetector(
            onTap: widget.onDownloadPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Progress indicator if downloading
        if (widget.isDownloading)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: widget.downloadProgress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(widget.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBlurryVideoPreview() {
    return Stack(
      children: [
        // Blurry background
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[400]!, Colors.grey[600]!, Colors.grey[800]!],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.white.withOpacity(0.7),
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Video File',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.fileName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.fileName!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        // Download button in center
        Center(
          child: GestureDetector(
            onTap: widget.onDownloadPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Progress indicator if downloading
        if (widget.isDownloading)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: widget.downloadProgress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(widget.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
