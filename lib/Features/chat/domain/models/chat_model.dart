// Domain Layer - Chat Model
import 'package:flutter/material.dart';

class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String category;
  final IconData icon;
  final Color color;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    required this.category,
    required this.icon,
    required this.color,
  });
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final bool isDelivered;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isRead,
    required this.isDelivered,
  });
}

enum MessageType { text, image, file, voice, link }

class ChatParticipant {
  final String id;
  final String name;
  final String? profileImageUrl;
  final bool isOnline;
  final DateTime lastSeen;

  ChatParticipant({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.isOnline,
    required this.lastSeen,
  });
}
