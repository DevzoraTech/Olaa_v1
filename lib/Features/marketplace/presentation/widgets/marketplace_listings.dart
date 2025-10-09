// Presentation Layer - Marketplace Listings Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/marketplace_model.dart';

class MarketplaceListings extends StatelessWidget {
  final String category;
  final String searchQuery;
  final String sortBy;
  final Function(MarketplaceItem) onItemTap;
  final Function(String) onSortChanged;

  const MarketplaceListings({
    super.key,
    required this.category,
    required this.searchQuery,
    required this.sortBy,
    required this.onItemTap,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredItems();

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
                '${items.length} items',
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

        // Listings Grid
        items.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildListingCard(items[index]);
              },
            ),
      ],
    );
  }

  Widget _buildListingCard(MarketplaceItem item) {
    return GestureDetector(
      onTap: () => onItemTap(item),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        item.image,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    // Badge
                    if (item.badge != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(item.badge!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.badge!,
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
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.price,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.sellerName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.timePosted,
                      style: TextStyle(fontSize: 9, color: Colors.grey[400]),
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
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters\nto find what you\'re looking for',
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
                // TODO: Navigate to post item screen
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('List an Item'),
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
                      'Lowest Price',
                      'Highest Price',
                      'Most Popular',
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

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
        return Colors.green[600]!;
      case 'urgent':
        return Colors.red[600]!;
      case 'negotiable':
        return Colors.blue[600]!;
      case 'free':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  List<MarketplaceItem> _getFilteredItems() {
    final allItems = _getMockItems();

    List<MarketplaceItem> filtered = allItems;

    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((item) => item.category == category).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (item) =>
                    item.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    item.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Sort items
    switch (sortBy) {
      case 'Lowest Price':
        filtered.sort(
          (a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)),
        );
        break;
      case 'Highest Price':
        filtered.sort(
          (a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)),
        );
        break;
      case 'Most Popular':
        filtered.sort((a, b) => b.views.compareTo(a.views));
        break;
      default: // Most Recent
        filtered.sort((a, b) => b.timePosted.compareTo(a.timePosted));
    }

    return filtered;
  }

  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  List<MarketplaceItem> _getMockItems() {
    return [
      MarketplaceItem(
        id: '1',
        title: 'MacBook Pro M1 13"',
        description: 'Excellent condition, barely used',
        price: '\$800',
        sellerName: 'Alex Johnson',
        sellerYear: 'Senior CS',
        category: 'Electronics',
        image: '💻',
        timePosted: '2h ago',
        views: 45,
        badge: 'New',
        isNegotiable: true,
      ),
      MarketplaceItem(
        id: '2',
        title: 'Calculus Textbook',
        description: 'Stewart Calculus 8th Edition',
        price: '\$25',
        sellerName: 'Sarah Kim',
        sellerYear: 'Sophomore Math',
        category: 'Books',
        image: '📚',
        timePosted: '4h ago',
        views: 23,
        badge: null,
        isNegotiable: false,
      ),
      MarketplaceItem(
        id: '3',
        title: 'Study Desk & Chair',
        description: 'Wooden desk with ergonomic chair',
        price: '\$120',
        sellerName: 'Mike Rodriguez',
        sellerYear: 'Junior Engineering',
        category: 'Furniture',
        image: '🪑',
        timePosted: '6h ago',
        views: 67,
        badge: 'Urgent',
        isNegotiable: true,
      ),
      MarketplaceItem(
        id: '4',
        title: 'AirPods Pro 2nd Gen',
        description: 'Like new, with case and charger',
        price: '\$150',
        sellerName: 'Emma Lee',
        sellerYear: 'Senior Business',
        category: 'Electronics',
        image: '🎧',
        timePosted: '8h ago',
        views: 89,
        badge: null,
        isNegotiable: true,
      ),
      MarketplaceItem(
        id: '5',
        title: 'Winter Jacket',
        description: 'North Face jacket, size M',
        price: '\$60',
        sellerName: 'David Chen',
        sellerYear: 'Graduate Student',
        category: 'Clothes',
        image: '🧥',
        timePosted: '1d ago',
        views: 34,
        badge: null,
        isNegotiable: false,
      ),
      MarketplaceItem(
        id: '6',
        title: 'Guitar Lessons',
        description: 'Beginner guitar lessons, \$20/hour',
        price: '\$20/hr',
        sellerName: 'Lisa Wang',
        sellerYear: 'Senior Music',
        category: 'Services',
        image: '🎸',
        timePosted: '2d ago',
        views: 56,
        badge: null,
        isNegotiable: true,
      ),
    ];
  }
}
