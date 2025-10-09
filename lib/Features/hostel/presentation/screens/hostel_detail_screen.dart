// Hostel Detail Screen
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';

class HostelDetailScreen extends StatefulWidget {
  final Map<String, dynamic> hostelData;

  const HostelDetailScreen({super.key, required this.hostelData});

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    final videoUrl = widget.hostelData['virtual_tour'];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _videoController!.initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildPhotosSection(),
                  const SizedBox(height: 24),
                  _buildVideoSection(),
                  const SizedBox(height: 24),
                  _buildRoomDetails(),
                  const SizedBox(height: 24),
                  _buildPricingDetails(),
                  const SizedBox(height: 24),
                  _buildAmenitiesSection(),
                  const SizedBox(height: 24),
                  _buildRulesSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.hostelData['name'] ?? widget.hostelData['title'] ?? 'Hostel',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: _buildHeroImage(),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: const Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final photos = List<String>.from(widget.hostelData['photos'] ?? []);
    if (photos.isEmpty) {
      return Container(
        color: AppTheme.primaryColor,
        child: const Center(
          child: Icon(Icons.home_outlined, color: Colors.white, size: 80),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          photos[_currentImageIndex],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.primaryColor,
              child: const Center(
                child: Icon(Icons.home_outlined, color: Colors.white, size: 80),
              ),
            );
          },
        ),
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${photos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hostelData['name'] ?? widget.hostelData['title'] ?? 'Hostel',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.hostelData['description'] ?? 'No description available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.hostelData['address'] ?? 'Address not provided',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.school_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.hostelData['campus'] ?? 'Campus not specified',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    final photos = List<String>.from(widget.hostelData['photos'] ?? []);
    if (photos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (photos.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index
                            ? AppTheme.primaryColor
                            : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final videoUrl = widget.hostelData['virtual_tour'];
    if (videoUrl == null || videoUrl.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Virtual Tour',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    _isVideoInitialized
                        ? Stack(
                          children: [
                            VideoPlayer(_videoController!),
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_videoController!.value.isPlaying) {
                                      _videoController!.pause();
                                    } else {
                                      _videoController!.play();
                                    }
                                  });
                                },
                                icon: Icon(
                                  _videoController!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ],
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Room Type',
            widget.hostelData['room_type'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Gender Preference',
            widget.hostelData['gender_preference'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Furnishing',
            widget.hostelData['furnishing'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Capacity',
            '${widget.hostelData['capacity'] ?? 1} person(s)',
          ),
          _buildDetailRow(
            'Room Size',
            '${widget.hostelData['room_size'] ?? 0} sq m',
          ),
          _buildDetailRow(
            'Utilities',
            widget.hostelData['utilities'] ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetails() {
    final monthlyRent =
        widget.hostelData['monthly_rent'] ??
        widget.hostelData['price_per_month'] ??
        0;
    final currency = widget.hostelData['currency'] ?? 'UGX';
    final securityDeposit = widget.hostelData['security_deposit'] ?? 0;
    final utilitiesIncluded = widget.hostelData['utilities_included'] ?? false;
    final utilitiesCost = widget.hostelData['utilities_cost'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing & Terms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_money_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$currency ${monthlyRent.toStringAsFixed(0)}/month',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Security Deposit',
            '$currency ${securityDeposit.toStringAsFixed(0)}',
          ),
          _buildDetailRow(
            'Payment Schedule',
            widget.hostelData['payment_schedule'] ?? 'Monthly',
          ),
          _buildDetailRow(
            'Utilities Included',
            utilitiesIncluded ? 'Yes' : 'No',
          ),
          if (!utilitiesIncluded && utilitiesCost > 0)
            _buildDetailRow(
              'Utilities Cost',
              '$currency ${utilitiesCost.toStringAsFixed(0)}/month',
            ),
          _buildDetailRow(
            'Lease Duration',
            widget.hostelData['lease_duration'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Move-in Date',
            widget.hostelData['move_in_date'] ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = List<String>.from(widget.hostelData['amenities'] ?? []);
    final nearbyFacilities = List<String>.from(
      widget.hostelData['nearby_facilities'] ?? [],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amenities & Facilities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (amenities.isNotEmpty) ...[
            const Text(
              'Room Amenities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  amenities
                      .map((amenity) => _buildAmenityChip(amenity))
                      .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (nearbyFacilities.isNotEmpty) ...[
            const Text(
              'Nearby Facilities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  nearbyFacilities
                      .map((facility) => _buildAmenityChip(facility))
                      .toList(),
            ),
          ],
          const SizedBox(height: 16),
          _buildDetailRow(
            'Parking',
            widget.hostelData['parking_info'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Security Features',
            widget.hostelData['security_features'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Internet Speed',
            widget.hostelData['internet_speed'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Laundry Facilities',
            widget.hostelData['laundry_facilities'] ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    final houseRules = List<String>.from(
      widget.hostelData['house_rules'] ?? [],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rules & Policies',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (houseRules.isNotEmpty) ...[
            const Text(
              'House Rules',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...houseRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rule,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildDetailRow(
            'Visitor Policy',
            widget.hostelData['visitor_policy'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Smoking Policy',
            widget.hostelData['smoking_policy'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Pet Policy',
            widget.hostelData['pet_policy'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Noise Policy',
            widget.hostelData['noise_policy'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Cleaning Policy',
            widget.hostelData['cleaning_policy'] ?? 'Not specified',
          ),
          if (widget.hostelData['additional_rules'] != null &&
              widget.hostelData['additional_rules'].isNotEmpty)
            _buildDetailRow(
              'Additional Rules',
              widget.hostelData['additional_rules'],
            ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Provider',
            widget.hostelData['provider_name'] ?? 'Not specified',
          ),
          _buildDetailRow(
            'Contact Info',
            widget.hostelData['contact_info'] ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        amenity,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement call functionality
              },
              icon: const Icon(Icons.phone_rounded, size: 18),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement chat functionality
              },
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
