// Presentation Layer - Marketplace Highlights Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MarketplaceHighlights extends StatelessWidget {
  const MarketplaceHighlights({super.key});

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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: Colors.green[600],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      '28 active deals',
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
                // TODO: Navigate to marketplace
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                child: _buildMarketplaceCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceCard(int index) {
    final marketplaceItems = [
      {
        'title': 'iPhone 13 Pro Max',
        'price': '\$3000',
        'category': 'Electronics',
        'image': '📱',
        'condition': 'Excellent',
        'seller': 'Alex M.',
        'time': '2h ago',
        'views': '24',
        'negotiable': true,
        'description': 'Like new iPhone 13 Pro Max, barely used',
      },
      {
        'title': 'Study Desk & Chair Set',
        'price': '\$400',
        'category': 'Furniture',
        'image': '🪑',
        'condition': 'Good',
        'seller': 'Sarah K.',
        'time': '1d ago',
        'views': '18',
        'negotiable': true,
        'description': 'Complete study setup, perfect for dorm',
      },
      {
        'title': 'Calculus Textbook',
        'price': '\$50',
        'category': 'Books',
        'image': '📚',
        'condition': 'Very Good',
        'seller': 'Mike R.',
        'time': '3d ago',
        'views': '12',
        'negotiable': false,
        'description': 'Latest edition, minimal highlighting',
      },
      {
        'title': 'MacBook Pro M2',
        'price': '\$1200',
        'category': 'Electronics',
        'image': '💻',
        'condition': 'Excellent',
        'seller': 'Emma L.',
        'time': '5d ago',
        'views': '31',
        'negotiable': true,
        'description': 'Perfect for coding and design work',
      },
    ];

    final item = marketplaceItems[index];

    return Container(
      width: 240, // Increased width for better content organization
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 65, // Further reduced height to eliminate overflow
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      item['image'] as String,
                      style: const TextStyle(fontSize: 28), // Reduced font size
                    ),
                  ),
                  // Negotiable badge
                  if (item['negotiable'] as bool)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Negotiable',
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Product Info Section
            Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Price and Condition Row
            Row(
              children: [
                Text(
                  item['price'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _getConditionColor(item['condition'] as String),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['condition'] as String,
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Description Section
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['description'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[700],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 8,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item['seller'] as String,
                        style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.access_time_rounded,
                        size: 8,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item['time'] as String,
                        style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Bottom Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 8,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item['category'] as String,
                      style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 8,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item['views'] as String,
                      style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'excellent':
        return Colors.green[600]!;
      case 'very good':
        return Colors.blue[600]!;
      case 'good':
        return Colors.orange[600]!;
      case 'fair':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
