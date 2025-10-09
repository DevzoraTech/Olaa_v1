// Basic Info Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelBasicInfoStep extends StatefulWidget {
  final HostelBasicInfoData data;
  final ValueChanged<HostelBasicInfoData> onDataChanged;

  const HostelBasicInfoStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HostelBasicInfoStep> createState() => _HostelBasicInfoStepState();
}

class _HostelBasicInfoStepState extends State<HostelBasicInfoStep> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _campusController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _descriptionController = TextEditingController(
      text: widget.data.description,
    );
    _addressController = TextEditingController(text: widget.data.address);
    _contactController = TextEditingController(text: widget.data.contactInfo);
    _campusController = TextEditingController(text: widget.data.campus);

    _addListeners();
  }

  void _addListeners() {
    _titleController.addListener(_updateData);
    _descriptionController.addListener(_updateData);
    _addressController.addListener(_updateData);
    _contactController.addListener(_updateData);
    _campusController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        contactInfo: _contactController.text.trim(),
        campus: _campusController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildTitleSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildAddressSection(),
          const SizedBox(height: 24),
          _buildCampusSection(),
          const SizedBox(height: 24),
          _buildContactSection(),
          const SizedBox(height: 32),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hostel Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell students about your hostel and how to reach you',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listing Title *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an attractive title that highlights your hostel\'s best features',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.trim().length < 10) {
              return 'Title must be at least 10 characters';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Cozy Single Room Near Campus - WiFi & AC Included',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.title_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your hostel, its location, and what makes it special',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            if (value.trim().length < 50) {
              return 'Description must be at least 50 characters';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Our hostel offers comfortable accommodation just 5 minutes walk from campus. Features include high-speed WiFi, air conditioning, shared kitchen, and 24/7 security. Perfect for students who want convenience and safety...',
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide the complete address including landmarks for easy location',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Address is required';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '123 University Road, Near Main Gate, Kampala, Uganda',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildCampusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campus *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Which campus is this hostel closest to?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _campusController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campus is required';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Main Campus, Nakawa Campus, etc.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.school_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
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
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How can interested students reach you?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contactController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Contact information is required';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '+256 700 123 456 or WhatsApp',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.contact_phone_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
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
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Be specific about location landmarks and include your best contact method. Students appreciate clear communication!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


            if (value == null || value.trim().isEmpty) {

              return 'Description is required';

            }

            if (value.trim().length < 50) {

              return 'Description must be at least 50 characters';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: 'Our hostel offers comfortable accommodation just 5 minutes walk from campus. Features include high-speed WiFi, air conditioning, shared kitchen, and 24/7 security. Perfect for students who want convenience and safety...',

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildAddressSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Address *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'Provide the complete address including landmarks for easy location',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _addressController,

          maxLines: 2,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Address is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '123 University Road, Near Main Gate, Kampala, Uganda',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.location_on_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildContactSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Contact Information *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'How can interested students reach you?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _contactController,

          keyboardType: TextInputType.phone,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Contact information is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '+256 700 123 456 or WhatsApp',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.contact_phone_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

        ),

      ],

    );

  }



  Widget _buildTipsSection() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: AppTheme.primaryColor.withOpacity(0.05),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppTheme.primaryColor.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        children: [

          Icon(

            Icons.lightbulb_outline_rounded,

            color: AppTheme.primaryColor,

            size: 20,

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Text(

              'Tip: Be specific about location landmarks and include your best contact method. Students appreciate clear communication!',

              style: TextStyle(

                fontSize: 14,

                color: Colors.grey[700],

                fontWeight: FontWeight.w500,

              ),

            ),

          ),

        ],

      ),

    );

  }

}




            if (value == null || value.trim().isEmpty) {

              return 'Description is required';

            }

            if (value.trim().length < 50) {

              return 'Description must be at least 50 characters';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: 'Our hostel offers comfortable accommodation just 5 minutes walk from campus. Features include high-speed WiFi, air conditioning, shared kitchen, and 24/7 security. Perfect for students who want convenience and safety...',

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildAddressSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Address *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'Provide the complete address including landmarks for easy location',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _addressController,

          maxLines: 2,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Address is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '123 University Road, Near Main Gate, Kampala, Uganda',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.location_on_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildContactSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Contact Information *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'How can interested students reach you?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _contactController,

          keyboardType: TextInputType.phone,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Contact information is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '+256 700 123 456 or WhatsApp',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.contact_phone_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

        ),

      ],

    );

  }



  Widget _buildTipsSection() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: AppTheme.primaryColor.withOpacity(0.05),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppTheme.primaryColor.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        children: [

          Icon(

            Icons.lightbulb_outline_rounded,

            color: AppTheme.primaryColor,

            size: 20,

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Text(

              'Tip: Be specific about location landmarks and include your best contact method. Students appreciate clear communication!',

              style: TextStyle(

                fontSize: 14,

                color: Colors.grey[700],

                fontWeight: FontWeight.w500,

              ),

            ),

          ),

        ],

      ),

    );

  }

}




            if (value == null || value.trim().isEmpty) {

              return 'Description is required';

            }

            if (value.trim().length < 50) {

              return 'Description must be at least 50 characters';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: 'Our hostel offers comfortable accommodation just 5 minutes walk from campus. Features include high-speed WiFi, air conditioning, shared kitchen, and 24/7 security. Perfect for students who want convenience and safety...',

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildAddressSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Address *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'Provide the complete address including landmarks for easy location',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _addressController,

          maxLines: 2,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Address is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '123 University Road, Near Main Gate, Kampala, Uganda',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.location_on_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

            contentPadding: const EdgeInsets.all(20),

          ),

        ),

      ],

    );

  }



  Widget _buildContactSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Contact Information *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'How can interested students reach you?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _contactController,

          keyboardType: TextInputType.phone,

          validator: (value) {

            if (value == null || value.trim().isEmpty) {

              return 'Contact information is required';

            }

            return null;

          },

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: '+256 700 123 456 or WhatsApp',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.contact_phone_rounded,

                color: Colors.grey[600],

                size: 20,

              ),

            ),

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

        ),

      ],

    );

  }



  Widget _buildTipsSection() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: AppTheme.primaryColor.withOpacity(0.05),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: AppTheme.primaryColor.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        children: [

          Icon(

            Icons.lightbulb_outline_rounded,

            color: AppTheme.primaryColor,

            size: 20,

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Text(

              'Tip: Be specific about location landmarks and include your best contact method. Students appreciate clear communication!',

              style: TextStyle(

                fontSize: 14,

                color: Colors.grey[700],

                fontWeight: FontWeight.w500,

              ),

            ),

          ),

        ],

      ),

    );

  }

}


