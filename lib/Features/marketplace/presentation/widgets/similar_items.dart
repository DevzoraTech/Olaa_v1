// Presentation Layer - Similar Items Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/marketplace_model.dart';

class SimilarItems extends StatelessWidget {
  const SimilarItems({super.key});

  @override
  Widget build(BuildContext context) {
    final similarItems = _getSimilarItems();

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
              itemCount: similarItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < similarItems.length - 1 ? 12 : 0,
                  ),
                  child: _buildSimilarItemCard(similarItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItemCard(MarketplaceItem item) {
    return Container(
      width: 140,
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
              child: Center(
                child: Text(item.image, style: const TextStyle(fontSize: 24)),
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
                    item.title,
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
                    item.price,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.sellerName,
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

  List<MarketplaceItem> _getSimilarItems() {
    return [
      MarketplaceItem(
        id: '1',
        title: 'MacBook Air M2',
        description: 'Like new MacBook Air',
        price: '\$750',
        sellerName: 'John D.',
        sellerYear: 'Senior CS',
        category: 'Electronics',
        image: '💻',
        timePosted: '1d ago',
        views: 32,
        badge: null,
        isNegotiable: true,
      ),
      MarketplaceItem(
        id: '2',
        title: 'iPad Pro 11"',
        description: 'Perfect for note-taking',
        price: '\$400',
        sellerName: 'Maria S.',
        sellerYear: 'Junior Business',
        category: 'Electronics',
        image: '📱',
        timePosted: '3d ago',
        views: 28,
        badge: 'New',
        isNegotiable: false,
      ),
      MarketplaceItem(
        id: '3',
        title: 'Dell XPS 13',
        description: 'Great laptop for coding',
        price: '\$600',
        sellerName: 'Tom W.',
        sellerYear: 'Graduate CS',
        category: 'Electronics',
        image: '💻',
        timePosted: '5d ago',
        views: 41,
        badge: null,
        isNegotiable: true,
      ),
      MarketplaceItem(
        id: '4',
        title: 'Surface Pro 8',
        description: '2-in-1 laptop tablet',
        price: '\$550',
        sellerName: 'Lisa K.',
        sellerYear: 'Senior Design',
        category: 'Electronics',
        image: '📱',
        timePosted: '1w ago',
        views: 19,
        badge: null,
        isNegotiable: true,
      ),
    ];
  }
}
