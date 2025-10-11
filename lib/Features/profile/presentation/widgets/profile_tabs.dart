// Presentation Layer - Profile Tabs Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../core/services/roommate_posting_service.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../marketplace/presentation/screens/marketplace_detail_screen.dart';
import '../../../marketplace/domain/models/marketplace_model.dart';
import '../../../hostel/presentation/screens/hostel_detail_screen.dart';

class ProfileTabs extends StatefulWidget {
  final String userRole;
  final String selectedTab;
  final Function(String) onTabChanged;

  const ProfileTabs({
    super.key,
    required this.userRole,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // Tab Headers
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: _getTabsForRole()),
          ),

          // Tab Content
          Container(
            padding: const EdgeInsets.all(16),
            child: _getTabContent(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _getTabsForRole() {
    final tabs = _getTabData();
    return tabs.map((tab) {
      final isSelected = widget.selectedTab == tab['name'];
      return Expanded(
        child: GestureDetector(
          onTap: () => widget.onTabChanged(tab['name']),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  tab['icon'],
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  tab['name'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getTabData() {
    switch (widget.userRole) {
      case 'Student':
        return [
          {'name': 'Roommate Requests', 'icon': Icons.home_outlined},
          {'name': 'My Events', 'icon': Icons.event_outlined},
          {'name': 'My Listings', 'icon': Icons.shopping_cart_outlined},
          {'name': 'Polls & Votes', 'icon': Icons.poll_outlined},
        ];
      case 'Hostel Provider':
        return [
          {'name': 'Hostel Listings', 'icon': Icons.home_outlined},
          {'name': 'My Listings', 'icon': Icons.shopping_cart_outlined},
          {'name': 'Contact Info', 'icon': Icons.phone_outlined},
          {'name': 'Chats', 'icon': Icons.chat_outlined},
        ];
      case 'Event Organizer':
        return [
          {'name': 'Events', 'icon': Icons.event_outlined},
          {'name': 'My Listings', 'icon': Icons.shopping_cart_outlined},
          {'name': 'Media Gallery', 'icon': Icons.photo_library_outlined},
          {'name': 'Polls', 'icon': Icons.poll_outlined},
        ];
      case 'Promoter':
        return [
          {'name': 'Events Promoted', 'icon': Icons.event_outlined},
          {'name': 'My Listings', 'icon': Icons.shopping_cart_outlined},
          {'name': 'Chats', 'icon': Icons.chat_outlined},
          {'name': 'Ticket Sales', 'icon': Icons.confirmation_number_outlined},
        ];
      default:
        return [];
    }
  }

  Widget _getTabContent(BuildContext context) {
    switch (widget.selectedTab) {
      case 'Roommate Requests':
        return _buildRoommateRequestsContent(context);
      case 'My Events':
        return _buildMyEventsContent();
      case 'My Listings':
        return _buildMyListingsContent();
      case 'Polls & Votes':
        return _buildPollsContent();
      case 'Hostel Listings':
        return _buildHostelListingsContent();
      case 'Contact Info':
        return _buildContactInfoContent();
      case 'Chats':
        return _buildChatsContent();
      case 'Events':
        return _buildEventsContent();
      case 'Media Gallery':
        return _buildMediaGalleryContent();
      case 'Polls':
        return _buildPollsContent();
      case 'Events Promoted':
        return _buildEventsPromotedContent();
      case 'Ticket Sales':
        return _buildTicketSalesContent();
      default:
        return _buildEmptyContent();
    }
  }

  Widget _buildRoommateRequestsContent(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getUserRoommateRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 8),
                Text(
                  'Failed to load roommate requests',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.person_search_outlined,
                  color: Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'No roommate requests yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first roommate request to get started',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/roommate-request');
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              requests.map((request) {
                final status = request['status'] ?? 'Active';
                final statusColor = _getStatusColor(status);
                final statusIcon = _getStatusIcon(status);

                return Column(
                  children: [
                    _buildContentItem(
                      title: request['student_name'] ?? 'Roommate Request',
                      subtitle: _buildRequestSubtitle(request),
                      status: status,
                      statusColor: statusColor,
                      icon: statusIcon,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/roommate-request',
                          arguments: {'requestId': request['id']},
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getUserRoommateRequests() async {
    try {
      final user = SupabaseAuthService.instance.currentUser;
      if (user == null) return [];

      return await RoommatePostingService.getUserRoommateRequests(
        userId: user.id,
      );
    } catch (e) {
      print('Error fetching roommate requests: $e');
      return [];
    }
  }

  String _buildRequestSubtitle(Map<String, dynamic> request) {
    final campus = request['campus'] ?? '';
    final budget = request['budget_range'] ?? '';
    final location = request['preferred_location'] ?? '';

    List<String> parts = [];
    if (campus.isNotEmpty) parts.add(campus);
    if (budget.isNotEmpty) parts.add('Budget: $budget');
    if (location.isNotEmpty) parts.add(location);

    return parts.isNotEmpty ? parts.join(' • ') : 'Roommate request';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.person_search_outlined;
      case 'matched':
        return Icons.check_circle_outline;
      case 'expired':
        return Icons.schedule_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildMyEventsContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Tech Meetup 2024',
          subtitle: 'Tomorrow, 2:00 PM • Main Auditorium',
          status: 'RSVP\'d',
          statusColor: Colors.green[600]!,
          icon: Icons.event_available_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Career Fair',
          subtitle: 'Next Friday, 10:00 AM • Student Center',
          status: 'RSVP\'d',
          statusColor: Colors.green[600]!,
          icon: Icons.event_available_outlined,
        ),
      ],
    );
  }

  Widget _buildMyListingsContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getUserMarketplaceItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 8),
                Text(
                  'Failed to load listings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please try again later',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No marketplace listings yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMarketplaceEmptyMessage(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to marketplace posting screen
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Listing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMarketplaceItem(context, item),
                );
              }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getUserMarketplaceItems() async {
    try {
      final user = SupabaseAuthService.instance.currentUser;
      if (user == null) return [];

      final databaseService = SupabaseDatabaseService.instance;
      return await databaseService.getUserMarketplaceItems(user.id);
    } catch (e) {
      print('Error fetching user marketplace items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final user = SupabaseAuthService.instance.currentUser;
      if (user == null) return null;

      return await SupabaseAuthService.instance.getUserProfile(user.id);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Widget _buildMarketplaceItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final title = item['title'] ?? 'Untitled Item';
    final category = item['category'] ?? 'General';
    final price = item['price']?.toString() ?? '0';
    final currency = item['currency'] ?? 'UGX';
    final viewCount = item['view_count'] ?? 0;
    final isAvailable = item['is_available'] ?? true;
    final condition = item['condition'] ?? 'Good';

    return _buildContentItem(
      title: title,
      subtitle: '$category • $currency $price • $viewCount views',
      status: isAvailable ? 'Available' : 'Sold',
      statusColor: isAvailable ? Colors.green[600]! : Colors.grey[600]!,
      icon: _getCategoryIcon(category),
      onTap: () {
        _navigateToMarketplaceDetail(context, item);
      },
    );
  }

  void _navigateToMarketplaceDetail(
    BuildContext context,
    Map<String, dynamic> itemData,
  ) {
    try {
      final marketplaceItem = _convertToMarketplaceItem(itemData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketplaceDetailScreen(item: marketplaceItem),
        ),
      );
    } catch (e) {
      print('Error navigating to marketplace detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open item details: ${e.toString()}'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  MarketplaceItem _convertToMarketplaceItem(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>? ?? {};
    final sellerName =
        '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
    final sellerYear = profile['year_of_study'] ?? 'Unknown';

    // Format price with currency
    final price = data['price']?.toString() ?? '0';
    final currency = data['currency'] ?? 'UGX';
    final formattedPrice = '$currency $price';

    // Format time posted
    final createdAt = data['created_at']?.toString() ?? '';
    final timePosted = _formatTimePosted(createdAt);

    // Get images array
    final images = List<String>.from(data['images'] ?? []);
    print('DEBUG: Marketplace images from database: $images');
    final primaryImage =
        images.isNotEmpty
            ? images.first
            : 'https://via.placeholder.com/300x200?text=No+Image';

    return MarketplaceItem(
      id: data['id'] ?? '',
      title: data['title'] ?? 'Untitled Item',
      description: data['description'] ?? 'No description available',
      price: formattedPrice,
      sellerName: sellerName.isNotEmpty ? sellerName : 'Unknown Seller',
      sellerYear: sellerYear,
      category: data['category'] ?? 'General',
      image: primaryImage,
      timePosted: timePosted,
      views: data['view_count'] ?? 0,
      badge: data['is_available'] == false ? 'Sold' : null,
      isNegotiable: true, // Default to true, could be added to database later
      images: images,
      condition: data['condition'] ?? 'Good',
      location: 'Campus', // Default location, could be added to database later
      contactPhone: data['contact_phone'] ?? profile['phone_number'],
      contactEmail: data['contact_email'] ?? profile['email'],
    );
  }

  String _formatTimePosted(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  String _getMarketplaceEmptyMessage() {
    switch (widget.userRole) {
      case 'Student':
        return 'Start selling your items on the marketplace';
      case 'Hostel Provider':
        return 'List your hostel services and amenities';
      case 'Event Organizer':
        return 'Promote your events and sell tickets';
      case 'Promoter':
        return 'Create listings for events you\'re promoting';
      default:
        return 'Start creating listings on the marketplace';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'books':
        return Icons.menu_book_outlined;
      case 'electronics':
        return Icons.phone_android_outlined;
      case 'furniture':
        return Icons.chair_outlined;
      case 'clothes':
        return Icons.checkroom_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'services':
        return Icons.build_outlined;
      default:
        return Icons.shopping_cart_outlined;
    }
  }

  Widget _buildPollsContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Campus Food Preferences',
          subtitle: 'Voted: More vegetarian options',
          status: 'Voted',
          statusColor: Colors.blue[600]!,
          icon: Icons.poll_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Library Hours Extension',
          subtitle: 'Voted: Yes, extend to midnight',
          status: 'Voted',
          statusColor: Colors.blue[600]!,
          icon: Icons.poll_outlined,
        ),
      ],
    );
  }

  Widget _buildHostelListingsContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseDatabaseService.instance.getHostelListingsByProvider(
        SupabaseAuthService.instance.currentUser?.id ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load hostel listings',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final hostelListings = snapshot.data ?? [];

        if (hostelListings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hostel listings yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first hostel listing to get started',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children:
              hostelListings.map((listing) {
                final status = listing['status'] ?? 'active';
                final statusColor =
                    status == 'active'
                        ? Colors.green[600]!
                        : Colors.orange[600]!;

                return Column(
                  children: [
                    _buildContentItem(
                      title:
                          listing['name'] ??
                          listing['title'] ??
                          'Untitled Listing',
                      subtitle: _buildHostelSubtitle(listing),
                      status: status == 'active' ? 'Available' : 'Unavailable',
                      statusColor: statusColor,
                      icon: Icons.home_outlined,
                      onTap: () => _navigateToHostelDetail(context, listing),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
        );
      },
    );
  }

  String _buildHostelSubtitle(Map<String, dynamic> listing) {
    final campus = listing['campus'] ?? '';
    final monthlyRent =
        listing['monthly_rent'] ?? listing['price_per_month'] ?? 0;
    final currency = listing['currency'] ?? 'UGX';
    final roomType = listing['room_type'] ?? '';

    String subtitle = '';
    if (campus.isNotEmpty) subtitle += '$campus • ';
    if (monthlyRent > 0)
      subtitle += '$currency ${monthlyRent.toStringAsFixed(0)}/month • ';
    if (roomType.isNotEmpty) subtitle += '$roomType';

    return subtitle.isNotEmpty ? subtitle : 'Hostel listing';
  }

  void _navigateToHostelDetail(
    BuildContext context,
    Map<String, dynamic> listing,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostelDetailScreen(hostelData: listing),
      ),
    );
  }

  Widget _buildContactInfoContent() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 8),
                Text(
                  'Failed to load contact information',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.person_outline, color: Colors.grey[400], size: 48),
                const SizedBox(height: 8),
                Text(
                  'No contact information available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final phone = profile['phone_number'] ?? '';
        final email = profile['email'] ?? '';
        final website = profile['website'] ?? '';
        final instagram = profile['instagram'] ?? '';
        final linkedin = profile['linkedin'] ?? '';
        final address = profile['address'] ?? '';
        final officeLocation = profile['office_location'] ?? '';

        return Column(
          children: [
            // Phone
            if (phone.isNotEmpty) ...[
              _buildContactItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: phone,
                action: 'Call',
              ),
              const SizedBox(height: 12),
            ],

            // Email
            if (email.isNotEmpty) ...[
              _buildContactItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
                action: 'Email',
              ),
              const SizedBox(height: 12),
            ],

            // Website
            if (website.isNotEmpty) ...[
              _buildContactItem(
                icon: Icons.language_outlined,
                label: 'Website',
                value: website,
                action: 'Visit',
              ),
              const SizedBox(height: 12),
            ],

            // Office Location
            if (officeLocation.isNotEmpty) ...[
              _buildContactItem(
                icon: Icons.location_on_outlined,
                label: 'Office',
                value: officeLocation,
                action: 'Directions',
              ),
              const SizedBox(height: 12),
            ] else if (address.isNotEmpty) ...[
              _buildContactItem(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: address,
                action: 'Directions',
              ),
              const SizedBox(height: 12),
            ],

            // Social Media
            if (instagram.isNotEmpty || linkedin.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Media',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (instagram.isNotEmpty) ...[
                          _buildSocialContactItem(
                            icon: Icons.camera_alt_outlined,
                            label: 'Instagram',
                            value: instagram,
                            action: 'Follow',
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (linkedin.isNotEmpty) ...[
                          _buildSocialContactItem(
                            icon: Icons.work_outlined,
                            label: 'LinkedIn',
                            value: linkedin,
                            action: 'Connect',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Show message if no contact info available
            if (phone.isEmpty &&
                email.isEmpty &&
                website.isEmpty &&
                officeLocation.isEmpty &&
                address.isEmpty &&
                instagram.isEmpty &&
                linkedin.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No contact information available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact information will appear here when available',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildChatsContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Alex M.',
          subtitle: 'Interested in the single room',
          status: '2h ago',
          statusColor: Colors.grey[600]!,
          icon: Icons.chat_bubble_outline,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Sarah K.',
          subtitle: 'Can I visit tomorrow?',
          status: '1d ago',
          statusColor: Colors.grey[600]!,
          icon: Icons.chat_bubble_outline,
        ),
      ],
    );
  }

  Widget _buildEventsContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Tech Hackathon 2024',
          subtitle: 'Next Saturday • 48-hour coding competition',
          status: 'Upcoming',
          statusColor: Colors.blue[600]!,
          icon: Icons.code_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'AI Workshop',
          subtitle: 'Last week • Machine Learning basics',
          status: 'Completed',
          statusColor: Colors.green[600]!,
          icon: Icons.school_outlined,
        ),
      ],
    );
  }

  Widget _buildMediaGalleryContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Event Photos',
          subtitle: '12 photos from recent events',
          status: 'View',
          statusColor: Colors.blue[600]!,
          icon: Icons.photo_library_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Event Posters',
          subtitle: '8 promotional materials',
          status: 'View',
          statusColor: Colors.blue[600]!,
          icon: Icons.image_outlined,
        ),
      ],
    );
  }

  Widget _buildEventsPromotedContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Summer Music Festival',
          subtitle: 'Next month • 500+ RSVPs',
          status: 'Active',
          statusColor: Colors.green[600]!,
          icon: Icons.music_note_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Pool Party Night',
          subtitle: 'This weekend • 200+ RSVPs',
          status: 'Active',
          statusColor: Colors.green[600]!,
          icon: Icons.pool_outlined,
        ),
      ],
    );
  }

  Widget _buildTicketSalesContent() {
    return Column(
      children: [
        _buildContentItem(
          title: 'Summer Festival',
          subtitle: '850 tickets sold • \$12,750 revenue',
          status: 'Completed',
          statusColor: Colors.green[600]!,
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 12),
        _buildContentItem(
          title: 'Pool Party',
          subtitle: '200 tickets sold • \$4,000 revenue',
          status: 'Active',
          statusColor: Colors.blue[600]!,
          icon: Icons.confirmation_number_outlined,
        ),
      ],
    );
  }

  Widget _buildContentItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required String action,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Handle contact action
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialContactItem({
    required IconData icon,
    required String label,
    required String value,
    required String action,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                // TODO: Handle social media action
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  action,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No content available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
