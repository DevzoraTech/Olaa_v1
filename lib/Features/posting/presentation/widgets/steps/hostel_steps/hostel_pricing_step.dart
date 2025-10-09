// Pricing & Terms Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelPricingStep extends StatefulWidget {
  final HostelPricingData data;
  final ValueChanged<HostelPricingData> onDataChanged;

  const HostelPricingStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HostelPricingStep> createState() => _HostelPricingStepState();
}

class _HostelPricingStepState extends State<HostelPricingStep> {
  late TextEditingController _monthlyRentController;
  late TextEditingController _securityDepositController;
  late TextEditingController _utilitiesCostController;
  late TextEditingController _moveInDateController;

  // Data Lists
  final List<String> _currencies = ['UGX', 'USD', 'EUR', 'GBP'];

  final List<String> _paymentSchedules = [
    'Monthly',
    'Quarterly',
    'Semester',
    'Yearly',
  ];

  final List<String> _leaseDurations = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _monthlyRentController = TextEditingController(
      text:
          widget.data.monthlyRent > 0 ? widget.data.monthlyRent.toString() : '',
    );
    _securityDepositController = TextEditingController(
      text:
          widget.data.securityDeposit > 0
              ? widget.data.securityDeposit.toString()
              : '',
    );
    _utilitiesCostController = TextEditingController(
      text:
          widget.data.utilitiesCost > 0
              ? widget.data.utilitiesCost.toString()
              : '',
    );
    _moveInDateController = TextEditingController(text: widget.data.moveInDate);

