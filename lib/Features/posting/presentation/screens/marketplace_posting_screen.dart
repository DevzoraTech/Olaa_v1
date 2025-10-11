// Presentation Layer - Marketplace Posting Screen (Step-by-Step)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';
import 'step_by_step_marketplace_posting_screen.dart';

class MarketplacePostingScreen extends StatefulWidget {
  const MarketplacePostingScreen({super.key});

  @override
  State<MarketplacePostingScreen> createState() =>
      _MarketplacePostingScreenState();
}

class _MarketplacePostingScreenState extends State<MarketplacePostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = '';
  String _selectedCondition = '';
  String _selectedPaymentMethod = '';
  List<String> _selectedTags = [];
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  final List<String> _categoryOptions = [
    'Electronics',
    'Books',
    'Furniture',
    'Clothing',
    'Sports',
    'Other',
  ];

  final List<String> _conditionOptions = [
    'Excellent',
    'Very Good',
    'Good',
    'Fair',
    'Poor',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'UPI',
    'Card Payment',
  ];

  final List<String> _tagOptions = [
    'Negotiable',
    'Urgent',
    'Brand New',
    'Used',
    'Student Discount',
    'Bulk Available',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const StepByStepMarketplacePostingScreen();
  }
}
