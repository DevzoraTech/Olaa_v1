// Roommate Request Card Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class RoommateRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onEdit;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDelete;
  final VoidCallback onViewInsights;

  const RoommateRequestCard({
    super.key,
    required this.request,
    required this.onEdit,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onViewInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and actions
          _buildHeader(),

          // Content
          Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and bio
                _buildTitleAndBio(),
                const SizedBox(height: 8), // Reduced from 12
                // Details row
                _buildDetailsRow(),
                const SizedBox(height: 8), // Reduced from 12
                // Stats row
                _buildStatsRow(),
                const SizedBox(height: 12), // Reduced from 16
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final status = request['status'] ?? 'Active';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),

          // Action menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'toggle':
                  onToggleVisibility();
                  break;
                case 'insights':
                  onViewInsights();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Hide/Show'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'insights',
                    child: Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('View Insights'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request['title'] ?? 'Roommate Request',
          style: TextStyle(
            fontSize: 15, // Reduced from 16
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4), // Reduced from 6
        Text(
          request['bio'] ?? 'Looking for a roommate...',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            height: 1.3,
          ), // Reduced font size and height
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    final budgetMin = request['budget_min'] ?? 0;
    final budgetMax = request['budget_max'] ?? 0;
    final locations = request['preferred_locations'] as List<String>? ?? [];
    final moveInDate = request['move_in_date'] as DateTime?;
    final urgency = request['urgency'] ?? '';

    return Row(
      children: [
        // Budget
        if (budgetMin > 0 && budgetMax > 0) ...[
          _buildDetailChip(
            icon: Icons.attach_money,
            label:
                '${_formatCurrency(budgetMin)} - ${_formatCurrency(budgetMax)} UGX',
            color: Colors.green[600]!,
          ),
          const SizedBox(width: 6), // Reduced from 8
        ],

        // Location
        if (locations.isNotEmpty) ...[
          _buildDetailChip(
            icon: Icons.location_on,
            label: locations.take(2).join(', '),
            color: Colors.blue[600]!,
          ),
          const SizedBox(width: 6), // Reduced from 8
        ],

        // Move-in date
        if (moveInDate != null) ...[
          _buildDetailChip(
            icon: Icons.calendar_today,
            label: _formatDate(moveInDate),
            color: Colors.orange[600]!,
          ),
          const SizedBox(width: 6), // Reduced from 8
        ],

        // Urgency
        if (urgency.isNotEmpty) ...[
          _buildDetailChip(
            icon: Icons.schedule,
            label: urgency,
            color:
                urgency.toLowerCase().contains('asap') ||
                        urgency.toLowerCase().contains('urgent')
                    ? Colors.red[600]!
                    : Colors.purple[600]!,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6), // Reduced border radius
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color), // Reduced icon size
          const SizedBox(width: 3), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // Reduced font size
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final viewsCount = request['views_count'] ?? 0;
    final chatsCount = request['chats_count'] ?? 0;
    final createdAt = request['created_at'] as DateTime?;

    return Row(
      children: [
        _buildStatItem(
          Icons.visibility,
          '$viewsCount views',
          Colors.grey[600]!,
        ),
        const SizedBox(width: 12), // Reduced from 16
        _buildStatItem(
          Icons.chat_bubble_outline,
          '$chatsCount chats',
          Colors.grey[600]!,
        ),
        const Spacer(),
        if (createdAt != null)
          Text(
            'Posted ${_formatDate(createdAt)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ), // Reduced font size
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color), // Reduced from 14
        const SizedBox(width: 3), // Reduced from 4
        Text(
          label,
          style: TextStyle(
            fontSize: 11, // Reduced from 12
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 14), // Reduced from 16
            label: const Text(
              'Edit',
              style: TextStyle(fontSize: 12),
            ), // Reduced font size
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // Reduced border radius
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ), // Reduced padding
            ),
          ),
        ),
        const SizedBox(width: 8), // Reduced from 12
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onViewInsights,
            icon: const Icon(
              Icons.analytics_outlined,
              size: 14,
            ), // Reduced from 16
            label: const Text(
              'Insights',
              style: TextStyle(fontSize: 12),
            ), // Reduced font size
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // Reduced border radius
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ), // Reduced padding
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    final statusText = status ?? 'Unknown';
    switch (statusText.toLowerCase()) {
      case 'active':
        return Colors.green[600]!;
      case 'matched':
        return Colors.blue[600]!;
      case 'expired':
        return Colors.orange[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatCurrency(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
