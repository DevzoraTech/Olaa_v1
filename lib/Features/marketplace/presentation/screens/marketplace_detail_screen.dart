// Presentation Layer - Marketplace Detail Screen
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../domain/models/marketplace_model.dart';
import '../widgets/item_image_carousel.dart';
import '../widgets/seller_profile_card.dart';
import '../widgets/similar_items.dart';

class MarketplaceDetailScreen extends StatefulWidget {
  final MarketplaceItem item;

  const MarketplaceDetailScreen({super.key, required this.item});

  @override
  State<MarketplaceDetailScreen> createState() =>
      _MarketplaceDetailScreenState();
}

class _MarketplaceDetailScreenState extends State<MarketplaceDetailScreen> {
  bool _isFavorite = false;
  bool _showFullDetails = false;
  int _currentViewCount = 0;
  final SupabaseDatabaseService _databaseService =
      SupabaseDatabaseService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  @override
  void initState() {
    super.initState();
    _currentViewCount = widget.item.views;
    _trackView();
  }

  void _trackView() async {
    // Track view when screen is opened
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.incrementMarketplaceItemViews(
        widget.item.id,
        user.id,
      );

      // Update view count in real-time
      final updatedViewCount = await _databaseService
          .getMarketplaceItemViewCount(widget.item.id);
      if (mounted) {
        setState(() {
          _currentViewCount = updatedViewCount;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          'Item Details',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.red : Colors.grey[600],
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: Icon(Icons.share_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel
            ItemImageCarousel(
              images: () {
                final images =
                    widget.item.images.isNotEmpty
                        ? widget.item.images
                        : [widget.item.image];
                print('DEBUG: Images passed to carousel: $images');
                return images;
              }(),
            ),

            // Item Details - Condensed View
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      if (widget.item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(widget.item.badge!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.item.badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.item.price,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (widget.item.isNegotiable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Negotiable',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Basic Info (Always Visible)
                  _buildInfoRow(
                    Icons.category_outlined,
                    'Category',
                    widget.item.category,
                  ),
                  _buildInfoRow(
                    Icons.construction_outlined,
                    'Condition',
                    widget.item.condition,
                  ),

                  // Read More Section
                  if (!_showFullDetails) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFullDetails = true;
                          });
                        },
                        icon: Icon(
                          Icons.expand_more,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        label: Text(
                          'Read More',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Full Details (Hidden by default)
                  if (_showFullDetails) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Location',
                      widget.item.location,
                    ),
                    _buildInfoRow(
                      Icons.visibility_outlined,
                      'Views',
                      '$_currentViewCount',
                    ),
                    _buildInfoRow(
                      Icons.access_time_outlined,
                      'Posted',
                      widget.item.timePosted,
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Read Less Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFullDetails = false;
                          });
                        },
                        icon: Icon(
                          Icons.expand_less,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        label: Text(
                          'Read Less',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Seller Profile (Always visible)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SellerProfileCard(
                sellerName: widget.item.sellerName,
                sellerYear: widget.item.sellerYear,
                rating: 4.8,
                totalSales: 23,
                isVerified: true,
                onChatPressed: () {
                  // TODO: Navigate to chat
                },
                onCallPressed: () {
                  _makePhoneCall();
                },
              ),
            ),

            // Similar Items (Always visible)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SimilarItems(currentItem: widget.item),
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to chat
                  },
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Chat Seller'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _makePhoneCall();
                  },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call Seller'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
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

  Future<void> _makePhoneCall() async {
    final phoneNumber = widget.item.contactPhone;

    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available for this seller'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure the phone number starts with + or add country code if needed
    final formattedPhoneNumber =
        cleanPhoneNumber.startsWith('+')
            ? cleanPhoneNumber
            : '+256$cleanPhoneNumber'; // Default to Uganda country code

    final Uri phoneUri = Uri(scheme: 'tel', path: formattedPhoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Could not launch phone call');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not make phone call: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
