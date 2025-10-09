// Presentation Layer - Events Detail Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event_model.dart';
import '../widgets/event_image_carousel.dart';
import '../widgets/organizer_profile_card.dart';
import '../widgets/related_events.dart';

class EventsDetailScreen extends StatefulWidget {
  final Event event;

  const EventsDetailScreen({super.key, required this.event});

  @override
  State<EventsDetailScreen> createState() => _EventsDetailScreenState();
}

class _EventsDetailScreenState extends State<EventsDetailScreen> {
  bool _isRsvped = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          'Event Details',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.red : Colors.grey[600],
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: Icon(Icons.share_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Event Image Carousel
            EventImageCarousel(
              images:
                  widget.event.images.isNotEmpty
                      ? widget.event.images
                      : [widget.event.image],
            ),

            // Event Details
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Tag
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      if (widget.event.tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventTagColor(widget.event.tag!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.event.tag!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price if applicable
                  if (widget.event.price != null)
                    Text(
                      widget.event.price!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Event Info
                  _buildInfoRow(
                    Icons.category_outlined,
                    'Category',
                    widget.event.category,
                  ),
                  _buildInfoRow(
                    Icons.access_time_rounded,
                    'Date & Time',
                    widget.event.dateTime,
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Location',
                    widget.event.location,
                  ),
                  _buildInfoRow(
                    Icons.group_outlined,
                    'RSVPs',
                    '${widget.event.rsvpCount} people going',
                  ),
                  _buildInfoRow(
                    Icons.business_outlined,
                    'Organizer',
                    widget.event.organizer,
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'About This Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Organizer Profile
            OrganizerProfileCard(
              organizerName: widget.event.organizer,
              organizerType: 'Student Club',
              rating: 4.8,
              totalEvents: 23,
              isVerified: true,
              onContactPressed: () {
                // TODO: Navigate to contact
              },
            ),

            // Related Events
            const RelatedEvents(),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add to calendar
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: const Text('Add to Calendar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRsvped = !_isRsvped;
                    });
                  },
                  icon: Icon(
                    _isRsvped
                        ? Icons.check_rounded
                        : Icons.event_available_rounded,
                  ),
                  label: Text(_isRsvped ? 'RSVP\'d' : widget.event.action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRsvped ? Colors.green[600] : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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
}
