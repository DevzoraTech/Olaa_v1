// Presentation Layer - Smart Suggestions Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SmartSuggestions extends StatelessWidget {
  final String category;

  const SmartSuggestions({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Suggestions
          _buildSection(
            title: 'Popular This Week',
            suggestions: _getPopularSuggestions(),
          ),
          const SizedBox(height: 24),

          // Category-specific suggestions
          _buildSection(
            title: _getCategoryTitle(),
            suggestions: _getCategorySuggestions(),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> suggestions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.whatshot,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < suggestions.length - 1 ? 12 : 0,
                ),
                child: _buildSuggestionCard(suggestions[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (suggestion['color'] as Color).withOpacity(0.15),
                    (suggestion['color'] as Color).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                suggestion['icon'] as IconData,
                color: suggestion['color'] as Color,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              suggestion['title'] as String,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              suggestion['subtitle'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // TODO: Handle suggestion tap
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  suggestion['action'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bolt,
                color: Colors.orange[600],
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.add_circle_outline,
                title: 'Post Request',
                subtitle: 'Find what you need',
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.bookmark_outline,
                title: 'Saved Searches',
                subtitle: 'Your favorites',
                color: Colors.orange[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle quick action
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getPopularSuggestions() {
    return [
      {
        'title': 'Popular Hostels',
        'subtitle': 'Near campus',
        'icon': Icons.home,
        'color': Colors.blue[600]!,
        'action': 'View All',
      },
      {
        'title': 'Top Roommates',
        'subtitle': 'Most requested',
        'icon': Icons.people,
        'color': Colors.green[600]!,
        'action': 'Browse',
      },
      {
        'title': 'Upcoming Events',
        'subtitle': 'This week',
        'icon': Icons.event,
        'color': Colors.orange[600]!,
        'action': 'See All',
      },
    ];
  }

  String _getCategoryTitle() {
    switch (category) {
      case 'Hostels':
        return 'Featured Hostels';
      case 'Roommates':
        return 'Available Roommates';
      case 'Events':
        return 'Upcoming Events';
      case 'Clubs':
        return 'Active Clubs';
      case 'Marketplace':
        return 'Hot Deals';
      default:
        return 'Trending Now';
    }
  }

  List<Map<String, dynamic>> _getCategorySuggestions() {
    switch (category) {
      case 'Hostels':
        return [
          {
            'title': 'Sunset Hostel',
            'subtitle': 'From \$350/month',
            'icon': Icons.home,
            'color': Colors.blue[600]!,
            'action': 'View Details',
          },
          {
            'title': 'Campus View',
            'subtitle': 'From \$400/month',
            'icon': Icons.home,
            'color': Colors.green[600]!,
            'action': 'View Details',
          },
        ];
      case 'Roommates':
        return [
          {
            'title': 'Alex M.',
            'subtitle': 'CS Student',
            'icon': Icons.person,
            'color': Colors.blue[600]!,
            'action': 'Connect',
          },
          {
            'title': 'Sarah K.',
            'subtitle': 'Business Student',
            'icon': Icons.person,
            'color': Colors.pink[600]!,
            'action': 'Connect',
          },
        ];
      case 'Events':
        return [
          {
            'title': 'Tech Talk',
            'subtitle': 'Tomorrow 2PM',
            'icon': Icons.event,
            'color': Colors.blue[600]!,
            'action': 'RSVP',
          },
          {
            'title': 'Movie Night',
            'subtitle': 'Friday 7PM',
            'icon': Icons.event,
            'color': Colors.purple[600]!,
            'action': 'RSVP',
          },
        ];
      case 'Clubs':
        return [
          {
            'title': 'Debate Club',
            'subtitle': '45 members',
            'icon': Icons.group,
            'color': Colors.red[600]!,
            'action': 'Join',
          },
          {
            'title': 'Tech Society',
            'subtitle': '120 members',
            'icon': Icons.group,
            'color': Colors.blue[600]!,
            'action': 'Join',
          },
        ];
      case 'Marketplace':
        return [
          {
            'title': 'iPhone 13',
            'subtitle': '\$3000',
            'icon': Icons.phone,
            'color': Colors.grey[600]!,
            'action': 'Buy Now',
          },
          {
            'title': 'Study Desk',
            'subtitle': '\$400',
            'icon': Icons.chair,
            'color': Colors.brown[600]!,
            'action': 'Buy Now',
          },
        ];
      default:
        return _getPopularSuggestions();
    }
  }
}
