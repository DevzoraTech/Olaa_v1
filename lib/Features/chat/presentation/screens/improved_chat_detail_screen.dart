// Presentation Layer - Improved Chat Detail Screen with Realtime
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/multiple_images_widget.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/local_file_storage_service.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/utils/date_time_utils.dart';

class ImprovedChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final VoidCallback? onChatUpdated;

  const ImprovedChatDetailScreen({
    super.key,
    required this.chat,
    this.onChatUpdated,
  });

  @override
  State<ImprovedChatDetailScreen> createState() =>
      _ImprovedChatDetailScreenState();
}

class _ImprovedChatDetailScreenState extends State<ImprovedChatDetailScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final ChatService _chatService = ChatService.instance;

  // Pagination
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  static const int _pageSize = 30;

  // Typing indicators
  final Set<String> _typingUsers = {};
  Timer? _typingTimer;

  // Realtime subscriptions
  StreamSubscription<Message>? _messagesSubscription;
  StreamSubscription<TypingIndicator>? _typingSubscription;

  bool _isLoading = true;

  // Group consecutive media messages (images and videos) within 2 minutes
  List<dynamic> _groupMessages() {
    final List<dynamic> groupedMessages = [];
    int i = 0;

    while (i < _messages.length) {
      final message = _messages[i];

      // Check if this is a media message (image or video)
      if (message.type == MessageType.image ||
          message.type == MessageType.video) {
        final List<Message> mediaGroup = [message];
        int j = i + 1;

        // Collect consecutive media messages from the same sender within 2 minutes
        while (j < _messages.length &&
            (_messages[j].type == MessageType.image ||
                _messages[j].type == MessageType.video) &&
            _messages[j].senderId == message.senderId &&
            _messages[j].createdAt.difference(message.createdAt).inMinutes <
                2) {
          mediaGroup.add(_messages[j]);
          j++;
        }

        if (mediaGroup.length > 1) {
          // Group multiple media files
          groupedMessages.add({
            'type': 'media_group',
            'messages': mediaGroup,
            'senderId': message.senderId,
            'senderName': message.senderName,
            'createdAt': message.createdAt,
            'isMe': message.senderId == _authService.currentUser?.id,
          });
        } else {
          // Single media message
          groupedMessages.add(mediaGroup[0]);
        }

        i = j;
      } else {
        // Non-media message
        groupedMessages.add(message);
        i++;
      }
    }

    return groupedMessages;
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeChat() async {
    await _initializeLocalStorage();
    await _loadInitialMessages();
    await _subscribeToRealtime();
    await _updateLastSeen();
  }

  Future<void> _initializeLocalStorage() async {
    try {
      final localStorage = LocalFileStorageService();
      await localStorage.initialize();
    } catch (e) {
      print('ERROR: Failed to initialize local storage: $e');
    }
  }

  Future<void> _loadInitialMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final messagesData = await _databaseService.getChatMessages(
        chatId: widget.chat.id,
        limit: _pageSize,
      );

      print('DEBUG: Initial load - got ${messagesData.length} messages');

      if (messagesData.length < _pageSize) {
        _hasMoreMessages = false;
        print(
          'DEBUG: All messages loaded (got ${messagesData.length} < $_pageSize)',
        );
      } else {
        _hasMoreMessages = true;
        print('DEBUG: More messages available');
      }

      final messages = await _parseMessages(messagesData);

      // Messages come from DB in DESC order (newest first)
      // Sort them DESC for consistency (newest first in our list)
      // With reverse: true ListView, newest messages appear at bottom
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _isLoading = false;
        });

        print('DEBUG: Loaded ${_messages.length} messages into state');

        // Scroll to bottom after loading (showing newest messages)
        // With reverse: true, this shows the newest messages at the bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: false);
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load messages. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// Load more older messages (pagination)
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _messages.isEmpty) {
      print(
        'DEBUG: Skipping load more - loading: $_isLoadingMore, hasMore: $_hasMoreMessages, messages: ${_messages.length}',
      );
      return;
    }

    print('DEBUG: Loading more messages...');
    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Get the oldest message's timestamp to load messages before it
      final oldestMessage =
          _messages.first; // First because messages are sorted newest->oldest
      final beforeTimestamp = oldestMessage.createdAt.toUtc().toIso8601String();

      print('DEBUG: Loading messages before: $beforeTimestamp');

      final messagesData = await _databaseService.getChatMessages(
        chatId: widget.chat.id,
        limit: _pageSize,
        beforeTimestamp: beforeTimestamp,
      );

      print('DEBUG: Loaded ${messagesData.length} older messages');

      // If we got fewer messages than page size, we've reached the end
      if (messagesData.length < _pageSize) {
        _hasMoreMessages = false;
        print('DEBUG: No more messages to load');
      }

      if (messagesData.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
            _hasMoreMessages = false;
          });
        }
        return;
      }

      final newMessages = await _parseMessages(messagesData);

      // Messages come from DB in DESC order (newest first)
      // Sort them DESC for consistency (newest first in our list)
      // With reverse: true ListView, newest messages appear at bottom
      newMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          // Insert older messages at the beginning (they're older than existing ones)
          _messages.insertAll(0, newMessages);
          _isLoadingMore = false;
        });

        print('DEBUG: Total messages now: ${_messages.length}');
      }
    } catch (e) {
      print('ERROR: Failed to load more messages: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load older messages. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<List<Message>> _parseMessages(
    List<Map<String, dynamic>> messagesData,
  ) async {
    final currentUser = _authService.currentUser;
    final messages = <Message>[];

    for (final data in messagesData) {
      final senderId = data['sender_id'] as String;
      final isMe = currentUser != null && senderId == currentUser.id;

      messages.add(
        Message(
          id: data['id'] ?? '',
          chatId: data['chat_id'] ?? '',
          senderId: senderId,
          senderName: isMe ? 'You' : _getSenderName(senderId),
          senderProfileImageUrl:
              isMe ? null : _getSenderProfileImageUrl(senderId),
          content: data['message'] ?? '',
          createdAt:
              DateTime.parse(
                data['created_at'] ?? DateTime.now().toIso8601String(),
              ).toLocal(), // Convert to local timezone
          type: MessageType.values.firstWhere(
            (e) => e.name == (data['type'] ?? 'text'),
            orElse: () => MessageType.text,
          ),
          fileUrl: data['file_url'],
          fileName: data['file_name'],
          fileSize: data['file_size'],
          replyToMessageId: data['reply_to_message_id'],
          isEdited: data['is_edited'] ?? false,
          editedAt:
              data['edited_at'] != null
                  ? DateTime.parse(data['edited_at']).toLocal()
                  : null,
          isRead: data['is_read'] ?? false,
          isDelivered: data['is_delivered'] ?? true,
        ),
      );
    }

    return messages;
  }

  Future<void> _subscribeToRealtime() async {
    try {
      // Subscribe to new messages
      await _chatService.subscribeToChat(widget.chat.id);

      _messagesSubscription = _chatService.messagesStream.listen((message) {
        if (message.chatId == widget.chat.id) {
          _onNewMessage(message);
        }
      });

      // Subscribe to typing indicators
      _typingSubscription = _chatService.typingStream.listen((indicator) {
        if (indicator.chatId == widget.chat.id) {
          _onTypingIndicator(indicator);
        }
      });
    } catch (e) {
      print('ERROR: Failed to subscribe to realtime: $e');
    }
  }

  void _onNewMessage(Message message) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Don't add if message already exists (exact ID match)
    if (_messages.any((m) => m.id == message.id)) {
      print('DEBUG: Message ${message.id} already exists, skipping');
      return;
    }

    // Check if this is a message from the current user that might replace an optimistic message
    if (message.senderId == currentUser.id) {
      // Look for optimistic message with same type and recent timestamp
      // Use different matching logic based on message type
      final optimisticIndex = _messages.indexWhere((m) {
        // Must be a temporary message from current user
        if (!m.id.startsWith('temp_') || m.senderId != currentUser.id) {
          return false;
        }

        // Must be same message type
        if (m.type != message.type) {
          return false;
        }

        // Must be within reasonable time window (30 seconds for file uploads)
        final timeDiff = m.createdAt.difference(message.createdAt).abs();
        if (timeDiff.inSeconds > 30) {
          return false;
        }

        // Type-specific matching logic
        switch (message.type) {
          case MessageType.text:
            // For text messages, match by content
            return m.content.trim() == message.content.trim();

          case MessageType.image:
          case MessageType.video:
          case MessageType.file:
          case MessageType.voice:
            // For file-based messages, match by filename
            // Filenames should be unique (include timestamp + user ID)
            if (m.fileName != null && message.fileName != null) {
              return m.fileName == message.fileName;
            }
            // Fallback: match by file size if filename not available
            if (m.fileSize != null && message.fileSize != null) {
              return m.fileSize == message.fileSize;
            }
            return false;

          case MessageType.location:
            // For location messages, match by coordinates
            return m.content == message.content;

          case MessageType.link:
            // For link messages, match by URL
            return m.content == message.content;
        }
      });

      if (optimisticIndex != -1) {
        // Replace optimistic message with real message
        print(
          'DEBUG: Replacing optimistic message at index $optimisticIndex with real message',
        );
        print(
          'DEBUG: Optimistic: ${_messages[optimisticIndex].id}, Real: ${message.id}, Type: ${message.type}',
        );
        if (mounted) {
          setState(() {
            _messages[optimisticIndex] = message;
          });
        }
        return;
      } else {
        print(
          'DEBUG: No matching optimistic message found for real message: ${message.id}',
        );
        print(
          'DEBUG: Real message - Type: ${message.type}, Content: ${message.content.substring(0, message.content.length > 50 ? 50 : message.content.length)}, FileName: ${message.fileName}',
        );
      }
    }

    if (mounted) {
      setState(() {
        _messages.insert(0, message);
      });

      // Scroll to bottom if user is near bottom
      if (_isNearBottom()) {
        _scrollToBottom();
      }

      // Mark as read if from other user
      if (message.senderId != currentUser.id) {
        _chatService.markMessageAsRead(message.id, widget.chat.id);
      }
    }
  }

  void _onTypingIndicator(TypingIndicator indicator) {
    final currentUser = _authService.currentUser;
    if (currentUser == null || indicator.userId == currentUser.id) return;

    if (mounted) {
      setState(() {
        if (indicator.isTyping) {
          _typingUsers.add(indicator.userName);
        } else {
          _typingUsers.remove(indicator.userName);
        }
      });
    }
  }

  void _onScroll() {
    // Load more when scrolled to top
    if (_scrollController.position.pixels == 0) {
      _loadMoreMessages();
    }
  }

  Future<void> _onRefresh() async {
    try {
      // Reset pagination state
      _hasMoreMessages = true;

      // Load fresh messages
      await _loadInitialMessages();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messages refreshed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh messages'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) < 200;
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _updateLastSeen() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _databaseService.updateUserLastSeen(currentUser.id);
        await _databaseService.updateLastReadAt(
          chatId: widget.chat.id,
          userId: currentUser.id,
        );
      }
    } catch (e) {
      print('Error updating last seen: $e');
    }
  }

  void _onTypingChanged(bool isTyping) {
    _chatService.sendTypingIndicator(
      chatId: widget.chat.id,
      isTyping: isTyping,
    );
  }

  @override
  void dispose() {
    print('DEBUG: Chat screen disposing - cancelling subscriptions');

    // Cancel all subscriptions immediately
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();

    // Dispose scroll controller
    _scrollController.dispose();

    // Unsubscribe from chat realtime - this is async but we don't need to wait
    // The unsubscribe will complete in the background
    _chatService.unsubscribeFromChat().catchError((error) {
      print('DEBUG: Error unsubscribing from chat: $error');
      // Ignore errors during disposal
    });

    // ALWAYS call super.dispose() last and synchronously
    super.dispose();

    print('DEBUG: Chat screen disposed successfully');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return PopScope(
      canPop: false, // Prevent back button from disposing
      onPopInvoked: (didPop) {
        if (didPop) {
          print('DEBUG: PopScope prevented disposal');
        }
      },
      child: Scaffold(
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
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          // Load more indicator
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          // Messages
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final groupedMessages = _groupMessages();
                                return RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  color: Colors.blue,
                                  backgroundColor: Colors.white,
                                  strokeWidth: 2.0,
                                  displacement: 40.0,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    reverse:
                                        true, // ✅ NEW: Show newest messages at bottom
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: groupedMessages.length,
                                    itemBuilder: (context, index) {
                                      final item = groupedMessages[index];

                                      if (item is Map &&
                                          item['type'] == 'media_group') {
                                        // Handle grouped media files
                                        final mediaGroup =
                                            item['messages'] as List<Message>;
                                        final isMe = item['isMe'] as bool;
                                        final showAvatar =
                                            index == 0 ||
                                            (groupedMessages[index - 1]
                                                    is Map &&
                                                (groupedMessages[index - 1]
                                                        as Map)['senderId'] !=
                                                    item['senderId']) ||
                                            (groupedMessages[index - 1]
                                                    is Message &&
                                                (groupedMessages[index - 1]
                                                            as Message)
                                                        .senderId !=
                                                    item['senderId']);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 2,
                                          ),
                                          child: _buildMediaGroupBubble(
                                            mediaGroup,
                                            isMe,
                                            showAvatar,
                                          ),
                                        );
                                      } else {
                                        // Handle single message
                                        final message = item as Message;
                                        final currentUser =
                                            _authService.currentUser;
                                        final isMe =
                                            currentUser != null &&
                                            message.senderId == currentUser.id;
                                        final showAvatar =
                                            index == 0 ||
                                            (groupedMessages[index - 1]
                                                    is Map &&
                                                (groupedMessages[index - 1]
                                                        as Map)['senderId'] !=
                                                    message.senderId) ||
                                            (groupedMessages[index - 1]
                                                    is Message &&
                                                (groupedMessages[index - 1]
                                                            as Message)
                                                        .senderId !=
                                                    message.senderId);

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
                                            onDownloadStateChanged: (
                                              updatedMessage,
                                            ) {
                                              setState(() {
                                                final idx = _messages
                                                    .indexWhere(
                                                      (m) =>
                                                          m.id ==
                                                          updatedMessage.id,
                                                    );
                                                if (idx != -1) {
                                                  _messages[idx] =
                                                      updatedMessage;
                                                }
                                              });
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Typing indicator
                          if (_typingUsers.isNotEmpty) _buildTypingIndicator(),
                        ],
                      ),
            ),

            // Message Input
            MessageInput(
              onSendMessage: (content) {
                _sendMessage(content);
              },
              onSendFile: (
                file,
                fileName,
                fileSize, {
                String? fileType,
                String? caption,
              }) {
                _sendFile(
                  file,
                  fileName,
                  fileSize,
                  fileType: fileType,
                  caption: caption,
                );
              },
              onSendLocation: (location) {
                _sendLocation(location);
              },
              onSendVoice: (file, fileName, fileSize) {
                _sendVoiceMessage(file, fileName, fileSize);
              },
              onTypingChanged: _onTypingChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final typingText =
        _typingUsers.length == 1
            ? '${_typingUsers.first} is typing...'
            : '${_typingUsers.length} people are typing...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            typingText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGroupBubble(
    List<Message> mediaGroup,
    bool isMe,
    bool showAvatar,
  ) {
    // Get the caption from the first message (they should all have the same caption)
    final caption = mediaGroup.first.content;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Image group content
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: MultipleImagesWidget(
                  imageUrls: mediaGroup.map((m) => m.fileUrl ?? '').toList(),
                  localFilePaths:
                      mediaGroup.map((m) => m.localFilePath).toList(),
                  fileNames: mediaGroup.map((m) => m.fileName).toList(),
                  fileSizes: mediaGroup.map((m) => m.fileSize).toList(),
                  isMe: isMe,
                  content: caption,
                  isDownloaded: mediaGroup.map((m) => m.isDownloaded).toList(),
                  downloadProgress:
                      mediaGroup.map((m) => m.downloadProgress).toList(),
                  isDownloading:
                      mediaGroup.map((m) => m.isDownloading).toList(),
                  onDownloadPressed: (index) {
                    // Handle download for specific image
                    final message = mediaGroup[index];
                    if (message.fileUrl != null) {
                      // TODO: Implement download functionality
                    }
                  },
                ),
              ),

              const SizedBox(height: 4),

              // Time and status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(mediaGroup.first.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      mediaGroup.first.isRead
                          ? Icons.done_all
                          : mediaGroup.first.isDelivered
                          ? Icons.done_all
                          : Icons.done,
                      size: 12,
                      color:
                          mediaGroup.first.isRead
                              ? Colors.blue
                              : Colors.grey[500],
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return 'Just now';
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Create optimistic message
    final optimisticMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
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

    if (mounted) {
      setState(() {
        _messages.insert(0, optimisticMessage);
      });
    }

    _scrollToBottom();

    try {
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content: content.trim(),
        type: 'text',
      );

      if (messageData != null && mounted) {
        // Update optimistic message with real data instead of removing it
        final realMessage = Message(
          id: messageData['id'] ?? optimisticMessage.id,
          chatId: messageData['chat_id'] ?? widget.chat.id,
          senderId: messageData['sender_id'] ?? currentUser.id,
          senderName: 'You',
          senderProfileImageUrl: null,
          content: messageData['message'] ?? content.trim(),
          createdAt: DateTimeUtils.parseSupabaseTimestamp(
            messageData['created_at'] ?? DateTime.now().toIso8601String(),
          ), // ✅ FIXED: Use DateTimeUtils for consistency
          type: MessageType.text,
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
        );

        if (mounted) {
          setState(() {
            final index = _messages.indexWhere(
              (m) => m.id == optimisticMessage.id,
            );
            if (index != -1) {
              _messages[index] = realMessage;
            }
          });
        }

        // Notify parent that chat was updated
        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending message: $e');
      print('Error stack trace: ${StackTrace.current}');

      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == optimisticMessage.id);
        });

        // Show user-friendly error message with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry sending the message
                _sendMessage(content);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendFile(
    File file,
    String fileName,
    int fileSize, {
    String? fileType,
    String? caption,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    String determinedFileType = fileType ?? 'file';
    final extension = fileName.split('.').last.toLowerCase();
    print(
      'DEBUG: File extension: $extension, File name: $fileName, Provided type: $fileType',
    );

    // If no file type provided, determine from extension
    if (fileType == null) {
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        determinedFileType = 'image';
      } else if ([
        'mp4',
        'avi',
        'mov',
        'mkv',
        'webm',
        'flv',
        'wmv',
      ].contains(extension)) {
        determinedFileType = 'video';
      } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(extension)) {
        determinedFileType = 'voice';
      }
    }

    print('DEBUG: Determined file type: $determinedFileType');
    print('DEBUG: File name being sent: $fileName');

    // Create optimistic message
    final messageType = MessageType.values.firstWhere(
      (e) => e.name == determinedFileType,
      orElse: () => MessageType.file,
    );
    print('DEBUG: Created MessageType: ${messageType.name}');
    print(
      'DEBUG: MessageType enum values: ${MessageType.values.map((e) => e.name).toList()}',
    );

    final optimisticMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chat.id,
      senderId: currentUser.id,
      senderName: 'You',
      senderProfileImageUrl: null,
      content:
          caption ?? fileName, // Use caption if available, otherwise filename
      createdAt: DateTime.now(),
      type: messageType,
      fileUrl: file.path, // Use local file path for immediate display
      fileName: fileName,
      fileSize: fileSize,
      isRead: false,
      isDelivered: false,
      isDownloaded: true, // Mark as downloaded since it's local
      localFilePath: file.path, // Store local path
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, optimisticMessage);
      });
      print(
        'DEBUG: Added optimistic message: ${optimisticMessage.id}, type: ${optimisticMessage.type}, fileName: ${optimisticMessage.fileName}',
      );
    }

    _scrollToBottom();

    try {
      print('DEBUG: Sending to database with type: $determinedFileType');
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content:
            caption ?? fileName, // Use caption if available, otherwise filename
        type: determinedFileType,
        file: file,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (messageData != null && mounted) {
        print('DEBUG: Received from database - type: ${messageData['type']}');
        print(
          'DEBUG: Database response - fileUrl: ${messageData['file_url']}, fileName: ${messageData['file_name']}',
        );
        // Update optimistic message with real data and start downloading
        final realMessage = Message(
          id: messageData['id'] ?? optimisticMessage.id,
          chatId: messageData['chat_id'] ?? widget.chat.id,
          senderId: messageData['sender_id'] ?? currentUser.id,
          senderName: 'You',
          senderProfileImageUrl: null,
          content: messageData['message'] ?? (caption ?? fileName),
          createdAt: DateTime.parse(
            messageData['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          type: MessageType.values.firstWhere(
            (e) => e.name == (messageData['type'] ?? determinedFileType),
            orElse: () => MessageType.file,
          ),
          fileUrl: messageData['file_url'],
          fileName: messageData['file_name'],
          fileSize: messageData['file_size'],
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
          isDownloaded: false, // Start as not downloaded
          isDownloading: true, // Start downloading immediately
          downloadProgress: 0.0, // Start with 0 progress
          localFilePath: file.path, // Keep original local path for now
        );

        if (mounted) {
          setState(() {
            final index = _messages.indexWhere(
              (m) => m.id == optimisticMessage.id,
            );
            if (index != -1) {
              _messages[index] = realMessage;
            }
          });
        }

        print('DEBUG: Updated message with real data: ${realMessage.id}');

        // Start automatic download for the sender
        _startAutomaticDownload(realMessage);

        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending file: $e');
      print('Error stack trace: ${StackTrace.current}');

      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == optimisticMessage.id);
        });

        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send file: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry sending the file
                _sendFile(
                  file,
                  fileName,
                  fileSize,
                  fileType: fileType,
                  caption: caption,
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendLocation(String location) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Create optimistic message
    final optimisticMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chat.id,
      senderId: currentUser.id,
      senderName: 'You',
      senderProfileImageUrl: null,
      content: location,
      createdAt: DateTime.now(),
      type: MessageType.location,
      isRead: false,
      isDelivered: false,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, optimisticMessage);
      });
    }

    _scrollToBottom();

    try {
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content: location,
        type: 'location',
      );

      if (messageData != null && mounted) {
        // Update optimistic message with real data
        final realMessage = Message(
          id: messageData['id'] ?? optimisticMessage.id,
          chatId: messageData['chat_id'] ?? widget.chat.id,
          senderId: messageData['sender_id'] ?? currentUser.id,
          senderName: 'You',
          senderProfileImageUrl: null,
          content: messageData['message'] ?? location,
          createdAt: DateTime.parse(
            messageData['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          type: MessageType.location,
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
        );

        if (mounted) {
          setState(() {
            final index = _messages.indexWhere(
              (m) => m.id == optimisticMessage.id,
            );
            if (index != -1) {
              _messages[index] = realMessage;
            }
          });
        }

        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending location: $e');
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == optimisticMessage.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send location. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _sendVoiceMessage(
    File file,
    String fileName,
    int fileSize,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Create optimistic message
    final optimisticMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chat.id,
      senderId: currentUser.id,
      senderName: 'You',
      senderProfileImageUrl: null,
      content: fileName,
      createdAt: DateTime.now(),
      type: MessageType.voice,
      isRead: false,
      isDelivered: false,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, optimisticMessage);
      });
    }

    _scrollToBottom();

    try {
      final messageData = await _databaseService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUser.id,
        content: fileName,
        type: 'voice',
        file: file,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (messageData != null && mounted) {
        // Update optimistic message with real data
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
          type: MessageType.voice,
          isRead: messageData['is_read'] ?? false,
          isDelivered: messageData['is_delivered'] ?? true,
        );

        if (mounted) {
          setState(() {
            final index = _messages.indexWhere(
              (m) => m.id == optimisticMessage.id,
            );
            if (index != -1) {
              _messages[index] = realMessage;
            }
          });
        }

        widget.onChatUpdated?.call();
      }
    } catch (e) {
      print('Error sending voice message: $e');
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == optimisticMessage.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send voice message. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getSenderName(String senderId) {
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

  // Start automatic download for the sender
  Future<void> _startAutomaticDownload(Message message) async {
    if (message.fileUrl == null) return;

    try {
      print(
        'DEBUG: Starting automatic download for sender: ${message.fileName}',
      );

      // Initialize local file storage service
      final localStorage = LocalFileStorageService();
      await localStorage.initialize();

      // Download and save file locally with progress tracking
      final localFilePath = await localStorage.downloadAndSaveFile(
        fileUrl: message.fileUrl!,
        fileName: message.fileName ?? 'file',
        chatId: message.chatId,
        messageId: message.id,
        onProgress: (progress) {
          // Update download progress in the message
          if (mounted) {
            setState(() {
              final index = _messages.indexWhere((m) => m.id == message.id);
              if (index != -1) {
                _messages[index] = _messages[index].copyWith(
                  isDownloading: true,
                  downloadProgress: progress,
                );
              }
            });
          }
        },
      );

      if (localFilePath != null) {
        print('DEBUG: Automatic download completed: $localFilePath');

        // Update message to downloaded state
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == message.id);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(
                isDownloaded: true,
                isDownloading: false,
                downloadProgress: 1.0,
                localFilePath: localFilePath,
              );
            }
          });
        }
      } else {
        print('DEBUG: Automatic download failed for: ${message.fileName}');

        // Update message to error state
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == message.id);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(
                isDownloading: false,
                downloadProgress: 0.0,
              );
            }
          });
        }
      }
    } catch (e) {
      print('ERROR: Automatic download failed: $e');

      // Update message to error state
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(
              isDownloading: false,
              downloadProgress: 0.0,
            );
          }
        });
      }
    }
  }
}
