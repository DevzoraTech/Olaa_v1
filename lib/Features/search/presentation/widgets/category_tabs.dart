// Presentation Layer - Category Tabs Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.search},
      {'name': 'Hostels', 'icon': Icons.home},
      {'name': 'Roommates', 'icon': Icons.people},
      {'name': 'Events', 'icon': Icons.event},
      {'name': 'Clubs', 'icon': Icons.group},
      {'name': 'Marketplace', 'icon': Icons.shopping_cart},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
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
                right: index < categories.length - 1 ? 8 : 0,
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
