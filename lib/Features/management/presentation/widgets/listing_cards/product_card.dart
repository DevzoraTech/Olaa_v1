// Product Card Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDelete;
  final VoidCallback onViewInsights;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onViewInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Image and Status Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child:
                      product['image_url'] != null
                          ? Image.network(
                            product['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              );
                            },
                          )
                          : Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(product['status']),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  product['title'] ?? 'Untitled Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  _formatCurrency(
                    product['price']?.toDouble() ?? 0,
                    currency: product['currency'] ?? 'UGX',
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.visibility_outlined,
                      '${product['views_count'] ?? 0} views',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.chat_bubble_outline_rounded,
                      '${product['chats_count'] ?? 0} chats',
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(product['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Edit',
                        Icons.edit_rounded,
                        AppTheme.primaryColor,
                        onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Hide',
                        Icons.visibility_off_rounded,
                        Colors.orange[600]!,
                        onToggleVisibility,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Insights',
                        Icons.analytics_outlined,
                        Colors.blue[600]!,
                        onViewInsights,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.delete_outline_rounded,
                      Colors.red[600]!,
                      onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value, {String currency = 'UGX'}) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final DateTime dateTime =
          date is DateTime ? date : DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildStatusBadge(String? status) {
    final statusText = status ?? 'Unknown';
    Color badgeColor;
    switch (statusText.toLowerCase()) {
      case 'active':
        badgeColor = Colors.green[600]!;
        break;
      case 'hidden':
        badgeColor = Colors.orange[600]!;
        break;
      case 'sold':
        badgeColor = Colors.blue[600]!;
        break;
      default:
        badgeColor = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
