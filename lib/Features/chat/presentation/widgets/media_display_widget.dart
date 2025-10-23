// Presentation Layer - Media Display Widget
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:io';
import 'full_screen_viewers.dart';
import 'universal_media_viewer.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';

class MediaDisplayWidget extends StatefulWidget {
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final int? fileSize;
  final bool isMe;
  final String? content;
  final bool isDownloaded;
  final bool isDownloading;
  final double downloadProgress;
  final Function()? onDownloadPressed;
  // Universal media viewer support
  final List<Message>? allMediaMessages;
  final int? currentMediaIndex;

  const MediaDisplayWidget({
    super.key,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    this.fileSize,
    required this.isMe,
    this.content,
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.onDownloadPressed,
    this.allMediaMessages,
    this.currentMediaIndex,
  });

  @override
  State<MediaDisplayWidget> createState() => _MediaDisplayWidgetState();
}

class _MediaDisplayWidgetState extends State<MediaDisplayWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
  }

  @override
  void didUpdateWidget(MediaDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize video if file path changed (e.g., downloaded)
    if (oldWidget.localFilePath != widget.localFilePath ||
        oldWidget.fileUrl != widget.fileUrl) {
      _initializeVideoIfNeeded();
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing controller
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (mounted && _videoController != null) {
      setState(() {
        // Video state updated
      });
    }
  }

  void _initializeVideoIfNeeded() {
    if (_isVideoFile()) {
      _initializeVideoPlayer();
    }
  }

  bool _isVideoFile() {
    final fileName = widget.fileName ?? '';
    final extension = fileName.split('.').last.toLowerCase();
    print(
      'DEBUG: Checking video file - fileName: $fileName, extension: $extension',
    );
    return [
      'mp4',
      'avi',
      'mov',
      'mkv',
      'webm',
      'flv',
      'wmv',
    ].contains(extension);
  }

  bool _isImageFile() {
    final fileName = widget.fileName ?? '';
    final extension = fileName.split('.').last.toLowerCase();
    print(
      'DEBUG: Checking image file - fileName: $fileName, extension: $extension',
    );
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // Check if widget is still mounted before starting
      if (!mounted) return;

      print('DEBUG: Initializing video player - isDownloaded: ${widget.isDownloaded}, localFilePath: ${widget.localFilePath}, fileUrl: ${widget.fileUrl}');

      String? videoPath;
      bool useLocalFile = false;

      // Prioritize local file if available and downloaded
      if (widget.isDownloaded &&
          widget.localFilePath != null &&
          File(widget.localFilePath!).existsSync()) {
        videoPath = widget.localFilePath!;
        useLocalFile = true;
        print('DEBUG: Using local video file: $videoPath');
      } else if (widget.fileUrl != null) {
        videoPath = widget.fileUrl!;
        useLocalFile = false;
        print('DEBUG: Using network video URL: $videoPath');
      } else {
        print('DEBUG: No video path available - cannot initialize video player');
        return;
      }

      // Dispose existing controller if any
      _videoController?.removeListener(_videoListener);
      _videoController?.dispose();

      // Use appropriate controller based on file type
      if (useLocalFile) {
        _videoController = VideoPlayerController.file(File(videoPath));
      } else {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoPath),
        );
      }

      // Initialize the video player
      await _videoController!.initialize();

      // Check if still mounted after async operation
      if (!mounted) {
        _videoController?.dispose();
        return;
      }

      // Set looping to false for better UX
      _videoController!.setLooping(false);

      setState(() {
        _isVideoInitialized = true;
      });

      // Add listener for video state changes
      _videoController!.addListener(_videoListener);

      // Ensure video is paused in chat bubble
      _videoController!.pause();

      print('DEBUG: Video player initialized successfully');
      print('DEBUG: Video duration: ${_videoController!.value.duration}');
      print('DEBUG: Video size: ${_videoController!.value.size}');
    } catch (e) {
      print('ERROR: Failed to initialize video player: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      'DEBUG MediaDisplay: fileName=${widget.fileName}, isVideo=${_isVideoFile()}, isImage=${_isImageFile()}',
    );
    // Check video first to avoid conflicts with image detection
    if (_isVideoFile()) {
      return _buildVideoDisplay();
    } else if (_isImageFile()) {
      return _buildImageDisplay();
    } else {
      return _buildGenericFileDisplay();
    }
  }

  Widget _buildImageDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showFullScreenImage(),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
              maxHeight: 450,
              minHeight: 200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Check if file is downloaded and local file exists
                  if (widget.isDownloaded &&
                      widget.localFilePath != null &&
                      File(widget.localFilePath!).existsSync())
                    // Clear image display from local file
                    Image.file(
                      File(widget.localFilePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          'DEBUG: Local image failed to load, falling back to network',
                        );
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
                                              loadingProgress
                                                  .expectedTotalBytes!
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
        ),
        // Caption if available
        if (widget.content != null && widget.content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              widget.content!,
              style: TextStyle(
                fontSize: 14,
                color: widget.isMe ? Colors.white : Colors.grey[800],
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
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
            maxWidth: 300,
            maxHeight: 200,
            minHeight: 120,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Check if file is downloaded
                if (widget.isDownloaded && widget.localFilePath != null)
                  // Clear video display with player
                  GestureDetector(
                    onTap: _showFullScreenVideo,
                    child: Stack(
                      children: [
                        // Compact video player preview
                        if (_isVideoInitialized && _videoController != null)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        else
                          Container(
                            height: 120,
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Loading...',
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

                        // Always show play button overlay (no inline playback)
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                            child: GestureDetector(
                              onTap: _showFullScreenVideo,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Video duration badge (always show)
                        if (_videoController != null)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                _formatDuration(
                                  _videoController!.value.duration,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                        // Full-screen button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: _showFullScreenVideo,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Compact blurry video display with download button
                  _buildBlurryVideoPreview(),
              ],
            ),
          ),
        ),
        // Caption if available
        if (widget.content != null && widget.content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              widget.content!,
              style: TextStyle(
                fontSize: 14,
                color: widget.isMe ? Colors.white : Colors.grey[800],
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
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
          color: (widget.isMe ? Colors.green : Colors.green[300]!).withOpacity(
            0.8,
          ),
          width: 2,
        ),
      ),
      child: Row(
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
                  'File',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: (widget.isMe ? Colors.white : Colors.grey[800]!)
                        .withOpacity(0.8),
                  ),
                ),
                if (widget.fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color: (widget.isMe ? Colors.white : Colors.grey[600]!)
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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

  // Compact blurry video preview with download button
  Widget _buildBlurryVideoPreview() {
    return Stack(
      children: [
        // Compact blurry background with video thumbnail
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Video thumbnail background (if available)
              if (widget.fileUrl != null)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[800]!, Colors.grey[900]!],
                      ),
                    ),
                  ),
                ),

              // Compact video icon and info overlay
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.videocam_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video File',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Removed filename display to make media fill the bubble
                  ],
                ),
              ),
            ],
          ),
        ),

        // Compact download button overlay
        Center(
          child: GestureDetector(
            onTap: widget.onDownloadPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Compact progress indicator if downloading
        if (widget.isDownloading)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      value: widget.downloadProgress,
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(widget.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

  void _showFullScreenImage() {
    // Use universal media viewer if we have multiple media messages
    if (widget.allMediaMessages != null &&
        widget.allMediaMessages!.length > 1 &&
        widget.currentMediaIndex != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => UniversalMediaViewer(
                mediaMessages: widget.allMediaMessages!,
                initialIndex: widget.currentMediaIndex!,
              ),
        ),
      );
    } else {
      // Use single image viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => FullScreenImageViewer(
                imageUrl: widget.fileUrl,
                localFilePath: widget.localFilePath,
                fileName: widget.fileName,
                isDownloaded: widget.isDownloaded,
              ),
        ),
      );
    }
  }

  void _showFullScreenVideo() {
    // Use universal media viewer if we have multiple media messages
    if (widget.allMediaMessages != null &&
        widget.allMediaMessages!.length > 1 &&
        widget.currentMediaIndex != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => UniversalMediaViewer(
                mediaMessages: widget.allMediaMessages!,
                initialIndex: widget.currentMediaIndex!,
              ),
        ),
      );
    } else {
      // Use single video viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => FullScreenVideoViewer(
                videoController: _videoController,
                fileUrl: widget.fileUrl,
                localFilePath: widget.localFilePath,
                fileName: widget.fileName,
                isDownloaded: widget.isDownloaded,
                isVideoInitialized: _isVideoInitialized,
              ),
        ),
      );
    }
  }
}