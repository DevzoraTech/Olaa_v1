import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HostelProviderSetupScreen extends StatefulWidget {
  const HostelProviderSetupScreen({super.key});

  @override
  State<HostelProviderSetupScreen> createState() =>
      _HostelProviderSetupScreenState();
}

class _HostelProviderSetupScreenState extends State<HostelProviderSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _businessNameFocusNode = FocusNode();
  final _contactPersonFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  bool _isLoading = false;
  int _currentStep = 0;
  String _selectedBusinessType = 'hostel';
  List<String> _selectedAmenities = [];
  String _selectedLocation = '';

  final List<String> _businessTypes = [
    'hostel',
    'apartment',
    'guesthouse',
    'student_residence',
    'boarding_house',
  ];

  final List<String> _amenities = [
    'WiFi',
    'Air Conditioning',
    'Hot Water',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Cleaning Service',
    'Study Room',
    'Common Area',
    'Gym',
    'Swimming Pool',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _businessNameFocusNode.dispose();
    _contactPersonFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _handleSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate setup process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // TODO: Implement actual setup logic with Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hostel provider setup completed successfully!'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate to hostel provider dashboard
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    // TODO: Navigate to hostel provider dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Welcome to your Hostel Provider Dashboard!'),
        backgroundColor: Colors.indigo[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Setup Your Business',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Form Content
              _buildFormContent(),
              const SizedBox(height: 32),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 0 ? Colors.indigo[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 1 ? Colors.indigo[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 2 ? Colors.indigo[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    List<String> titles = [
      'Business Information',
      'Location & Contact',
      'Amenities & Description',
    ];

    List<String> subtitles = [
      'Tell us about your business',
      'Where can students find you?',
      'What makes your place special?',
    ];

    return Column(
      children: [
        Text(
          titles[_currentStep],
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitles[_currentStep],
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep == 0) _buildBusinessInfoForm(),
            if (_currentStep == 1) _buildLocationContactForm(),
            if (_currentStep == 2) _buildAmenitiesDescriptionForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoForm() {
    return Column(
      children: [
        // Business Type Selection
        _buildBusinessTypeSelection(),
        const SizedBox(height: 24),

        // Business Name
        _buildTextField(
          controller: _businessNameController,
          focusNode: _businessNameFocusNode,
          label: 'Business Name',
          hint: 'Enter your business name',
          icon: Icons.business_rounded,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _contactPersonFocusNode.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your business name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Contact Person
        _buildTextField(
          controller: _contactPersonController,
          focusNode: _contactPersonFocusNode,
          label: 'Contact Person',
          hint: 'Enter contact person name',
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter contact person name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Type',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _businessTypes.map((type) {
                final isSelected = _selectedBusinessType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBusinessType = type;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo[50] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.indigo[400]!
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      _getBusinessTypeLabel(type),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.indigo[700] : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _getBusinessTypeLabel(String type) {
    switch (type) {
      case 'hostel':
        return 'Hostel';
      case 'apartment':
        return 'Apartment';
      case 'guesthouse':
        return 'Guest House';
      case 'student_residence':
        return 'Student Residence';
      case 'boarding_house':
        return 'Boarding House';
      default:
        return type;
    }
  }

  Widget _buildLocationContactForm() {
    return Column(
      children: [
        // Phone Number
        _buildTextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          label: 'Email Address',
          hint: 'Enter your email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _addressFocusNode.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Address
        _buildTextField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          label: 'Business Address',
          hint: 'Enter your business address',
          icon: Icons.location_on_outlined,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your business address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesDescriptionForm() {
    return Column(
      children: [
        // Amenities Selection
        _buildAmenitiesSelection(),
        const SizedBox(height: 24),

        // Description
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildAmenitiesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select amenities available at your property',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _amenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenity);
                      } else {
                        _selectedAmenities.add(amenity);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo[600] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.indigo[600]!
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Icon(Icons.check, size: 16, color: Colors.white),
                        if (isSelected) const SizedBox(width: 4),
                        Text(
                          amenity,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Description',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Describe your business, what makes it special...',
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[400]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[800]),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            if (value.length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[400]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[800]),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Previous',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _handleSetup : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        _currentStep == 2 ? 'Complete Setup' : 'Next',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
