// Core Services - Local File Storage Service
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class LocalFileStorageService {
  static final LocalFileStorageService _instance =
      LocalFileStorageService._internal();
  factory LocalFileStorageService() => _instance;
  LocalFileStorageService._internal();

  // Cache directory for downloaded files
  Directory? _cacheDirectory;

  // Initialize the cache directory
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory(path.join(appDir.path, 'chat_media'));

      // Create the directory if it doesn't exist
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }

      print(
        'DEBUG: Local file storage initialized at: ${_cacheDirectory!.path}',
      );
    } catch (e) {
      print('ERROR: Failed to initialize local file storage: $e');
    }
  }

  // Get the cache directory
  Directory get cacheDirectory {
    if (_cacheDirectory == null) {
      throw Exception(
        'LocalFileStorageService not initialized. Call initialize() first.',
      );
    }
    return _cacheDirectory!;
  }

  // Download file from URL and save locally
  Future<String?> downloadAndSaveFile({
    required String fileUrl,
    required String fileName,
    required String chatId,
    required String messageId,
    Function(double)? onProgress,
  }) async {
    try {
      print('DEBUG: Starting download for: $fileName');

      // Create unique filename to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = path.extension(fileName);
      final baseName = path.basenameWithoutExtension(fileName);
      final uniqueFileName =
          '${timestamp}_${messageId}_${baseName}$fileExtension';

      // Create chat-specific directory
      final chatDir = Directory(path.join(cacheDirectory.path, chatId));
      if (!await chatDir.exists()) {
        await chatDir.create(recursive: true);
      }

      // Full local file path
      final localFilePath = path.join(chatDir.path, uniqueFileName);
      final localFile = File(localFilePath);

      print('DEBUG: Downloading to: $localFilePath');

      // Download file
      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        // Save file locally
        await localFile.writeAsBytes(response.bodyBytes);

        print('DEBUG: File saved locally: $localFilePath');
        print('DEBUG: File size: ${await localFile.length()} bytes');

        return localFilePath;
      } else {
        print(
          'ERROR: Failed to download file. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('ERROR: Failed to download and save file: $e');
      return null;
    }
  }

  // Check if file exists locally
  Future<bool> fileExistsLocally(String localFilePath) async {
    try {
      final file = File(localFilePath);
      return await file.exists();
    } catch (e) {
      print('ERROR: Failed to check if file exists: $e');
      return false;
    }
  }

  // Get local file
  Future<File?> getLocalFile(String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get local file: $e');
      return null;
    }
  }

  // Get file size
  Future<int?> getFileSize(String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get file size: $e');
      return null;
    }
  }

  // Delete local file
  Future<bool> deleteLocalFile(String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (await file.exists()) {
        await file.delete();
        print('DEBUG: Local file deleted: $localFilePath');
        return true;
      }
      return false;
    } catch (e) {
      print('ERROR: Failed to delete local file: $e');
      return false;
    }
  }

  // Clear all files for a specific chat
  Future<void> clearChatFiles(String chatId) async {
    try {
      final chatDir = Directory(path.join(cacheDirectory.path, chatId));
      if (await chatDir.exists()) {
        await chatDir.delete(recursive: true);
        print('DEBUG: Cleared all files for chat: $chatId');
      }
    } catch (e) {
      print('ERROR: Failed to clear chat files: $e');
    }
  }

  // Clear all cached files
  Future<void> clearAllFiles() async {
    try {
      if (await cacheDirectory.exists()) {
        await cacheDirectory.delete(recursive: true);
        await cacheDirectory.create(recursive: true);
        print('DEBUG: Cleared all cached files');
      }
    } catch (e) {
      print('ERROR: Failed to clear all files: $e');
    }
  }

  // Get total cache size
  Future<int> getTotalCacheSize() async {
    try {
      int totalSize = 0;
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('ERROR: Failed to get cache size: $e');
      return 0;
    }
  }

  // Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
