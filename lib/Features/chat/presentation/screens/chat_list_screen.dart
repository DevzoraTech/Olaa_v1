// Presentation Layer - Chat List Screen
import 'package:flutter/material.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_category_tabs.dart';
import '../widgets/conversation_list.dart';
import 'improved_chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  void _refreshConversations() {
    // Trigger a rebuild to refresh conversations
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter/sort functionality
            },
            icon: Icon(Icons.tune_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Header with Quick Actions
          ChatHeader(onChatCreated: _refreshConversations),

          // Category Tabs
          ChatCategoryTabs(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          // Conversation List
          Expanded(
            child: ConversationList(
              category: _selectedCategory,
              searchQuery: _searchQuery,
              onChatTap: (chat) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ImprovedChatDetailScreen(
                          chat: chat,
                          onChatUpdated: _refreshConversations,
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
