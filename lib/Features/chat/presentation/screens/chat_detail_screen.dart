// Presentation Layer - Chat Detail Screen
import 'package:flutter/material.dart';
import '../../domain/models/chat_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_app_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // Mock messages for demonstration
    _messages.addAll([
      Message(
        id: '1',
        chatId: widget.chat.id,
        senderId: 'other',
        senderName: widget.chat.name,
        content: 'Hey! Are you still looking for a roommate?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
      Message(
        id: '2',
        chatId: widget.chat.id,
        senderId: 'me',
        senderName: 'You',
        content: 'Yes, I am! What\'s your budget range?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
      Message(
        id: '3',
        chatId: widget.chat.id,
        senderId: 'other',
        senderName: widget.chat.name,
        content:
            'I\'m looking for something around \$200-300 per month. Are you okay with that?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
      Message(
        id: '4',
        chatId: widget.chat.id,
        senderId: 'me',
        senderName: 'You',
        content: 'That works perfectly! When are you planning to move in?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
      Message(
        id: '5',
        chatId: widget.chat.id,
        senderId: 'other',
        senderName: widget.chat.name,
        content:
            'Next semester, around January. Would you like to meet up to discuss more details?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: ChatAppBar(
        chat: widget.chat,
        onCallPressed: () {
          // TODO: Implement call functionality
        },
        onInfoPressed: () {
          // TODO: Show chat info/profile
        },
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == 'me';
                final showAvatar =
                    index == 0 ||
                    _messages[index - 1].senderId != message.senderId;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  child: MessageBubble(
                    message: message,
                    isMe: isMe,
                    showAvatar: showAvatar,
                    chatType: widget.chat.category,
                  ),
                );
              },
            ),
          ),

          // Message Input
          MessageInput(
            onSendMessage: (content) {
              _sendMessage(content);
            },
            onSendVoice: () {
              // TODO: Implement voice message
            },
            onSendAttachment: () {
              // TODO: Implement file/image attachment
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'me',
      senderName: 'You',
      content: content.trim(),
      timestamp: DateTime.now(),
      type: MessageType.text,
      isRead: false,
      isDelivered: false,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: Send message to backend
  }
}
