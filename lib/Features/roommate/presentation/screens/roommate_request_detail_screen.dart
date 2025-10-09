// Presentation Layer - Roommate Request Detail Screen
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/roommate_posting_service.dart';
import '../../../../core/utils/app_utils.dart';
import '../widgets/profile_summary.dart';
import '../widgets/request_details.dart';
import '../widgets/compatibility_info.dart';
import '../widgets/photos_and_media.dart';
import '../widgets/action_buttons.dart';
import '../widgets/extra_features.dart';
import '../../domain/models/roommate_request_model.dart';

class RoommateRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RoommateRequestDetailScreen({super.key, required this.requestId});

  @override
  State<RoommateRequestDetailScreen> createState() =>
      _RoommateRequestDetailScreenState();
}

class _RoommateRequestDetailScreenState
    extends State<RoommateRequestDetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Real data from database
  RoommateRequest? _request;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final requestData = await RoommatePostingService.getRoommateRequestById(
        requestId: widget.requestId,
      );

      if (requestData != null) {
        print('DEBUG: Retrieved roommate request data: $requestData');
        print('DEBUG: Photos from database: ${requestData['photos']}');
        setState(() {
          _request = _convertToRoommateRequest(requestData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Roommate request not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load roommate request: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  RoommateRequest _convertToRoommateRequest(Map<String, dynamic> data) {
    final photos = List<String>.from(data['photos'] ?? []);
    final hostelListings = List<String>.from(data['hostel_listings'] ?? []);

    print('DEBUG: Converting photos: $photos');
    print('DEBUG: Converting hostel listings: $hostelListings');
    print(
      'DEBUG: Converting profile picture URL: ${data['profile_picture_url']}',
    );

    return RoommateRequest(
      id: data['id'] ?? '',
      studentId: data['student_id'] ?? '',
      studentName: data['student_name'] ?? '',
      nickname: data['nickname'],
      campus: data['campus'] ?? '',
      yearOfStudy: data['year_of_study'] ?? '',
      bio: data['bio'] ?? '',
      profilePictureUrl: data['profile_picture_url'],
      requestDetails: RequestDetails(
        preferredLocation: data['preferred_location'] ?? '',
        budgetRange: data['budget_range'] ?? '',
        preferredHostel: data['preferred_hostel'] ?? '',
        moveInDate:
            data['move_in_date'] != null
                ? DateTime.parse(data['move_in_date'])
                : DateTime.now(),
        urgency: data['urgency'] ?? '',
        leaseDuration: data['lease_duration'] ?? '',
      ),
      compatibilityInfo: CompatibilityInfo(
        sleepSchedule: _parseSleepSchedule(data['sleep_schedule']),
        lifestylePreference: _parseLifestylePreference(
          data['lifestyle_preference'],
        ),
        smokingPreference: _parseSmokingPreference(data['smoking_preference']),
        drinkingPreference: _parseDrinkingPreference(
          data['drinking_preference'],
        ),
        sharingStyle: _parseSharingStyle(data['sharing_style']),
        compatibilityScore: data['compatibility_score'],
      ),
      photos: photos,
      hostelListings: hostelListings,
      status: _parseRequestStatus(data['status']),
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : DateTime.now(),
      phoneNumber: data['phone_number'],
      isPhoneShared: data['is_phone_shared'] ?? false,
    );
  }

  SleepSchedule _parseSleepSchedule(String? value) {
    switch (value) {
      case 'Early Riser':
        return SleepSchedule.earlyRiser;
      case 'Night Owl':
        return SleepSchedule.nightOwl;
      case 'Flexible':
        return SleepSchedule.flexible;
      default:
        return SleepSchedule.flexible;
    }
  }

  LifestylePreference _parseLifestylePreference(String? value) {
    switch (value) {
      case 'Quiet':
        return LifestylePreference.quiet;
      case 'Social':
        return LifestylePreference.social;
      case 'Music Lover':
        return LifestylePreference.musicLover;
      case 'Study Focused':
        return LifestylePreference.studious;
      default:
        return LifestylePreference.quiet;
    }
  }

  SmokingPreference _parseSmokingPreference(String? value) {
    switch (value) {
      case 'Non-smoker':
        return SmokingPreference.nonSmoker;
      case 'Smoker':
        return SmokingPreference.smoker;
      case 'Occasional':
        return SmokingPreference.okayWithSmoking;
      default:
        return SmokingPreference.nonSmoker;
    }
  }

  DrinkingPreference _parseDrinkingPreference(String? value) {
    switch (value) {
      case 'Non-drinker':
        return DrinkingPreference.nonDrinker;
      case 'Social Drinker':
        return DrinkingPreference.socialDrinker;
      case 'Regular Drinker':
        return DrinkingPreference.regularDrinker;
      default:
        return DrinkingPreference.socialDrinker;
    }
  }

  SharingStyle _parseSharingStyle(String? value) {
    switch (value) {
      case 'Private':
        return SharingStyle.private;
      case 'Okay with Visitors':
        return SharingStyle.okayWithVisitors;
      case 'Very Social':
        return SharingStyle.verySocial;
      default:
        return SharingStyle.okayWithVisitors;
    }
  }

  RequestStatus _parseRequestStatus(String? value) {
    switch (value) {
      case 'Active':
        return RequestStatus.active;
      case 'Matched':
        return RequestStatus.matched;
      case 'Expired':
        return RequestStatus.expired;
      case 'Cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey[800],
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Roommate Request',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_request != null)
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppTheme.primaryColor : Colors.grey[600],
                size: 22,
              ),
              onPressed: _onBookmarkPressed,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              'Error Loading Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequest,
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

    if (_request == null) {
      return const Center(child: Text('Roommate request not found'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Profile Summary
          ProfileSummary(request: _request!, onProfileTap: _onProfilePressed),

          const SizedBox(height: 16),

          // Request Details
          RequestDetailsWidget(request: _request!),

          const SizedBox(height: 16),

          // Compatibility Info
          CompatibilityInfoWidget(
            compatibilityInfo: _request!.compatibilityInfo,
          ),

          const SizedBox(height: 16),

          // Photos & Media
          if (_request!.photos.isNotEmpty ||
              _request!.hostelListings.isNotEmpty)
            PhotosAndMedia(
              photos: _request!.photos,
              hostelListings: _request!.hostelListings,
            ),

          if (_request!.photos.isNotEmpty ||
              _request!.hostelListings.isNotEmpty)
            const SizedBox(height: 16),

          // Action Buttons
          ActionButtons(
            request: _request!,
            onChat: _onChatPressed,
            onCall: _onCallPressed,
            onAccept: _onAcceptPressed,
            onDecline: _onDeclinePressed,
          ),

          const SizedBox(height: 16),

          // Extra Features
          ExtraFeatures(
            onBookmark: _onBookmarkPressed,
            onReport: _onReportPressed,
            onShare: _onSharePressed,
            isBookmarked: _isBookmarked,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _onProfilePressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening profile...')));
    // TODO: Navigate to profile screen
  }

  void _onChatPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening chat...')));
    // TODO: Navigate to chat screen
  }

  void _onCallPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calling...')));
    // TODO: Initiate phone call
  }

  void _onAcceptPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match request sent to John!')),
    );
    // TODO: Send match request
  }

  void _onDeclinePressed() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Decline Request'),
            content: const Text(
              'Are you sure you want to decline this roommate request?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request declined')),
                  );
                  // TODO: Decline request
                },
                child: const Text('Decline'),
              ),
            ],
          ),
    );
  }

  void _onBookmarkPressed() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Request bookmarked' : 'Bookmark removed',
        ),
      ),
    );
  }

  void _onReportPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    // TODO: Open report dialog
  }

  void _onSharePressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request shared')));
    // TODO: Share request
  }
}
