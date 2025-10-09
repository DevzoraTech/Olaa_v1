// Presentation Layer - Marketplace List Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../widgets/marketplace_header.dart';
import '../widgets/marketplace_category_tabs.dart';
import '../widgets/featured_listings.dart';
import '../widgets/marketplace_listings.dart';
import 'marketplace_detail_screen.dart';
import '../../../posting/presentation/screens/step_by_step_marketplace_posting_screen.dart';
import '../../../management/presentation/widgets/management_fab.dart';

class MarketplaceListScreen extends StatefulWidget {
  const MarketplaceListScreen({super.key});

  @override
  State<MarketplaceListScreen> createState() => _MarketplaceListScreenState();
}

class _MarketplaceListScreenState extends State<MarketplaceListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Most Recent';
  int _activeListingsCount = 0;
  int _newTodayCount = 0;
  int _underFiftyCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadMarketplaceStats();
  }

  Future<void> _loadMarketplaceStats() async {
    try {
      final databaseService = SupabaseDatabaseService.instance;

      // Load all marketplace items
      final allItems = await databaseService.getMarketplaceItems();

      // Calculate stats
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final activeCount = allItems.length;
      final newTodayCount =
          allItems.where((item) {
            final createdAt = DateTime.parse(item['created_at'] ?? '');
            return createdAt.isAfter(todayStart);
          }).length;
      final underFiftyCount =
          allItems.where((item) {
            final price =
                double.tryParse(item['price']?.toString() ?? '0') ?? 0;
            return price < 50;
          }).length;

      if (mounted) {
        setState(() {
          _activeListingsCount = activeCount;
          _newTodayCount = newTodayCount;
          _underFiftyCount = underFiftyCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading marketplace stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
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
        title: const Text(
          'Marketplace',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter functionality
            },
            icon: Icon(Icons.tune_rounded, color: Colors.grey[600], size: 22),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const StepByStepMarketplacePostingScreen(),
                ),
              );
            },
            icon: Icon(Icons.add_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Marketplace Header with Search
              MarketplaceHeader(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onFilterPressed: () {
                  // TODO: Show filter modal
                },
                activeListingsCount: _isLoadingStats ? null : _activeListingsCount,
                newTodayCount: _isLoadingStats ? null : _newTodayCount,
                underFiftyCount: _isLoadingStats ? null : _underFiftyCount,
              ),

              // Category Tabs
              MarketplaceCategoryTabs(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              // Scrollable Content with Featured Listings and Main Listings
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Featured Listings
                      const FeaturedListings(),

                      // Main Listings Feed
                      MarketplaceListings(
                        category: _selectedCategory,
                        searchQuery: _searchQuery,
                        sortBy: _sortBy,
                        onItemTap: (item) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MarketplaceDetailScreen(item: item),
                            ),
                          );
                        },
                        onSortChanged: (sort) {
                          setState(() {
                            _sortBy = sort;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Management FAB positioned above the marketplace FAB
          const ManagementFAB(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StepByStepMarketplacePostingScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
