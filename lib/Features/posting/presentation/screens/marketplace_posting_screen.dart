// Presentation Layer - Marketplace Posting Screen (Step-by-Step)
import 'package:flutter/material.dart';
import 'step_by_step_marketplace_posting_screen.dart';

class MarketplacePostingScreen extends StatelessWidget {
  const MarketplacePostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StepByStepMarketplacePostingScreen();
  }
}


        const SizedBox(height: 20),

        _buildDropdownField(

          value: _selectedCondition,

          label: 'Condition',

          icon: Icons.star_rounded,

          items: _conditionOptions,

          onChanged: (value) {

            setState(() {

              _selectedCondition = value ?? '';

              _hasUnsavedChanges = true;

            });

          },

        ),

      ],

    );

  }



  Widget _buildPricingSection() {

    return _buildSectionCard(

      title: 'Pricing & Payment',

      icon: Icons.attach_money_rounded,

      children: [

        _buildPremiumTextField(

          controller: _priceController,

          label: 'Price',

          prefixIcon: Icons.monetization_on_rounded,

          hintText: '500',

          keyboardType: TextInputType.number,

          validator:

              (value) => value?.isEmpty == true ? 'Price is required' : null,

        ),

        const SizedBox(height: 20),

        _buildDropdownField(

          value: _selectedPaymentMethod,

          label: 'Payment Method',

          icon: Icons.payment_rounded,

          items: _paymentMethods,

          onChanged: (value) {

            setState(() {

              _selectedPaymentMethod = value ?? '';

              _hasUnsavedChanges = true;

            });

          },

        ),

      ],

    );

  }



  Widget _buildTagsSection() {

    return _buildSectionCard(

      title: 'Tags & Features',

      icon: Icons.tag_rounded,

      children: [_buildTagsSelector()],

    );

  }



  Widget _buildSectionCard({

    required String title,

    required IconData icon,

    required List<Widget> children,

  }) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 15,

            offset: const Offset(0, 5),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(

                  color: AppTheme.secondaryColor.withOpacity(0.1),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Icon(icon, color: AppTheme.secondaryColor, size: 20),

              ),

              const SizedBox(width: 12),

              Text(

                title,

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.w600,

                  color: Colors.grey[800],

                ),

              ),

            ],

          ),

          const SizedBox(height: 24),

          ...children,

        ],

      ),

    );

  }



  Widget _buildPremiumTextField({

    required TextEditingController controller,

    required String label,

    String? hintText,

    IconData? prefixIcon,

    TextInputType? keyboardType,

    int maxLines = 1,

    int? maxLength,

    String? Function(String?)? validator,

  }) {

    return TextFormField(

      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      maxLength: maxLength,

      validator: validator,

      style: TextStyle(

        fontSize: 16,

        color: Colors.grey[800],

        fontWeight: FontWeight.w500,

      ),

      decoration: InputDecoration(

        labelText: label,

        hintText: hintText,

        prefixIcon:

            prefixIcon != null

                ? Padding(

                  padding: const EdgeInsets.only(left: 12, right: 8),

                  child: Icon(prefixIcon, color: Colors.grey[600], size: 20),

                )

                : null,

        labelStyle: TextStyle(

          color: Colors.grey[600],

          fontSize: 14,

          fontWeight: FontWeight.w500,

        ),

        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

        counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),

        ),

        errorBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),

        ),

        focusedErrorBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.red[400]!, width: 2),

        ),

        filled: true,

        fillColor: Colors.grey[50],

        contentPadding: const EdgeInsets.symmetric(

          horizontal: 20,

          vertical: 16,

        ),

      ),

    );

  }



  Widget _buildDropdownField({

    required String value,

    required String label,

    required IconData icon,

    required List<String> items,

    required ValueChanged<String?> onChanged,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.grey[50],

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey[200]!, width: 1.5),

      ),

      child: DropdownButtonFormField<String>(

        value: value.isEmpty ? null : value,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Padding(

            padding: const EdgeInsets.only(left: 12, right: 8),

            child: Icon(icon, color: Colors.grey[600], size: 20),

          ),

          labelStyle: TextStyle(

            color: Colors.grey[600],

            fontSize: 14,

            fontWeight: FontWeight.w500,

          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(

            horizontal: 20,

            vertical: 16,

          ),

        ),

        style: TextStyle(

          fontSize: 16,

          color: Colors.grey[800],

          fontWeight: FontWeight.w500,

        ),

        dropdownColor: Colors.white,

        borderRadius: BorderRadius.circular(12),

        items:

            items

                .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                .toList(),

        onChanged: onChanged,

      ),

    );

  }



  Widget _buildTagsSelector() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Icon(Icons.tag_rounded, color: Colors.grey[600], size: 20),

            const SizedBox(width: 8),

            Text(

              'Tags',

              style: TextStyle(

                fontSize: 16,

                fontWeight: FontWeight.w600,

                color: Colors.grey[700],

              ),

            ),

          ],

        ),

        const SizedBox(height: 12),

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children:

              _tagOptions.map((tag) {

                final isSelected = _selectedTags.contains(tag);

                return GestureDetector(

                  onTap: () {

                    HapticFeedback.lightImpact();

                    setState(() {

                      if (isSelected) {

                        _selectedTags.remove(tag);

                      } else {

                        _selectedTags.add(tag);

                      }

                      _hasUnsavedChanges = true;

                    });

                  },

                  child: AnimatedContainer(

                    duration: const Duration(milliseconds: 200),

                    padding: const EdgeInsets.symmetric(

                      horizontal: 16,

                      vertical: 8,

                    ),

                    decoration: BoxDecoration(

                      color:

                          isSelected

                              ? AppTheme.secondaryColor

                              : Colors.grey[100],

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(

                        color:

                            isSelected

                                ? AppTheme.secondaryColor

                                : Colors.grey[300]!,

                        width: 1,

                      ),

                    ),

                    child: Text(

                      tag,

                      style: TextStyle(

                        color: isSelected ? Colors.white : Colors.grey[700],

                        fontSize: 14,

                        fontWeight: FontWeight.w500,

                      ),

                    ),

                  ),

                );

              }).toList(),

        ),

      ],

    );

  }



  Future<bool> _showUnsavedChangesDialog() async {

    return await showDialog<bool>(

          context: context,

          builder:

              (context) => AlertDialog(

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(20),

                ),

                title: Row(

                  children: [

                    Container(

                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(

                        color: Colors.orange[50],

                        shape: BoxShape.circle,

                      ),

                      child: Icon(

                        Icons.warning_amber_rounded,

                        color: Colors.orange[600],

                      ),

                    ),

                    const SizedBox(width: 12),

                    const Text('Unsaved Changes'),

                  ],

                ),

                content: const Text(

                  'You have unsaved changes. Are you sure you want to leave without saving?',

                ),

                actions: [

                  TextButton(

                    onPressed: () => Navigator.pop(context, false),

                    child: Text(

                      'Stay',

                      style: TextStyle(color: Colors.grey[600]),

                    ),

                  ),

                  TextButton(

                    onPressed: () => Navigator.pop(context, true),

                    style: TextButton.styleFrom(

                      backgroundColor: Colors.red,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(8),

                      ),

                    ),

                    child: const Text('Leave'),

                  ),

                ],

              ),

        ) ??

        false;

  }



  Future<void> _postMarketplaceItem() async {

    if (!_formKey.currentState!.validate()) {

      AppUtils.showErrorSnackBar(

        context,

        'Please fill in all required fields correctly.',

      );

      return;

    }



    setState(() {

      _isLoading = true;

    });



    try {

      final user = _authService.currentUser;

      if (user == null) {

        throw Exception('User not logged in');

      }



      // Prepare posting data

      final postingData = <String, dynamic>{

        'user_id': user.id,

        'type': 'marketplace_item',

        'title': _titleController.text.trim(),

        'description': _descriptionController.text.trim(),

        'category': _selectedCategory,

        'brand': _brandController.text.trim(),

        'model': _modelController.text.trim(),

        'condition': _selectedCondition,

        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,

        'payment_method': _selectedPaymentMethod,

        'tags': _selectedTags,

        'status': 'active',

        'created_at': DateTime.now().toIso8601String(),

      };



      // TODO: Save to database

      print('DEBUG: Posting marketplace item: $postingData');



      if (mounted) {

        setState(() {

          _hasUnsavedChanges = false;

        });



        // Show success with haptic feedback

        HapticFeedback.heavyImpact();



        AppUtils.showSuccessSnackBar(context, 'Item posted successfully! 🎉');



        // Navigate back with result

        Navigator.pop(context, true);

      }

    } catch (e) {

      if (mounted) {

        HapticFeedback.heavyImpact();

        AppUtils.showErrorSnackBar(

          context,

          'Failed to post item. Please try again.',

        );

      }

    } finally {

      if (mounted) {

        setState(() {

          _isLoading = false;

        });

      }

    }

  }

}




        const SizedBox(height: 20),

        _buildDropdownField(

          value: _selectedCondition,

          label: 'Condition',

          icon: Icons.star_rounded,

          items: _conditionOptions,

          onChanged: (value) {

            setState(() {

              _selectedCondition = value ?? '';

              _hasUnsavedChanges = true;

            });

          },

        ),

      ],

    );

  }



  Widget _buildPricingSection() {

    return _buildSectionCard(

      title: 'Pricing & Payment',

      icon: Icons.attach_money_rounded,

      children: [

        _buildPremiumTextField(

          controller: _priceController,

          label: 'Price',

          prefixIcon: Icons.monetization_on_rounded,

          hintText: '500',

          keyboardType: TextInputType.number,

          validator:

              (value) => value?.isEmpty == true ? 'Price is required' : null,

        ),

        const SizedBox(height: 20),

        _buildDropdownField(

          value: _selectedPaymentMethod,

          label: 'Payment Method',

          icon: Icons.payment_rounded,

          items: _paymentMethods,

          onChanged: (value) {

            setState(() {

              _selectedPaymentMethod = value ?? '';

              _hasUnsavedChanges = true;

            });

          },

        ),

      ],

    );

  }



  Widget _buildTagsSection() {

    return _buildSectionCard(

      title: 'Tags & Features',

      icon: Icons.tag_rounded,

      children: [_buildTagsSelector()],

    );

  }



  Widget _buildSectionCard({

    required String title,

    required IconData icon,

    required List<Widget> children,

  }) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 15,

            offset: const Offset(0, 5),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(

                  color: AppTheme.secondaryColor.withOpacity(0.1),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Icon(icon, color: AppTheme.secondaryColor, size: 20),

              ),

              const SizedBox(width: 12),

              Text(

                title,

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.w600,

                  color: Colors.grey[800],

                ),

              ),

            ],

          ),

          const SizedBox(height: 24),

          ...children,

        ],

      ),

    );

  }



  Widget _buildPremiumTextField({

    required TextEditingController controller,

    required String label,

    String? hintText,

    IconData? prefixIcon,

    TextInputType? keyboardType,

    int maxLines = 1,

    int? maxLength,

    String? Function(String?)? validator,

  }) {

    return TextFormField(

      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      maxLength: maxLength,

      validator: validator,

      style: TextStyle(

        fontSize: 16,

        color: Colors.grey[800],

        fontWeight: FontWeight.w500,

      ),

      decoration: InputDecoration(

        labelText: label,

        hintText: hintText,

        prefixIcon:

            prefixIcon != null

                ? Padding(

                  padding: const EdgeInsets.only(left: 12, right: 8),

                  child: Icon(prefixIcon, color: Colors.grey[600], size: 20),

                )

                : null,

        labelStyle: TextStyle(

          color: Colors.grey[600],

          fontSize: 14,

          fontWeight: FontWeight.w500,

        ),

        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

        counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: AppTheme.secondaryColor, width: 2),

        ),

        errorBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),

        ),

        focusedErrorBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.red[400]!, width: 2),

        ),

        filled: true,

        fillColor: Colors.grey[50],

        contentPadding: const EdgeInsets.symmetric(

          horizontal: 20,

          vertical: 16,

        ),

      ),

    );

  }



  Widget _buildDropdownField({

    required String value,

    required String label,

    required IconData icon,

    required List<String> items,

    required ValueChanged<String?> onChanged,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.grey[50],

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey[200]!, width: 1.5),

      ),

      child: DropdownButtonFormField<String>(

        value: value.isEmpty ? null : value,

        decoration: InputDecoration(

          labelText: label,

          prefixIcon: Padding(

            padding: const EdgeInsets.only(left: 12, right: 8),

            child: Icon(icon, color: Colors.grey[600], size: 20),

          ),

          labelStyle: TextStyle(

            color: Colors.grey[600],

            fontSize: 14,

            fontWeight: FontWeight.w500,

          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(

            horizontal: 20,

            vertical: 16,

          ),

        ),

        style: TextStyle(

          fontSize: 16,

          color: Colors.grey[800],

          fontWeight: FontWeight.w500,

        ),

        dropdownColor: Colors.white,

        borderRadius: BorderRadius.circular(12),

        items:

            items

                .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                .toList(),

        onChanged: onChanged,

      ),

    );

  }



  Widget _buildTagsSelector() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Icon(Icons.tag_rounded, color: Colors.grey[600], size: 20),

            const SizedBox(width: 8),

            Text(

              'Tags',

              style: TextStyle(

                fontSize: 16,

                fontWeight: FontWeight.w600,

                color: Colors.grey[700],

              ),

            ),

          ],

        ),

        const SizedBox(height: 12),

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children:

              _tagOptions.map((tag) {

                final isSelected = _selectedTags.contains(tag);

                return GestureDetector(

                  onTap: () {

                    HapticFeedback.lightImpact();

                    setState(() {

                      if (isSelected) {

                        _selectedTags.remove(tag);

                      } else {

                        _selectedTags.add(tag);

                      }

                      _hasUnsavedChanges = true;

                    });

                  },

                  child: AnimatedContainer(

                    duration: const Duration(milliseconds: 200),

                    padding: const EdgeInsets.symmetric(

                      horizontal: 16,

                      vertical: 8,

                    ),

                    decoration: BoxDecoration(

                      color:

                          isSelected

                              ? AppTheme.secondaryColor

                              : Colors.grey[100],

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(

                        color:

                            isSelected

                                ? AppTheme.secondaryColor

                                : Colors.grey[300]!,

                        width: 1,

                      ),

                    ),

                    child: Text(

                      tag,

                      style: TextStyle(

                        color: isSelected ? Colors.white : Colors.grey[700],

                        fontSize: 14,

                        fontWeight: FontWeight.w500,

                      ),

                    ),

                  ),

                );

              }).toList(),

        ),

      ],

    );

  }



  Future<bool> _showUnsavedChangesDialog() async {

    return await showDialog<bool>(

          context: context,

          builder:

              (context) => AlertDialog(

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(20),

                ),

                title: Row(

                  children: [

                    Container(

                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(

                        color: Colors.orange[50],

                        shape: BoxShape.circle,

                      ),

                      child: Icon(

                        Icons.warning_amber_rounded,

                        color: Colors.orange[600],

                      ),

                    ),

                    const SizedBox(width: 12),

                    const Text('Unsaved Changes'),

                  ],

                ),

                content: const Text(

                  'You have unsaved changes. Are you sure you want to leave without saving?',

                ),

                actions: [

                  TextButton(

                    onPressed: () => Navigator.pop(context, false),

                    child: Text(

                      'Stay',

                      style: TextStyle(color: Colors.grey[600]),

                    ),

                  ),

                  TextButton(

                    onPressed: () => Navigator.pop(context, true),

                    style: TextButton.styleFrom(

                      backgroundColor: Colors.red,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(8),

                      ),

                    ),

                    child: const Text('Leave'),

                  ),

                ],

              ),

        ) ??

        false;

  }



  Future<void> _postMarketplaceItem() async {

    if (!_formKey.currentState!.validate()) {

      AppUtils.showErrorSnackBar(

        context,

        'Please fill in all required fields correctly.',

      );

      return;

    }



    setState(() {

      _isLoading = true;

    });



    try {

      final user = _authService.currentUser;

      if (user == null) {

        throw Exception('User not logged in');

      }



      // Prepare posting data

      final postingData = <String, dynamic>{

        'user_id': user.id,

        'type': 'marketplace_item',

        'title': _titleController.text.trim(),

        'description': _descriptionController.text.trim(),

        'category': _selectedCategory,

        'brand': _brandController.text.trim(),

        'model': _modelController.text.trim(),

        'condition': _selectedCondition,

        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,

        'payment_method': _selectedPaymentMethod,

        'tags': _selectedTags,

        'status': 'active',

        'created_at': DateTime.now().toIso8601String(),

      };



      // TODO: Save to database

      print('DEBUG: Posting marketplace item: $postingData');



      if (mounted) {

        setState(() {

          _hasUnsavedChanges = false;

        });



        // Show success with haptic feedback

        HapticFeedback.heavyImpact();



        AppUtils.showSuccessSnackBar(context, 'Item posted successfully! 🎉');



        // Navigate back with result

        Navigator.pop(context, true);

      }

    } catch (e) {

      if (mounted) {

        HapticFeedback.heavyImpact();

        AppUtils.showErrorSnackBar(

          context,

          'Failed to post item. Please try again.',

        );

      }

    } finally {

      if (mounted) {

        setState(() {

          _isLoading = false;

        });

      }

    }

  }

}




