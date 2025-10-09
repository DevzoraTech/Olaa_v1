// Presentation Layer - Message Input Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onSendVoice;
  final VoidCallback onSendAttachment;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendVoice,
    required this.onSendAttachment,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: widget.onSendAttachment,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
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
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.trim().isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              onTap: () {
                // TODO: Implement emoji picker
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.grey[600],
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
                  color: _isTyping ? AppTheme.primaryColor : Colors.grey[100],
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
}
