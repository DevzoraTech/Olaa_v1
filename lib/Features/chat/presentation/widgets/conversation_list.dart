// Presentation Layer - Conversation List Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import 'package:pulse_campus/Features/chat/domain/models/chat_model.dart';

class ConversationList extends StatefulWidget {
  final String category;
  final String searchQuery;
  final Function(Chat) onChatTap;

  const ConversationList({
    super.key,
    required this.category,
    required this.searchQuery,
    required this.onChatTap,
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  List<Chat> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void didUpdateWidget(ConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadConversations();
    }
  }

  // Public method to refresh conversations
  Future<void> refreshConversations() async {
    await _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _error = 'User not authenticated';
        });
        return;
      }

      print('DEBUG: Loading conversations for user: ${currentUser.id}');

      // Get user's chats
      final chats = await _databaseService.getUserChats(currentUser.id);
      print('DEBUG: Found ${chats.length} chats for user ${currentUser.id}');
      print('DEBUG: Chats data: $chats');

      // Debug each chat
      for (int i = 0; i < chats.length; i++) {
        print(
          'DEBUG: Chat $i: ${chats[i]['id']} - is_group: ${chats[i]['is_group']}',
        );
      }

      // Convert to Chat objects with participants
      final conversations = <Chat>[];
      for (final chatData in chats) {
        try {
          print('DEBUG: Processing chat: ${chatData['id']}');

          // Get participants for this chat
          final participants = await _databaseService.getChatParticipants(
            chatData['id'],
          );
          print(
            'DEBUG: Found ${participants.length} participants for chat ${chatData['id']}',
          );
          print('DEBUG: Participants data: $participants');

          final chatParticipants =
              participants.map((p) {
                print('DEBUG: Raw participant data: $p');
                print('DEBUG: Profile data: ${p['profile']}');
                final participant = ChatParticipant.fromMap(p, p['profile']);
                print(
                  'DEBUG: Created participant: ${participant.userId} - ${participant.name}',
                );
                return participant;
              }).toList();

          // Get the other participant (not current user) for display name
          print(
            'DEBUG: Looking for participant that is NOT: ${currentUser.id}',
          );
          final otherParticipant = chatParticipants.firstWhere(
            (p) {
              final isNotCurrentUser = p.userId != currentUser.id;
              print(
                'DEBUG: Participant ${p.userId} (${p.userId.runtimeType}) != ${currentUser.id} (${currentUser.id.runtimeType})? $isNotCurrentUser',
              );
              print(
                'DEBUG: String comparison: "${p.userId}" != "${currentUser.id}"? ${p.userId != currentUser.id}',
              );
              return isNotCurrentUser;
            },
            orElse:
                () =>
                    chatParticipants.isNotEmpty
                        ? chatParticipants.first
                        : ChatParticipant(
                          id: '',
                          chatId: chatData['id'] ?? '',
                          userId: 'unknown',
                          name: 'Unknown User',
                          isOnline: false,
                          lastSeen: DateTime.now(),
                          joinedAt: DateTime.now(),
                        ),
          );

          print('DEBUG: Current user: ${currentUser.id}');
          print(
            'DEBUG: Chat participants: ${chatParticipants.map((p) => '${p.userId}: ${p.name}').join(', ')}',
          );
          print(
            'DEBUG: Other participant: ${otherParticipant.userId}: ${otherParticipant.name}',
          );

          // Create Chat object with proper name
          print('DEBUG: Creating chat with name: ${otherParticipant.name}');
          final chat = Chat(
            id: chatData['id'] ?? '',
            isGroup: chatData['is_group'] ?? false,
            groupName:
                chatData['is_group'] == true
                    ? chatData['group_name']
                    : otherParticipant.name,
            groupDescription: chatData['group_description'],
            groupImageUrl:
                chatData['is_group'] == true
                    ? chatData['group_image_url']
                    : otherParticipant.profileImageUrl,
            createdAt: DateTime.parse(
              chatData['created_at'] ?? DateTime.now().toIso8601String(),
            ),
            updatedAt: DateTime.parse(
              chatData['updated_at'] ?? DateTime.now().toIso8601String(),
            ),
            lastMessageAt: DateTime.parse(
              chatData['last_message_at'] ?? DateTime.now().toIso8601String(),
            ),
            lastMessage: chatData['last_message'],
            lastMessageSenderId: chatData['last_message_sender_id'],
            unreadCount: chatData['unread_count'] ?? 0,
            participants: chatParticipants,
          );

          // Verify the chat name is correct
          print('DEBUG: Chat name verification:');
          print('DEBUG: - Chat.name: ${chat.name}');
          print(
            'DEBUG: - Chat.getOtherParticipantName(${currentUser.id}): ${chat.getOtherParticipantName(currentUser.id)}',
          );
          print('DEBUG: - Other participant name: ${otherParticipant.name}');

          // Check if chat has actual messages
          final hasMessages = await _chatHasMessages(chatData['id']);

          if (hasMessages) {
            conversations.add(chat);
            print('DEBUG: Successfully created chat: ${chat.name}');
          } else {
            print('DEBUG: Skipping empty chat: ${chat.name}');
          }
        } catch (e) {
          print('Error processing chat ${chatData['id']}: $e');
        }
      }

      print('DEBUG: Created ${conversations.length} conversation objects');

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load conversations';
      });
    }
  }

  // Helper method to check if a chat has messages
  Future<bool> _chatHasMessages(String chatId) async {
    try {
      final messages = await _databaseService.getChatMessages(
        chatId: chatId,
        limit: 1, // We only need to check if at least one message exists
      );
      return messages.isNotEmpty;
    } catch (e) {
      print('Error checking messages for chat $chatId: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConversations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredConversations = _getFilteredConversations();

    if (filteredConversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredConversations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildConversationCard(filteredConversations[index]),
          );
        },
      ),
    );
  }

  Widget _buildConversationCard(Chat chat) {
    return GestureDetector(
      onTap: () => widget.onChatTap(chat),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            // Profile Image
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: chat.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      chat.groupImageUrl != null &&
                              chat.groupImageUrl!.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              chat.groupImageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  chat.icon,
                                  color: chat.color,
                                  size: 24,
                                );
                              },
                            ),
                          )
                          : Icon(chat.icon, color: chat.color, size: 24),
                ),
                if (!chat.isGroup &&
                    chat.isOtherParticipantOnline(
                      _authService.currentUser?.id ?? '',
                    ))
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.isGroup
                              ? chat.name
                              : chat.getOtherParticipantName(
                                _authService.currentUser?.id ?? '',
                              ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Text(
                        chat.lastMessageTime,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (chat.category != 'Personal')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            chat.category,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          chat.category,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(chat.category),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat to connect with roommates,\nhostels, or join group discussions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement new chat functionality
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Chat> _getFilteredConversations() {
    List<Chat> filtered = _conversations;

    // Filter by category
    if (widget.category != 'All') {
      filtered =
          filtered.where((chat) => chat.category == widget.category).toList();
    }

    // Filter by search query
    if (widget.searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (chat) =>
                    chat.name.toLowerCase().contains(
                      widget.searchQuery.toLowerCase(),
                    ) ||
                    (chat.lastMessage ?? '').toLowerCase().contains(
                      widget.searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Sort by last message time (most recent first)
    filtered.sort(
      (a, b) => (b.lastMessageAt ?? DateTime.now()).compareTo(
        a.lastMessageAt ?? DateTime.now(),
      ),
    );

    return filtered;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.blue[600]!;
      case 'Hostels':
        return Colors.green[600]!;
      case 'Groups':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
