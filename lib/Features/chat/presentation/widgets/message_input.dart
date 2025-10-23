// Presentation Layer - Message Input Widget
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../core/theme/app_theme.dart';
import 'file_picker_overlay.dart';
import 'voice_recording_widget.dart';

// Image with caption class
class ImageWithCaption {
  final AssetEntity asset;
  final String caption;

  ImageWithCaption({required this.asset, this.caption = ''});
}

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, String, int, {String? fileType, String? caption})?
  onSendFile; // File object, fileName, fileSize, fileType, caption
  final Function(String)? onSendLocation; // Location string
  final Function(File, String, int)?
  onSendVoice; // Voice file, fileName, fileSize
  final Function(bool)? onTypingChanged; // Typing indicator callback

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.onSendFile,
    this.onSendLocation,
    this.onSendVoice,
    this.onTypingChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  FocusNode _focusNode = FocusNode();

  // File upload progress tracking
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

  // Typing indicator
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _handleTyping(String value) {
    final hasText = value.trim().isNotEmpty;
    final wasTyping = _isTyping;

    // Cancel previous timer
    _typingTimer?.cancel();

    if (hasText) {
      // Send typing indicator only when starting to type
      if (!wasTyping) {
        widget.onTypingChanged?.call(true);
      }

      // Set timer to stop typing indicator after 3 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onTypingChanged?.call(false);
          // Don't change _isTyping here - keep send button visible
        }
      });
    } else {
      // Stop typing indicator immediately when text is empty
      widget.onTypingChanged?.call(false);
    }

    setState(() {
      _isTyping = hasText; // Keep send button visible as long as there's text
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Column(
      children: [
        // Voice Recording Widget
        if (_isRecording)
          Container(
            padding: const EdgeInsets.all(16),
            child: VoiceRecordingWidget(
              onVoiceRecorded: (file, fileName, fileSize) {
                setState(() {
                  _isRecording = false;
                });
                widget.onSendVoice?.call(file, fileName, fileSize);
              },
              onCancel: () {
                setState(() {
                  _isRecording = false;
                });
              },
            ),
          ),
        // Emoji Picker
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _messageController.text += emoji.emoji;
                _messageController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _messageController.text.length),
                );
                // Trigger typing handler to show send button
                _handleTyping(_messageController.text);
              },
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 28,
                  backgroundColor: Colors.white,
                  recentsLimit: 28,
                  replaceEmojiOnLimitExceed: false,
                  noRecents: Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  loadingIndicator: const SizedBox.shrink(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  enabled: true,
                  backgroundColor: Colors.white,
                  buttonColor: AppTheme.primaryColor,
                  buttonIconColor: Colors.white,
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: Colors.white,
                  iconColorSelected: AppTheme.primaryColor,
                  backspaceColor: AppTheme.primaryColor,
                ),
                searchViewConfig: SearchViewConfig(
                  backgroundColor: Colors.white,
                  hintText: 'Search emoji...',
                ),
              ),
            ),
          ),

        // Message Input Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment Button
                GestureDetector(
                  onTap: _isUploadingFile ? null : _showFilePicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _isUploadingFile
                              ? Colors.blue[100]
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        _isUploadingFile
                            ? Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      value: _uploadProgress,
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue[600]!,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Icon(
                              Icons.attach_file_rounded,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                  ),
                ),
                const SizedBox(width: 12),

                // Message Input Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      onChanged: _handleTyping,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Emoji Button
                GestureDetector(
                  onTap: _toggleEmojiPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _showEmojiPicker
                              ? AppTheme.primaryColor
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: _showEmojiPicker ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Voice/Send Button
                GestureDetector(
                  onTap: _isTyping ? _sendMessage : _startVoiceRecording,
                  onLongPressStart:
                      _isTyping ? null : (_) => _startVoiceRecording(),
                  onLongPressEnd:
                      _isTyping ? null : (_) => _stopVoiceRecording(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _isTyping ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:
                          _isTyping
                              ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                      color: _isTyping ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Upload progress indicator
        if (_isUploadingFile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uploading ${_uploadingFileName ?? 'file'}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.blue[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();

      // Stop typing indicator
      _typingTimer?.cancel();
      widget.onTypingChanged?.call(false);

      setState(() {
        _isTyping = false; // Reset typing state after sending
      });
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  // Method to update upload progress (called from parent)
  void updateUploadProgress(double progress) {
    setState(() {
      _uploadProgress = progress;
    });
  }

  void _showFilePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            builder:
                (context, scrollController) => FilePickerOverlay(
                  onFileSelected: _handleFileSelection,
                  onLocationSelected: _handleLocationSelection,
                  onImagesSelected: _handleImagesSelected,
                  onClose: () => Navigator.pop(context),
                ),
          ),
    );
  }

  void _handleLocationSelection(String location) {
    widget.onSendLocation?.call(location);
  }

  void _handleImagesSelected(List<AssetEntity> selectedAssets) {
    print(
      'DEBUG: MessageInput - Handling ${selectedAssets.length} selected images',
    );

    // SIMPLIFIED FLOW:
    // 1. Immediately send the images (no preview, no delays)
    // 2. The optimistic update in chat screen will show them instantly
    // 3. Once uploaded, real messages will replace optimistic ones

    // Send images immediately without preview
    _sendImagesDirectly(selectedAssets);
  }

  // Simplified: Send images directly without preview screen
  Future<void> _sendImagesDirectly(List<dynamic> selectedAssets) async {
    if (selectedAssets.isEmpty) return;

    print('DEBUG: Sending ${selectedAssets.length} images directly');

    // Send each image one by one
    for (final item in selectedAssets) {
      try {
        AssetEntity asset;
        String caption = '';

        // Handle both AssetEntity and ImageWithCaption
        if (item is AssetEntity) {
          asset = item;
        } else if (item is ImageWithCaption) {
          asset = item.asset;
          caption = item.caption;
        } else {
          print('DEBUG: Unknown item type: ${item.runtimeType}');
          continue;
        }

        final file = await asset.file;
        if (file != null) {
          final fileName =
              asset.title ??
              'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final fileSize = await file.length();

          print('DEBUG: Sending image: $fileName');

          // Call the callback to send the file
          if (widget.onSendFile != null) {
            await widget.onSendFile!(
              file,
              fileName,
              fileSize,
              fileType: 'image',
              caption: caption.isNotEmpty ? caption : null,
            );
          }
        }
      } catch (e) {
        print('ERROR: Failed to send image: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send image: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }

    print('DEBUG: All images sent');
  }

  void _showCustomImagePreview(List<AssetEntity> selectedAssets) {
    // Use showDialog to prevent widget disposal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          '${selectedAssets.length} image${selectedAssets.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          // Add a small delay to ensure dialog is closed
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          _sendImagesDirectly(selectedAssets);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ),
                // Preview Content
                Expanded(
                  child: _WhatsAppStylePreview(
                    selectedAssets: selectedAssets,
                    onSendImages: (imagesWithCaptions) async {
                      Navigator.of(dialogContext).pop();
                      // Add a small delay to ensure dialog is closed
                      await Future.delayed(const Duration(milliseconds: 100));
                      await _sendImagesDirectly(imagesWithCaptions);
                    },
                    onCancel: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NOTE: This complex preview flow has been removed in favor of direct sending
  // Users can still add captions by tapping on the sent image
  // This simplifies the code and prevents widget disposal issues

  Future<void> _handleFileSelection(
    File file,
    String fileName,
    int fileSize, {
    String? fileType,
    String? caption,
  }) async {
    try {
      print(
        'DEBUG: Message input - Handling file: $fileName, Size: $fileSize, Type: $fileType',
      );

      // Check file size (limit to 50MB)
      if (fileSize > 50 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size too large. Maximum 50MB allowed.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Set uploading state
      setState(() {
        _isUploadingFile = true;
        _uploadProgress = 0.0;
        _uploadingFileName = fileName;
      });

      if (widget.onSendFile != null) {
        print('DEBUG: Message input - Calling onSendFile callback');
        // Call the callback with progress tracking
        await widget.onSendFile!(
          file,
          fileName,
          fileSize,
          fileType: fileType,
          caption: caption,
        );
      }

      // Reset uploading state
      setState(() {
        _isUploadingFile = false;
        _uploadProgress = 0.0;
        _uploadingFileName = null;
      });
    } catch (e) {
      print('Error handling file selection: $e');

      // Reset uploading state on error
      setState(() {
        _isUploadingFile = false;
        _uploadProgress = 0.0;
        _uploadingFileName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
    });
  }

  void _stopVoiceRecording() {
    // This will be handled by the VoiceRecordingWidget
    // when the user taps the send button
  }
}

// WhatsApp-style preview widget
class _WhatsAppStylePreview extends StatefulWidget {
  final List<AssetEntity> selectedAssets;
  final Function(List<ImageWithCaption>) onSendImages;
  final VoidCallback onCancel;

  const _WhatsAppStylePreview({
    required this.selectedAssets,
    required this.onSendImages,
    required this.onCancel,
  });

  @override
  State<_WhatsAppStylePreview> createState() => _WhatsAppStylePreviewState();
}

class _WhatsAppStylePreviewState extends State<_WhatsAppStylePreview> {
  late PageController _pageController;
  late List<ImageWithCaption> _imagesWithCaptions;
  int _currentIndex = 0;
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    print(
      'DEBUG: _WhatsAppStylePreview initState with ${widget.selectedAssets.length} assets',
    );
    _pageController = PageController();
    _imagesWithCaptions =
        widget.selectedAssets
            .map((asset) => ImageWithCaption(asset: asset))
            .toList();
    _captionController = TextEditingController(
      text: _imagesWithCaptions[_currentIndex].caption,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: _WhatsAppStylePreview build called');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} of ${_imagesWithCaptions.length}'),
        leading: IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => widget.onSendImages(_imagesWithCaptions),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image viewer
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                // Update caption controller with current image's caption
                _captionController.text = _imagesWithCaptions[index].caption;
              },
              itemCount: _imagesWithCaptions.length,
              itemBuilder: (context, index) {
                final imageWithCaption = _imagesWithCaptions[index];
                return InteractiveViewer(
                  child: Center(
                    child: FutureBuilder<File?>(
                      future: imageWithCaption.asset.file,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.file(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Caption input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: TextField(
              controller: _captionController,
              onChanged: (value) {
                setState(() {
                  _imagesWithCaptions[_currentIndex] = ImageWithCaption(
                    asset: _imagesWithCaptions[_currentIndex].asset,
                    caption: value,
                  );
                });
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.transparent,
              ),
              decoration: const InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
