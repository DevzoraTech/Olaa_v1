// Core Service - Chat Service with Realtime Support
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';
import '../config/supabase_config.dart';
import 'supabase_auth_service.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._();

  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  // Realtime subscriptions
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _chatsChannel;
  RealtimeChannel? _typingChannel;

  // Stream controllers
  final _messagesController = StreamController<Message>.broadcast();
  final _chatsController = StreamController<Chat>.broadcast();
  final _typingController = StreamController<TypingIndicator>.broadcast();

  // Public streams
  Stream<Message> get messagesStream => _messagesController.stream;
  Stream<Chat> get chatsStream => _chatsController.stream;
  Stream<TypingIndicator> get typingStream => _typingController.stream;

  // Typing indicator state
  final Map<String, DateTime> _typingUsers = {};
  Timer? _typingCleanupTimer;

  /// Subscribe to messages for a specific chat
  Future<void> subscribeToChat(String chatId) async {
    try {
      // Unsubscribe from previous chat if exists
      await unsubscribeFromChat();

      print('DEBUG: Subscribing to chat: $chatId');

      // Subscribe to messages for this chat
      _messagesChannel =
          SupabaseConfig.client
              .channel('messages:$chatId')
              .onPostgresChanges(
                event: PostgresChangeEvent.insert,
                schema: 'public',
                table: 'messages',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'chat_id',
                  value: chatId,
                ),
                callback: (payload) async {
                  print('DEBUG: New message received: ${payload.newRecord}');
                  final message = await _parseMessageFromPayload(
                    payload.newRecord,
                  );
                  if (message != null) {
                    _messagesController.add(message);
                  }
                },
              )
              .subscribe();

      // Subscribe to typing indicators
      _subscribeToTypingIndicators(chatId);

      print('DEBUG: Successfully subscribed to chat: $chatId');
    } catch (e) {
      print('ERROR: Failed to subscribe to chat: $e');
    }
  }

  /// Subscribe to typing indicators for a chat
  void _subscribeToTypingIndicators(String chatId) {
    _typingChannel =
        SupabaseConfig.client
            .channel('typing:$chatId')
            .onBroadcast(
              event: 'typing',
              callback: (payload) {
                final userId = payload['user_id'] as String?;
                final userName = payload['user_name'] as String?;
                final isTyping = payload['is_typing'] as bool? ?? false;

                if (userId != null && userName != null) {
                  if (isTyping) {
                    _typingUsers[userId] = DateTime.now();
                  } else {
                    _typingUsers.remove(userId);
                  }

                  _typingController.add(
                    TypingIndicator(
                      chatId: chatId,
                      userId: userId,
                      userName: userName,
                      isTyping: isTyping,
                    ),
                  );
                }
              },
            )
            .subscribe();

    // Start cleanup timer for stale typing indicators
    _typingCleanupTimer?.cancel();
    _typingCleanupTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _cleanupStaleTypingIndicators(chatId),
    );
  }

  /// Clean up typing indicators that haven't been updated in 3 seconds
  void _cleanupStaleTypingIndicators(String chatId) {
    final now = DateTime.now();
    final staleUsers = <String>[];

    _typingUsers.forEach((userId, lastUpdate) {
      if (now.difference(lastUpdate).inSeconds > 3) {
        staleUsers.add(userId);
      }
    });

    for (final userId in staleUsers) {
      _typingUsers.remove(userId);
      _typingController.add(
        TypingIndicator(
          chatId: chatId,
          userId: userId,
          userName: '',
          isTyping: false,
        ),
      );
    }
  }

  /// Broadcast typing indicator
  Future<void> sendTypingIndicator({
    required String chatId,
    required bool isTyping,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      await _typingChannel?.sendBroadcastMessage(
        event: 'typing',
        payload: {
          'user_id': currentUser.id,
          'user_name': currentUser.userMetadata?['full_name'] ?? 'User',
          'is_typing': isTyping,
        },
      );
    } catch (e) {
      print('ERROR: Failed to send typing indicator: $e');
    }
  }

  /// Subscribe to user's chats list
  Future<void> subscribeToUserChats() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      print('DEBUG: Subscribing to user chats');

      // Subscribe to changes in chats where user is a participant
      _chatsChannel =
          SupabaseConfig.client
              .channel('chats:${currentUser.id}')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'chats',
                callback: (payload) async {
                  print('DEBUG: Chat update received: ${payload.newRecord}');
                  // Emit event to refresh chats list
                  // The chat list widget will handle the refresh
                },
              )
              .subscribe();

      print('DEBUG: Successfully subscribed to user chats');
    } catch (e) {
      print('ERROR: Failed to subscribe to user chats: $e');
    }
  }

  /// Unsubscribe from current chat
  Future<void> unsubscribeFromChat() async {
    try {
      await _messagesChannel?.unsubscribe();
      await _typingChannel?.unsubscribe();
      _typingCleanupTimer?.cancel();
      _typingUsers.clear();
      _messagesChannel = null;
      _typingChannel = null;
      print('DEBUG: Unsubscribed from chat');
    } catch (e) {
      print('ERROR: Failed to unsubscribe from chat: $e');
    }
  }

  /// Unsubscribe from user chats
  Future<void> unsubscribeFromUserChats() async {
    try {
      await _chatsChannel?.unsubscribe();
      _chatsChannel = null;
      print('DEBUG: Unsubscribed from user chats');
    } catch (e) {
      print('ERROR: Failed to unsubscribe from user chats: $e');
    }
  }

  /// Parse message from Supabase payload
  Future<Message?> _parseMessageFromPayload(Map<String, dynamic> data) async {
    try {
      final currentUser = _authService.currentUser;
      final senderId = data['sender_id'] as String;
      final isMe = currentUser != null && senderId == currentUser.id;

      // Get sender info from profiles table
      String senderName = 'Unknown User';
      String? senderProfileImageUrl;

      if (!isMe) {
        try {
          final profileData =
              await SupabaseConfig.from('profiles')
                  .select('first_name, last_name, profile_image_url')
                  .eq('id', senderId)
                  .single();

          senderName =
              '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'
                  .trim();
          senderProfileImageUrl = profileData['profile_image_url'];
        } catch (e) {
          print('ERROR: Failed to fetch sender profile: $e');
        }
      } else {
        senderName = 'You';
      }

      return Message(
        id: data['id'] ?? '',
        chatId: data['chat_id'] ?? '',
        senderId: senderId,
        senderName: senderName,
        senderProfileImageUrl: senderProfileImageUrl,
        content: data['message'] ?? '',
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
                ? DateTime.parse(data['edited_at'])
                : null,
        createdAt: DateTime.parse(
          data['created_at'] ?? DateTime.now().toIso8601String(),
        ),
        isRead: data['is_read'] ?? false,
        isDelivered: data['is_delivered'] ?? true,
      );
    } catch (e) {
      print('ERROR: Failed to parse message: $e');
      return null;
    }
  }

  /// Mark message as read
  Future<bool> markMessageAsRead(String messageId, String chatId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Update message read status
      await SupabaseConfig.from('messages')
          .update({'is_read': true})
          .eq('id', messageId)
          .neq('sender_id', currentUser.id); // Don't mark own messages

      // Update last_read_at in chat_participants
      await SupabaseConfig.from('chat_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', currentUser.id);

      return true;
    } catch (e) {
      print('ERROR: Failed to mark message as read: $e');
      return false;
    }
  }

  /// Dispose all subscriptions
  Future<void> dispose() async {
    await unsubscribeFromChat();
    await unsubscribeFromUserChats();
    _typingCleanupTimer?.cancel();
    await _messagesController.close();
    await _chatsController.close();
    await _typingController.close();
  }
}

/// Typing indicator model
class TypingIndicator {
  final String chatId;
  final String userId;
  final String userName;
  final bool isTyping;

  TypingIndicator({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.isTyping,
  });
}
