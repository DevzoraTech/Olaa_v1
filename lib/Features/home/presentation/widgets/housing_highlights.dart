// Presentation Layer - Housing Highlights Widget
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/roommate_posting_service.dart';

class HousingHighlights extends StatefulWidget {
  const HousingHighlights({super.key});

  @override
  State<HousingHighlights> createState() => _HousingHighlightsState();
}

class _HousingHighlightsState extends State<HousingHighlights> {
  List<Map<String, dynamic>> _roommateRequests = [];
  List<Map<String, dynamic>> _hostelListings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHousingData();
  }

  Future<void> _loadHousingData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load roommate requests
      final roommateRequests =
          await RoommatePostingService.getRecentRoommateRequests(limit: 3);

      // Load hostel listings
      final hostelListings = await SupabaseDatabaseService.instance
          .getHostelListings(limit: 2);

      if (mounted) {
        setState(() {
          _roommateRequests = roommateRequests;
          _hostelListings = hostelListings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading housing data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load housing data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.home_work,
                    color: Colors.blue[600],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roommate & Housing',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_roommateRequests.length + _hostelListings.length} new listings',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to housing section
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 32),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[600], fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadHousingData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final allItems = [..._roommateRequests, ..._hostelListings];

    if (allItems.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_outlined, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'No housing listings yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300, // Further reduced height for more compact cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];
          final isRoommateRequest = _roommateRequests.contains(item);

          return Padding(
            padding: EdgeInsets.only(
              right: index < allItems.length - 1 ? 12 : 0,
            ),
            child:
                isRoommateRequest
                    ? _buildRoommateCard(context, item)
                    : _buildHostelCard(context, item),
          );
        },
      ),
    );
  }

  Widget _buildRoommateCard(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final nickname = request['nickname'] ?? 'Student';
    final bio = request['bio'] ?? 'Looking for a roommate';
    final budgetMin = (request['budget_min'] as num?)?.toDouble() ?? 0.0;
    final budgetMax = (request['budget_max'] as num?)?.toDouble() ?? 0.0;
    final locations =
        (request['preferred_locations'] as List<dynamic>?)?.cast<String>() ??
        [];
    final urgency = request['urgency'] ?? '';
    final sleepSchedule = request['sleep_schedule'] ?? '';
    final lifestylePreference = request['lifestyle_preference'] ?? '';
    final requestId = request['id'] ?? '';
    final profilePictureUrl = request['profile_picture_url'] ?? '';
    final campus = request['campus'] ?? '';
    final yearOfStudy = request['year_of_study'] ?? '';
    final moveInDate = request['move_in_date'] as String?;
    final smokingPreference = request['smoking_preference'] ?? '';
    final drinkingPreference = request['drinking_preference'] ?? '';
    final sharingStyle = request['sharing_style'] ?? '';
    final viewsCount = (request['views_count'] as num?)?.toInt() ?? 0;
    final chatsCount = (request['chats_count'] as num?)?.toInt() ?? 0;
    final createdAt = request['created_at'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/roommate-request',
          arguments: {'requestId': requestId},
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Image
            Container(
              padding: const EdgeInsets.all(10), // Further reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 50, // More compact size
                    height: 50, // More compact size
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2, // Professional border width
                      ),
                    ),
                    child: ClipOval(
                      child:
                          profilePictureUrl.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: profilePictureUrl,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                placeholder:
                                    (context, url) => Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue[600],
                                        size: 24,
                                      ),
                                    ),
                              )
                              : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: TextStyle(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 1), // Reduced spacing
                        if (campus.isNotEmpty && yearOfStudy.isNotEmpty) ...[
                          Text(
                            '$yearOfStudy • $campus',
                            style: TextStyle(
                              fontSize: 10, // Reduced font size
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (campus.isNotEmpty) ...[
                          Text(
                            campus,
                            style: TextStyle(
                              fontSize: 10, // Reduced font size
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 3), // Reduced spacing
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // Reduced padding
                            vertical: 1, // Reduced padding
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Smaller radius
                          ),
                          child: Text(
                            'Looking for roommate',
                            style: TextStyle(
                              fontSize: 9, // Reduced font size
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(10), // Further reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio Preview
                  Text(
                    bio.length > 50
                        ? '${bio.substring(0, 50)}...'
                        : bio, // Further reduced bio length
                    style: TextStyle(
                      fontSize: 11, // Slightly smaller font
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Further reduced spacing
                  // Key Details Grid
                  Container(
                    padding: const EdgeInsets.all(6), // Further reduced padding
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Budget Row
                        if (budgetMin > 0 && budgetMax > 0) ...[
                          _buildDetailRow(
                            icon: Icons.attach_money_rounded,
                            label: 'Budget',
                            value:
                                '${_formatCurrency(budgetMin)} - ${_formatCurrency(budgetMax)}/month',
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Location Row
                        if (locations.isNotEmpty) ...[
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: locations.take(2).join(', '),
                            color: Colors.blue[600]!,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Move-in Date Row
                        if (moveInDate != null && moveInDate.isNotEmpty) ...[
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Move-in',
                            value: _formatDateFromString(moveInDate),
                            color: Colors.green[600]!,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Lifestyle Preferences Row
                        if (smokingPreference.isNotEmpty ||
                            drinkingPreference.isNotEmpty ||
                            sharingStyle.isNotEmpty) ...[
                          _buildDetailRow(
                            icon: Icons.person_outline,
                            label: 'Lifestyle',
                            value: [
                                  smokingPreference,
                                  drinkingPreference,
                                  sharingStyle,
                                ]
                                .where((item) => item.isNotEmpty)
                                .take(2)
                                .join(' • '),
                            color: Colors.orange[600]!,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Urgency Badge
                        if (urgency.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // Reduced padding
                              vertical: 4, // Reduced padding
                            ),
                            decoration: BoxDecoration(
                              color:
                                  urgency.toLowerCase().contains('asap') ||
                                          urgency.toLowerCase().contains(
                                            'urgent',
                                          )
                                      ? Colors.red[50]
                                      : urgency.toLowerCase().contains('high')
                                      ? Colors.orange[50]
                                      : Colors.blue[50],
                              borderRadius: BorderRadius.circular(
                                6,
                              ), // Smaller radius
                              border: Border.all(
                                color:
                                    urgency.toLowerCase().contains('asap') ||
                                            urgency.toLowerCase().contains(
                                              'urgent',
                                            )
                                        ? Colors.red[200]!
                                        : urgency.toLowerCase().contains('high')
                                        ? Colors.orange[200]!
                                        : Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  urgency.toLowerCase().contains('asap') ||
                                          urgency.toLowerCase().contains(
                                            'urgent',
                                          )
                                      ? Icons.priority_high
                                      : Icons.schedule,
                                  size: 12, // Smaller icon
                                  color:
                                      urgency.toLowerCase().contains('asap') ||
                                              urgency.toLowerCase().contains(
                                                'urgent',
                                              )
                                          ? Colors.red[600]
                                          : urgency.toLowerCase().contains(
                                            'high',
                                          )
                                          ? Colors.orange[600]
                                          : Colors.blue[600],
                                ),
                                const SizedBox(width: 4), // Reduced spacing
                                Text(
                                  'Urgency: $urgency',
                                  style: TextStyle(
                                    fontSize: 10, // Smaller font
                                    color:
                                        urgency.toLowerCase().contains(
                                                  'asap',
                                                ) ||
                                                urgency.toLowerCase().contains(
                                                  'urgent',
                                                )
                                            ? Colors.red[600]
                                            : urgency.toLowerCase().contains(
                                              'high',
                                            )
                                            ? Colors.orange[600]
                                            : Colors.blue[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8), // Reduced spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostelCard(BuildContext context, Map<String, dynamic> hostel) {
    final name = hostel['name'] ?? 'Hostel';
    final location = hostel['location'] ?? '';
    final pricePerMonth =
        (hostel['price_per_month'] as num?)?.toDouble() ?? 0.0;
    final roomsAvailable = (hostel['rooms_available'] as num?)?.toInt() ?? 0;
    final amenities =
        (hostel['amenities'] as List<dynamic>?)?.cast<String>() ?? [];
    final hostelId = hostel['id'] ?? '';
    final description = hostel['description'] ?? '';
    final campus = hostel['campus'] ?? '';
    final roomType = hostel['room_type'] ?? '';
    final rating = (hostel['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (hostel['review_count'] as num?)?.toInt() ?? 0;
    final contactPhone = hostel['contact_phone'] ?? '';
    final contactEmail = hostel['contact_email'] ?? '';
    final images = (hostel['photos'] as List<dynamic>?)?.cast<String>() ?? [];
    final createdAt = hostel['created_at'] as String?;

    // Debug: Print hostel data to see what's available
    print('Hostel data keys: ${hostel.keys.toList()}');
    print('Photos field: ${hostel['photos']}');
    print('Images count: ${images.length}');

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/hostel-detail',
          arguments: {'hostelData': hostel},
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hostel Image Header
            Container(
              height: 120, // Compact height for better proportions
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [Colors.green[100]!, Colors.green[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Hostel Images Carousel or Placeholder
                  if (images.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: _buildImageCarousel(images),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[100]!, Colors.green[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work,
                            color: Colors.green[600],
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No photos yet',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Image Indicators (if multiple images)
                  if (images.length > 1) ...[
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${images.length} photos',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Rating Badge
                  if (rating > 0) ...[
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (reviewCount > 0) ...[
                              Text(
                                ' ($reviewCount)',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Campus Badge
                  if (campus.isNotEmpty) ...[
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          campus,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(12), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hostel Name and Room Type on same line
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15, // Slightly smaller
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (roomType.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            roomType,
                            style: TextStyle(
                              fontSize: 9, // Smaller font
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  // Description Preview - One line only
                  if (description.isNotEmpty) ...[
                    Text(
                      description.length > 60
                          ? '${description.substring(0, 60)}...'
                          : description,
                      style: TextStyle(
                        fontSize: 11, // Smaller font
                        color: Colors.grey[700],
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                  ],

                  // Key Details Container
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Location Row
                        if (location.isNotEmpty) ...[
                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: location,
                            color: Colors.blue[600]!,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Price Row
                        if (pricePerMonth > 0) ...[
                          _buildDetailRow(
                            icon: Icons.attach_money_rounded,
                            label: 'Price',
                            value: '${_formatCurrency(pricePerMonth)}/month',
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                        ],

                        // Rooms Available Row
                        _buildDetailRow(
                          icon: Icons.bed_outlined,
                          label: 'Available',
                          value: '$roomsAvailable rooms',
                          color: Colors.green[600]!,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8), // Reduced spacing
                  // Amenities Row
                  if (amenities.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12, // Smaller icon
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4), // Reduced spacing
                        Expanded(
                          child: Text(
                            'Amenities: ${amenities.take(2).join(', ')}${amenities.length > 2 ? '...' : ''}', // Show fewer amenities
                            style: TextStyle(
                              fontSize: 10, // Smaller font
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                  ],

                  // Contact Info Row
                  if (contactPhone.isNotEmpty || contactEmail.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.contact_phone_outlined,
                          size: 12, // Smaller icon
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4), // Reduced spacing
                        Expanded(
                          child: Text(
                            contactPhone.isNotEmpty
                                ? contactPhone
                                : contactEmail,
                            style: TextStyle(
                              fontSize: 10, // Smaller font
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color), // Smaller icon
        const SizedBox(width: 6), // Reduced spacing
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 10, // Smaller font
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 3), // Reduced spacing
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10, // Smaller font
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6), // Smaller radius
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color), // Smaller icon
          const SizedBox(width: 3), // Reduced spacing
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 9, // Smaller font
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFromString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference < 7) {
        return 'In $difference days';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        final remainingDays = difference % 7;
        if (remainingDays == 0) {
          return weeks == 1 ? 'In 1 week' : 'In $weeks weeks';
        } else {
          return weeks == 1
              ? 'In 1 week and $remainingDays ${remainingDays == 1 ? 'day' : 'days'}'
              : 'In $weeks weeks and $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
        }
      } else if (difference < 365) {
        final months = (difference / 30).floor();
        final remainingDays = difference % 30;
        final weeks = (remainingDays / 7).floor();
        final extraDays = remainingDays % 7;

        String result = months == 1 ? 'In 1 month' : 'In $months months';

        if (weeks > 0) {
          result += weeks == 1 ? ' and 1 week' : ' and $weeks weeks';
        }
        if (extraDays > 0) {
          result += ' and $extraDays ${extraDays == 1 ? 'day' : 'days'}';
        }

        return result;
      } else {
        final years = (difference / 365).floor();
        final remainingDays = difference % 365;
        final months = (remainingDays / 30).floor();
        final extraDays = remainingDays % 30;
        final weeks = (extraDays / 7).floor();
        final finalDays = extraDays % 7;

        String result = years == 1 ? 'In 1 year' : 'In $years years';

        if (months > 0) {
          result += months == 1 ? ' and 1 month' : ' and $months months';
        }
        if (weeks > 0) {
          result += weeks == 1 ? ' and 1 week' : ' and $weeks weeks';
        }
        if (finalDays > 0) {
          result += ' and $finalDays ${finalDays == 1 ? 'day' : 'days'}';
        }

        return result;
      }
    } catch (e) {
      return 'Date not specified';
    }
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  String _formatCurrency(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, color: Colors.green[600], size: 32),
            const SizedBox(height: 4),
            Text(
              'No photos yet',
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (images.length == 1) {
      return CachedNetworkImage(
        imageUrl: images.first,
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Icon(Icons.home_work, color: Colors.green[600], size: 32),
            ),
      );
    }

    // Multiple images - create carousel
    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: images[index],
          width: double.infinity,
          height: 100,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.home_work,
                  color: Colors.green[600],
                  size: 32,
                ),
              ),
        );
      },
    );
  }
}
