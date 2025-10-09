// Photos & Media Step Widget for Hostel Posting
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_utils.dart';
import '../../../../domain/models/hostel_steps.dart';

class HostelPhotosStep extends StatefulWidget {
  final HostelPhotosData data;
  final ValueChanged<HostelPhotosData> onDataChanged;

  const HostelPhotosStep({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HostelPhotosStep> createState() => _HostelPhotosStepState();
}

class _HostelPhotosStepState extends State<HostelPhotosStep> {
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _virtualTourController;
  late TextEditingController _floorPlanController;
  late TextEditingController _neighborhoodMapController;

  // Video recording
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  bool _isRecording = false;
  String? _recordedVideoPath;
  bool _isVideoPlaying = false;
  bool _showVideoPreview = false;

  // Map location
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  bool _isMapVisible = false;

  @override
  void initState() {
    super.initState();
    _virtualTourController = TextEditingController(
      text: widget.data.virtualTour,
    );
    _floorPlanController = TextEditingController(text: widget.data.floorPlan);
    _neighborhoodMapController = TextEditingController(
      text: widget.data.neighborhoodMap,
    );

    _addListeners();
  }

  void _addListeners() {
    _virtualTourController.addListener(_updateData);
    _floorPlanController.addListener(_updateData);
    _neighborhoodMapController.addListener(_updateData);
  }

  void _updateData() {
    widget.onDataChanged(
      widget.data.copyWith(
        virtualTour: _recordedVideoPath ?? _virtualTourController.text.trim(),
        floorPlan: _floorPlanController.text.trim(),
        neighborhoodMap: _neighborhoodMapController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _virtualTourController.dispose();
    _floorPlanController.dispose();
    _neighborhoodMapController.dispose();
    _cameraController?.dispose();
    _videoController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildPhotosSection(),
          const SizedBox(height: 24),
          _buildVideoWalkthroughSection(),
          const SizedBox(height: 24),
          _buildVirtualTourSection(),
          const SizedBox(height: 24),
          _buildFloorPlanSection(),
          const SizedBox(height: 24),
          _buildNeighborhoodMapSection(),
          const SizedBox(height: 32),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos & Media',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Show students what your hostel looks like',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hostel Photos *',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add photos of your hostel rooms, common areas, and facilities',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildPhotosSelector(),
      ],
    );
  }

  Widget _buildPhotosSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_rounded, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _pickPhotos,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.data.photos.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.data.photos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final photoPath = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(photoPath),
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              final photos = List<String>.from(
                                widget.data.photos,
                              );
                              photos.removeAt(index);
                              widget.onDataChanged(
                                widget.data.copyWith(photos: photos),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.grey[400],
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'No photos added yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add photos to help students visualize your hostel',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoWalkthroughSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Walkthrough',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Record a video walkthrough of your hostel (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildVideoRecordingInterface(),
      ],
    );
  }

