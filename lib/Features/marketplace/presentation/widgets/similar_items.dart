// Presentation Layer - Similar Items Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../domain/models/marketplace_model.dart';
import '../screens/marketplace_detail_screen.dart';

class SimilarItems extends StatefulWidget {
  final MarketplaceItem currentItem;

  const SimilarItems({super.key, required this.currentItem});

  @override
  State<SimilarItems> createState() => _SimilarItemsState();
}

class _SimilarItemsState extends State<SimilarItems> {
  List<MarketplaceItem> _similarItems = [];
  bool _isLoading = true;
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final Set<String> _viewedItems =
      {}; // Track viewed items to avoid duplicate counts
  final Map<String, int> _realTimeViewCounts =
      {}; // Store real-time view counts

  @override
  void initState() {
    super.initState();
    _loadSimilarItems();
  }

  @override
  Widget build(BuildContext context) {
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _similarItems.isEmpty
                    ? Center(
                      child: Text(
                        'No similar items found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarItems.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < _similarItems.length - 1 ? 12 : 0,
                          ),
                          child: _buildSimilarItemCard(_similarItems[index]),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItemCard(MarketplaceItem item) {
    return GestureDetector(
      onTap: () {
        // Track view when user taps on similar item
        _trackItemView(item.id);

        // Navigate to item detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarketplaceDetailScreen(item: item),
          ),
        );
      },
      child: Container(
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
                child:
                    item.images.isNotEmpty
                        ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            item.images.first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  _getCategoryEmoji(item.category),
                                  style: const TextStyle(fontSize: 24),
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Text(
                            _getCategoryEmoji(item.category),
                            style: const TextStyle(fontSize: 24),
                          ),
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 8,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${_realTimeViewCounts[item.id] ?? item.views}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[500],
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
      ),
    );
  }

  Future<void> _loadSimilarItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final databaseService = SupabaseDatabaseService.instance;

      // Get items from the same category, excluding the current item
      final items = await databaseService.getMarketplaceItems(
        category: widget.currentItem.category,
        limit: 10,
      );

      // Filter out the current item and find similar items
      final filteredItems =
          items.where((item) => item['id'] != widget.currentItem.id).toList();

      // Find similar items based on title keywords and model names
      final similarItems = _findSimilarItems(filteredItems, widget.currentItem);

      // Convert to MarketplaceItem objects
      final marketplaceItems =
          similarItems.map((item) => _convertToMarketplaceItem(item)).toList();

      if (mounted) {
        setState(() {
          _similarItems = marketplaceItems;
          _isLoading = false;
        });

        // Initialize real-time view counts
        _initializeRealTimeViewCounts();
      }
    } catch (e) {
      print('Error loading similar items: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _findSimilarItems(
    List<Map<String, dynamic>> items,
    MarketplaceItem currentItem,
  ) {
    // Extract keywords from current item title
    final currentTitle = currentItem.title.toLowerCase();
    final currentKeywords = _extractKeywords(currentTitle);

    // Score items based on similarity
    final scoredItems =
        items.map((item) {
          final itemTitle = (item['title'] ?? '').toString().toLowerCase();
          final itemKeywords = _extractKeywords(itemTitle);

          // Calculate similarity score
          double score = 0.0;

          // Same category gets base score
          if (item['category'] == currentItem.category) {
            score += 10.0;
          }

          // Keyword matching
          for (final keyword in currentKeywords) {
            if (itemKeywords.contains(keyword)) {
              score += 5.0;
            }
          }

          // Title similarity (fuzzy matching)
          score += _calculateTitleSimilarity(currentTitle, itemTitle) * 3.0;

          // Price range similarity (within 50% of current price)
          final currentPrice = _extractPrice(currentItem.price);
          final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
          if (currentPrice > 0 && itemPrice > 0) {
            final priceRatio = (itemPrice / currentPrice).clamp(0.5, 2.0);
            if (priceRatio >= 0.5 && priceRatio <= 2.0) {
              score += 2.0;
            }
          }

          // Popularity boost based on view count
          final viewCount = (item['view_count'] as num?)?.toInt() ?? 0;
          if (viewCount > 0) {
            // Logarithmic scaling to prevent extremely popular items from dominating
            score += (viewCount / 10).clamp(0.0, 5.0);
          }

          return {'item': item, 'score': score};
        }).toList();

    // Sort by score and return top 6 items
    scoredItems.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );
    return scoredItems
        .take(6)
        .map((scored) => scored['item'] as Map<String, dynamic>)
        .toList();
  }

  List<String> _extractKeywords(String title) {
    // Common words to ignore
    const stopWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'must',
      'can',
      'this',
      'that',
      'these',
      'those',
    };

    return title
        .split(RegExp(r'[^\w]+'))
        .where(
          (word) =>
              word.isNotEmpty &&
              word.length > 2 &&
              !stopWords.contains(word.toLowerCase()),
        )
        .map((word) => word.toLowerCase())
        .toList();
  }

  double _calculateTitleSimilarity(String title1, String title2) {
    final words1 = title1.split(' ');
    final words2 = title2.split(' ');

    int matches = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1 == word2 || word1.contains(word2) || word2.contains(word1)) {
          matches++;
          break;
        }
      }
    }

    return matches / (words1.length + words2.length - matches);
  }

  double _extractPrice(String priceString) {
    final priceRegex = RegExp(r'[\d,]+\.?\d*');
    final match = priceRegex.firstMatch(priceString);
    if (match != null) {
      return double.tryParse(match.group(0)?.replaceAll(',', '') ?? '0') ?? 0.0;
    }
    return 0.0;
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
      isNegotiable: true,
      images: images,
      condition: data['condition'] ?? 'Good',
      location: 'Campus',
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

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return '📱';
      case 'books':
        return '📚';
      case 'furniture':
        return '🪑';
      case 'clothing':
        return '👕';
      case 'sports':
        return '⚽';
      case 'vehicles':
        return '🚗';
      case 'services':
        return '🔧';
      case 'food':
        return '🍕';
      default:
        return '📦';
    }
  }

  void _trackItemView(String itemId) async {
    // Only track if not already viewed in this session
    if (!_viewedItems.contains(itemId)) {
      _viewedItems.add(itemId);
      final user = _authService.currentUser;
      if (user != null) {
        await _databaseService.incrementMarketplaceItemViews(itemId, user.id);

        // Update real-time view count
        final updatedViewCount = await _databaseService
            .getMarketplaceItemViewCount(itemId);
        if (mounted) {
          setState(() {
            _realTimeViewCounts[itemId] = updatedViewCount;
          });
        }
      }
    }
  }

  void _initializeRealTimeViewCounts() async {
    // Initialize view counts for all similar items
    for (final item in _similarItems) {
      final viewCount = await _databaseService.getMarketplaceItemViewCount(
        item.id,
      );
      if (mounted) {
        setState(() {
          _realTimeViewCounts[item.id] = viewCount;
        });
      }
    }
  }
}
