// Presentation Layer - New Chat Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/chat_model.dart';
import '../screens/chat_detail_screen.dart';

class NewChatScreen extends StatefulWidget {
  final VoidCallback? onChatCreated;

  const NewChatScreen({super.key, this.onChatCreated});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
        _isSearching = false;
      });
    } else {
      setState(() {
        _filteredUsers =
            _users.where((user) {
              final firstName = (user['first_name'] ?? '').toLowerCase();
              final lastName = (user['last_name'] ?? '').toLowerCase();
              final email = (user['email'] ?? '').toLowerCase();
              final fullName = '$firstName $lastName';

              return firstName.contains(query) ||
                  lastName.contains(query) ||
                  email.contains(query) ||
                  fullName.contains(query);
            }).toList();
        _isSearching = true;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Get all users except the current user
      final response = await SupabaseConfig.from(
        'profiles',
      ).select('*').neq('id', currentUser.id).order('first_name');

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // Check if a direct chat already exists
      final existingChatId = await _databaseService.getExistingDirectChat(
        currentUser.id,
        user['id'],
      );

      String chatId;
      if (existingChatId != null) {
        chatId = existingChatId;
      } else {
        // Create new direct chat
        chatId =
            await _databaseService.createDirectChat(
              currentUser.id,
              user['id'],
            ) ??
            '';
      }

      if (chatId.isNotEmpty) {
        // Update user's online status
        await _databaseService.updateUserOnlineStatus(currentUser.id, true);

        // Get chat participants to create Chat object
        final participants = await _databaseService.getChatParticipants(chatId);
        final chatParticipants =
            participants
                .map((p) => ChatParticipant.fromMap(p, p['profile']))
                .toList();

        // Find the other participant (not current user) for display name
        final otherParticipant = chatParticipants.firstWhere(
          (p) => p.userId != currentUser.id,
          orElse: () => chatParticipants.first,
        );

        print('DEBUG: New chat - Current user: ${currentUser.id}');
        print(
          'DEBUG: New chat - Other participant: ${otherParticipant.userId} - ${otherParticipant.name}',
        );

        // Create a basic Chat object
        final chat = Chat(
          id: chatId,
          isGroup: false,
          groupName: otherParticipant.name,
          groupImageUrl: otherParticipant.profileImageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastMessageAt: DateTime.now(),
          lastMessage: 'Chat started',
          unreadCount: 0,
          participants: chatParticipants,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatDetailScreen(
                    chat: chat,
                    onChatUpdated: widget.onChatCreated,
                  ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create chat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error starting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Chat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Users List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching
                                ? 'No users found'
                                : 'No users available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isSearching) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserTile(user);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final firstName = user['first_name'] ?? '';
    final lastName = user['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = user['email'] ?? '';
    final profileImageUrl = user['profile_image_url'];
    final role = user['primary_role'] ?? 'User';
    final campus = user['campus'] ?? '';
    final isOnline = user['is_online'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage:
                  profileImageUrl != null
                      ? NetworkImage(profileImageUrl)
                      : null,
              child:
                  profileImageUrl == null
                      ? Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                      : null,
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          fullName.isNotEmpty ? fullName : email,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fullName.isNotEmpty && email.isNotEmpty)
              Text(
                email,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (campus.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      campus,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chat_bubble_outline,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        onTap: () => _startChat(user),
      ),
    );
  }
}
