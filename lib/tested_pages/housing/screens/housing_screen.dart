import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/roommate_request_card.dart';

class HousingScreen extends StatefulWidget {
  final String? universityId;
  final String? userId;

  const HousingScreen({super.key, this.universityId, this.userId});

  @override
  State<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  String _activeTab = 'listings';
  Map<String, dynamic> _filters = {};
  bool _showFilters = false;
  bool _refreshing = false;
  bool _isLoading = true;

  // Mock data - replace with actual API calls
  final List<Map<String, dynamic>> _housingListings = [
    {
      'id': '1',
      'title': 'Cozy Studio Apartment',
      'price': 450,
      'location': 'Near Campus',
      'description': 'Beautiful studio apartment with modern amenities',
      'contactName': 'John Smith',
      'contactPhone': '+256701234567',
      'postedBy': 'user1',
      'images': ['https://via.placeholder.com/300x200'],
      'amenities': ['WiFi', 'Parking', 'Security'],
    },
    {
      'id': '2',
      'title': 'Shared Room Available',
      'price': 200,
      'location': 'Student Village',
      'description': 'Shared room in a friendly house',
      'contactName': 'Sarah Johnson',
      'contactPhone': '+256701234568',
      'postedBy': 'user2',
      'images': ['https://via.placeholder.com/300x200'],
      'amenities': ['WiFi', 'Kitchen', 'Laundry'],
    },
  ];

  final List<Map<String, dynamic>> _roommateRequests = [
    {
      'id': '1',
      'name': 'Sarah Chen',
      'major': 'Computer Science • Junior',
      'description':
          'Looking for a roommate for Spring 2024 semester. I\'m a quiet student who loves cooking and keeping things organized. Prefer someone who shares similar lifestyle habits.',
      'budget': '\$800-900/month',
      'moveInDate': 'January 2024',
      'tags': ['Non-smoker', 'Clean'],
      'profileImage':
          'https://images.unsplash.com/photo-1592188657297-c6473609e988?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTkyNTc3MDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'contactInfo': {'preferredContact': 'phone', 'phone': '+256701234569'},
      'postedBy': 'user3',
      'poster': {'name': 'Sarah Chen'},
    },
    {
      'id': '2',
      'name': 'Mike Wilson',
      'major': 'Business Administration • Senior',
      'description':
          'Need someone to share apartment costs. I\'m outgoing, love sports, and enjoy hosting study groups. Looking for someone who\'s social and responsible.',
      'budget': '\$600-700/month',
      'moveInDate': 'February 2024',
      'tags': ['Social', 'Studious'],
      'profileImage':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTkyNTc3MDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'contactInfo': {'preferredContact': 'chat', 'phone': '+256701234570'},
      'postedBy': 'user4',
      'poster': {'name': 'Mike Wilson'},
    },
    {
      'id': '3',
      'name': 'Emma Davis',
      'major': 'Psychology • Sophomore',
      'description':
          'Seeking a clean, responsible roommate who values quiet study time. I\'m an early riser and prefer a peaceful living environment.',
      'budget': '\$500-600/month',
      'moveInDate': 'March 2024',
      'tags': ['Quiet', 'Clean', 'Early Riser'],
      'profileImage':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTkyNTc3MDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'contactInfo': {'preferredContact': 'phone', 'phone': '+256701234571'},
      'postedBy': 'user5',
      'poster': {'name': 'Emma Davis'},
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _handleRefresh() async {
    setState(() {
      _refreshing = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _refreshing = false;
    });
  }

  void _handleTabPress(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _handleFilterPress() {
    setState(() {
      _showFilters = true;
    });
  }

  void _handleAddPress() {
    if (_activeTab == 'listings') {
      // Navigate to add housing listing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Navigate to Add Housing'),
          backgroundColor: Colors.indigo[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      // Navigate to add roommate request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Navigate to Add Roommate Request'),
          backgroundColor: Colors.indigo[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _handleCall(String contactName, String phone) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Call $contactName'),
            content: Text(phone),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement phone call functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $phone...'),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                },
                child: const Text('Call'),
              ),
            ],
          ),
    );
  }

  void _handleChat(
    String otherUserId,
    String? listingId,
    String? roommateRequestId,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening chat...'),
        backgroundColor: Colors.indigo[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildHousingCard(Map<String, dynamic> listing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to housing details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${listing['title']}'),
                backgroundColor: Colors.indigo[600],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 12),

                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing['title'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Text(
                      '\$${listing['price']}/month',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      listing['location'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  listing['description'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Amenities
                Wrap(
                  spacing: 8,
                  children:
                      (listing['amenities'] as List).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            amenity,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.indigo[700],
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _handleCall(
                              listing['contactName'],
                              listing['contactPhone'],
                            ),
                        icon: Icon(Icons.phone_rounded, size: 18),
                        label: Text('Call'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _handleChat(
                              listing['postedBy'],
                              listing['id'],
                              null,
                            ),
                        icon: Icon(Icons.chat_rounded, size: 18),
                        label: Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoommateCard(Map<String, dynamic> request) {
    return RoommateRequestCard(
      request: request,
      onViewProfile: () {
        Navigator.pushNamed(
          context,
          '/roommate-request',
          arguments: {'requestId': request['id'] ?? 'default_id'},
        );
      },
      onSendMessage: () {
        final contactMethod = request['contactInfo']['preferredContact'];
        if (contactMethod == 'phone') {
          _handleCall(request['name'], request['contactInfo']['phone']);
        } else {
          _handleChat(request['postedBy'], null, request['id']);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _activeTab == 'listings'
                  ? Icons.home_outlined
                  : Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _activeTab == 'listings'
                  ? 'No housing listings yet'
                  : 'No roommate requests yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _activeTab == 'listings'
                  ? 'Be the first to post a housing listing!'
                  : 'Be the first to post a roommate request!',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleAddPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _activeTab == 'listings' ? 'Post Housing' : 'Find Roommate',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModal() {
    return ModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Filter options would go here
                Text(
                  'Filter options coming soon...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData =
        _activeTab == 'listings' ? _housingListings : _roommateRequests;
    final isEmpty = currentData.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Housing & Roommates',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _handleFilterPress,
                        icon: Icon(
                          Icons.tune_rounded,
                          color: Colors.indigo[600],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.indigo[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _handleAddPress,
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleTabPress('listings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _activeTab == 'listings'
                                  ? Colors.indigo[50]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_rounded,
                              size: 20,
                              color:
                                  _activeTab == 'listings'
                                      ? Colors.indigo[600]
                                      : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Housing',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    _activeTab == 'listings'
                                        ? Colors.indigo[600]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleTabPress('roommates'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _activeTab == 'roommates'
                                  ? Colors.indigo[50]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: 20,
                              color:
                                  _activeTab == 'roommates'
                                      ? Colors.indigo[600]
                                      : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Roommates',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    _activeTab == 'roommates'
                                        ? Colors.indigo[600]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.indigo[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: () async => _handleRefresh(),
                        color: Colors.indigo[600],
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: currentData.length,
                          itemBuilder: (context, index) {
                            final item = currentData[index];
                            return _activeTab == 'listings'
                                ? _buildHousingCard(item)
                                : _buildRoommateCard(item);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for modal bottom sheet
class ModalBottomSheet extends StatelessWidget {
  final BuildContext context;
  final Widget Function(BuildContext) builder;

  const ModalBottomSheet({
    super.key,
    required this.context,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void show() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: builder(context),
          ),
    );
  }
}
