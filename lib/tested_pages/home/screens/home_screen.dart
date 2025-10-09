import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../housing/screens/housing_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userType;
  final String? selectedUniversity;
  final VoidCallback? onLogout;

  const HomeScreen({
    super.key,
    this.userType,
    this.selectedUniversity,
    this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String get _selectedUniversity =>
      widget.selectedUniversity ?? 'Makerere University';
  String _userName = 'John'; // This would come from user data

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Find Roommate',
      'subtitle': 'Connect with compatible students',
      'icon': Icons.people_alt_rounded,
      'color': Colors.blue,
      'gradient': [Colors.blue[400]!, Colors.blue[600]!],
    },
    {
      'title': 'Find Hostel',
      'subtitle': 'Discover perfect accommodation',
      'icon': Icons.home_work_rounded,
      'color': Colors.green,
      'gradient': [Colors.green[400]!, Colors.green[600]!],
    },
    {
      'title': 'Marketplace',
      'subtitle': 'Buy & sell student essentials',
      'icon': Icons.storefront_rounded,
      'color': Colors.orange,
      'gradient': [Colors.orange[400]!, Colors.orange[600]!],
    },
    {
      'title': 'Campus News',
      'subtitle': 'Stay updated with campus life',
      'icon': Icons.newspaper_rounded,
      'color': Colors.purple,
      'gradient': [Colors.purple[400]!, Colors.purple[600]!],
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'New roommate matches found',
      'subtitle': '3 compatible students near you',
      'time': '2 hours ago',
      'icon': Icons.people_alt_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'Hostel booking confirmed',
      'subtitle': 'Your booking at Campus View is confirmed',
      'time': '1 day ago',
      'icon': Icons.home_work_rounded,
      'color': Colors.green,
    },
    {
      'title': 'New marketplace item',
      'subtitle': 'Textbook: Introduction to Computer Science',
      'time': '2 days ago',
      'icon': Icons.storefront_rounded,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _campusEvents = [
    {
      'title': 'Tech Innovation Summit',
      'date': 'Dec 15, 2024',
      'location': 'Main Auditorium',
      'type': 'Conference',
    },
    {
      'title': 'Cultural Night',
      'date': 'Dec 20, 2024',
      'location': 'Student Center',
      'type': 'Entertainment',
    },
    {
      'title': 'Career Fair 2024',
      'date': 'Dec 25, 2024',
      'location': 'Sports Complex',
      'type': 'Career',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            _buildSliverAppBar(),

            // Welcome Section
            _buildWelcomeSection(),

            // Quick Actions Grid
            _buildQuickActionsSection(),

            // Recent Activities
            _buildRecentActivitiesSection(),

            // Campus Events
            _buildCampusEventsSection(),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.indigo[600],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo[600]!, Colors.indigo[800]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                // Profile Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back, $_userName!',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedUniversity,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification Bell
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Profile Menu
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'logout' && widget.onLogout != null) {
                        widget.onLogout!();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 20),
                                const SizedBox(width: 8),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(Icons.settings_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text('Settings'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Campus Hub',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everything you need for campus life in one place',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                final action = _quickActions[index];
                return _buildQuickActionCard(action);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: action['gradient'],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: action['color'].withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Navigate to respective feature
            _handleQuickAction(action['title']);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(action['icon'], color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  action['title'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action['subtitle'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all activities
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._recentActivities.map(
              (activity) => _buildActivityCard(activity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity['icon'], color: activity['color'], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusEventsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all events
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _campusEvents.length,
                itemBuilder: (context, index) {
                  final event = _campusEvents[index];
                  return _buildEventCard(event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              event['type'],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event['title'],
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                event['date'],
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event['location'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // Search tab
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => HousingScreen(
                      universityId: _selectedUniversity,
                      userId: 'current_user_id',
                    ),
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.indigo[600],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Find Roommate':
      case 'Find Hostel':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => HousingScreen(
                  universityId: _selectedUniversity,
                  userId: 'current_user_id', // TODO: Get actual user ID
                ),
          ),
        );
        break;
      case 'Marketplace':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marketplace coming soon...'),
            backgroundColor: Colors.indigo[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        break;
      case 'Campus News':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Campus News coming soon...'),
            backgroundColor: Colors.indigo[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $action...'),
            backgroundColor: Colors.indigo[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
  }
}
