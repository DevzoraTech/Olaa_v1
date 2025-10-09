import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UniversitySelectionScreen extends StatefulWidget {
  final bool isFromSignup;

  const UniversitySelectionScreen({super.key, this.isFromSignup = false});

  @override
  State<UniversitySelectionScreen> createState() =>
      _UniversitySelectionScreenState();
}

class _UniversitySelectionScreenState extends State<UniversitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  final List<Map<String, String>> _universities = [
    {
      'name': 'Makerere University',
      'location': 'Kampala, Uganda',
      'country': 'Uganda',
    },
    {
      'name': 'University of Nairobi',
      'location': 'Nairobi, Kenya',
      'country': 'Kenya',
    },
    {
      'name': 'University of Cape Town',
      'location': 'Cape Town, South Africa',
      'country': 'South Africa',
    },
    {
      'name': 'University of Ghana',
      'location': 'Accra, Ghana',
      'country': 'Ghana',
    },
    {
      'name': 'Cairo University',
      'location': 'Cairo, Egypt',
      'country': 'Egypt',
    },
    {
      'name': 'University of Lagos',
      'location': 'Lagos, Nigeria',
      'country': 'Nigeria',
    },
    {
      'name': 'University of Dar es Salaam',
      'location': 'Dar es Salaam, Tanzania',
      'country': 'Tanzania',
    },
    {
      'name': 'Addis Ababa University',
      'location': 'Addis Ababa, Ethiopia',
      'country': 'Ethiopia',
    },
  ];

  List<Map<String, String>> get _filteredUniversities {
    if (_searchQuery.isEmpty) return _universities;
    return _universities
        .where(
          (uni) =>
              uni['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              uni['location']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              uni['country']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleUniversitySelection(
    String name,
    String location,
    String country,
  ) {
    // Show selection confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $name'),
        backgroundColor: Colors.indigo[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // TODO: Save university selection to user profile/preferences
    // This would typically involve:
    // 1. Saving to SharedPreferences or local storage
    // 2. Updating user profile in Firebase
    // 3. Setting up university-specific features

    // Navigate based on context
    if (widget.isFromSignup) {
      // If coming from signup, navigate to main app
      _navigateToMainApp();
    } else {
      // If coming from settings/profile, just show success
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    }
  }

  void _navigateToMainApp() {
    // TODO: Navigate to main app dashboard
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Welcome to PulseCampus! Main app coming soon.'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Replace with actual navigation to main app
    // Navigator.of(context).pushReplacementNamed('/main-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PulseCampus',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your one-stop student life app',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Subtitle
              Text(
                'Select your university to get started',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search universities...',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // University List
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredUniversities.length,
                  itemBuilder: (context, index) {
                    final university = _filteredUniversities[index];
                    return _buildUniversityCard(
                      university['name']!,
                      university['location']!,
                      university['country']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversityCard(String name, String location, String country) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleUniversitySelection(name, location, country),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // University Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.indigo[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // University Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
