// Presentation Layer - Chat Detail Screen
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/chat_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_app_bar.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/local_file_storage_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final VoidCallback? onChatUpdated;

  const ChatDetailScreen({super.key, required this.chat, this.onChatUpdated});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  @override
  void initState() {
    super.initState();
    _initializeLocalStorage();
    _loadMessages();
    _updateLastSeen();
  }

  Future<void> _initializeLocalStorage() async {
    try {
      final localStorage = LocalFileStorageService();
      await localStorage.initialize();
      print(
        'DEBUG: Local file storage initialized for chat: ${widget.chat.id}',
      );
    } catch (e) {
      print('ERROR: Failed to initialize local storage: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      // Fetch real messages from database
      final messagesData = await _databaseService.getChatMessages(
        chatId: widget.chat.id,
        limit: 50,
      );

      // Convert to Message objects
      final messages =
          messagesData.map((data) {
            final currentUser = _authService.currentUser;
            final isMe =
                currentUser != null && data['sender_id'] == currentUser.id;

            final createdAt = DateTime.parse(
              data['created_at'] ?? DateTime.now().toIso8601String(),
            );

            print(
              'DEBUG: Message timestamp - Raw: ${data['created_at']}, Parsed: $createdAt',
            );

            return Message(
              id: data['id'] ?? '',
              chatId: data['chat_id'] ?? '',
              senderId: data['sender_id'] ?? '',
              senderName: isMe ? 'You' : _getSenderName(data['sender_id']),
              senderProfileImageUrl:
                  isMe ? null : _getSenderProfileImageUrl(data['sender_id']),
              content: data['message'] ?? '',
              createdAt: createdAt,
              type: MessageType.values.firstWhere(
                (e) => e.toString().split('.').last == data['type'],
                orElse: () => MessageType.text,
              ),
              isRead: data['is_read'] ?? false,
              isDelivered: data['is_delivered'] ?? false,
            );
          }).toList();

      // Sort messages by creation time (latest at bottom)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      // Fallback to mock messages if database fails
      _loadMockMessages();
    }
  }

  void _loadMockMessages() {
    // Mock messages for demonstration
    final currentUser = _authService.currentUser;
    final otherUserId =
        widget.chat.participants
            .firstWhere(
              (p) => p.userId != currentUser?.id,
              orElse: () => widget.chat.participants.first,
            )
            .userId;

    _messages.addAll([
      Message(
        id: '1',
        chatId: widget.chat.id,
        senderId: otherUserId,
        senderName: widget.chat.name,
        content: 'Hey! Are you still looking for a roommate?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
      Message(
        id: '2',
        chatId: widget.chat.id,
        senderId: currentUser?.id ?? 'current-user',
        senderName: 'You',
        content: 'Yes, I am! What\'s your budget range?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        type: MessageType.text,
        isRead: true,
        isDelivered: true,
      ),
    ]);
  }

  String _getSenderName(String senderId) {
    // Find sender name from chat participants
    final participant = widget.chat.participants.firstWhere(
      (p) => p.userId == senderId,
      orElse:
          () => ChatParticipant(
            id: '',
            chatId: '',
            userId: senderId,
            name: 'Unknown User',
            isOnline: false,
            lastSeen: DateTime.now(),
            joinedAt: DateTime.now(),
          ),
    );
    return participant.name;
  }

  String? _getSenderProfileImageUrl(String senderId) {
    // Find sender profile image from chat participants
    final participant = widget.chat.participants.firstWhere(
      (p) => p.userId == senderId,
      orElse:
          () => ChatParticipant(
            id: '',
            chatId: '',
            userId: senderId,
            name: 'Unknown User',
            isOnline: false,
            lastSeen: DateTime.now(),
            joinedAt: DateTime.now(),
          ),
    );
    return participant.profileImageUrl;
  }

  Future<void> _updateLastSeen() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Update last seen in profiles table
        await _databaseService.updateUserLastSeen(currentUser.id);

        // Update last read at for this chat
        await _databaseService.updateLastReadAt(
          chatId: widget.chat.id,
          userId: currentUser.id,
        );
      }
    } catch (e) {
      print('Error updating last seen: $e');
    }
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
                final currentUser = _authService.currentUser;
                final isMe =
                    currentUser != null && message.senderId == currentUser.id;
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
                    onDownloadStateChanged: (updatedMessage) {
                      setState(() {
                        final index = _messages.indexWhere(
                          (m) => m.id == updatedMessage.id,
                        );
                        if (index != -1) {
                          _messages[index] = updatedMessage;
                        }
                      });
                    },
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
            onSendFile: (file, fileName, fileSize) {
              _sendFile(file, fileName, fileSize);
            },
            onSendVoice: () {
              // TODO: Implement voice message
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Create optimistic message for immediate UI update
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: currentUser.id,
      senderName: 'You',
      senderProfileImageUrl: null,
      content: content.trim(),
      createdAt: DateTime.now(),
      type: MessageType.text,
      isRead: false,
      isDelivered: false,
    );

    // Add to UI immediately
    setState(() {
      _messages.add(optimisticMessage);
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

    try {
      // Send message to database
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content: content.trim(),
        type: 'text',
      );

      if (messageData != null) {
        // Update the optimistic message with real data
        final realMessage = Message(
          id: messageData['id'] ?? optimisticMessage.id,
          chatId: messageData['chat_id'] ?? widget.chat.id,
          senderId: messageData['sender_id'] ?? currentUser.id,
          senderName: 'You',
          senderProfileImageUrl: null,
          content: messageData['message'] ?? content.trim(),
          createdAt: DateTime.parse(
            messageData['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          type: MessageType.text,
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
        );

        // Replace optimistic message with real message
        setState(() {
          final index = _messages.indexWhere(
            (m) => m.id == optimisticMessage.id,
          );
          if (index != -1) {
            _messages[index] = realMessage;
          }
        });

        // Notify parent that chat was updated
        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Remove optimistic message on error
      setState(() {
        _messages.removeWhere((m) => m.id == optimisticMessage.id);
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  Future<void> _sendFile(File file, String fileName, int fileSize) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Determine file type based on extension
    String fileType = 'file';
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      fileType = 'image';
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(extension)) {
      fileType = 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
      fileType = 'voice';
    }

    // Create optimistic message for immediate UI update
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: currentUser.id,
      senderName: 'You',
      senderProfileImageUrl: null,
      content: fileName,
      createdAt: DateTime.now(),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == fileType,
        orElse: () => MessageType.file,
      ),
      isRead: false,
      isDelivered: false,
    );

    // Add to UI immediately
    setState(() {
      _messages.add(optimisticMessage);
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

    try {
      // Send file to database with upload
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content: fileName,
        type: fileType,
        file: file, // Pass the File object for upload
        fileName: fileName,
        fileSize: fileSize,
      );

      if (messageData != null) {
        // Update the optimistic message with real data
        final realMessage = Message(
          id: messageData['id'] ?? optimisticMessage.id,
          chatId: messageData['chat_id'] ?? widget.chat.id,
          senderId: messageData['sender_id'] ?? currentUser.id,
          senderName: 'You',
          senderProfileImageUrl: null,
          content: messageData['message'] ?? fileName,
          createdAt: DateTime.parse(
            messageData['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          type: MessageType.values.firstWhere(
            (e) =>
                e.toString().split('.').last ==
                (messageData['type'] ?? fileType),
            orElse: () => MessageType.file,
          ),
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
        );

        // Replace optimistic message with real message
        setState(() {
          final index = _messages.indexWhere(
            (m) => m.id == optimisticMessage.id,
          );
          if (index != -1) {
            _messages[index] = realMessage;
          }
        });

        // Notify parent that chat was updated
        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending file: $e');
      // Remove optimistic message on error
      setState(() {
        _messages.removeWhere((m) => m.id == optimisticMessage.id);
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send file: $e')));
      }
    }
  }
}
