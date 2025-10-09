// Products Manager Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/supabase_database_service.dart';
import '../../../../../core/services/supabase_auth_service.dart';
import '../listing_cards/product_card.dart';
import '../empty_states/products_empty_state.dart';

class ProductsManager extends StatefulWidget {
  final String filter;

  const ProductsManager({super.key, required this.filter});

  @override
  State<ProductsManager> createState() => _ProductsManagerState();
}

class _ProductsManagerState extends State<ProductsManager> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(ProductsManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current user ID
      final userId = SupabaseAuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user's marketplace items from Supabase
      final products = await SupabaseDatabaseService.instance
          .getUserMarketplaceItems(userId);

      // Apply filter if needed
      List<Map<String, dynamic>> filteredProducts = products;
      if (widget.filter != 'All') {
        filteredProducts =
            products.where((product) {
              final status =
                  product['status']?.toString().toLowerCase() ?? 'active';
              return status == widget.filter.toLowerCase();
            }).toList();
      }

      if (!mounted) return;
      setState(() {
        _products = filteredProducts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load products: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return ProductsEmptyState(onAddNew: _onAddNew);
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onEdit: () => _onEditProduct(product),
          onToggleVisibility: () => _onToggleVisibility(product),
          onDelete: () => _onDeleteProduct(product),
          onViewInsights: () => _onViewInsights(product),
        );
      },
    );
  }

  void _onAddNew() {
    // TODO: Navigate to add product screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to Add Product')));
  }

  void _onEditProduct(Map<String, dynamic> product) {
    // TODO: Navigate to edit product screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${product['title']}')));
  }

  void _onToggleVisibility(Map<String, dynamic> product) {
    // TODO: Toggle product visibility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Toggle visibility for ${product['title']}')),
    );
  }

  void _onDeleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text(
              'Are you sure you want to delete "${product['title']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Delete product
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${product['title']}')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _onViewInsights(Map<String, dynamic> product) {
    // TODO: Navigate to insights screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View insights for ${product['title']}')),
    );
  }
}