    _addListeners();
  }

  void _addListeners() {
    _monthlyRentController.addListener(_updateData);
    _securityDepositController.addListener(_updateData);
    _utilitiesCostController.addListener(_updateData);
    _moveInDateController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        monthlyRent: double.tryParse(_monthlyRentController.text) ?? 0.0,
        securityDeposit:
            double.tryParse(_securityDepositController.text) ?? 0.0,
        utilitiesCost: double.tryParse(_utilitiesCostController.text) ?? 0.0,
        moveInDate: _moveInDateController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _monthlyRentController.dispose();
    _securityDepositController.dispose();
    _utilitiesCostController.dispose();
    _moveInDateController.dispose();
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
          _buildRentSection(),
          const SizedBox(height: 24),
          _buildDepositSection(),
          const SizedBox(height: 24),
          _buildUtilitiesSection(),
          const SizedBox(height: 24),
          _buildPaymentSection(),
          const SizedBox(height: 24),
          _buildLeaseSection(),
          const SizedBox(height: 24),
          _buildMoveInSection(),
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
                Icons.attach_money_rounded,
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
                    'Pricing & Terms',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set your rental rates and payment terms',
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

  Widget _buildRentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Rent *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What is the monthly rental amount?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _monthlyRentController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Monthly rent is required';
                  }
                  final rent = double.tryParse(value);
                  if (rent == null || rent <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '500000',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.monetization_on_rounded,
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
                    borderSide: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdownField(
                value: widget.data.currency,
                items: _currencies,
                onChanged: (value) {
                  widget.onDataChanged(
                    widget.data.copyWith(currency: value ?? 'UGX'),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepositSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Deposit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How much security deposit do you require? (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _securityDepositController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '100000',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.security_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            suffixText: widget.data.currency,
            suffixStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utilities Cost',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Are utilities included in the rent?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            Switch(
              value: widget.data.utilitiesIncluded,
              onChanged: (value) {
                widget.onDataChanged(
                  widget.data.copyWith(utilitiesIncluded: value),
                );
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!widget.data.utilitiesIncluded) ...[
          TextFormField(
            controller: _utilitiesCostController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '50000',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.electrical_services_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              suffixText: '${widget.data.currency}/month',
              suffixStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Schedule *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How often should rent be paid?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.paymentSchedule,
          items: _paymentSchedules,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(paymentSchedule: value ?? 'Monthly'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lease Duration *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What is the minimum lease period?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: widget.data.leaseDuration,
          items: _leaseDurations,
          onChanged: (value) {
            widget.onDataChanged(
              widget.data.copyWith(leaseDuration: value ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoveInSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Move-in Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'When is the room available for move-in?',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _moveInDateController,
          readOnly: true,
          onTap: () => _selectMoveInDate(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Select move-in date',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.calendar_today_rounded,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 140),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        hint: Text(
          'Currency',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Icon(
              Icons.arrow_drop_down_rounded,
              color: Colors.grey[600],
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectMoveInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final formattedDate = '${picked.day}/${picked.month}/${picked.year}';
      _moveInDateController.text = formattedDate;
      widget.onDataChanged(widget.data.copyWith(moveInDate: formattedDate));
    }
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
              'Tip: Be transparent about all costs. Students appreciate knowing the total monthly expense upfront!',
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


              borderRadius: BorderRadius.circular(16),

              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),

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



  Widget _buildUtilitiesSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Utilities Cost',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Row(

          children: [

            Expanded(

              child: Text(

                'Are utilities included in the rent?',

                style: TextStyle(fontSize: 14, color: Colors.grey[600]),

              ),

            ),

            Switch(

              value: widget.data.utilitiesIncluded,

              onChanged: (value) {

                widget.onDataChanged(widget.data.copyWith(utilitiesIncluded: value));

              },

              activeColor: AppTheme.primaryColor,

            ),

          ],

        ),

        const SizedBox(height: 12),

        if (!widget.data.utilitiesIncluded) ...[

          TextFormField(

            controller: _utilitiesCostController,

            keyboardType: TextInputType.number,

            style: TextStyle(

              fontSize: 16,

              color: Colors.grey[800],

              fontWeight: FontWeight.w500,

            ),

            decoration: InputDecoration(

              hintText: '50000',

              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

              prefixIcon: Padding(

                padding: const EdgeInsets.only(left: 12, right: 8),

                child: Icon(

                  Icons.electrical_services_rounded,

                  color: Colors.grey[600],

                  size: 20,

                ),

              ),

              suffixText: '${widget.data.currency}/month',

              suffixStyle: TextStyle(

                color: Colors.grey[600],

                fontSize: 14,

                fontWeight: FontWeight.w500,

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

              contentPadding: const EdgeInsets.symmetric(

                horizontal: 20,

                vertical: 16,

              ),

            ),

          ),

        ],

      ],

    );

  }



  Widget _buildPaymentSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Payment Schedule *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'How often should rent be paid?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        _buildDropdownField(

          value: widget.data.paymentSchedule,

          items: _paymentSchedules,

          onChanged: (value) {

            widget.onDataChanged(widget.data.copyWith(paymentSchedule: value ?? 'Monthly'));

          },

        ),

      ],

    );

  }



  Widget _buildLeaseSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Lease Duration *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'What is the minimum lease period?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        _buildDropdownField(

          value: widget.data.leaseDuration,

          items: _leaseDurations,

          onChanged: (value) {

            widget.onDataChanged(widget.data.copyWith(leaseDuration: value ?? ''));

          },

        ),

      ],

    );

  }



  Widget _buildMoveInSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Available Move-in Date',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'When is the room available for move-in?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _moveInDateController,

          readOnly: true,

          onTap: () => _selectMoveInDate(),

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: 'Select move-in date',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.calendar_today_rounded,

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

            contentPadding: const EdgeInsets.symmetric(

              horizontal: 20,

              vertical: 16,

            ),

          ),

        ),

      ],

    );

  }



  Widget _buildDropdownField({

    required String value,

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

          prefixIcon: Padding(

            padding: const EdgeInsets.only(left: 12, right: 8),

            child: Icon(

              Icons.arrow_drop_down_rounded,

              color: Colors.grey[600],

              size: 20,

            ),

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

        items: items.map((item) => DropdownMenuItem(

          value: item,

          child: Text(item),

        )).toList(),

        onChanged: onChanged,

      ),

    );

  }



  Future<void> _selectMoveInDate() async {

    final DateTime? picked = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime.now().add(const Duration(days: 365)),

    );

    

    if (picked != null) {

      final formattedDate = '${picked.day}/${picked.month}/${picked.year}';

      _moveInDateController.text = formattedDate;

      widget.onDataChanged(widget.data.copyWith(moveInDate: formattedDate));

    }

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

              'Tip: Be transparent about all costs. Students appreciate knowing the total monthly expense upfront!',

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




              borderRadius: BorderRadius.circular(16),

              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),

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



  Widget _buildUtilitiesSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Utilities Cost',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Row(

          children: [

            Expanded(

              child: Text(

                'Are utilities included in the rent?',

                style: TextStyle(fontSize: 14, color: Colors.grey[600]),

              ),

            ),

            Switch(

              value: widget.data.utilitiesIncluded,

              onChanged: (value) {

                widget.onDataChanged(widget.data.copyWith(utilitiesIncluded: value));

              },

              activeColor: AppTheme.primaryColor,

            ),

          ],

        ),

        const SizedBox(height: 12),

        if (!widget.data.utilitiesIncluded) ...[

          TextFormField(

            controller: _utilitiesCostController,

            keyboardType: TextInputType.number,

            style: TextStyle(

              fontSize: 16,

              color: Colors.grey[800],

              fontWeight: FontWeight.w500,

            ),

            decoration: InputDecoration(

              hintText: '50000',

              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

              prefixIcon: Padding(

                padding: const EdgeInsets.only(left: 12, right: 8),

                child: Icon(

                  Icons.electrical_services_rounded,

                  color: Colors.grey[600],

                  size: 20,

                ),

              ),

              suffixText: '${widget.data.currency}/month',

              suffixStyle: TextStyle(

                color: Colors.grey[600],

                fontSize: 14,

                fontWeight: FontWeight.w500,

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

              contentPadding: const EdgeInsets.symmetric(

                horizontal: 20,

                vertical: 16,

              ),

            ),

          ),

        ],

      ],

    );

  }



  Widget _buildPaymentSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Payment Schedule *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'How often should rent be paid?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        _buildDropdownField(

          value: widget.data.paymentSchedule,

          items: _paymentSchedules,

          onChanged: (value) {

            widget.onDataChanged(widget.data.copyWith(paymentSchedule: value ?? 'Monthly'));

          },

        ),

      ],

    );

  }



  Widget _buildLeaseSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Lease Duration *',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'What is the minimum lease period?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        _buildDropdownField(

          value: widget.data.leaseDuration,

          items: _leaseDurations,

          onChanged: (value) {

            widget.onDataChanged(widget.data.copyWith(leaseDuration: value ?? ''));

          },

        ),

      ],

    );

  }



  Widget _buildMoveInSection() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Available Move-in Date',

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.w600,

            color: Colors.grey[800],

          ),

        ),

        const SizedBox(height: 8),

        Text(

          'When is the room available for move-in?',

          style: TextStyle(fontSize: 14, color: Colors.grey[600]),

        ),

        const SizedBox(height: 12),

        TextFormField(

          controller: _moveInDateController,

          readOnly: true,

          onTap: () => _selectMoveInDate(),

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey[800],

            fontWeight: FontWeight.w500,

          ),

          decoration: InputDecoration(

            hintText: 'Select move-in date',

            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),

            prefixIcon: Padding(

              padding: const EdgeInsets.only(left: 12, right: 8),

              child: Icon(

                Icons.calendar_today_rounded,

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

            contentPadding: const EdgeInsets.symmetric(

              horizontal: 20,

              vertical: 16,

            ),

          ),

        ),

      ],

    );

  }



  Widget _buildDropdownField({

    required String value,

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

          prefixIcon: Padding(

            padding: const EdgeInsets.only(left: 12, right: 8),

            child: Icon(

              Icons.arrow_drop_down_rounded,

              color: Colors.grey[600],

              size: 20,

            ),

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

        items: items.map((item) => DropdownMenuItem(

          value: item,

          child: Text(item),

        )).toList(),

        onChanged: onChanged,

      ),

    );

  }



  Future<void> _selectMoveInDate() async {

    final DateTime? picked = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime.now().add(const Duration(days: 365)),

    );

    

    if (picked != null) {

      final formattedDate = '${picked.day}/${picked.month}/${picked.year}';

      _moveInDateController.text = formattedDate;

      widget.onDataChanged(widget.data.copyWith(moveInDate: formattedDate));

    }

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

              'Tip: Be transparent about all costs. Students appreciate knowing the total monthly expense upfront!',

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


