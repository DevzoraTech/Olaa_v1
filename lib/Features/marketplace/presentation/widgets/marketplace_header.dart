// Presentation Layer - Marketplace Header Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MarketplaceHeader extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterPressed;
  final int? activeListingsCount;
  final int? newTodayCount;
  final int? underFiftyCount;

  const MarketplaceHeader({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
    this.activeListingsCount,
    this.newTodayCount,
    this.underFiftyCount,
  });

  @override
  State<MarketplaceHeader> createState() => _MarketplaceHeaderState();
}

class _MarketplaceHeaderState extends State<MarketplaceHeader> {
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused ? AppTheme.primaryColor : Colors.grey[200]!,
                width: _isFocused ? 2 : 1,
              ),
              boxShadow:
                  _isFocused
                      ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: _isFocused ? AppTheme.primaryColor : Colors.grey[500],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    onTap: () => setState(() => _isFocused = true),
                    onSubmitted: (_) => setState(() => _isFocused = false),
                    decoration: InputDecoration(
                      hintText: 'Search books, electronics, furniture...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                GestureDetector(
                  onTap: widget.onFilterPressed,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange[600]!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.orange[600],
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Stats
          Row(
            children: [
              _buildStatItem(
                icon: Icons.storefront_outlined,
                count: '${widget.activeListingsCount ?? 0}',
                label: 'Active Listings',
                color: Colors.blue[600]!,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.trending_up_outlined,
                count: '${widget.newTodayCount ?? 0}',
                label: 'New Today',
                color: Colors.green[600]!,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.local_offer_outlined,
                count: '${widget.underFiftyCount ?? 0}',
                label: 'Under \$50',
                color: Colors.orange[600]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}
