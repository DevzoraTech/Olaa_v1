// Roommate Requests Manager Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/supabase_database_service.dart';
import '../../../../../core/services/supabase_auth_service.dart';
import '../listing_cards/roommate_request_card.dart';
import '../empty_states/roommate_requests_empty_state.dart';

class RoommateRequestsManager extends StatefulWidget {
  final String filter;

  const RoommateRequestsManager({super.key, required this.filter});

  @override
  State<RoommateRequestsManager> createState() =>
      _RoommateRequestsManagerState();
}

class _RoommateRequestsManagerState extends State<RoommateRequestsManager> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoommateRequests();
  }

  @override
  void didUpdateWidget(RoommateRequestsManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _loadRoommateRequests();
    }
  }

  Future<void> _loadRoommateRequests() async {
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

      // Fetch user's roommate requests from Supabase
      final requests = await SupabaseDatabaseService.instance
          .getUserRoommateRequests(userId);

      // Apply filter if needed
      List<Map<String, dynamic>> filteredRequests = requests;
      if (widget.filter != 'All') {
        filteredRequests =
            requests.where((request) {
              final status =
                  request['status']?.toString().toLowerCase() ?? 'active';
              return status == widget.filter.toLowerCase();
            }).toList();
      }

      if (!mounted) return;
      setState(() {
        _requests = filteredRequests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load roommate requests: ${e.toString()}';
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
              'Error Loading Requests',
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
              onPressed: _loadRoommateRequests,
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

    if (_requests.isEmpty) {
      return RoommateRequestsEmptyState(onAddNew: _onAddNew);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12), // Reduced from 16
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // Reduced from 16
          child: RoommateRequestCard(
            request: request,
            onEdit: () => _onEditRequest(request),
            onToggleVisibility: () => _onToggleVisibility(request),
            onDelete: () => _onDeleteRequest(request),
            onViewInsights: () => _onViewInsights(request),
          ),
        );
      },
    );
  }

  void _onAddNew() {
    // TODO: Navigate to add roommate request screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Roommate Request')),
    );
  }

  void _onEditRequest(Map<String, dynamic> request) {
    // TODO: Navigate to edit roommate request screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${request['title']}')));
  }

  void _onToggleVisibility(Map<String, dynamic> request) {
    // TODO: Toggle request visibility
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Toggle visibility for ${request['title']}')),
    );
  }

  void _onDeleteRequest(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Request'),
            content: Text(
              'Are you sure you want to delete "${request['title']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Delete request
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${request['title']}')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _onViewInsights(Map<String, dynamic> request) {
    // TODO: Navigate to insights screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View insights for ${request['title']}')),
    );
  }
}
