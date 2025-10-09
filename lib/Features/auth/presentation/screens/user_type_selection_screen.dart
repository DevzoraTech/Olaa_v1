// Presentation Layer - User Type Selection Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'student_details_screen.dart';
import 'hostel_provider_details_screen.dart';
import 'event_organizer_details_screen.dart';
import 'promoter_details_screen.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const UserTypeSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Choose Account Type',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Select your account type to personalize your PulseCampus experience.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Student Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUserType = 'student';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _selectedUserType == 'student'
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedUserType == 'student'
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                      width: _selectedUserType == 'student' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              _selectedUserType == 'student'
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Access housing, events, marketplace, and connect with roommates',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedUserType == 'student')
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Event Organizer Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUserType = 'event_organizer';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _selectedUserType == 'event_organizer'
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedUserType == 'event_organizer'
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                      width: _selectedUserType == 'event_organizer' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              _selectedUserType == 'event_organizer'
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event Organizer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create events, manage RSVPs, and engage with campus community',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedUserType == 'event_organizer')
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Promoter Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUserType = 'promoter';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _selectedUserType == 'promoter'
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedUserType == 'promoter'
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                      width: _selectedUserType == 'promoter' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              _selectedUserType == 'promoter'
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Promoter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Promote concerts, parties, and off-campus events to students',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedUserType == 'promoter')
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hostel Provider Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUserType = 'hostel_provider';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        _selectedUserType == 'hostel_provider'
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedUserType == 'hostel_provider'
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                      width: _selectedUserType == 'hostel_provider' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              _selectedUserType == 'hostel_provider'
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_work,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hostel Provider',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'List properties, manage bookings, and connect with students',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedUserType == 'hostel_provider')
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedUserType != null ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Add extra padding at the bottom to ensure content is visible above keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedUserType == 'student') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => StudentDetailsScreen(
                name: widget.name,
                email: widget.email,
                password: widget.password,
              ),
        ),
      );
    } else if (_selectedUserType == 'hostel_provider') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => HostelProviderDetailsScreen(
                name: widget.name,
                email: widget.email,
                password: widget.password,
              ),
        ),
      );
    } else if (_selectedUserType == 'event_organizer') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => EventOrganizerDetailsScreen(
                name: widget.name,
                email: widget.email,
                password: widget.password,
              ),
        ),
      );
    } else if (_selectedUserType == 'promoter') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => PromoterDetailsScreen(
                name: widget.name,
                email: widget.email,
                password: widget.password,
              ),
        ),
      );
    }
  }
}
