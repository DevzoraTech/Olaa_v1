// Rules & Policies Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelRulesStep extends StatefulWidget {
  final HostelRulesData data;
  final ValueChanged<HostelRulesData> onDataChanged;

  const HostelRulesStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HostelRulesStep> createState() => _HostelRulesStepState();
}

class _HostelRulesStepState extends State<HostelRulesStep> {
  late TextEditingController _additionalRulesController;
  late TextEditingController _visitorController;
  late TextEditingController _smokingController;
  late TextEditingController _petController;
  late TextEditingController _noiseController;
  late TextEditingController _cleaningController;

  // House Rules Options
  final List<String> _houseRulesOptions = [
    'No Smoking',
    'No Pets',
    'No Parties',
    'No Overnight Guests',
    'Quiet Hours (10 PM - 7 AM)',
    'Clean Common Areas',
    'Respect Privacy',
    'No Alcohol',
    'No Cooking After Hours',
    'Maintain Cleanliness',
    'No Loud Music',
    'No Gambling',
    'No Illegal Activities',
    'Follow COVID-19 Guidelines',
    'Report Maintenance Issues',
  ];

  @override
  void initState() {
    super.initState();
    _additionalRulesController = TextEditingController(
      text: widget.data.additionalRules,
    );
    _visitorController = TextEditingController(text: widget.data.visitorPolicy);
    _smokingController = TextEditingController(text: widget.data.smokingPolicy);
    _petController = TextEditingController(text: widget.data.petPolicy);
    _noiseController = TextEditingController(text: widget.data.noisePolicy);
    _cleaningController = TextEditingController(
      text: widget.data.cleaningPolicy,
    );

    _addListeners();
  }

  void _addListeners() {
    _additionalRulesController.addListener(_updateData);
    _visitorController.addListener(_updateData);
    _smokingController.addListener(_updateData);
    _petController.addListener(_updateData);
    _noiseController.addListener(_updateData);
    _cleaningController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        additionalRules: _additionalRulesController.text.trim(),
        visitorPolicy: _visitorController.text.trim(),
        smokingPolicy: _smokingController.text.trim(),
        petPolicy: _petController.text.trim(),
        noisePolicy: _noiseController.text.trim(),
        cleaningPolicy: _cleaningController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _additionalRulesController.dispose();
    _visitorController.dispose();
    _smokingController.dispose();
    _petController.dispose();
    _noiseController.dispose();
    _cleaningController.dispose();
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
          _buildHouseRulesSection(),
          const SizedBox(height: 24),
          _buildVisitorPolicySection(),
          const SizedBox(height: 24),
          _buildSmokingPolicySection(),
          const SizedBox(height: 24),
          _buildPetPolicySection(),
          const SizedBox(height: 24),
          _buildNoisePolicySection(),
          const SizedBox(height: 24),
          _buildCleaningPolicySection(),
          const SizedBox(height: 24),
          _buildAdditionalRulesSection(),
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
                Icons.rule_rounded,
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
                    'Rules & Policies',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set clear expectations for your tenants',
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

  Widget _buildHouseRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'House Rules *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the rules that apply to your hostel',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _houseRulesOptions.map((rule) {
                final isSelected = widget.data.houseRules.contains(rule);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final rules = List<String>.from(widget.data.houseRules);
                      if (isSelected) {
                        rules.remove(rule);
                      } else {
                        rules.add(rule);
                      }
                      widget.onDataChanged(
                        widget.data.copyWith(houseRules: rules),
                      );
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

  Widget _buildVisitorPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visitor Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What are your rules regarding visitors?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _visitorController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Visitors allowed during day hours only. Overnight guests require prior approval.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.people_outline_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildSmokingPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smoking Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What are your smoking rules?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _smokingController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Strictly no smoking inside the building. Designated smoking area outside.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.smoke_free_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildPetPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Are pets allowed?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _petController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'No pets allowed due to building regulations.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.pets_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildNoisePolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Noise Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What are your noise restrictions?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _noiseController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Quiet hours from 10 PM to 7 AM. Keep noise levels reasonable at all times.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.volume_off_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildCleaningPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cleaning Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What are your cleaning expectations?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cleaningController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Keep your room clean. Common areas cleaned weekly. Dispose of waste properly.',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.cleaning_services_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalRulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Rules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Any other specific rules or guidelines?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _additionalRulesController,
          maxLines: 3,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Additional rules or special instructions for tenants...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.notes_rounded,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(20),
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
              'Tip: Clear rules help maintain a peaceful environment. Be specific about expectations to avoid misunderstandings!',
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
