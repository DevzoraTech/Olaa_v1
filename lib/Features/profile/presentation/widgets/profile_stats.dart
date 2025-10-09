// Presentation Layer - Profile Stats Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/roommate_posting_service.dart';

class ProfileStats extends StatefulWidget {
  final String userRole;

  const ProfileStats({super.key, required this.userRole});

  @override
  State<ProfileStats> createState() => _ProfileStatsState();
}

class _ProfileStatsState extends State<ProfileStats> {
  int _roommateRequestsCount = 0;
  int _eventsAttendedCount = 0;
  int _itemsListedCount = 0;
  int _totalListingsCount = 0;
  int _studentsServedCount = 0;
  double _rating = 0.0;
  int _eventsHostedCount = 0;
  int _followersCount = 0;
  int _upcomingEventsCount = 0;
  int _ticketsSoldCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final user = SupabaseAuthService.instance.currentUser;
      if (user == null) return;

      final databaseService = SupabaseDatabaseService.instance;

      switch (widget.userRole) {
        case 'Student':
          await _loadStudentStats(user.id, databaseService);
          break;
        case 'Hostel Provider':
          await _loadHostelProviderStats(user.id, databaseService);
          break;
        case 'Event Organizer':
          await _loadEventOrganizerStats(user.id, databaseService);
          break;
        case 'Promoter':
          await _loadPromoterStats(user.id, databaseService);
          break;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStudentStats(
    String userId,
    SupabaseDatabaseService databaseService,
  ) async {
    // Load roommate requests count
    final roommateRequests =
        await RoommatePostingService.getUserRoommateRequests(userId: userId);

    // Load marketplace items count
    final marketplaceItems = await databaseService.getUserMarketplaceItems(
      userId,
    );

    // Load events attended count (placeholder - implement when events system is ready)
    final eventsAttended = 0; // TODO: Implement when events system is ready

    setState(() {
      _roommateRequestsCount = roommateRequests.length;
      _itemsListedCount = marketplaceItems.length;
      _eventsAttendedCount = eventsAttended;
    });
  }

  Future<void> _loadHostelProviderStats(
    String userId,
    SupabaseDatabaseService databaseService,
  ) async {
    // Load hostel listings count
    final hostelListings = await databaseService.getHostelListingsByProvider(
      userId,
    );

    // Load students served count (placeholder - implement when booking system is ready)
    final studentsServed = 0; // TODO: Implement when booking system is ready

    // Load rating (placeholder - implement when rating system is ready)
    final rating = 0.0; // TODO: Implement when rating system is ready

    setState(() {
      _totalListingsCount = hostelListings.length;
      _studentsServedCount = studentsServed;
      _rating = rating;
    });
  }

  Future<void> _loadEventOrganizerStats(
    String userId,
    SupabaseDatabaseService databaseService,
  ) async {
    // Load events hosted count
    final eventsHosted = await databaseService.getEventsByOrganizer(userId);

    // Load followers count (placeholder - implement when follow system is ready)
    final followers = 0; // TODO: Implement when follow system is ready

    // Load upcoming events count
    final upcomingEvents =
        eventsHosted.where((event) {
          final eventDate = DateTime.parse(event['event_date'] ?? '');
          return eventDate.isAfter(DateTime.now());
        }).length;

    setState(() {
      _eventsHostedCount = eventsHosted.length;
      _followersCount = followers;
      _upcomingEventsCount = upcomingEvents;
    });
  }

  Future<void> _loadPromoterStats(
    String userId,
    SupabaseDatabaseService databaseService,
  ) async {
    // Load followers count (placeholder - implement when follow system is ready)
    final followers = 0; // TODO: Implement when follow system is ready

    // Load tickets sold count (placeholder - implement when ticketing system is ready)
    final ticketsSold = 0; // TODO: Implement when ticketing system is ready

    // Load events hosted count
    final eventsHosted = await databaseService.getEventsByOrganizer(userId);

    setState(() {
      _followersCount = followers;
      _ticketsSoldCount = ticketsSold;
      _eventsHostedCount = eventsHosted.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(children: _getStatsForRole()),
        ],
      ),
    );
  }

  List<Widget> _getStatsForRole() {
    if (_isLoading) {
      return [
        _buildStatItem(
          icon: Icons.hourglass_empty,
          label: 'Loading...',
          value: '...',
          color: Colors.grey[600]!,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.hourglass_empty,
          label: 'Loading...',
          value: '...',
          color: Colors.grey[600]!,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.hourglass_empty,
          label: 'Loading...',
          value: '...',
          color: Colors.grey[600]!,
        ),
      ];
    }

    switch (widget.userRole) {
      case 'Student':
        return [
          _buildStatItem(
            icon: Icons.people_outline,
            label: 'Roommate Requests',
            value: '$_roommateRequestsCount',
            color: Colors.blue[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.event_available_outlined,
            label: 'Events Attended',
            value: '$_eventsAttendedCount',
            color: Colors.green[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Items Listed',
            value: '$_itemsListedCount',
            color: Colors.orange[600]!,
          ),
        ];
      case 'Hostel Provider':
        return [
          _buildStatItem(
            icon: Icons.home_outlined,
            label: 'Total Listings',
            value: '$_totalListingsCount',
            color: Colors.blue[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.people_outline,
            label: 'Students Served',
            value: '$_studentsServedCount',
            color: Colors.green[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.star_outline,
            label: 'Rating',
            value: _rating > 0 ? _rating.toStringAsFixed(1) : 'N/A',
            color: Colors.orange[600]!,
          ),
        ];
      case 'Event Organizer':
        return [
          _buildStatItem(
            icon: Icons.event_outlined,
            label: 'Events Hosted',
            value: '$_eventsHostedCount',
            color: Colors.blue[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.people_outline,
            label: 'Followers',
            value: '$_followersCount',
            color: Colors.green[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.event_available_outlined,
            label: 'Upcoming',
            value: '$_upcomingEventsCount',
            color: Colors.orange[600]!,
          ),
        ];
      case 'Promoter':
        return [
          _buildStatItem(
            icon: Icons.people_outline,
            label: 'Followers',
            value: '$_followersCount',
            color: Colors.blue[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Tickets Sold',
            value: '$_ticketsSoldCount',
            color: Colors.green[600]!,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.event_outlined,
            label: 'Events Hosted',
            value: '$_eventsHostedCount',
            color: Colors.orange[600]!,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
