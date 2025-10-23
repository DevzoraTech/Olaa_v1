// Presentation Layer - Message Bubble Widget
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/local_file_storage_service.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';
import 'media_display_widget.dart';
import 'voice_message_playback.dart';
import 'audio_file_playback.dart';
import '../screens/document_viewer_screen.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final String chatType;
  final Function(Message)? onDownloadStateChanged;
  // Universal media viewer support
  final List<Message>? allMediaMessages;
  final int? currentMediaIndex;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.chatType,
    this.onDownloadStateChanged,
    this.allMediaMessages,
    this.currentMediaIndex,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  void initState() {
    super.initState();
    _checkForExistingDownload();
  }

  Future<void> _checkForExistingDownload() async {
    // Only check for files that have a fileUrl but are not yet downloaded
    if (widget.message.fileUrl != null &&
        !widget.message.isDownloaded &&
        widget.message.localFilePath == null) {
      try {
        final localStorage = LocalFileStorageService();
        await localStorage.initialize();

        final existingFilePath = await localStorage.getLocalFilePathForMessage(
          chatId: widget.message.chatId,
          messageId: widget.message.id,
          fileName: widget.message.fileName ?? 'file',
        );

        if (existingFilePath != null && await File(existingFilePath).exists()) {
          print('DEBUG: Found existing downloaded file: $existingFilePath');

          // Update download state to downloaded with existing local path
          if (widget.onDownloadStateChanged != null) {
            final updatedMessage = widget.message.copyWith(
              isDownloaded: true,
              isDownloading: false,
              downloadProgress: 1.0,
              localFilePath: existingFilePath,
            );
            widget.onDownloadStateChanged!(updatedMessage);
          }
        }
      } catch (e) {
        print('ERROR: Failed to check for existing download: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message Content
              Container(
                padding: _getMessagePadding(),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
                    bottomRight: Radius.circular(widget.isMe ? 4 : 16),
                  ),
                  border:
                      _shouldShowBorder()
                          ? Border.all(
                            color:
                                widget.isMe ? Colors.blue : Colors.grey[200]!,
                            width: 1,
                          )
                          : null,
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
                    if (!widget.isMe && widget.chatType == 'Groups')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          widget.message.senderName,
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
                    _formatTime(widget.message.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      widget.message.isRead
                          ? Icons.done_all_rounded
                          : widget.message.isDelivered
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color:
                          widget.message.isRead
                              ? Colors.blue
                              : Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            fontSize: 14,
            color: widget.isMe ? Colors.white : Colors.grey[800],
            height: 1.3,
          ),
        );

      case MessageType.image:
        return MediaDisplayWidget(
          fileUrl: widget.message.fileUrl,
          localFilePath: widget.message.localFilePath,
          fileName: widget.message.fileName,
          fileSize: widget.message.fileSize,
          isMe: widget.isMe,
          content: widget.message.content,
          isDownloaded: widget.message.isDownloaded,
          isDownloading: widget.message.isDownloading,
          downloadProgress: widget.message.downloadProgress,
          onDownloadPressed: () => _downloadFile(widget.message.fileUrl ?? ''),
          allMediaMessages: widget.allMediaMessages,
          currentMediaIndex: widget.currentMediaIndex,
        );

      case MessageType.video:
        return MediaDisplayWidget(
          fileUrl: widget.message.fileUrl,
          localFilePath: widget.message.localFilePath,
          fileName: widget.message.fileName,
          fileSize: widget.message.fileSize,
          isMe: widget.isMe,
          content: widget.message.content,
          isDownloaded: widget.message.isDownloaded,
          isDownloading: widget.message.isDownloading,
          downloadProgress: widget.message.downloadProgress,
          onDownloadPressed: () => _downloadFile(widget.message.fileUrl ?? ''),
          allMediaMessages: widget.allMediaMessages,
          currentMediaIndex: widget.currentMediaIndex,
        );

      case MessageType.file:
        return _buildFilePreview();

      case MessageType.location:
        return _buildLocationMessage();

      case MessageType.voice:
        // Check if this is a voice note (recorded) or audio file (shared)
        final fileName = widget.message.fileName ?? '';
        final isVoiceNote =
            fileName.startsWith('voice_') || fileName.contains('recording');

        if (isVoiceNote) {
          // Use VoiceMessagePlayback for recorded voice notes
          return VoiceMessagePlayback(
            fileUrl: widget.message.fileUrl,
            localFilePath: widget.message.localFilePath,
            fileName: widget.message.fileName,
            fileSize: widget.message.fileSize,
            isMe: widget.isMe,
          );
        } else {
          // Use AudioFilePlayback for shared audio files
          return AudioFilePlayback(
            fileUrl: widget.message.fileUrl,
            localFilePath: widget.message.localFilePath,
            fileName: widget.message.fileName,
            fileSize: widget.message.fileSize,
            isMe: widget.isMe,
            isDownloaded: widget.message.isDownloaded,
            downloadProgress: widget.message.downloadProgress,
            isDownloading: widget.message.isDownloading,
            onDownloadComplete: (localPath) {
              // Update message with local file path
              _updateMessageWithLocalPath(localPath);
            },
          );
        }

      default:
        return Text(
          widget.message.content,
          style: TextStyle(
            fontSize: 14,
            color: widget.isMe ? Colors.white : Colors.grey[800],
            height: 1.3,
          ),
        );
    }
  }

  Widget _buildLocationMessage() {
    return GestureDetector(
      onTap: () => _openLocation(widget.message.content),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (widget.isMe ? Colors.white : Colors.grey[100]!).withOpacity(
            0.3,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (widget.isMe ? Colors.white : Colors.grey[300]!).withOpacity(
              0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.red[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isMe ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.message.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: (widget.isMe ? Colors.white : Colors.grey[600]!)
                          .withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: widget.isMe ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocation(String location) async {
    try {
      // Extract coordinates from location string
      final RegExp coordRegex = RegExp(r'(\d+\.?\d*),\s*(\d+\.?\d*)');
      final match = coordRegex.firstMatch(location);

      if (match != null) {
        final latitude = match.group(1);
        final longitude = match.group(2);

        // Try to open in Google Maps app first
        if (await canLaunchUrl(
          Uri.parse('comgooglemaps://?q=$latitude,$longitude'),
        )) {
          await launchUrl(Uri.parse('comgooglemaps://?q=$latitude,$longitude'));
        } else if (await canLaunchUrl(
          Uri.parse('https://www.google.com/maps?q=$latitude,$longitude'),
        )) {
          await launchUrl(
            Uri.parse('https://www.google.com/maps?q=$latitude,$longitude'),
          );
        }
      }
    } catch (e) {
      print('Error opening location: $e');
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

  EdgeInsets _getMessagePadding() {
    // For media messages (image, video, voice) and document messages (file), use minimal padding to fill the bubble
    if (widget.message.type == MessageType.image ||
        widget.message.type == MessageType.video ||
        widget.message.type == MessageType.voice ||
        widget.message.type == MessageType.file) {
      // If there's a caption, add more padding for better text spacing
      if (widget.message.content.isNotEmpty &&
          widget.message.content != widget.message.fileName) {
        return const EdgeInsets.all(8);
      }
      return const EdgeInsets.all(4);
    }

    // For other message types, use normal padding
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  bool _shouldShowBorder() {
    // Don't show border for media messages (image, video, voice) and document messages (file)
    // This makes them look clean like voice notes and images
    if (widget.message.type == MessageType.image ||
        widget.message.type == MessageType.video ||
        widget.message.type == MessageType.voice ||
        widget.message.type == MessageType.file) {
      return false;
    }

    // Show border for text messages and other types
    return true;
  }

  Widget _buildFilePreview() {
    final fileName = widget.message.fileName ?? 'Unknown file';
    final fileExtension = fileName.split('.').last.toLowerCase();

    // Check if file is downloaded
    if (widget.message.isDownloaded && widget.message.localFilePath != null) {
      // Show clear content for downloaded files
      return _buildDownloadedFilePreview(fileExtension);
    } else {
      // Show blurry preview with download arrow for undownloaded files
      return _buildUndownloadedFilePreview(fileExtension);
    }
  }

  Widget _buildDownloadedFilePreview(String fileExtension) {
    // Images and videos are handled by MediaDisplayWidget, so only handle other file types
    if (['pdf'].contains(fileExtension)) {
      return _buildClearPdfPreview();
    } else {
      return _buildClearGenericFilePreview();
    }
  }

  Widget _buildUndownloadedFilePreview(String fileExtension) {
    // Images and videos are handled by MediaDisplayWidget, so only handle other file types
    if (['pdf'].contains(fileExtension)) {
      return _buildBlurryPdfPreview();
    } else {
      return _buildBlurryGenericFilePreview();
    }
  }

  // Blurry preview for undownloaded PDF files
  Widget _buildBlurryPdfPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.red[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // PDF Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white : Colors.red[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: widget.isMe ? Colors.red[600] : Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'PDF Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isMe ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (widget.message.fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.isMe
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600]!,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Download button
          GestureDetector(
            onTap: () => _downloadFile(widget.message.fileUrl ?? ''),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.download_rounded,
                color: widget.isMe ? Colors.white : Colors.red[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clear preview for downloaded PDF files
  Widget _buildClearPdfPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.red[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // PDF Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white : Colors.red[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: widget.isMe ? Colors.red[600] : Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'PDF Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isMe ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (widget.message.fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.isMe
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600]!,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Open button
          GestureDetector(
            onTap: () => _openDocument(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.open_in_new_rounded,
                color: widget.isMe ? Colors.white : Colors.red[600],
                size: 20,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blue[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white : Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getFileIcon(widget.message.fileName ?? ''),
              color: widget.isMe ? Colors.blue[600] : Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isMe ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (widget.message.fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.isMe
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600]!,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Download button
          GestureDetector(
            onTap: () => _downloadFile(widget.message.fileUrl ?? ''),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.download_rounded,
                color: widget.isMe ? Colors.white : Colors.blue[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clear preview for downloaded generic files
  Widget _buildClearGenericFilePreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blue[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white : Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getFileIcon(widget.message.fileName ?? ''),
              color: widget.isMe ? Colors.blue[600] : Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isMe ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (widget.message.fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(widget.message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          widget.isMe
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600]!,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Open button
          GestureDetector(
            onTap: () => _openDocument(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.open_in_new_rounded,
                color: widget.isMe ? Colors.white : Colors.blue[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument() async {
    try {
      // Check if file is downloaded
      if (widget.message.isDownloaded && widget.message.localFilePath != null) {
        // Open in-app viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DocumentViewerScreen(
                  fileUrl: widget.message.fileUrl,
                  localFilePath: widget.message.localFilePath,
                  fileName:
                      widget.message.fileName ??
                      widget.message.fileName ??
                      'Document',
                  isMe: widget.isMe,
                ),
          ),
        );
      } else {
        // Download first, then open
        await _downloadFile(widget.message.fileUrl ?? '');
        // After download, the file will be available locally
        // You might want to show a success message and allow user to tap again
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download completed. Tap again to open.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error opening document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      print('DEBUG: Starting download for: $fileUrl');

      // Initialize local file storage service
      final localStorage = LocalFileStorageService();
      await localStorage.initialize();

      // First check if file is already downloaded
      final existingFilePath = await localStorage.getLocalFilePathForMessage(
        chatId: widget.message.chatId,
        messageId: widget.message.id,
        fileName: widget.message.fileName ?? 'file',
      );

      if (existingFilePath != null && await File(existingFilePath).exists()) {
        print('DEBUG: File already exists locally: $existingFilePath');

        // Update download state to downloaded with existing local path
        if (widget.onDownloadStateChanged != null) {
          final updatedMessage = widget.message.copyWith(
            isDownloaded: true,
            isDownloading: false,
            downloadProgress: 1.0,
            localFilePath: existingFilePath,
          );
          widget.onDownloadStateChanged!(updatedMessage);
        }
        return;
      }

      // Update download state to downloading
      if (widget.onDownloadStateChanged != null) {
        final updatedMessage = widget.message.copyWith(
          isDownloading: true,
          downloadProgress: 0.0,
        );
        widget.onDownloadStateChanged!(updatedMessage);
      }

      // Download and save file locally
      final localFilePath = await localStorage.downloadAndSaveFile(
        fileUrl: fileUrl,
        fileName: widget.message.fileName ?? 'file',
        chatId: widget.message.chatId,
        messageId: widget.message.id,
        onProgress: (progress) {
          // Update download progress
          if (widget.onDownloadStateChanged != null) {
            final updatedMessage = widget.message.copyWith(
              isDownloading: true,
              downloadProgress: progress,
            );
            widget.onDownloadStateChanged!(updatedMessage);
          }
        },
      );

      if (localFilePath != null) {
        print('DEBUG: File downloaded and saved locally: $localFilePath');

        // Update download state to downloaded with local path
        if (widget.onDownloadStateChanged != null) {
          final updatedMessage = widget.message.copyWith(
            isDownloaded: true,
            isDownloading: false,
            downloadProgress: 1.0,
            localFilePath: localFilePath,
          );
          widget.onDownloadStateChanged!(updatedMessage);
        }

        // Launch the local file
        final localFile = File(localFilePath);
        if (await localFile.exists()) {
          // For images, we don't need to launch externally since they're displayed in the chat
          // For other files, we can launch them
          if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(
            widget.message.fileName?.split('.').last.toLowerCase() ?? '',
          )) {
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
        if (widget.onDownloadStateChanged != null) {
          final updatedMessage = widget.message.copyWith(
            isDownloading: false,
            downloadProgress: 0.0,
          );
          widget.onDownloadStateChanged!(updatedMessage);
        }
      }
    } catch (e) {
      print('ERROR: Failed to download file: ${e.toString()}');

      // Update download state to failed
      if (widget.onDownloadStateChanged != null) {
        final updatedMessage = widget.message.copyWith(
          isDownloading: false,
          downloadProgress: 0.0,
        );
        widget.onDownloadStateChanged!(updatedMessage);
      }
    }
  }

  void _updateMessageWithLocalPath(String localPath) {
    // Update the message with the local file path using the existing callback
    if (widget.onDownloadStateChanged != null) {
      final updatedMessage = widget.message.copyWith(
        isDownloaded: true,
        isDownloading: false,
        downloadProgress: 1.0,
        localFilePath: localPath,
      );
      widget.onDownloadStateChanged!(updatedMessage);
    }
  }
}
