// Calendar Date Picker Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CustomCalendarDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String label;
  final String hintText;
  final IconData icon;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomCalendarDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<CustomCalendarDatePicker> createState() =>
      _CustomCalendarDatePickerState();
}

class _CustomCalendarDatePickerState extends State<CustomCalendarDatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (_selectedDate != null) {
      _controller.text = _formatDate(_selectedDate!);
    } else {
      _controller.text = '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate:
          widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateController();
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Call the callback
      widget.onDateSelected(picked);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _updateController();
    });

    HapticFeedback.lightImpact();
    widget.onDateSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: _selectDate,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: Row(
              children: [
                // Icon
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(widget.icon, color: Colors.grey[600], size: 20),
                ),

                // Date Text
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : widget.hintText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedDate != null
                              ? Colors.grey[800]
                              : Colors.grey[400],
                    ),
                  ),
                ),

                // Clear Button (if date is selected)
                if (_selectedDate != null)
                  GestureDetector(
                    onTap: _clearDate,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),

                // Calendar Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Helper Text
        Text(
          'Tap to select your preferred move-in date',
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
