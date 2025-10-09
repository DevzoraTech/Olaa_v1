// Presentation Layer - Upcoming Events Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UpcomingEvents extends StatelessWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getUpcomingEvents().length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _getUpcomingEvents().length - 1 ? 12 : 0,
                  ),
                  child: _buildUpcomingEventCard(_getUpcomingEvents()[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(Map<String, dynamic> event) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Event Image
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      event['image'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  // Event Tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getEventTagColor(event['tag'] as String),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['tag'] as String,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Content
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 8,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 1),
                      Text(
                        event['time'] as String,
                        style: TextStyle(fontSize: 7, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 8,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 1),
                      Expanded(
                        child: Text(
                          event['location'] as String,
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event['action'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'free':
        return Colors.green[600]!;
      case 'paid':
        return Colors.blue[600]!;
      case 'rsvp':
        return Colors.orange[600]!;
      case 'urgent':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  List<Map<String, dynamic>> _getUpcomingEvents() {
    return [
      {
        'title': 'Career Fair 2024',
        'time': 'Today, 2:00 PM',
        'location': 'Main Auditorium',
        'tag': 'Free',
        'image': '🎯',
        'action': 'RSVP',
      },
      {
        'title': 'Tech Hackathon',
        'time': 'Tomorrow, 9:00 AM',
        'location': 'Computer Lab',
        'tag': 'RSVP',
        'image': '💻',
        'action': 'Join',
      },
      {
        'title': 'Music Concert',
        'time': 'Friday, 7:00 PM',
        'location': 'Open Air Theater',
        'tag': 'Paid',
        'image': '🎵',
        'action': 'Buy Ticket',
      },
      {
        'title': 'Sports Tournament',
        'time': 'Saturday, 10:00 AM',
        'location': 'Sports Complex',
        'tag': 'Free',
        'image': '⚽',
        'action': 'Register',
      },
    ];
  }
}
