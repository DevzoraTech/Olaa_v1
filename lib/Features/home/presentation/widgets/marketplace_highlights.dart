// Presentation Layer - Marketplace Highlights Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../Features/marketplace/presentation/screens/marketplace_list_screen.dart';
import '../../../../Features/marketplace/presentation/screens/marketplace_detail_screen.dart';
import '../../../../Features/marketplace/domain/models/marketplace_model.dart';

class MarketplaceHighlights extends StatefulWidget {
  const MarketplaceHighlights({super.key});

  @override
  State<MarketplaceHighlights> createState() => _MarketplaceHighlightsState();
}

class _MarketplaceHighlightsState extends State<MarketplaceHighlights> {
  List<Map<String, dynamic>> _marketplaceItems = [];
  bool _isLoading = true;
  String? _errorMessage;
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
    _loadMarketplaceData();
  }

  Future<void> _loadMarketplaceData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final databaseService = SupabaseDatabaseService.instance;
      final items = await databaseService.getMarketplaceItems(limit: 4);

      if (mounted) {
        setState(() {
          _marketplaceItems = items;
          _isLoading = false;
        });

        // Initialize real-time view counts
        _initializeRealTimeViewCounts();
      }
    } catch (e) {
      print('Error loading marketplace data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load marketplace items';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    color: isDarkMode ? Colors.green[900] : Colors.green[50],
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
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_marketplaceItems.length} active deals',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketplaceListScreen(),
                  ),
                );
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
                onPressed: _loadMarketplaceData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_marketplaceItems.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'No marketplace items yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300, // Increased height to accommodate taller cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _marketplaceItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < _marketplaceItems.length - 1 ? 8 : 0,
            ),
            child: _buildMarketplaceCard(_marketplaceItems[index]),
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceCard(Map<String, dynamic> item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Extract data from the real item
    final title = item['title'] ?? 'Untitled Item';
    final price = item['price'] ?? 0.0;
    final category = item['category'] ?? 'General';
    final condition = item['condition'] ?? 'Good';
    final description = item['description'] ?? 'No description available';

    // Extract seller information from profiles join
    final profiles = item['profiles'] as Map<String, dynamic>?;
    final sellerFirstName = profiles?['first_name'] ?? '';
    final sellerLastName = profiles?['last_name'] ?? '';
    final sellerName =
        sellerFirstName.isNotEmpty && sellerLastName.isNotEmpty
            ? '$sellerFirstName $sellerLastName'
            : sellerFirstName.isNotEmpty
            ? sellerFirstName
            : sellerLastName.isNotEmpty
            ? sellerLastName
            : 'Unknown Seller';

    final createdAt = item['created_at'] as String?;
    final itemId = item['id'] as String;
    final viewsCount = _realTimeViewCounts[itemId] ?? 0;
    final isNegotiable = item['is_negotiable'] ?? false;
    final images = (item['images'] as List<dynamic>?)?.cast<String>() ?? [];

    // Format price
    final formattedPrice = '\$${price.toStringAsFixed(0)}';

    // Format time ago
    final timeAgo = _formatTimeAgo(createdAt);

    // Get category emoji
    final categoryEmoji = _getCategoryEmoji(category);

    return GestureDetector(
      onTap: () {
        _navigateToMarketplaceDetail(context, item);
      },
      child: Container(
        width: 240, // Increased width for better content organization
        height: 280, // Fixed height to prevent overflow
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
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
                height: 90, // Increased height for better image display
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Display actual image if available, otherwise show category emoji
                    if (images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images.first,
                          width: double.infinity,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                categoryEmoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          categoryEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    // Negotiable badge
                    if (isNegotiable)
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
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Price and Condition Row
              Row(
                children: [
                  Text(
                    formattedPrice,
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
                      color: _getConditionColor(condition),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      condition,
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
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
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
                          sellerName,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.access_time_rounded,
                          size: 8,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          timeAgo,
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
                        category,
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
                        viewsCount.toString(),
                        style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Recently';

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

  void _navigateToMarketplaceDetail(
    BuildContext context,
    Map<String, dynamic> itemData,
  ) {
    try {
      final marketplaceItem = _convertToMarketplaceItem(itemData);

      // Track view when user taps on item
      _trackItemView(itemData['id']);

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
    // Initialize view counts for all items
    for (final item in _marketplaceItems) {
      final itemId = item['id'] as String;
      final viewCount = await _databaseService.getMarketplaceItemViewCount(
        itemId,
      );
      if (mounted) {
        setState(() {
          _realTimeViewCounts[itemId] = viewCount;
        });
      }
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
      views: _realTimeViewCounts[data['id']] ?? 0,
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
}
