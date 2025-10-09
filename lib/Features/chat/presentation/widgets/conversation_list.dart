// Presentation Layer - Conversation List Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/chat_model.dart';

class ConversationList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final conversations = _getFilteredConversations();

    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildConversationCard(conversations[index]),
        );
      },
    );
  }

  Widget _buildConversationCard(Chat chat) {
    return GestureDetector(
      onTap: () => onChatTap(chat),
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
                  child: Icon(chat.icon, color: chat.color, size: 24),
                ),
                if (chat.isOnline)
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
                          chat.name,
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
                          chat.lastMessage,
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
    final allConversations = _getMockConversations();

    List<Chat> filtered = allConversations;

    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((chat) => chat.category == category).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (chat) =>
                    chat.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    chat.lastMessage.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

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

  List<Chat> _getMockConversations() {
    return [
      Chat(
        id: '1',
        name: 'Alex Johnson',
        lastMessage: 'Hey! Are you still looking for a roommate?',
        lastMessageTime: '2m',
        unreadCount: 2,
        isOnline: true,
        category: 'Personal',
        icon: Icons.person,
        color: Colors.blue[600]!,
      ),
      Chat(
        id: '2',
        name: 'Sunset Hostel',
        lastMessage: 'We have availability for next semester. Call us!',
        lastMessageTime: '1h',
        unreadCount: 1,
        isOnline: false,
        category: 'Hostels',
        icon: Icons.home,
        color: Colors.green[600]!,
      ),
      Chat(
        id: '3',
        name: 'Tech Society',
        lastMessage: 'Sarah: The coding workshop is tomorrow at 3 PM',
        lastMessageTime: '3h',
        unreadCount: 0,
        isOnline: false,
        category: 'Groups',
        icon: Icons.group,
        color: Colors.purple[600]!,
      ),
      Chat(
        id: '4',
        name: 'Sarah Kim',
        lastMessage: 'Thanks for the study notes! 📚',
        lastMessageTime: '5h',
        unreadCount: 0,
        isOnline: true,
        category: 'Personal',
        icon: Icons.person,
        color: Colors.pink[600]!,
      ),
      Chat(
        id: '5',
        name: 'Campus View Hostel',
        lastMessage: 'Your room is ready. Check-in starts Monday.',
        lastMessageTime: '1d',
        unreadCount: 0,
        isOnline: false,
        category: 'Hostels',
        icon: Icons.home,
        color: Colors.teal[600]!,
      ),
      Chat(
        id: '6',
        name: 'Study Group CS101',
        lastMessage: 'Mike: Can we meet at the library tomorrow?',
        lastMessageTime: '2d',
        unreadCount: 3,
        isOnline: false,
        category: 'Groups',
        icon: Icons.group,
        color: Colors.orange[600]!,
      ),
    ];
  }
}
