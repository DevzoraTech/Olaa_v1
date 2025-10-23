// Presentation Layer - Multiple Images Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'universal_media_viewer.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MultipleImagesWidget extends StatelessWidget {
  final List<String> imageUrls;
  final List<String?> localFilePaths;
  final List<String?> fileNames;
  final List<int?> fileSizes;
  final bool isMe;
  final String? content;
  final List<bool> isDownloaded;
  final List<double> downloadProgress;
  final List<bool> isDownloading;
  final Function(int index)? onDownloadPressed;

  const MultipleImagesWidget({
    super.key,
    required this.imageUrls,
    required this.localFilePaths,
    required this.fileNames,
    required this.fileSizes,
    required this.isMe,
    this.content,
    required this.isDownloaded,
    required this.downloadProgress,
    required this.isDownloading,
    this.onDownloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Images grid
        _buildImagesGrid(context),

        // Caption if available
        if (content != null && content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              content!,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.grey[800],
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagesGrid(BuildContext context) {
    final imageCount = imageUrls.length;

    if (imageCount == 1) {
      return _buildSingleImage(context, 0);
    } else if (imageCount == 2) {
      return _buildTwoImages(context);
    } else if (imageCount == 3) {
      return _buildThreeImages(context);
    } else if (imageCount == 4) {
      return _buildFourImages(context);
    } else {
      return _buildFiveOrMoreImages(context);
    }
  }

  Widget _buildSingleImage(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, index),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 250,
          maxHeight: 300,
          minHeight: 200,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(index),
        ),
      ),
    );
  }

  Widget _buildTwoImages(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullScreen(context, 0),
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(0),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullScreen(context, 1),
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImages(BuildContext context) {
    return Column(
      children: [
        // First image (full width)
        GestureDetector(
          onTap: () => _openFullScreen(context, 0),
          child: Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(0),
            ),
          ),
        ),
        // Second and third images (side by side)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 1),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(1),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 2),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFourImages(BuildContext context) {
    return Column(
      children: [
        // Top row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 0),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(right: 2, bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 1),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(left: 2, bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(1),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Bottom row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 2),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(right: 2, top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 3),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(left: 2, top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiveOrMoreImages(BuildContext context) {
    return Column(
      children: [
        // Top row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 0),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(right: 2, bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 1),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(left: 2, bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(1),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Bottom row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 2),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(right: 2, top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImageWidget(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openFullScreen(context, 3),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(left: 2, top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        _buildImageWidget(3),
                        // Overlay for "+X more" if there are more than 4 images
                        if (imageUrls.length > 4)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '+${imageUrls.length - 4}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isVideoFile(int index) {
    final fileName = fileNames[index] ?? '';
    final extension = fileName.split('.').last.toLowerCase();
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

  bool _isImageFile(int index) {
    final fileName = fileNames[index] ?? '';
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  Widget _buildImageWidget(int index) {
    // Check if it's a video file first
    if (_isVideoFile(index)) {
      return _buildVideoWidget(index);
    }

    // Handle image files
    // Prioritize local file if available and exists
    if (localFilePaths[index] != null) {
      final file = File(localFilePaths[index]!);
      if (file.existsSync()) {
        print(
          'DEBUG: MultipleImagesWidget - Using local image: ${localFilePaths[index]}',
        );
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print(
              'DEBUG: MultipleImagesWidget - Local image failed, falling back to network',
            );
            // Fallback to network if local file fails
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.grey),
                );
              },
            );
          },
        );
      }
    }

    // Use network image if no local file or local file doesn't exist
    if (imageUrls[index].isNotEmpty) {
      print(
        'DEBUG: MultipleImagesWidget - Using network image: ${imageUrls[index]}',
      );
      return Image.network(
        imageUrls[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildVideoWidget(int index) {
    return Stack(
      children: [
        // Video thumbnail background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Try to show video thumbnail if local file exists
                if (localFilePaths[index] != null &&
                    File(localFilePaths[index]!).existsSync())
                  FutureBuilder<Uint8List?>(
                    future: _getVideoThumbnail(localFilePaths[index]!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildVideoFallback();
                          },
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return _buildVideoFallback();
                      }
                    },
                  )
                else
                  _buildVideoFallback(),
              ],
            ),
          ),
        ),

        // Play button overlay
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
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
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[800]!, Colors.purple[900]!],
        ),
      ),
      child: Stack(
        children: [
          // Video pattern background
          Positioned.fill(child: CustomPaint(painter: VideoPatternPainter())),

          // Video icon and text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
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
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _getVideoThumbnail(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!file.existsSync()) {
        print('DEBUG: Video file does not exist: $videoPath');
        return null;
      }

      print('DEBUG: Generating thumbnail for video: $videoPath');
      
      // Generate thumbnail using video_thumbnail package
      final thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200, // Optimized size for grouped media
        quality: 75,
      );
      
      if (thumbnailData != null) {
        print('DEBUG: Successfully generated thumbnail for: $videoPath');
        return thumbnailData;
      } else {
        print('DEBUG: Failed to generate thumbnail for: $videoPath');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error generating video thumbnail: $e');
      return null;
    }
  }

  void _openFullScreen(BuildContext context, int startIndex) {
    // Convert the data to Message objects for UniversalMediaViewer
    List<Message> mediaMessages = [];
    for (int i = 0; i < imageUrls.length; i++) {
      // Determine message type based on file extension
      MessageType messageType;
      if (_isVideoFile(i)) {
        messageType = MessageType.video;
      } else if (_isImageFile(i)) {
        messageType = MessageType.image;
      } else {
        messageType = MessageType.file;
      }

      mediaMessages.add(
        Message(
          id: 'temp_$i',
          chatId: 'temp_chat',
          senderId: 'temp_sender',
          content: fileNames[i] ?? '',
          type: messageType,
          createdAt: DateTime.now(),
          fileUrl: imageUrls[i],
          fileName: fileNames[i],
          fileSize: fileSizes[i],
          isDownloaded: isDownloaded[i],
          localFilePath: localFilePaths[i],
          senderName: 'temp_sender',
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UniversalMediaViewer(
              mediaMessages: mediaMessages,
              initialIndex: startIndex,
            ),
      ),
    );
  }
}

class VideoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Draw diagonal lines pattern
    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
