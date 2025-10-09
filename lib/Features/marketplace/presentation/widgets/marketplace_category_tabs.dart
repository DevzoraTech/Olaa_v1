// Presentation Layer - Marketplace Category Tabs Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MarketplaceCategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const MarketplaceCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view_outlined, 'count': '156'},
      {'name': 'Books', 'icon': Icons.menu_book_outlined, 'count': '45'},
      {'name': 'Electronics', 'icon': Icons.laptop_outlined, 'count': '32'},
      {'name': 'Furniture', 'icon': Icons.chair_outlined, 'count': '28'},
      {'name': 'Clothes', 'icon': Icons.checkroom_outlined, 'count': '24'},
      {
        'name': 'Entertainment',
        'icon': Icons.headphones_outlined,
        'count': '18',
      },
      {'name': 'Services', 'icon': Icons.build_outlined, 'count': '9'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];

            return Padding(
              padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () => onCategoryChanged(category['name'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category['count'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
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
    );
  }
}
