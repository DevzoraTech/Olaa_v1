// Presentation Layer - Search Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/search_header.dart';
import '../widgets/category_tabs.dart';
import '../widgets/smart_suggestions.dart';
import '../widgets/search_results.dart';
import '../widgets/advanced_filters.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showFilters = false;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Find anything on campus',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          SearchHeader(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
                _isSearching = query.isNotEmpty;
              });
            },
            onFilterPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            onMicPressed: () {
              // TODO: Implement voice search
            },
          ),

          // Category Tabs
          CategoryTabs(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          // Content Area
          Expanded(
            child:
                _isSearching
                    ? SearchResults(
                      query: _searchQuery,
                      category: _selectedCategory,
                    )
                    : SmartSuggestions(category: _selectedCategory),
          ),

          // Advanced Filters Modal
          if (_showFilters)
            AdvancedFilters(
              category: _selectedCategory,
              onClose: () {
                setState(() {
                  _showFilters = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
