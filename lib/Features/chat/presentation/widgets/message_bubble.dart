// Presentation Layer - Message Bubble Widget
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/local_file_storage_service.dart';
import '../../domain/models/chat_model.dart';
import 'media_display_widget.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final String chatType;
  final Function(Message)? onDownloadStateChanged;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.chatType,
    this.onDownloadStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe && showAvatar) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child:
                  message.senderProfileImageUrl != null &&
                          message.senderProfileImageUrl!.isNotEmpty
                      ? Image.network(
                        message.senderProfileImageUrl!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[600],
                          );
                        },
                      )
                      : Icon(Icons.person, size: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (!isMe)
          const SizedBox(width: 36),

        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message Content
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: Border.all(
                      color: isMe ? AppTheme.primaryColor : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender name (for group chats)
                      if (!isMe && chatType == 'Groups')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                      // Message content
                      _buildMessageContent(),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Time and status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : message.isDelivered
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead ? Colors.blue : Colors.grey[400],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        if (isMe) const SizedBox(width: 36),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    print(
      'DEBUG: Time formatting - Now: $now, Timestamp: $timestamp, Difference: $difference',
    );

    // If the timestamp is in the future (shouldn't happen but handle gracefully)
    if (difference.isNegative) {
      final futureDiff = timestamp.difference(now);
      print('DEBUG: Future timestamp detected, difference: $futureDiff');

      // If it's a small future difference (likely timezone issue), treat as "Just now"
      if (futureDiff.inMinutes < 60) {
        return 'Just now';
      }

      // If it's a large future difference, show the actual time
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }

    // More than 7 days ago - show date
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    // More than 1 day ago - show days
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    }

    // More than 1 hour ago - show hours
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }

    // More than 1 minute ago - show minutes
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }

    // Less than 1 minute ago
    if (difference.inSeconds > 10) {
      return '${difference.inSeconds}s ago';
    }

    return 'Just now';
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.grey[800],
            height: 1.3,
          ),
        );

      case MessageType.image:
        return MediaDisplayWidget(
          fileUrl: message.fileUrl,
          localFilePath: message.localFilePath,
          fileName: message.fileName,
          isMe: isMe,
          content: message.content,
          isDownloaded: message.isDownloaded,
          isDownloading: message.isDownloading,
          downloadProgress: message.downloadProgress,
          onDownloadPressed: () => _downloadFile(message.fileUrl ?? ''),
        );

      case MessageType.file:
        // Check if it's a video file
        final fileName = message.fileName ?? '';
        final extension = fileName.split('.').last.toLowerCase();
        if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension)) {
          return MediaDisplayWidget(
            fileUrl: message.fileUrl,
            localFilePath: message.localFilePath,
            fileName: message.fileName,
            isMe: isMe,
            content: message.content,
            isDownloaded: message.isDownloaded,
            isDownloading: message.isDownloading,
            downloadProgress: message.downloadProgress,
            onDownloadPressed: () => _downloadFile(message.fileUrl ?? ''),
          );
        } else {
          return _buildFilePreview();
        }

      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.grey[800],
            height: 1.3,
          ),
        );
    }
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFilePreview() {
    final fileName = message.fileName ?? 'Unknown file';
    final fileExtension = fileName.split('.').last.toLowerCase();

    // Check if file is downloaded
    if (message.isDownloaded && message.localFilePath != null) {
      // Show clear content for downloaded files
      return _buildDownloadedFilePreview(fileExtension);
    } else {
      // Show blurry preview with download arrow for undownloaded files
      return _buildUndownloadedFilePreview(fileExtension);
    }
  }

  Widget _buildDownloadedFilePreview(String fileExtension) {
    // Images and videos are handled by MediaDisplayWidget, so only handle other file types
    if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(fileExtension)) {
      return _buildClearAudioPreview();
    } else if (['pdf'].contains(fileExtension)) {
      return _buildClearPdfPreview();
    } else {
      return _buildClearGenericFilePreview();
    }
  }

  Widget _buildUndownloadedFilePreview(String fileExtension) {
    // Images and videos are handled by MediaDisplayWidget, so only handle other file types
    if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(fileExtension)) {
      return _buildBlurryAudioPreview();
    } else if (['pdf'].contains(fileExtension)) {
      return _buildBlurryPdfPreview();
    } else {
      return _buildBlurryGenericFilePreview();
    }
  }

  // Blurry preview for undownloaded audio files
  Widget _buildBlurryAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color: (isMe ? Colors.white : Colors.blue[100]!).withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: (isMe ? Colors.white : Colors.blue[700]!).withOpacity(
                    0.7,
                  ),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'Audio File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (isMe ? Colors.white : Colors.grey[800]!)
                            .withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Download button
          Center(
            child: GestureDetector(
              onTap: () => _downloadFile(message.fileUrl ?? ''),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                    Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Download Audio',
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
          if (message.isDownloading) ...[
            const SizedBox(height: 8),
            Container(
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
                      value: message.downloadProgress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(message.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Clear preview for downloaded audio files
  Widget _buildClearAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color:
                      isMe ? Colors.white.withOpacity(0.2) : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: isMe ? Colors.white : Colors.blue[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'Audio File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isMe ? Colors.white : Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Play button
          GestureDetector(
            onTap: () => _downloadFile(message.fileUrl ?? ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isMe ? Colors.white.withOpacity(0.3) : Colors.blue[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: isMe ? Colors.white : Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Play Audio',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Colors.white : Colors.blue[700],
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

  // Blurry preview for undownloaded PDF files
  Widget _buildBlurryPdfPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color: (isMe ? Colors.white : Colors.red[100]!).withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: (isMe ? Colors.white : Colors.red[700]!).withOpacity(
                    0.7,
                  ),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'PDF Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (isMe ? Colors.white : Colors.grey[800]!)
                            .withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Download button
          Center(
            child: GestureDetector(
              onTap: () => _downloadFile(message.fileUrl ?? ''),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                    Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Download PDF',
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
          if (message.isDownloading) ...[
            const SizedBox(height: 8),
            Container(
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
                      value: message.downloadProgress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(message.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Clear preview for downloaded PDF files
  Widget _buildClearPdfPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color: isMe ? Colors.white.withOpacity(0.2) : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: isMe ? Colors.white : Colors.red[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'PDF Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isMe ? Colors.white : Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Open PDF button
          GestureDetector(
            onTap: () => _downloadFile(message.fileUrl ?? ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isMe ? Colors.white.withOpacity(0.3) : Colors.red[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    color: isMe ? Colors.white : Colors.red[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Open PDF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Colors.white : Colors.red[700],
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

  // Blurry preview for undownloaded generic files
  Widget _buildBlurryGenericFilePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color: (isMe ? Colors.white : Colors.grey[200]!).withOpacity(
                    0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(message.fileName ?? ''),
                  color: (isMe ? Colors.white : Colors.grey[600]!).withOpacity(
                    0.7,
                  ),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'Unknown file',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (isMe ? Colors.white : Colors.grey[800]!)
                            .withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Download button
          Center(
            child: GestureDetector(
              onTap: () => _downloadFile(message.fileUrl ?? ''),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                    Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Download File',
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
          if (message.isDownloading) ...[
            const SizedBox(height: 8),
            Container(
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
                      value: message.downloadProgress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(message.downloadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Clear preview for downloaded generic files
  Widget _buildClearGenericFilePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : Colors.grey[100]!).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isMe ? Colors.white : Colors.grey[300]!).withOpacity(0.5),
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
                  color:
                      isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(message.fileName ?? ''),
                  color: isMe ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'Unknown file',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isMe ? Colors.white : Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (message.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isMe ? Colors.white : Colors.grey[600]!)
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Download button
          GestureDetector(
            onTap: () => _downloadFile(message.fileUrl ?? ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isMe ? Colors.white.withOpacity(0.3) : Colors.blue[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_rounded,
                    color: isMe ? Colors.white : Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMe ? Colors.white : Colors.blue[700],
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

  Future<void> _downloadFile(String fileUrl) async {
    try {
      print('DEBUG: Starting download for: $fileUrl');

      // Update download state to downloading
      if (onDownloadStateChanged != null) {
        final updatedMessage = message.copyWith(
          isDownloading: true,
          downloadProgress: 0.0,
        );
        onDownloadStateChanged!(updatedMessage);
      }

      // Initialize local file storage service
      final localStorage = LocalFileStorageService();
      await localStorage.initialize();

      // Download and save file locally
      final localFilePath = await localStorage.downloadAndSaveFile(
        fileUrl: fileUrl,
        fileName: message.fileName ?? 'file',
        chatId: message.chatId,
        messageId: message.id,
        onProgress: (progress) {
          // Update download progress
          if (onDownloadStateChanged != null) {
            final updatedMessage = message.copyWith(
              isDownloading: true,
              downloadProgress: progress,
            );
            onDownloadStateChanged!(updatedMessage);
          }
        },
      );

      if (localFilePath != null) {
        print('DEBUG: File downloaded and saved locally: $localFilePath');

        // Update download state to downloaded with local path
        if (onDownloadStateChanged != null) {
          final updatedMessage = message.copyWith(
            isDownloaded: true,
            isDownloading: false,
            downloadProgress: 1.0,
            localFilePath: localFilePath,
          );
          onDownloadStateChanged!(updatedMessage);
        }

        // Launch the local file
        final localFile = File(localFilePath);
        if (await localFile.exists()) {
          // For images, we don't need to launch externally since they're displayed in the chat
          // For other files, we can launch them
          if (![
            'jpg',
            'jpeg',
            'png',
            'gif',
            'webp',
          ].contains(message.fileName?.split('.').last.toLowerCase() ?? '')) {
            final uri = Uri.file(localFilePath);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              print('DEBUG: Local file launched successfully');
            }
          }
        }
      } else {
        print('ERROR: Failed to download file locally');

        // Update download state to failed
        if (onDownloadStateChanged != null) {
          final updatedMessage = message.copyWith(
            isDownloading: false,
            downloadProgress: 0.0,
          );
          onDownloadStateChanged!(updatedMessage);
        }
      }
    } catch (e) {
      print('ERROR: Failed to download file: ${e.toString()}');

      // Update download state to failed
      if (onDownloadStateChanged != null) {
        final updatedMessage = message.copyWith(
          isDownloading: false,
          downloadProgress: 0.0,
        );
        onDownloadStateChanged!(updatedMessage);
      }
    }
  }
}