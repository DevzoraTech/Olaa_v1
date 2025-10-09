// Presentation Layer - Search Results Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'empty_state.dart';

class SearchResults extends StatelessWidget {
  final String query;
  final String category;

  const SearchResults({super.key, required this.query, required this.category});

  @override
  Widget build(BuildContext context) {
    final resultsCount = _getResultsCount();

    if (resultsCount == 0) {
      return EmptyState(
        message: _getEmptyStateMessage(),
        actionText: 'Expand Filters',
        onActionPressed: () {
          // TODO: Open filters
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '$resultsCount results',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results List
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    switch (category) {
      case 'Hostels':
        return _buildHostelResults();
      case 'Roommates':
        return _buildRoommateResults();
      case 'Events':
        return _buildEventResults();
      case 'Clubs':
        return _buildClubResults();
      case 'Marketplace':
        return _buildMarketplaceResults();
      default:
        return _buildMixedResults();
    }
  }

  Widget _buildHostelResults() {
    final hostels = [
      {
        'name': 'Sunset Hostel',
        'price': '\$350/month',
        'location': 'Near Campus',
        'rating': 4.5,
        'image': '🏠',
        'amenities': ['Wi-Fi', 'Meals', 'Laundry'],
      },
      {
        'name': 'Campus View',
        'price': '\$400/month',
        'location': 'Downtown',
        'rating': 4.2,
        'image': '🏢',
        'amenities': ['Wi-Fi', 'Gym', 'Study Room'],
      },
      {
        'name': 'Student Haven',
        'price': '\$320/month',
        'location': '2km from Campus',
        'rating': 4.3,
        'image': '🏘️',
        'amenities': ['Wi-Fi', 'Laundry', 'Parking'],
      },
      {
        'name': 'Green Valley',
        'price': '\$380/month',
        'location': 'Near Park',
        'rating': 4.7,
        'image': '🌳',
        'amenities': ['Wi-Fi', 'Gym', 'Study Room', 'Meals'],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hostels.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHostelCard(hostels[index]),
        );
      },
    );
  }

  Widget _buildHostelCard(Map<String, dynamic> hostel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      hostel['image'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hostel['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hostel['location'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${hostel['rating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hostel['price'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Handle contact
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Contact',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children:
                  (hostel['amenities'] as List<String>).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoommateResults() {
    final roommates = [
      {
        'name': 'Alex M.',
        'year': '2nd Year CS',
        'budget': '\$200/month',
        'interests': ['Gaming', 'Tech', 'Movies'],
        'image': '👨',
      },
      {
        'name': 'Sarah K.',
        'year': '3rd Year Business',
        'budget': '\$250/month',
        'interests': ['Reading', 'Yoga', 'Cooking'],
        'image': '👩',
      },
      {
        'name': 'Mike D.',
        'year': '1st Year Engineering',
        'budget': '\$180/month',
        'interests': ['Sports', 'Music', 'Photography'],
        'image': '👨‍💼',
      },
      {
        'name': 'Emma L.',
        'year': '4th Year Arts',
        'budget': '\$220/month',
        'interests': ['Art', 'Travel', 'Coffee'],
        'image': '👩‍🎨',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roommates.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRoommateCard(context, roommates[index]),
        );
      },
    );
  }

  Widget _buildRoommateCard(
    BuildContext context,
    Map<String, dynamic> roommate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  roommate['image'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roommate['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roommate['year'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roommate['budget'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children:
                        (roommate['interests'] as List<String>).map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/roommate-request',
                  arguments: {'requestId': roommate['id']},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Request', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventResults() {
    final events = [
      {
        'title': 'Tech Talk: AI in Education',
        'date': 'Tomorrow, 2:00 PM',
        'location': 'CS Building',
        'organizer': 'Computer Science Dept',
        'type': 'Free',
      },
      {
        'title': 'Movie Night',
        'date': 'Friday, 7:00 PM',
        'location': 'Student Center',
        'organizer': 'Student Union',
        'type': 'Free',
      },
      {
        'title': 'Career Fair 2024',
        'date': 'Next Week, 9:00 AM',
        'location': 'Main Hall',
        'organizer': 'Career Services',
        'type': 'Free',
      },
      {
        'title': 'Music Concert',
        'date': 'Saturday, 8:00 PM',
        'location': 'Auditorium',
        'organizer': 'Music Society',
        'type': 'Paid',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(events[index]),
        );
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['date'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['location'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['organizer'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['type'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle RSVP
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('RSVP', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubResults() {
    final clubs = [
      {
        'name': 'Debate Club',
        'members': '45 members',
        'category': 'Academic',
        'description': 'Weekly debates and public speaking',
      },
      {
        'name': 'Tech Society',
        'members': '120 members',
        'category': 'Technology',
        'description': 'Tech talks and coding workshops',
      },
      {
        'name': 'Photography Club',
        'members': '32 members',
        'category': 'Arts',
        'description': 'Photo walks and exhibitions',
      },
      {
        'name': 'Volunteer Society',
        'members': '78 members',
        'category': 'Community Service',
        'description': 'Community outreach programs',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildClubCard(clubs[index]),
        );
      },
    );
  }

  Widget _buildClubCard(Map<String, dynamic> club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.group, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club['members'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club['description'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      club['category'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle join
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Join', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceResults() {
    final products = [
      {
        'name': 'iPhone 13',
        'price': '\$3000',
        'seller': 'John D.',
        'condition': 'Excellent',
        'image': '📱',
      },
      {
        'name': 'Study Desk',
        'price': '\$400',
        'seller': 'Sarah M.',
        'condition': 'Good',
        'image': '🪑',
      },
      {
        'name': 'MacBook Pro',
        'price': '\$1200',
        'seller': 'Mike R.',
        'condition': 'Very Good',
        'image': '💻',
      },
      {
        'name': 'Textbook Bundle',
        'price': '\$150',
        'seller': 'Emma L.',
        'condition': 'Good',
        'image': '📚',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  product['image'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sold by ${product['seller']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product['condition'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle buy
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Buy Now', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixedResults() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Hostels Section
        _buildSectionHeader('Hostels'),
        _buildHostelResults(),
        const SizedBox(height: 24),

        // Roommates Section
        _buildSectionHeader('Roommates'),
        _buildRoommateResults(),
        const SizedBox(height: 24),

        // Events Section
        _buildSectionHeader('Events'),
        _buildEventResults(),
        const SizedBox(height: 24),

        // Clubs Section
        _buildSectionHeader('Clubs'),
        _buildClubResults(),
        const SizedBox(height: 24),

        // Marketplace Section
        _buildSectionHeader('Marketplace'),
        _buildMarketplaceResults(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  int _getResultsCount() {
    // Mock count based on category
    switch (category) {
      case 'Hostels':
        return 12;
      case 'Roommates':
        return 8;
      case 'Events':
        return 15;
      case 'Clubs':
        return 6;
      case 'Marketplace':
        return 25;
      default:
        return 66;
    }
  }

  String _getEmptyStateMessage() {
    switch (category) {
      case 'Hostels':
        return 'No hostels found in this price range';
      case 'Roommates':
        return 'No roommates match your criteria';
      case 'Events':
        return 'No events found for this time period';
      case 'Clubs':
        return 'No clubs match your interests';
      case 'Marketplace':
        return 'No products found in this category';
      default:
        return 'No results found for your search';
    }
  }
}
