// Presentation Layer - Profile Picture Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_auth_service.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';

class ProfilePictureScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String userType;

  // Student fields
  final String? campus;
  final String? year;
  final String? course;
  final String? phone;
  final String? gender;
  final List<String>? interests;

  // Hostel provider fields
  final String? businessName;
  final String? primaryPhone;
  final String? secondaryPhone;
  final String? locationName;
  final String? address;

  const ProfilePictureScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.campus,
    this.year,
    this.course,
    this.phone,
    this.gender,
    this.interests,
    this.businessName,
    this.primaryPhone,
    this.secondaryPhone,
    this.locationName,
    this.address,
  });

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _imageUrl;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(24),
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
              // Title
              Text(
                'Profile Picture',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Add a profile picture to help others recognize you and build trust.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Profile Picture Upload Area
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Stack(
                      children: [
                        if (_selectedImage != null)
                          ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_isUploadingImage)
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Option
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gallery Option
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Skip Option
              Center(
                child: TextButton(
                  onPressed: () {
                    _handleComplete();
                  },
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Complete Registration Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            _isUploadingImage
                                ? 'Uploading Image...'
                                : 'Complete Registration',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              // Add extra padding at the bottom to ensure content is visible above keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? finalImageUrl = _imageUrl;

      // Skip image upload during signup - will be uploaded after authentication
      // This avoids RLS policy issues during the signup process
      if (_selectedImage != null) {
        print(
          'DEBUG: Image selected but will be uploaded after authentication',
        );
        // Store the image path for later upload after user is created
        finalImageUrl = null; // Will be uploaded after signup completes
      }

      // Complete signup with all collected data
      await _authService.completeSignUp(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        userType: widget.userType,
        // Student fields
        campus: widget.campus,
        yearOfStudy: widget.year,
        course: widget.course,
        phone: widget.phone,
        gender: widget.gender,
        interests: widget.interests,
        // Hostel provider fields
        businessName: widget.businessName,
        primaryPhone: widget.primaryPhone,
        secondaryPhone: widget.secondaryPhone,
        locationName: widget.locationName,
        address: widget.address,
        // Event organizer fields (not used - event organizers go directly to their screen)
        organizationName: null,
        organizationType: null,
        organizationDescription: null,
        organizationWebsite: null,
        organizationPhone: null,
        // Promoter fields (not used - promoters go directly to their screen)
        agencyName: null,
        agencyType: null,
        agencyDescription: null,
        agencyWebsite: null,
        agencyPhone: null,
        // Profile image
        profileImageUrl: finalImageUrl,
        // Image path for upload after authentication
        imagePath: _selectedImage?.path,
      );

      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Account created successfully!');
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showErrorSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Select Profile Picture',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Camera option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use camera to take a new photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),

                // Gallery option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select from your photo library'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                if (_selectedImage != null) ...[
                  const Divider(),
                  // Remove photo option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    title: const Text('Remove Photo'),
                    subtitle: const Text('Remove current profile picture'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _imageUrl = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('DEBUG: Starting image picker for source: $source');

      // Request permissions first
      bool hasPermission = await _requestPermissions(source);
      print('DEBUG: Permission result: $hasPermission');

      if (!hasPermission) {
        print('DEBUG: Permission denied, returning early');
        return;
      }

      print('DEBUG: Calling image picker...');
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      print('DEBUG: Image picker result: ${image?.path}');

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isUploadingImage = false; // Don't upload immediately
          _imageUrl = null; // Clear previous URL
        });

        if (mounted) {
          AppUtils.showSuccessSnackBar(
            context,
            'Image selected! Tap "Complete Registration" to upload.',
          );
        }
      } else {
        print('DEBUG: No image selected');
      }
    } catch (e) {
      print('DEBUG: Error in _pickImage: $e');
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          'Failed to pick image: ${e.toString()}',
        );
      }
    }
  }

  Future<bool> _requestPermissions(ImageSource source) async {
    print('DEBUG: Requesting permissions for source: $source');

    if (source == ImageSource.camera) {
      // Check current camera permission status first
      final currentStatus = await Permission.camera.status;
      print('DEBUG: Camera permission status: $currentStatus');

      if (currentStatus == PermissionStatus.granted) {
        print('DEBUG: Camera permission already granted');
        return true; // Already granted, no need to request
      }

      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      print('DEBUG: Camera permission request result: $cameraStatus');

      if (cameraStatus == PermissionStatus.permanentlyDenied) {
        await _showPermissionDeniedDialog(
          context,
          'Camera Permission Denied',
          'Camera access has been permanently denied. Please enable it in Settings > Apps > Olaa > Permissions.',
        );
        return false;
      } else if (cameraStatus == PermissionStatus.denied) {
        await _showPermissionExplanationDialog(
          context,
          'Camera Permission',
          'Camera access is needed to take your profile photo.',
        );
        // Try requesting again
        final retryStatus = await Permission.camera.request();
        print('DEBUG: Camera permission retry result: $retryStatus');
        return retryStatus == PermissionStatus.granted;
      }
      return cameraStatus == PermissionStatus.granted;
    } else {
      // For gallery, we need to handle permissions more carefully
      PermissionStatus status;

      if (Platform.isAndroid) {
        // For Android, check both photos and storage permissions
        final photosStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;
        print(
          'DEBUG: Android photos status: $photosStatus, storage status: $storageStatus',
        );

        // If either is granted, we can proceed
        if (photosStatus == PermissionStatus.granted ||
            storageStatus == PermissionStatus.granted) {
          print('DEBUG: Android permission already granted');
          return true;
        }

        // Try to request photos permission first (Android 13+)
        try {
          status = await Permission.photos.request();
          print('DEBUG: Android photos permission request result: $status');
          if (status == PermissionStatus.granted) {
            return true;
          }
        } catch (e) {
          print('DEBUG: Android photos permission failed, trying storage: $e');
          // Fallback to storage permission for older Android versions
          status = await Permission.storage.request();
          print('DEBUG: Android storage permission request result: $status');
        }
      } else {
        // iOS - use photos permission
        final currentStatus = await Permission.photos.status;
        print('DEBUG: iOS photos permission status: $currentStatus');
        if (currentStatus == PermissionStatus.granted) {
          print('DEBUG: iOS permission already granted');
          return true;
        }
        status = await Permission.photos.request();
        print('DEBUG: iOS photos permission request result: $status');
      }

      if (status == PermissionStatus.permanentlyDenied) {
        await _showPermissionDeniedDialog(
          context,
          'Storage Permission Denied',
          'Storage access has been permanently denied. Please enable it in Settings > Apps > Olaa > Permissions.',
        );
        return false;
      } else if (status == PermissionStatus.denied) {
        await _showPermissionExplanationDialog(
          context,
          'Storage Permission',
          'Storage access is needed to select photos from your gallery.',
        );
        // Try requesting again
        PermissionStatus retryStatus;
        if (Platform.isAndroid) {
          try {
            retryStatus = await Permission.photos.request();
          } catch (e) {
            retryStatus = await Permission.storage.request();
          }
        } else {
          retryStatus = await Permission.photos.request();
        }
        print('DEBUG: Permission retry result: $retryStatus');
        return retryStatus == PermissionStatus.granted;
      }
      return status == PermissionStatus.granted;
    }
  }

  Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionExplanationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap "Allow" when the permission dialog appears',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showUploadFailedDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[600],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload Failed',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed to upload your profile picture. This might be due to network issues or server configuration.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can continue without a profile picture and add one later.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue Without Image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
