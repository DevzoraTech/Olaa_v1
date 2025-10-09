// Management Dashboard Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../widgets/role_based_content.dart';
import '../widgets/management_app_bar.dart';
import '../widgets/management_summary_bar.dart';
import '../widgets/management_filter_bar.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() =>
      _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentRole = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> _filterOptions = ['All', 'Active', 'Hidden', 'Completed'];

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
        _currentRole = userProfile?['primary_role'] ?? 'Student';
        _isLoading = false;
      });

      // Initialize tab controller based on role
      _initializeTabController();
    } catch (e) {
      setState(() {
        _currentRole = 'Student';
        _isLoading = false;
      });
      _initializeTabController();
    }
  }

  void _initializeTabController() {
    final tabs = _getTabsForRole(_currentRole);
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  List<String> _getTabsForRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return ['Products', 'Roommate Requests'];
      case 'hostel provider':
        return ['Hostels'];
      case 'event organizer':
        return ['Events'];
      case 'promoter':
        return ['Promotions'];
      default:
        return ['Products', 'Roommate Requests'];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: ManagementAppBar(role: _currentRole, onAddNew: _onAddNew),
      body: Column(
        children: [
          // Summary Bar
          ManagementSummaryBar(role: _currentRole, filter: _selectedFilter),

          // Filter Bar
          ManagementFilterBar(
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          // Tab Bar (only show for roles with multiple tabs)
          if (_getTabsForRole(_currentRole).length > 1)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs:
                    _getTabsForRole(
                      _currentRole,
                    ).map((tab) => Tab(text: tab)).toList(),
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // Content Area
          Expanded(
            child: RoleBasedContent(
              role: _currentRole,
              filter: _selectedFilter,
              tabController: _tabController,
            ),
          ),
        ],
      ),
    );
  }

  void _onAddNew() {
    // Navigate to appropriate add form based on role
    switch (_currentRole.toLowerCase()) {
      case 'student':
        // Navigate to add product
        break;
      case 'hostel provider':
        // Navigate to add hostel
        break;
      case 'event organizer':
        // Navigate to add event
        break;
      case 'promoter':
        // Navigate to add promotion
        break;
    }
  }
}
