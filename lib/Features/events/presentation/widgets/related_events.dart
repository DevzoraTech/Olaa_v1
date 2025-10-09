// Presentation Layer - Related Events Widget
import 'package:flutter/material.dart';
import '../../domain/models/event_model.dart';

class RelatedEvents extends StatelessWidget {
  const RelatedEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final relatedEvents = _getRelatedEvents();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You may also like',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedEvents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < relatedEvents.length - 1 ? 12 : 0,
                  ),
                  child: _buildRelatedEventCard(relatedEvents[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedEventCard(Event event) {
    return Container(
      width: 160,
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
          // Image
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
                      event.image,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  if (event.tag != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getEventTagColor(event.tag!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.tag!,
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

          // Content
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.dateTime,
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${event.rsvpCount} going',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  List<Event> _getRelatedEvents() {
    return [
      Event(
        id: '1',
        title: 'Tech Workshop',
        description: 'Learn new technologies',
        organizer: 'Tech Club',
        category: 'Tech',
        image: '💻',
        dateTime: 'Next Week',
        location: 'Lab',
        rsvpCount: 45,
        tag: 'Free',
        action: 'RSVP',
        isRsvpRequired: true,
      ),
      Event(
        id: '2',
        title: 'Art Exhibition',
        description: 'Student artwork showcase',
        organizer: 'Art Society',
        category: 'Cultural',
        image: '🎨',
        dateTime: 'This Weekend',
        location: 'Gallery',
        rsvpCount: 78,
        tag: 'Free',
        action: 'RSVP',
        isRsvpRequired: true,
      ),
      Event(
        id: '3',
        title: 'Study Group',
        description: 'Collaborative learning',
        organizer: 'Study Network',
        category: 'Academic',
        image: '📚',
        dateTime: 'Tomorrow',
        location: 'Library',
        rsvpCount: 23,
        tag: null,
        action: 'Join',
        isRsvpRequired: false,
      ),
      Event(
        id: '4',
        title: 'Fitness Class',
        description: 'Group workout session',
        organizer: 'Fitness Club',
        category: 'Sports',
        image: '💪',
        dateTime: 'Daily',
        location: 'Gym',
        rsvpCount: 56,
        tag: 'Free',
        action: 'RSVP',
        isRsvpRequired: true,
      ),
    ];
  }
}
