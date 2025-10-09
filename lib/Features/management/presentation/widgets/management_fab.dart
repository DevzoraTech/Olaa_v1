// Management Floating Action Button Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../screens/management_dashboard_screen.dart';

class ManagementFAB extends StatefulWidget {
  const ManagementFAB({super.key});

  @override
  State<ManagementFAB> createState() => _ManagementFABState();
}

class _ManagementFABState extends State<ManagementFAB> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userProfile = await SupabaseAuthService.instance.getUserProfile(
        SupabaseAuthService.instance.currentUser?.id ?? '',
      );
      setState(() {
        _userRole = userProfile?['primary_role'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userRole = 'Student';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100, // Position it even closer to the marketplace FAB
      right: 16,
      child: GestureDetector(
        onTap: _navigateToManagement,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dashboard_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _getFABLabel(),
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFABLabel() {
    switch (_userRole?.toLowerCase()) {
      case 'student':
        return 'My Listings';
      case 'hostel provider':
        return 'My Hostels';
      case 'event organizer':
        return 'My Events';
      case 'promoter':
        return 'My Campaigns';
      default:
        return 'My Listings';
    }
  }

  void _navigateToManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManagementDashboardScreen(),
      ),
    );
  }
}
