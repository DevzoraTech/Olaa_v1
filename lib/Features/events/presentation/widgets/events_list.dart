// Presentation Layer - Events List Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event_model.dart';

class EventsList extends StatelessWidget {
  final String category;
  final String searchQuery;
  final String sortBy;
  final Function(Event) onEventTap;
  final Function(String) onSortChanged;

  const EventsList({
    super.key,
    required this.category,
    required this.searchQuery,
    required this.sortBy,
    required this.onEventTap,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final events = _getFilteredEvents();

    return Column(
      children: [
        // Sort Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${events.length} events',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showSortOptions(context),
                child: Row(
                  children: [
                    Icon(Icons.sort_rounded, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      sortBy,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Events List
        events.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEventCard(events[index]),
                );
              },
            ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
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
        child: Row(
          children: [
            // Event Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                  // Event Tag
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

            // Event Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.dateTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.rsvpCount} people going',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event.action,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
            Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters\nto find events you\'re interested in',
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
                // TODO: Navigate to create event screen
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Event'),
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                      'Most Recent',
                      'Soonest First',
                      'Most Popular',
                      'Most RSVPs',
                    ]
                    .map(
                      (option) => ListTile(
                        title: Text(option),
                        trailing:
                            sortBy == option
                                ? Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.primaryColor,
                                )
                                : null,
                        onTap: () {
                          onSortChanged(option);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
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

  List<Event> _getFilteredEvents() {
    final allEvents = _getMockEvents();

    List<Event> filtered = allEvents;

    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((event) => event.category == category).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (event) =>
                    event.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    event.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    event.organizer.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Sort events
    switch (sortBy) {
      case 'Soonest First':
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'Most Popular':
        filtered.sort((a, b) => b.rsvpCount.compareTo(a.rsvpCount));
        break;
      case 'Most RSVPs':
        filtered.sort((a, b) => b.rsvpCount.compareTo(a.rsvpCount));
        break;
      default: // Most Recent
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }

    return filtered;
  }

  List<Event> _getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Career Fair 2024',
        description: 'Meet top companies and explore career opportunities',
        organizer: 'Career Services',
        category: 'Academic',
        image: '🎯',
        dateTime: 'Today, 2:00 PM',
        location: 'Main Auditorium',
        rsvpCount: 156,
        tag: 'Free',
        action: 'RSVP',
        isRsvpRequired: true,
      ),
      Event(
        id: '2',
        title: 'Tech Hackathon',
        description: '48-hour coding competition with prizes',
        organizer: 'Computer Science Club',
        category: 'Tech',
        image: '💻',
        dateTime: 'Tomorrow, 9:00 AM',
        location: 'Computer Lab',
        rsvpCount: 89,
        tag: 'RSVP',
        action: 'Join',
        isRsvpRequired: true,
      ),
      Event(
        id: '3',
        title: 'Music Concert',
        description: 'Live performance by local bands',
        organizer: 'Music Society',
        category: 'Cultural',
        image: '🎵',
        dateTime: 'Friday, 7:00 PM',
        location: 'Open Air Theater',
        rsvpCount: 234,
        tag: 'Paid',
        action: 'Buy Ticket',
        isRsvpRequired: false,
      ),
      Event(
        id: '4',
        title: 'Sports Tournament',
        description: 'Annual inter-college sports competition',
        organizer: 'Sports Committee',
        category: 'Sports',
        image: '⚽',
        dateTime: 'Saturday, 10:00 AM',
        location: 'Sports Complex',
        rsvpCount: 67,
        tag: 'Free',
        action: 'Register',
        isRsvpRequired: true,
      ),
      Event(
        id: '5',
        title: 'Drama Performance',
        description: 'Student-led theatrical production',
        organizer: 'Drama Club',
        category: 'Cultural',
        image: '🎭',
        dateTime: 'Sunday, 6:00 PM',
        location: 'Theater Hall',
        rsvpCount: 45,
        tag: 'Free',
        action: 'RSVP',
        isRsvpRequired: true,
      ),
      Event(
        id: '6',
        title: 'Study Group Meetup',
        description: 'Collaborative study session for finals',
        organizer: 'Study Buddy Network',
        category: 'Academic',
        image: '📚',
        dateTime: 'Monday, 3:00 PM',
        location: 'Library',
        rsvpCount: 23,
        tag: null,
        action: 'Join',
        isRsvpRequired: false,
      ),
    ];
  }
}
