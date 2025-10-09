// Hostel Card Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_utils.dart';

class HostelCard extends StatelessWidget {
  final Map<String, dynamic> hostel;
  final VoidCallback onEdit;
  final VoidCallback onUpdatePhotos;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDelete;
  final VoidCallback onViewBookings;

  const HostelCard({
    super.key,
    required this.hostel,
    required this.onEdit,
    required this.onUpdatePhotos,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child:
                      hostel['image_url'] != null
                          ? Image.network(
                            hostel['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.home_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              );
                            },
                          )
                          : Icon(
                            Icons.home_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(hostel['status']),
              ),
              // Rooms Available Badge
              Positioned(bottom: 12, left: 12, child: _buildRoomsBadge()),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  hostel['name'] ?? 'Untitled Hostel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hostel['location'] ?? 'Location not specified',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  _formatCurrency(
                        hostel['price_per_month']?.toDouble() ?? 0,
                        currency: hostel['currency'] ?? 'UGX',
                      ) +
                      ' /month',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.bed_outlined,
                      '${hostel['rooms_available'] ?? 0}/${hostel['total_rooms'] ?? 0} rooms',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.inbox_outlined,
                      '${hostel['inquiries_count'] ?? 0} inquiries',
                    ),
                    const Spacer(),
                    Text(
                      AppUtils.formatDate(hostel['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Edit',
                        Icons.edit_rounded,
                        AppTheme.primaryColor,
                        onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Photos',
                        Icons.photo_camera_outlined,
                        Colors.purple[600]!,
                        onUpdatePhotos,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Bookings',
                        Icons.calendar_today_outlined,
                        Colors.blue[600]!,
                        onViewBookings,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.delete_outline_rounded,
                      Colors.red[600]!,
                      onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value, {String currency = 'UGX'}) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildStatusBadge(String? status) {
    final statusText = status ?? 'Unknown';
    Color badgeColor;
    switch (statusText.toLowerCase()) {
      case 'active':
        badgeColor = Colors.green[600]!;
        break;
      case 'fully booked':
        badgeColor = Colors.blue[600]!;
        break;
      case 'hidden':
        badgeColor = Colors.orange[600]!;
        break;
      default:
        badgeColor = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRoomsBadge() {
    final roomsAvailable = hostel['rooms_available'] ?? 0;
    final totalRooms = hostel['total_rooms'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$roomsAvailable/$totalRooms rooms',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
