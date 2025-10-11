// Domain Layer - Chat Model
import 'package:flutter/material.dart';

class Chat {
  final String id;
  final bool isGroup;
  final String? groupName;
  final String? groupDescription;
  final String? groupImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final int unreadCount;
  final List<ChatParticipant> participants;

  Chat({
    required this.id,
    required this.isGroup,
    this.groupName,
    this.groupDescription,
    this.groupImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.lastMessage,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.participants = const [],
  });

  // Helper getters for UI compatibility
  String get name {
    if (isGroup) {
      return groupName ?? 'Group Chat';
    } else {
      // For 1-on-1 chats, return the other participant's name
      if (participants.length >= 2) {
        // Assuming the first participant is the current user
        return participants[1].name;
      }
      return 'Unknown User';
    }
  }

  String get lastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isOnline {
    if (isGroup) return false; // Groups don't have online status
    if (participants.length >= 2) {
      return participants[1].isOnline;
    }
    return false;
  }

  String get category {
    return isGroup ? 'Group' : 'Direct';
  }

  IconData get icon {
    return isGroup ? Icons.group : Icons.person;
  }

  Color get color {
    return isGroup ? Colors.green : Colors.blue;
  }

  factory Chat.fromMap(
    Map<String, dynamic> data,
    List<ChatParticipant> participants,
  ) {
    return Chat(
      id: data['id'] ?? '',
      isGroup: data['is_group'] ?? false,
      groupName: data['group_name'],
      groupDescription: data['group_description'],
      groupImageUrl: data['group_image_url'],
      createdAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        data['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessageAt:
          data['last_message_at'] != null
              ? DateTime.parse(data['last_message_at'])
              : null,
      lastMessage: data['last_message'],
      lastMessageSenderId: data['last_message_sender_id'],
      unreadCount: data['unread_count'] ?? 0,
      participants: participants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_group': isGroup,
      'group_name': groupName,
      'group_description': groupDescription,
      'group_image_url': groupImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
    };
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderProfileImageUrl;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final bool isRead;
  final bool isDelivered;
  // Download state tracking
  final bool isDownloaded;
  final double downloadProgress;
  final bool isDownloading;
  // Local file storage
  final String? localFilePath;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImageUrl,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    this.isRead = false,
    this.isDelivered = true,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
    this.localFilePath,
  });

  factory Message.fromMap(
    Map<String, dynamic> data,
    String senderName, {
    String? senderProfileImageUrl,
  }) {
    return Message(
      id: data['id'] ?? '',
      chatId: data['chat_id'] ?? '',
      senderId: data['sender_id'] ?? '',
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
          data['edited_at'] != null ? DateTime.parse(data['edited_at']) : null,
      createdAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Copy with method for updating download state
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderProfileImageUrl,
    String? content,
    MessageType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? replyToMessageId,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    bool? isRead,
    bool? isDelivered,
    bool? isDownloaded,
    double? downloadProgress,
    bool? isDownloading,
    String? localFilePath,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImageUrl:
          senderProfileImageUrl ?? this.senderProfileImageUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isDownloading: isDownloading ?? this.isDownloading,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': content,
      'type': type.name,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'reply_to_message_id': replyToMessageId,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum MessageType { text, image, file, voice, link }

class ChatParticipant {
  final String id;
  final String chatId;
  final String userId;
  final String name;
  final String? profileImageUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime joinedAt;
  final DateTime? lastReadAt;
  final bool isAdmin;

  ChatParticipant({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.isOnline,
    required this.lastSeen,
    required this.joinedAt,
    this.lastReadAt,
    this.isAdmin = false,
  });

  factory ChatParticipant.fromMap(
    Map<String, dynamic> data,
    Map<String, dynamic> profile,
  ) {
    return ChatParticipant(
      id: data['id'] ?? '',
      chatId: data['chat_id'] ?? '',
      userId: data['user_id'] ?? '',
      name:
          '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim(),
      profileImageUrl: profile['profile_image_url'],
      isOnline: profile['is_online'] ?? false,
      lastSeen: DateTime.parse(
        profile['last_seen'] ?? DateTime.now().toIso8601String(),
      ),
      joinedAt: DateTime.parse(
        data['joined_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastReadAt:
          data['last_read_at'] != null
              ? DateTime.parse(data['last_read_at'])
              : null,
      isAdmin: data['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'is_admin': isAdmin,
    };
  }
}
