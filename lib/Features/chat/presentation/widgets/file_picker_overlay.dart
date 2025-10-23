// Presentation Layer - File Picker Overlay Widget
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:typed_data';

class ImageWithCaption {
  final AssetEntity asset;
  final String caption;

  ImageWithCaption({required this.asset, this.caption = ''});
}

class FilePickerOverlay extends StatefulWidget {
  final Function(File, String, int, {String? fileType})? onFileSelected;
  final Function(String)? onLocationSelected;
  final Function(List<AssetEntity>)? onImagesSelected;
  final VoidCallback? onClose;

  const FilePickerOverlay({
    super.key,
    this.onFileSelected,
    this.onLocationSelected,
    this.onImagesSelected,
    this.onClose,
  });

  @override
  State<FilePickerOverlay> createState() => _FilePickerOverlayState();
}

class _FilePickerOverlayState extends State<FilePickerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Share File',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // File picker options grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // First row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPickerOption(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          color: Colors.blue,
                          onTap: () => _pickFromGallery(),
                        ),
                        _buildPickerOption(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: Colors.pink,
                          onTap: () => _pickFromCamera(),
                        ),
                        _buildPickerOption(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          color: Colors.teal,
                          onTap: () => _shareLocation(),
                        ),
                        _buildPickerOption(
                          icon: Icons.contact_phone_rounded,
                          label: 'Contact',
                          color: Colors.lightBlue,
                          onTap: () => _shareContact(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Second row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPickerOption(
                          icon: Icons.description_rounded,
                          label: 'Document',
                          color: Colors.purple,
                          onTap: () => _pickDocument(),
                        ),
                        _buildPickerOption(
                          icon: Icons.headphones_rounded,
                          label: 'Audio',
                          color: Colors.orange,
                          onTap: () => _pickAudio(),
                        ),
                        _buildPickerOption(
                          icon: Icons.poll_rounded,
                          label: 'Poll',
                          color: Colors.amber,
                          onTap: () => _createPoll(),
                        ),
                        _buildPickerOption(
                          icon: Icons.event_rounded,
                          label: 'Event',
                          color: Colors.red,
                          onTap: () => _createEvent(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Third row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPickerOption(
                          icon: Icons.auto_awesome_rounded,
                          label: 'AI Images',
                          color: Colors.blue,
                          onTap: () => _generateAIImage(),
                        ),
                        const SizedBox(width: 80), // Spacing for single item
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      // Request permission
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        print('Permission denied');
        return;
      }

      // ✅ NEW: Get ALL albums with BOTH images AND videos
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common, // ✅ Get both images and videos
        onlyAll: false,
      );

      if (albums.isEmpty) {
        print('No albums found');
        return;
      }

      print('DEBUG: Found ${albums.length} albums (images & videos)');
      for (var album in albums) {
        print('DEBUG: Album: ${album.name}');
      }

      // Get recent media from first album
      final AssetPathEntity recentAlbum = albums.first;
      final List<AssetEntity> assets = await recentAlbum.getAssetListPaged(
        page: 0,
        size: 100,
      );

      if (assets.isEmpty) {
        print('No media found');
        return;
      }

      print('DEBUG: Found ${assets.length} media items in ${recentAlbum.name}');

      // Show custom gallery picker WITH album selector and media type filter
      _showCustomGallery(albums, recentAlbum, assets);
    } catch (e) {
      print('Error accessing gallery: $e');
      // Fallback to file picker
      _pickFromGalleryFallback();
    }
  }

  void _showCustomGallery(
    List<AssetPathEntity> albums,
    AssetPathEntity currentAlbum,
    List<AssetEntity> assets,
  ) {
    Navigator.pop(context); // Close file picker overlay

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _MultiSelectGallery(
            albums: albums, // ✅ Pass all albums
            currentAlbum: currentAlbum, // ✅ Pass current album
            assets: assets,
            onImagesSelected: (selectedAssets) {
              print(
                'DEBUG: onImagesSelected called with ${selectedAssets.length} assets',
              );
              // Don't process here, just close gallery and let parent handle it
              Navigator.pop(context); // Close gallery
              // Pass the selected assets to parent widget
              widget.onImagesSelected?.call(selectedAssets);
            },
          ),
    );
  }

  Future<void> _processSelectedAsset(AssetEntity asset) async {
    try {
      final file = await asset.file;
      if (file != null) {
        final fileName =
            asset.title ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final fileSize = await file.length();

        // Show preview before sending
        _showFilePreview(file, fileName, fileSize);
      }
    } catch (e) {
      print('Error processing selected asset: $e');
    }
  }

  Future<void> _pickFromGalleryFallback() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        final filePath = file.path!;
        final fileName = file.name;
        final fileSize = file.size;

        // Show preview before sending
        _showFilePreview(File(filePath), fileName, fileSize);
      }
    } catch (e) {
      print('Error picking from gallery fallback: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileName = image.name;
        final fileSize = await file.length();

        // Show preview before sending
        _showFilePreview(file, fileName, fileSize);
      }
    } catch (e) {
      print('Error picking from camera: $e');
    }
  }

  Future<void> _shareLocation() async {
    try {
      // Get current location or use a default location
      // For now, we'll use a sample location (you can integrate with geolocation later)
      const double latitude = 37.7749; // San Francisco coordinates
      const double longitude = -122.4194;

      // Create Google Maps URL
      final String mapsUrl =
          'https://www.google.com/maps?q=$latitude,$longitude';

      // Try to open in Google Maps app first
      if (await canLaunchUrl(
        Uri.parse('comgooglemaps://?q=$latitude,$longitude'),
      )) {
        await launchUrl(Uri.parse('comgooglemaps://?q=$latitude,$longitude'));
      } else if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(Uri.parse(mapsUrl));
      } else {
        // Fallback to sharing coordinates as text
        widget.onLocationSelected?.call('📍 Location: $latitude, $longitude');
        widget.onClose?.call();
      }
    } catch (e) {
      print('Error sharing location: $e');
      // Fallback to sharing coordinates as text
      widget.onLocationSelected?.call('📍 Location: 37.7749, -122.4194');
      widget.onClose?.call();
    }
  }

  Future<void> _shareContact() async {
    // TODO: Implement contact sharing
    _showComingSoon('Contact');
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'rtf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        final filePath = file.path!;
        final fileName = file.name;
        final fileSize = file.size;

        // Show preview before sending
        _showFilePreview(File(filePath), fileName, fileSize);
      }
    } catch (e) {
      print('Error picking document: $e');
    }
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        final filePath = file.path!;
        final fileName = file.name;
        final fileSize = file.size;

        // Show preview before sending with audio file type
        _showFilePreview(File(filePath), fileName, fileSize, fileType: 'voice');
      }
    } catch (e) {
      print('Error picking audio: $e');
    }
  }

  Future<void> _createPoll() async {
    // TODO: Implement poll creation
    _showComingSoon('Poll');
  }

  Future<void> _createEvent() async {
    // TODO: Implement event creation
    _showComingSoon('Event');
  }

  Future<void> _generateAIImage() async {
    // TODO: Implement AI image generation
    _showComingSoon('AI Images');
  }

  void _showFilePreview(
    File file,
    String fileName,
    int fileSize, {
    String? fileType,
  }) {
    Navigator.pop(context); // Close the file picker overlay

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Preview File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),

                // File preview
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // File icon and info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getFileIcon(fileName),
                                size: 48,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fileName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatFileSize(fileSize),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Image preview for images
                        if (_isImageFile(fileName))
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleFileSelection(
                              file,
                              fileName,
                              fileSize,
                              fileType: fileType,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _handleFileSelection(
    File file,
    String fileName,
    int fileSize, {
    String? fileType,
  }) {
    print(
      'DEBUG: File picker - Selected file: $fileName, Size: $fileSize, Type: $fileType',
    );
    widget.onFileSelected?.call(file, fileName, fileSize, fileType: fileType);
    widget.onClose?.call();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _processSelectedAssets(List<AssetEntity> selectedAssets) async {
    if (selectedAssets.isEmpty) return;

    try {
      print('DEBUG: Processing ${selectedAssets.length} selected assets');

      // Check if widget is still mounted
      if (!mounted) {
        print('DEBUG: Widget not mounted, skipping preview');
        return;
      }

      // Close gallery first, then show preview
      Navigator.pop(context); // Close gallery

      // Small delay to ensure gallery is closed
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if widget is still mounted after delay
      if (!mounted) {
        print('DEBUG: Widget not mounted after delay, skipping preview');
        return;
      }

      // Show preview for multiple images
      _showMultipleImagePreview(selectedAssets);
    } catch (e) {
      print('Error processing selected assets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing images'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMultipleImagePreview(List<AssetEntity> selectedAssets) {
    print(
      'DEBUG: Showing WhatsApp-style preview for ${selectedAssets.length} images',
    );

    // Check if widget is still mounted
    if (!mounted) {
      print('DEBUG: Widget not mounted, cannot show preview');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => _WhatsAppStylePreview(
              selectedAssets: selectedAssets,
              onSendImages: (imagesWithCaptions) async {
                print(
                  'DEBUG: Sending ${imagesWithCaptions.length} media files with captions',
                );
                Navigator.pop(context); // Close preview
                await _sendImagesWithCaptions(imagesWithCaptions);
              },
              onCancel: () {
                print('DEBUG: Cancelling preview');
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  Future<void> _sendImagesWithCaptions(
    List<ImageWithCaption> imagesWithCaptions,
  ) async {
    try {
      int imageCount = 0;
      int videoCount = 0;

      for (final mediaData in imagesWithCaptions) {
        final file = await mediaData.asset.file;
        if (file != null) {
          // Determine file type and extension
          final isVideo = mediaData.asset.type == AssetType.video;
          final fileExtension = isVideo ? 'mp4' : 'jpg';
          final fileType = isVideo ? 'video' : 'image';

          final fileName =
              mediaData.asset.title ??
              '${isVideo ? 'video' : 'image'}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
          final fileSize = await file.length();

          // Count media types for success message
          if (isVideo) {
            videoCount++;
          } else {
            imageCount++;
          }

          // Send each media file with caption
          widget.onFileSelected?.call(
            file,
            fileName,
            fileSize,
            fileType: fileType,
          );
        }
      }

      widget.onClose?.call();

      // Create appropriate success message
      String successMessage;
      if (imageCount > 0 && videoCount > 0) {
        successMessage =
            '$imageCount image${imageCount > 1 ? 's' : ''} and $videoCount video${videoCount > 1 ? 's' : ''} sent successfully!';
      } else if (imageCount > 0) {
        successMessage =
            '$imageCount image${imageCount > 1 ? 's' : ''} sent successfully!';
      } else if (videoCount > 0) {
        successMessage =
            '$videoCount video${videoCount > 1 ? 's' : ''} sent successfully!';
      } else {
        successMessage = 'Media sent successfully!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error sending media with captions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error sending media'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMultipleImages(List<AssetEntity> selectedAssets) async {
    try {
      for (final asset in selectedAssets) {
        final file = await asset.file;
        if (file != null) {
          final fileName =
              asset.title ??
              'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final fileSize = await file.length();

          // Send each image
          widget.onFileSelected?.call(file, fileName, fileSize);
        }
      }

      widget.onClose?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedAssets.length} images sent successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error sending multiple images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error sending images'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MultiSelectGallery extends StatefulWidget {
  final List<AssetPathEntity> albums;
  final AssetPathEntity currentAlbum;
  final List<AssetEntity> assets;
  final Function(List<AssetEntity>) onImagesSelected;

  const _MultiSelectGallery({
    required this.albums,
    required this.currentAlbum,
    required this.assets,
    required this.onImagesSelected,
  });

  @override
  State<_MultiSelectGallery> createState() => _MultiSelectGalleryState();
}

class _MultiSelectGalleryState extends State<_MultiSelectGallery> {
  final Set<AssetEntity> _selectedAssets = {};
  late AssetPathEntity _currentAlbum;
  late List<AssetEntity> _currentAssets;
  late List<AssetEntity> _allAssets; // Store all assets before filtering
  bool _isLoadingAlbum = false;

  // ✅ NEW: Media type filter
  String _mediaFilter = 'All'; // All, Photos, Videos

  @override
  void initState() {
    super.initState();
    _currentAlbum = widget.currentAlbum;
    _allAssets = widget.assets;
    _currentAssets = widget.assets;
  }

  Future<void> _loadAlbum(AssetPathEntity album) async {
    setState(() {
      _isLoadingAlbum = true;
    });

    try {
      final assets = await album.getAssetListPaged(page: 0, size: 100);

      setState(() {
        _currentAlbum = album;
        _allAssets = assets;
        _applyMediaFilter(); // Apply current filter
        _selectedAssets.clear(); // Clear selection when changing albums
        _isLoadingAlbum = false;
      });
    } catch (e) {
      print('Error loading album: $e');
      setState(() {
        _isLoadingAlbum = false;
      });
    }
  }

  // ✅ NEW: Apply media type filter
  void _applyMediaFilter() {
    if (_mediaFilter == 'All') {
      _currentAssets = _allAssets;
    } else if (_mediaFilter == 'Photos') {
      _currentAssets =
          _allAssets.where((asset) => asset.type == AssetType.image).toList();
    } else if (_mediaFilter == 'Videos') {
      _currentAssets =
          _allAssets.where((asset) => asset.type == AssetType.video).toList();
    }
  }

  // ✅ NEW: Change media filter
  void _changeMediaFilter(String filter) {
    setState(() {
      _mediaFilter = filter;
      _applyMediaFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title and Done button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    if (_selectedAssets.isNotEmpty)
                      Text(
                        '${_selectedAssets.length} selected',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          _selectedAssets.isNotEmpty
                              ? () {
                                print(
                                  'DEBUG: Done button pressed with ${_selectedAssets.length} assets',
                                );
                                widget.onImagesSelected(
                                  _selectedAssets.toList(),
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ✅ NEW: Album selector dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => _showAlbumPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentAlbum.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ NEW: Media type filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildFilterTab('All', Icons.photo_library)),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterTab('Photos', Icons.photo)),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterTab('Videos', Icons.videocam)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gallery grid
          Expanded(
            child:
                _isLoadingAlbum
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _currentAssets.length, // ✅ Use _currentAssets
                      itemBuilder: (context, index) {
                        final asset =
                            _currentAssets[index]; // ✅ Use _currentAssets
                        final isSelected = _selectedAssets.contains(asset);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedAssets.remove(asset);
                              } else {
                                _selectedAssets.add(asset);
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.blue
                                            : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List?>(
                                    future: asset.thumbnailDataWithSize(
                                      const ThumbnailSize(200, 200),
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                asset.type == AssetType.video
                                                    ? Icons.videocam
                                                    : Icons.image_not_supported,
                                                color: Colors.grey[600],
                                                size: 40,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Selection indicator
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              // ✅ NEW: Video indicator
                              if (asset.type == AssetType.video)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        Text(
                                          _formatDuration(
                                            Duration(seconds: asset.duration),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Show album picker dialog
  void _showAlbumPicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Select Album',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.albums.length,
                    itemBuilder: (context, index) {
                      final album = widget.albums[index];
                      final isSelected = album.id == _currentAlbum.id;

                      return ListTile(
                        leading: FutureBuilder<List<AssetEntity>>(
                          future: album.getAssetListPaged(page: 0, size: 1),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return FutureBuilder<File?>(
                                future: snapshot.data!.first.file,
                                builder: (context, fileSnapshot) {
                                  if (fileSnapshot.hasData &&
                                      fileSnapshot.data != null) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(fileSnapshot.data!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.photo_library,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              );
                            }
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.photo_library,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                        title: Text(
                          album.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.grey[800],
                          ),
                        ),
                        subtitle: FutureBuilder<int>(
                          future: album.assetCountAsync,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text('${snapshot.data} items');
                            }
                            return const Text('Loading...');
                          },
                        ),
                        trailing:
                            isSelected
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                        onTap: () {
                          Navigator.pop(context);
                          _loadAlbum(album);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ✅ NEW: Build filter tab widget
  Widget _buildFilterTab(String filter, IconData icon) {
    final isActive = _mediaFilter == filter;
    return GestureDetector(
      onTap: () => _changeMediaFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              filter,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Format duration helper
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class _WhatsAppStylePreview extends StatefulWidget {
  final List<AssetEntity> selectedAssets;
  final Function(List<ImageWithCaption>) onSendImages;
  final VoidCallback onCancel;

  const _WhatsAppStylePreview({
    required this.selectedAssets,
    required this.onSendImages,
    required this.onCancel,
  });

  @override
  State<_WhatsAppStylePreview> createState() => _WhatsAppStylePreviewState();
}

class _WhatsAppStylePreviewState extends State<_WhatsAppStylePreview> {
  late PageController _pageController;
  late List<ImageWithCaption> _imagesWithCaptions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print(
      'DEBUG: _WhatsAppStylePreview initState with ${widget.selectedAssets.length} assets',
    );
    _pageController = PageController();
    _imagesWithCaptions =
        widget.selectedAssets
            .map((asset) => ImageWithCaption(asset: asset))
            .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: _WhatsAppStylePreview build called');
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Top bar with image counter and send button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),

                // Image counter
                Text(
                  '${_currentIndex + 1} of ${_imagesWithCaptions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Send button
                ElevatedButton(
                  onPressed: () => widget.onSendImages(_imagesWithCaptions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image viewer with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _imagesWithCaptions.length,
              itemBuilder: (context, index) {
                final imageData = _imagesWithCaptions[index];
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: FutureBuilder<File?>(
                      future: imageData.asset.file,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return InteractiveViewer(
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
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

          // Caption input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Page indicators
                if (_imagesWithCaptions.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _imagesWithCaptions.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              index == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Caption input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: TextEditingController(
                      text: _imagesWithCaptions[_currentIndex].caption,
                    ),
                    onChanged: (value) {
                      _imagesWithCaptions[_currentIndex] = ImageWithCaption(
                        asset: _imagesWithCaptions[_currentIndex].asset,
                        caption: value,
                      );
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a caption...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // Add emoji picker or other features
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
