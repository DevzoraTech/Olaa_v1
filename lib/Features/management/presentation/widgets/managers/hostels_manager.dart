// Hostels Manager Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/supabase_database_service.dart';
import '../../../../../core/services/supabase_auth_service.dart';
import '../listing_cards/hostel_card.dart';
import '../empty_states/hostels_empty_state.dart';

class HostelsManager extends StatefulWidget {
  final String filter;

  const HostelsManager({super.key, required this.filter});

  @override
  State<HostelsManager> createState() => _HostelsManagerState();
}

class _HostelsManagerState extends State<HostelsManager> {
  List<Map<String, dynamic>> _hostels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHostels();
  }

  @override
  void didUpdateWidget(HostelsManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _loadHostels();
    }
  }

  Future<void> _loadHostels() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current user ID
      final userId = SupabaseAuthService.instance.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user's hostel listings from Supabase
      final hostels = await SupabaseDatabaseService.instance
          .getHostelListingsByProvider(userId);

      // Apply filter if needed
      List<Map<String, dynamic>> filteredHostels = hostels;
      if (widget.filter != 'All') {
        filteredHostels =
            hostels.where((hostel) {
              final status =
                  hostel['status']?.toString().toLowerCase() ?? 'active';
              return status == widget.filter.toLowerCase();
            }).toList();
      }

      if (!mounted) return;
      setState(() {
        _hostels = filteredHostels;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load hostels: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Hostels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHostels,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_hostels.isEmpty) {
      return HostelsEmptyState(onAddNew: _onAddNew);
    }

    return ListView.builder(
      itemCount: _hostels.length,
      itemBuilder: (context, index) {
        final hostel = _hostels[index];
        return HostelCard(
          hostel: hostel,
          onEdit: () => _onEditHostel(hostel),
          onUpdatePhotos: () => _onUpdatePhotos(hostel),
          onToggleVisibility: () => _onToggleVisibility(hostel),
          onDelete: () => _onDeleteHostel(hostel),
          onViewBookings: () => _onViewBookings(hostel),
        );
      },
    );
  }

  void _onAddNew() {
    // TODO: Navigate to add hostel screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to Add Hostel')));
  }

  void _onEditHostel(Map<String, dynamic> hostel) {
    // TODO: Navigate to edit hostel screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${hostel['name']}')));
  }

  void _onUpdatePhotos(Map<String, dynamic> hostel) {
    // TODO: Navigate to update photos screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update photos for ${hostel['name']}')),
    );
  }

  void _onToggleVisibility(Map<String, dynamic> hostel) {
    // TODO: Toggle hostel visibility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Toggle visibility for ${hostel['name']}')),
    );
  }

  void _onDeleteHostel(Map<String, dynamic> hostel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Hostel'),
            content: Text(
              'Are you sure you want to delete "${hostel['name']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Delete hostel
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${hostel['name']}')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _onViewBookings(Map<String, dynamic> hostel) {
    // TODO: Navigate to bookings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View bookings for ${hostel['name']}')),
    );
  }
}
