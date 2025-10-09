// Presentation Layer - Home Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_database_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/housing_highlights.dart';
import '../widgets/campus_feed.dart';
import '../widgets/marketplace_highlights.dart';
import '../widgets/trending_carousel.dart';
import '../widgets/bottom_navigation.dart';
import '../../../../Features/management/presentation/widgets/management_fab.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../marketplace/presentation/screens/marketplace_list_screen.dart';
import '../../../events/presentation/screens/events_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _eventCount = 0;
  int _messageCount = 0;
  int _marketplaceCount = 0;
  bool _isLoadingStats = true;
  String _userName = 'Student';
  String _userRole = 'Student';
  bool _isLoadingUser = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userProfile = await SupabaseAuthService.instance.getUserProfile(
        SupabaseAuthService.instance.currentUser?.id ?? '',
      );

      if (mounted) {
        setState(() {
          _userName = userProfile?['first_name'] ?? 'Student';
          _userRole = userProfile?['primary_role'] ?? 'Student';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
      if (mounted) {
        setState(() {
          _userName = 'Student';
          _userRole = 'Student';
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final databaseService = SupabaseDatabaseService.instance;

      // Load events count
      final events = await databaseService.getEvents(limit: 100);

      // Load marketplace items count
      final marketplaceItems = await databaseService.getMarketplaceItems(
        limit: 100,
      );

      // For messages, we'll use a placeholder since we don't have a messages service yet
      // This could be implemented when the chat system is ready

      if (mounted) {
        setState(() {
          _eventCount = events.length;
          _marketplaceCount = marketplaceItems.length;
          _messageCount =
              0; // Placeholder - implement when chat system is ready
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF0B1014) : Colors.grey[50],
      body: SafeArea(
          child: Stack(
            children: [
              Column(
          children: [
            // Header with search and notifications (only show on home screen)
            if (_currentIndex == 0) const HomeHeader(),

            // Main content based on selected tab
            Expanded(child: _buildCurrentScreen()),
                ],
              ),
              // Management FAB positioned in top-right
              const ManagementFAB(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SearchScreen();
      case 2:
        return const ChatListScreen();
      case 3:
        return const MarketplaceListScreen();
      case 4:
        return const EventsListScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_loadStats(), _loadUserInfo()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Personalized Greeting Section
            _buildGreetingSection(),
            const SizedBox(height: 20),

            // Trending/Featured Section
            _buildFeaturedSection(),
            const SizedBox(height: 28),

            // Quick Action Shortcuts
            const QuickActions(),
            const SizedBox(height: 28),

            // Roommate & Housing Highlights
            const HousingHighlights(),
            const SizedBox(height: 28),

            // Campus Feed
            const CampusFeed(),
            const SizedBox(height: 28),

            // Marketplace Highlights
            const MarketplaceHighlights(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getDynamicSubtitle(int hour, String role) {
    final weekday = DateTime.now().weekday;
    final isWeekend =
        weekday == DateTime.saturday || weekday == DateTime.sunday;

    // Time-based messages
    if (hour >= 5 && hour < 9) {
      return isWeekend
          ? 'Ready for a relaxing weekend?'
          : 'Ready to tackle the day?';
    } else if (hour >= 9 && hour < 12) {
      return isWeekend
          ? 'Perfect time for weekend activities!'
          : 'Hope your morning is going well!';
    } else if (hour >= 12 && hour < 14) {
      return isWeekend
          ? 'Enjoying your weekend?'
          : 'How\'s your day going so far?';
    } else if (hour >= 14 && hour < 17) {
      return isWeekend
          ? 'Making the most of your weekend!'
          : 'Keep up the great work!';
    } else if (hour >= 17 && hour < 21) {
      return isWeekend
          ? 'Hope you\'re having a great evening!'
          : 'Great job today! Time to unwind.';
    } else {
      return isWeekend
          ? 'Hope you had a wonderful day!'
          : 'Time to rest and recharge!';
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 1) {
      return 'Just now';
    } else if (hour < 2) {
      return '1 hr ago';
    } else if (hour < 6) {
      return '${hour} hrs ago';
    } else if (hour < 12) {
      return '${hour} hrs ago';
    } else if (hour < 24) {
      return '${hour} hrs ago';
    } else {
      return 'Yesterday';
    }
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    final now = DateTime.now();

    // Time-based greeting
    String greeting = 'Good Morning';
    IconData greetingIcon = Icons.wb_sunny_outlined;
    Color greetingColor = Colors.orange[600]!;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.orange[600]!;
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
      greetingColor = Colors.amber[600]!;
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
      greetingIcon = Icons.wb_twilight_outlined;
      greetingColor = Colors.purple[600]!;
    } else {
      greeting = 'Good Night';
      greetingIcon = Icons.nights_stay_outlined;
      greetingColor = Colors.indigo[600]!;
    }

    // Dynamic subtitle based on time and role
    String subtitle = _getDynamicSubtitle(hour, _userRole);

    return Container(
      padding: const EdgeInsets.all(8), // Further reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _isDarkMode
                  ? [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.08),
                  ]
                  : [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.primaryColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ), // Further reduced border radius
        border: Border.all(
          color:
              _isDarkMode
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingUser ? '$greeting!' : '$greeting, $_userName!',
                      style: TextStyle(
                        fontSize: 16, // Further reduced font size
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11, // Further reduced font size
                        color:
                            _isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Theme Toggle Button
                  GestureDetector(
                    onTap: _toggleTheme,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color:
                            _isDarkMode ? Colors.amber[600] : Colors.grey[700],
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Greeting Icon
                  Container(
                    padding: const EdgeInsets.all(6), // Further reduced padding
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Further reduced border radius
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 6, // Reduced blur
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      greetingIcon,
                      color: greetingColor,
                      size: 18, // Further reduced icon size
                    ), // Reduced icon size
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8), // Further reduced spacing
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available,
                  label: 'Events',
                  value: _isLoadingStats ? '...' : '$_eventCount',
                  color: Colors.blue[600]!,
                ),
              ),
              const SizedBox(width: 6), // Further reduced spacing
              Expanded(
                child: _buildStatCard(
                  icon: Icons.message_outlined,
                  label: 'Messages',
                  value: _isLoadingStats ? '...' : '$_messageCount',
                  color: Colors.green[600]!,
                ),
              ),
              const SizedBox(width: 6), // Further reduced spacing
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_offer_outlined,
                  label: 'Marketplace',
                  value: _isLoadingStats ? '...' : '$_marketplaceCount',
                  color: Colors.purple[600]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 4,
      ), // Further reduced padding
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8), // Further reduced border radius
        border: Border.all(
          color: _isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16), // Further reduced icon size
          const SizedBox(height: 3), // Further reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 12, // Further reduced font size
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 1), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 8, // Further reduced font size
              color: _isDarkMode ? Colors.grey[300] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.whatshot,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Trending Now',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.orange[900] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isDarkMode ? Colors.orange[600]! : Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                _getTimeAgo(),
                style: TextStyle(
                  fontSize: 10,
                  color: _isDarkMode ? Colors.orange[200] : Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(height: 190, child: TrendingCarousel()),
      ],
    );
  }
}
