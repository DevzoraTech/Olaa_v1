// Presentation Layer - Search Header Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SearchHeader extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onMicPressed;

  const SearchHeader({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onMicPressed,
  });

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Enhanced Search Bar
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused ? AppTheme.primaryColor : Colors.grey[300]!,
                width: _isFocused ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? AppTheme.primaryColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: _isFocused ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    onTap: () => setState(() => _isFocused = true),
                    onSubmitted: (_) => setState(() => _isFocused = false),
                    decoration: InputDecoration(
                      hintText: 'Search anything...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                // Voice Search Button
                _buildActionButton(
                  icon: Icons.mic_rounded,
                  onTap: widget.onMicPressed,
                  color: Colors.blue[600]!,
                  label: 'Voice',
                ),
                const SizedBox(width: 6),
                // Filter Button
                _buildActionButton(
                  icon: Icons.tune_rounded,
                  onTap: widget.onFilterPressed,
                  color: AppTheme.primaryColor,
                  label: 'Filter',
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Searches
          _buildRecentSearches(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      'Roommates under \$200',
      'Hostels near campus',
      'Tech events this week',
      'Study groups',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < recentSearches.length - 1 ? 10 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    _searchController.text = recentSearches[index];
                    widget.onSearchChanged(recentSearches[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          recentSearches[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