  Widget _buildVideoRecordingInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Column(
        children: [
          // Video Preview/Recording Area
          _buildVideoArea(),

          const SizedBox(height: 16),

          // Action Buttons
          _buildVideoActionButtons(),

          const SizedBox(height: 12),

          // Upload Option
          _buildVideoUploadOption(),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _getVideoContent(),
      ),
    );
  }

  Widget _getVideoContent() {
    // Show recorded video preview
    if (_showVideoPreview &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return Stack(
        children: [
          VideoPlayer(_videoController!),
          // Play/Pause overlay
          Center(
            child: GestureDetector(
              onTap: _toggleVideoPlayback,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isVideoPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Video duration
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_videoController!.value.duration),
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

    // Show camera preview
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }

    // Show placeholder
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, color: Colors.grey[400], size: 48),
          const SizedBox(height: 8),
          Text(
            'No video recorded yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Record a new video or upload an existing one',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Record new video
        if (!_isRecording && !_showVideoPreview)
          ElevatedButton.icon(
            onPressed: _startVideoRecording,
            icon: const Icon(Icons.videocam_rounded, size: 18),
            label: const Text('Record Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

        // Stop recording
        if (_isRecording)
          ElevatedButton.icon(
            onPressed: _stopVideoRecording,
            icon: const Icon(Icons.stop_rounded, size: 18),
            label: const Text('Stop Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

        // Preview recorded video
        if (_recordedVideoPath != null && !_showVideoPreview)
          ElevatedButton.icon(
            onPressed: _previewRecordedVideo,
            icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
            label: const Text('Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

        // Confirm and save video
        if (_showVideoPreview)
          ElevatedButton.icon(
            onPressed: _confirmAndSaveVideo,
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Confirm & Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

        // Discard video
        if (_showVideoPreview)
          OutlinedButton.icon(
            onPressed: _discardVideo,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Discard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[600]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoUploadOption() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _uploadExistingVideo,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('Upload Existing Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualTourSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Virtual Tour Link',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share a virtual tour or video walkthrough (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _virtualTourController,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'https://youtube.com/watch?v=... or https://example.com/virtual-tour',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.video_library_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Floor Plan Link',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share a floor plan or layout diagram (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _floorPlanController,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'https://example.com/floor-plan or upload image',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.map_rounded, color: Colors.grey[600], size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeighborhoodMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neighborhood Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pin your hostel location on the map (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Map Interface
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                _isMapVisible && _selectedLocation != null
                    ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation!,
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      onTap: _onMapTap,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    )
                    : Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No location selected',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Get Current Location" to start',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 12),

        // Location Controls
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Get Current Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedLocation != null ? _saveLocation : null,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Manual URL Input
        TextFormField(
          controller: _neighborhoodMapController,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: 'Or enter map URL manually',
            hintText: 'https://maps.google.com/...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.link_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Good photos and videos are crucial! Show rooms, common areas, and unique features. Record a walkthrough or upload an existing video to help students feel confident about their choice!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Video Recording Methods
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        await _cameraController!.initialize();
        setState(() {});
      }
    } catch (e) {
      AppUtils.showErrorSnackBar(context, 'Failed to initialize camera: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null) {
      await _initializeCamera();
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        AppUtils.showErrorSnackBar(context, 'Failed to start recording: $e');
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController != null && _isRecording) {
      try {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordedVideoPath = videoFile.path;
        });

        // Update form data with new video path
        _updateData();

        AppUtils.showSuccessSnackBar(
          context,
          'Video recorded! Tap "Preview" to review it.',
        );
      } catch (e) {
        AppUtils.showErrorSnackBar(context, 'Failed to stop recording: $e');
      }
    }
  }

  void _saveVideoWalkthrough() {
    if (_recordedVideoPath != null) {
      widget.onDataChanged(
        widget.data.copyWith(virtualTour: _recordedVideoPath!),
      );
      AppUtils.showSuccessSnackBar(context, 'Video walkthrough saved!');
    }
  }

  // New video handling methods
  void _previewRecordedVideo() async {
    if (_recordedVideoPath != null) {
      _videoController = VideoPlayerController.file(File(_recordedVideoPath!));
      await _videoController!.initialize();

      // Add listener for video completion
      _videoController!.addListener(() {
        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          setState(() {
            _isVideoPlaying = false;
          });
        }
      });

      setState(() {
        _showVideoPreview = true;
        _isVideoPlaying = false;
      });
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController != null) {
      if (_isVideoPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  void _confirmAndSaveVideo() {
    if (_recordedVideoPath != null) {
      widget.onDataChanged(
        widget.data.copyWith(virtualTour: _recordedVideoPath!),
      );
      AppUtils.showSuccessSnackBar(
        context,
        'Video walkthrough confirmed and saved!',
      );
      setState(() {
        _showVideoPreview = false;
        _isVideoPlaying = false;
      });
    }
  }

  void _discardVideo() {
    setState(() {
      _recordedVideoPath = null;
      _showVideoPreview = false;
      _isVideoPlaying = false;
      _videoController?.dispose();
      _videoController = null;
    });
    AppUtils.showSuccessSnackBar(context, 'Video discarded');
  }

  Future<void> _uploadExistingVideo() async {
    try {
      final XFile? videoFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limit to 5 minutes
      );

      if (videoFile != null) {
        // Check file size (limit to 100MB)
        final file = File(videoFile.path);
        final fileSize = await file.length();
        const maxSize = 100 * 1024 * 1024; // 100MB

        if (fileSize > maxSize) {
          AppUtils.showErrorSnackBar(
            context,
            'Video file is too large. Please select a video smaller than 100MB.',
          );
          return;
        }

        setState(() {
          _recordedVideoPath = videoFile.path;
        });

        // Update form data with new video path
        _updateData();

        // Show preview of uploaded video
        _previewRecordedVideo();

        AppUtils.showSuccessSnackBar(context, 'Video uploaded successfully!');
      }
    } catch (e) {
      AppUtils.showErrorSnackBar(
        context,
        'Failed to upload video. Please try again.',
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Map Location Methods
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppUtils.showErrorSnackBar(context, 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppUtils.showErrorSnackBar(
            context,
            'Location permissions are denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppUtils.showErrorSnackBar(
          context,
          'Location permissions are permanently denied',
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _selectedLocation!,
            infoWindow: const InfoWindow(title: 'Hostel Location'),
          ),
        };
        _isMapVisible = true;
      });
    } catch (e) {
      AppUtils.showErrorSnackBar(context, 'Failed to get location: $e');
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'Hostel Location'),
        ),
      };
    });
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      final locationString =
          '${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
      widget.onDataChanged(
        widget.data.copyWith(neighborhoodMap: locationString),
      );
      AppUtils.showSuccessSnackBar(context, 'Location saved!');
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          final photos = List<String>.from(widget.data.photos);
          photos.addAll(images.map((image) => image.path));
          widget.onDataChanged(widget.data.copyWith(photos: photos));
        });
      }
    } catch (e) {
      AppUtils.showErrorSnackBar(
        context,
        'Failed to pick photos. Please try again.',
      );
    }
  }
}
