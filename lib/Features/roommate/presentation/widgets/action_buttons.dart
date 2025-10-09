// Presentation Layer - Action Buttons Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/roommate_request_model.dart';

class ActionButtons extends StatelessWidget {
  final RoommateRequest request;
  final VoidCallback onChat;
  final VoidCallback onCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ActionButtons({
    super.key,
    required this.request,
    required this.onChat,
    required this.onCall,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Primary Actions Row
            Row(
              children: [
                // Chat Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    color: AppTheme.primaryColor,
                    onPressed: onChat,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 12),

                // Call Button (if phone is shared)
                if (request.isPhoneShared)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone_outlined,
                      label: 'Call',
                      color: Colors.green,
                      onPressed: onCall,
                      isPrimary: true,
                    ),
                  )
                else
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone_disabled_outlined,
                      label: 'Call',
                      color: Colors.grey,
                      onPressed: null,
                      isPrimary: false,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Secondary Actions Row
            Row(
              children: [
                // Accept Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Accept',
                    color: Colors.green,
                    onPressed: onAccept,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),

                // Decline Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Decline',
                    color: Colors.red,
                    onPressed: onDecline,
                    isPrimary: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.isPhoneShared
                          ? 'Phone number is shared. You can call directly.'
                          : 'Phone number is private. Use chat to communicate.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: onPressed != null ? color : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isPrimary && onPressed != null
                      ? color.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: onPressed != null ? color : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? color : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
