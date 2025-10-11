// Presentation Layer - Message Input Widget
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, String, int)?
  onSendFile; // File object, fileName, fileSize
  final VoidCallback onSendVoice;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.onSendFile,
    required this.onSendVoice,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  bool _showEmojiPicker = false;
  FocusNode _focusNode = FocusNode();

  // File upload progress tracking
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  onTap: _isUploadingFile ? null : _pickFile,
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
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.trim().isNotEmpty;
                        });
                      },
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
                  onTap: _isTyping ? _sendMessage : widget.onSendVoice,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _isTyping ? AppTheme.primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
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
      setState(() {
        _isTyping = false;
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        final filePath = file.path!;
        final fileName = file.name;
        final fileSize = file.size;

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

        // Create File object
        final fileObj = File(filePath);

        if (widget.onSendFile != null) {
          // Call the callback with progress tracking
          await widget.onSendFile!(fileObj, fileName, fileSize);
        }

        // Reset uploading state
        setState(() {
          _isUploadingFile = false;
          _uploadProgress = 0.0;
          _uploadingFileName = null;
        });
      }
    } catch (e) {
      print('Error picking file: $e');

      // Reset uploading state on error
      setState(() {
        _isUploadingFile = false;
        _uploadProgress = 0.0;
        _uploadingFileName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
