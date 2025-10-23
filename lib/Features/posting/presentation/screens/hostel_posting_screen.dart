// Presentation Layer - Hostel Listing Posting Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/services/supabase_auth_service.dart';

class HostelPostingScreen extends StatefulWidget {
  const HostelPostingScreen({super.key});

  @override
  State<HostelPostingScreen> createState() => _HostelPostingScreenState();
}

class _HostelPostingScreenState extends State<HostelPostingScreen>
    with TickerProviderStateMixin {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _contactController = TextEditingController();
  final _rulesController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  String _selectedRoomType = '';
  String _selectedGenderPreference = '';
  String _selectedFurnishing = '';
  String _selectedUtilities = '';
  List<String> _selectedAmenities = [];
  List<String> _selectedRules = [];

  // Data Lists
  final List<String> _roomTypes = [
    'Single Room',
    'Double Room',
    'Triple Room',
    'Quad Room',
    'Shared Room',
    'Studio',
    'Apartment',
  ];

  final List<String> _genderPreferences = [
    'Male Only',
    'Female Only',
    'Mixed Gender',
    'No Preference',
  ];

  final List<String> _furnishingOptions = [
    'Fully Furnished',
    'Semi Furnished',
    'Unfurnished',
  ];

  final List<String> _utilitiesOptions = ['Included', 'Separate', 'Shared'];

  final List<String> _amenityOptions = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Gym',
    'Study Room',
    'Common Area',
    'Balcony',
    'Garden',
    'Swimming Pool',
    'Cafeteria',
    'Library',
    'Recreation Room',
  ];

  final List<String> _ruleOptions = [
    'No Smoking',
    'No Pets',
    'No Parties',
    'No Overnight Guests',
    'Quiet Hours',
    'Clean Common Areas',
    'Respect Privacy',
    'No Alcohol',
    'No Cooking After Hours',
    'Maintain Cleanliness',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _addListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _addListeners() {
    final controllers = [
      _titleController,
      _descriptionController,
      _addressController,
      _priceController,
      _depositController,
      _contactController,
      _rulesController,
    ];

    for (var controller in controllers) {
      controller.addListener(() {
        if (!_hasUnsavedChanges) {
          setState(() {
            _hasUnsavedChanges = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _contactController.dispose();
    _rulesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        extendBodyBehindAppBar: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () async {
            if (_hasUnsavedChanges) {
              final shouldLeave = await _showUnsavedChangesDialog();
              if (shouldLeave) Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey[800],
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _hasUnsavedChanges
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextButton(
            onPressed: _isLoading ? null : _postHostelListing,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:
                _isLoading
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _hasUnsavedChanges
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                    )
                    : Text(
                      'Post',
                      style: TextStyle(
                        color:
                            _hasUnsavedChanges
                                ? Colors.white
                                : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor.withOpacity(0.6),
                AppTheme.secondaryColor.withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.home_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  'List Your Hostel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with students looking for accommodation 🏠',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildRoomDetailsSection(),
            const SizedBox(height: 20),
            _buildPricingSection(),
            const SizedBox(height: 20),
            _buildAmenitiesSection(),
            const SizedBox(height: 20),
            _buildRulesSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Hostel Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildPremiumTextField(
          controller: _titleController,
          label: 'Listing Title',
          prefixIcon: Icons.title_rounded,
          hintText: 'e.g., Cozy Single Room Near Campus',
          validator:
              (value) => value?.isEmpty == true ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _descriptionController,
          label: 'Description',
          prefixIcon: Icons.description_rounded,
          hintText:
              'Describe your hostel, its location, and what makes it special...',
          maxLines: 4,
          maxLength: 500,
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Description is required' : null,
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _addressController,
          label: 'Address',
          prefixIcon: Icons.location_on_rounded,
          hintText: 'Full address including landmarks',
          validator:
              (value) => value?.isEmpty == true ? 'Address is required' : null,
        ),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _contactController,
          label: 'Contact Information',
          prefixIcon: Icons.contact_phone_rounded,
          hintText: 'Phone number or WhatsApp',
          validator:
              (value) => value?.isEmpty == true ? 'Contact is required' : null,
        ),
      ],
    );
  }

  Widget _buildRoomDetailsSection() {
    return _buildSectionCard(
      title: 'Room Details',
      icon: Icons.bed_rounded,
      children: [
        _buildDropdownField(
          value: _selectedRoomType,
          label: 'Room Type',
          icon: Icons.home_work_rounded,
          items: _roomTypes,
          onChanged: (value) {
            setState(() {
              _selectedRoomType = value ?? '';
              _hasUnsavedChanges = true;
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                value: _selectedGenderPreference,
                label: 'Gender Preference',
                icon: Icons.person_rounded,
                items: _genderPreferences,
                onChanged: (value) {
                  setState(() {
                    _selectedGenderPreference = value ?? '';
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                value: _selectedFurnishing,
                label: 'Furnishing',
                icon: Icons.chair_rounded,
                items: _furnishingOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedFurnishing = value ?? '';
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedUtilities,
          label: 'Utilities',
          icon: Icons.electrical_services_rounded,
          items: _utilitiesOptions,
          onChanged: (value) {
            setState(() {
              _selectedUtilities = value ?? '';
              _hasUnsavedChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionCard(
      title: 'Pricing',
      icon: Icons.attach_money_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPremiumTextField(
                controller: _priceController,
                label: 'Monthly Rent',
                prefixIcon: Icons.monetization_on_rounded,
                hintText: '500',
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Price is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPremiumTextField(
                controller: _depositController,
                label: 'Security Deposit',
                prefixIcon: Icons.security_rounded,
                hintText: '200',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return _buildSectionCard(
      title: 'Amenities',
      icon: Icons.home_work_outlined,
      children: [_buildAmenitiesSelector()],
    );
  }

  Widget _buildRulesSection() {
    return _buildSectionCard(
      title: 'House Rules',
      icon: Icons.rule_rounded,
      children: [
        _buildRulesSelector(),
        const SizedBox(height: 20),
        _buildPremiumTextField(
          controller: _rulesController,
          label: 'Additional Rules',
          prefixIcon: Icons.notes_rounded,
          hintText: 'Any other specific rules or guidelines...',
          maxLines: 3,
        ),
      ],
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
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
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
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

  Widget _buildAmenitiesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home_work_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Available Amenities',
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
              _amenityOptions.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenity);
                      } else {
                        _selectedAmenities.add(amenity);
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
                    child: Text(
                      amenity,
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

  Widget _buildRulesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.rule_rounded, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'House Rules',
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
              _ruleOptions.map((rule) {
                final isSelected = _selectedRules.contains(rule);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSelected) {
                        _selectedRules.remove(rule);
                      } else {
                        _selectedRules.add(rule);
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
                      rule,
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

  Future<void> _postHostelListing() async {
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
        'type': 'hostel_listing',
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'contact': _contactController.text.trim(),
        'room_type': _selectedRoomType,
        'gender_preference': _selectedGenderPreference,
        'furnishing': _selectedFurnishing,
        'utilities': _selectedUtilities,
        'monthly_rent': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'security_deposit':
            double.tryParse(_depositController.text.trim()) ?? 0.0,
        'amenities': _selectedAmenities,
        'rules': _selectedRules,
        'additional_rules': _rulesController.text.trim(),
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      // TODO: Save to database
      print('DEBUG: Posting hostel listing: $postingData');

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Show success with haptic feedback
        HapticFeedback.heavyImpact();

        AppUtils.showSuccessSnackBar(
          context,
          'Hostel listing posted successfully! 🎉',
        );

        // Navigate back with result
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppUtils.showErrorSnackBar(
          context,
          'Failed to post hostel listing. Please try again.',
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









