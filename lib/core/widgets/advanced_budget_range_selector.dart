// Advanced Budget Range Selector Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class AdvancedBudgetRangeSelector extends StatefulWidget {
  final RangeValues currentRange;
  final ValueChanged<RangeValues> onRangeChanged;
  final String label;
  final String currency;
  final double minValue;
  final double maxValue;
  final int divisions;
  final bool isRequired;

  const AdvancedBudgetRangeSelector({
    super.key,
    required this.currentRange,
    required this.onRangeChanged,
    required this.label,
    this.currency = 'UGX',
    this.minValue = 0,
    this.maxValue = 5000000,
    this.divisions = 100,
    this.isRequired = false,
  });

  @override
  State<AdvancedBudgetRangeSelector> createState() =>
      _AdvancedBudgetRangeSelectorState();
}

class _AdvancedBudgetRangeSelectorState
    extends State<AdvancedBudgetRangeSelector> {
  late RangeValues _currentRange;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.currentRange;
    _minController = TextEditingController(
      text: _formatNumber(_currentRange.start),
    );
    _maxController = TextEditingController(
      text: _formatNumber(_currentRange.end),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double _parseNumber(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? widget.minValue;
  }

  void _onRangeChanged(RangeValues range) {
    setState(() {
      _currentRange = range;
      _minController.text = _formatNumber(range.start);
      _maxController.text = _formatNumber(range.end);
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onMinValueChanged(String value) {
    final parsedValue = _parseNumber(value);
    if (parsedValue >= widget.minValue && parsedValue <= _currentRange.end) {
      final newRange = RangeValues(parsedValue, _currentRange.end);
      widget.onRangeChanged(newRange);
      _onRangeChanged(newRange);
    }
  }

  void _onMaxValueChanged(String value) {
    final parsedValue = _parseNumber(value);
    if (parsedValue <= widget.maxValue && parsedValue >= _currentRange.start) {
      final newRange = RangeValues(_currentRange.start, parsedValue);
      widget.onRangeChanged(newRange);
      _onRangeChanged(newRange);
    }
  }

  void _applyChanges() {
    setState(() {
      _isApplying = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate apply animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.label} (${widget.currency})' +
                  (widget.isRequired ? ' *' : ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: _applyChanges,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      _isApplying
                          ? AppTheme.primaryColor.withOpacity(0.8)
                          : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Range Slider
        Container(
          height: 40,
          child: RangeSlider(
            values: _currentRange,
            min: widget.minValue,
            max: widget.maxValue,
            divisions: widget.divisions,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.grey[300],
            onChanged: _onRangeChanged,
          ),
        ),

        const SizedBox(height: 16),

        // Input Fields
        Row(
          children: [
            // Min Value Input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Min',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  onChanged: _onMinValueChanged,
                ),
              ),
            ),

            // Separator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),

            // Max Value Input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Max',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  onChanged: _onMaxValueChanged,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Helper Text
        Text(
          'Select your monthly budget range for accommodation',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// Custom input formatter for thousands separator
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Add thousands separators
    String formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}






