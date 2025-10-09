// Presentation Layer - Featured Listings Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FeaturedListings extends StatelessWidget {
  const FeaturedListings({super.key});

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
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: Colors.orange[600],
              ),
              const SizedBox(width: 6),
              Text(
                'Featured This Week',
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
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getFeaturedItems().length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _getFeaturedItems().length - 1 ? 12 : 0,
                  ),
                  child: _buildFeaturedCard(_getFeaturedItems()[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> item) {
    return Container(
      width: 180,
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
          // Image placeholder
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                item['image'] as String,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['price'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 10,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['seller'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  List<Map<String, dynamic>> _getFeaturedItems() {
    return [
      {
        'title': 'MacBook Pro M1',
        'price': '\$800',
        'seller': 'Alex J.',
        'image': '💻',
      },
      {
        'title': 'Calculus Textbook',
        'price': '\$25',
        'seller': 'Sarah K.',
        'image': '📚',
      },
      {
        'title': 'Study Desk',
        'price': '\$120',
        'seller': 'Mike R.',
        'image': '🪑',
      },
      {
        'title': 'AirPods Pro',
        'price': '\$150',
        'seller': 'Emma L.',
        'image': '🎧',
      },
    ];
  }
}
