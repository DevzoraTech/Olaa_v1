// Presentation Layer - Chat App Bar Widget
import 'package:flutter/material.dart';
import '../../domain/models/chat_model.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;
  final VoidCallback onCallPressed;
  final VoidCallback onInfoPressed;

  const ChatAppBar({
    super.key,
    required this.chat,
    required this.onCallPressed,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 56,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.grey[700],
          size: 20,
        ),
      ),
      title: Row(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: chat.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(chat.icon, color: chat.color, size: 18),
              ),
              if (chat.isOnline)
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
          const SizedBox(width: 12),

          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  chat.isOnline ? 'Online' : 'Last seen recently',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Call Button (only for hostels)
        if (chat.category == 'Hostels')
          IconButton(
            onPressed: onCallPressed,
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.call_rounded,
                color: Colors.green[600],
                size: 18,
              ),
            ),
          ),

        // Info Button
        IconButton(
          onPressed: onInfoPressed,
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
