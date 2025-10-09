// Presentation Layer - Request Details Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/roommate_request_model.dart';

class RequestDetailsWidget extends StatelessWidget {
  final RoommateRequest request;

  const RequestDetailsWidget({super.key, required this.request});

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
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            _buildDetailItem(
              icon: Icons.location_on_outlined,
              title: 'Preferred Location',
              value: request.requestDetails.preferredLocation,
              color: Colors.red,
            ),
            const SizedBox(height: 12),

            // Budget
            _buildDetailItem(
              icon: Icons.attach_money_outlined,
              title: 'Budget Range',
              value: request.requestDetails.budgetRange,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            // Preferred Hostel (if available)
            if (request.requestDetails.preferredHostel != null) ...[
              _buildDetailItem(
                icon: Icons.home_outlined,
                title: 'Preferred Hostel',
                value: request.requestDetails.preferredHostel!,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
            ],

            // Move-in Date and Urgency
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Move-in Date',
                    value:
                        request.requestDetails.moveInDate != null
                            ? '${request.requestDetails.moveInDate!.day}/${request.requestDetails.moveInDate!.month}/${request.requestDetails.moveInDate!.year}'
                            : 'Flexible',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.schedule_outlined,
                    title: 'Urgency',
                    value: request.requestDetails.urgency,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lease Duration
            _buildDetailItem(
              icon: Icons.access_time_outlined,
              title: 'Lease Duration',
              value: request.requestDetails.leaseDuration,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
