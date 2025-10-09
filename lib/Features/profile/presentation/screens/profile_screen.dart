// Presentation Layer - Profile Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/profile_actions.dart';
import '../../../posting/presentation/screens/roommate_request_screen.dart';
import '../../../posting/presentation/screens/marketplace_posting_screen.dart';
import '../../../posting/presentation/screens/step_by_step_hostel_posting_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  String _selectedTab = '';
  String _userRole = 'Student';
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.getUserProfile(user.id);
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _userRole = profile?['primary_role'] ?? 'Student';
            _selectedTab = _getDefaultTabForRole(_userRole);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.grey[600],
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeader(userRole: _userRole),

            // Profile Stats
            ProfileStats(userRole: _userRole),

            // Profile Tabs
            if (!_isLoading)
              ProfileTabs(
                userRole: _userRole,
                selectedTab: _selectedTab,
                onTabChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),

            // Profile Actions
            ProfileActions(userRole: _userRole),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showPostingOptions,
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  void _showPostingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'What would you like to post?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._getPostingOptions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  List<Widget> _getPostingOptions() {
    switch (_userRole) {
      case 'Student':
        return [
          _buildPostingOption(
            icon: Icons.person_add_rounded,
            title: 'Roommate Request',
            subtitle: 'Find a roommate for your accommodation',
            onTap: () => _navigateToRoommatePosting(),
          ),
          _buildPostingOption(
            icon: Icons.shopping_cart_rounded,
            title: 'Marketplace Item',
            subtitle: 'Sell or trade items with other students',
            onTap: () => _navigateToMarketplacePosting(),
          ),
        ];
      case 'Hostel Provider':
        return [
          _buildPostingOption(
            icon: Icons.home_rounded,
            title: 'Hostel Listing',
            subtitle: 'Post available rooms and accommodation',
            onTap: () => _navigateToHostelPosting(),
          ),
        ];
      case 'Event Organizer':
        return [
          _buildPostingOption(
            icon: Icons.event_rounded,
            title: 'Event',
            subtitle: 'Create and promote campus events',
            onTap: () => _navigateToEventPosting(),
          ),
        ];
      case 'Promoter':
        return [
          _buildPostingOption(
            icon: Icons.campaign_rounded,
            title: 'Promotion',
            subtitle: 'Promote events and activities',
            onTap: () => _navigateToPromotionPosting(),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildPostingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _navigateToRoommatePosting() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoommateRequestScreen()),
    );
  }

  void _navigateToMarketplacePosting() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MarketplacePostingScreen()),
    );
  }

  void _navigateToHostelPosting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StepByStepHostelPostingScreen(),
      ),
    );
  }

  void _navigateToEventPosting() {
    // TODO: Navigate to event posting screen
    print('Navigate to event posting');
  }

  void _navigateToPromotionPosting() {
    // TODO: Navigate to promotion posting screen
    print('Navigate to promotion posting');
  }

  String _getDefaultTabForRole(String role) {
    switch (role) {
      case 'Student':
        return 'Roommate Requests';
      case 'Hostel Provider':
        return 'Hostel Listings';
      case 'Event Organizer':
        return 'Events';
      case 'Promoter':
        return 'Events Promoted';
      default:
        return 'Roommate Requests';
    }
  }
}
