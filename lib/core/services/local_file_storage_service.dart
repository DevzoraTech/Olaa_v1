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

      // Check if file already exists
      if (await localFile.exists()) {
        print('DEBUG: File already exists locally: $localFilePath');
        onProgress?.call(1.0);
        return localFilePath;
      }

      // Download file with progress tracking
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(fileUrl));
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        final totalBytes = streamedResponse.contentLength ?? 0;
        int downloadedBytes = 0;

        // Create file and write stream
        final fileStream = localFile.openWrite();

        await for (final chunk in streamedResponse.stream) {
          fileStream.add(chunk);
          downloadedBytes += chunk.length;

          // Update progress if callback provided
          if (onProgress != null && totalBytes > 0) {
            final progress = downloadedBytes / totalBytes;
            onProgress(progress);
          }
        }

        await fileStream.close();
        client.close();

        print('DEBUG: File saved locally: $localFilePath');
        print('DEBUG: File size: ${await localFile.length()} bytes');

        return localFilePath;
      } else {
        print(
          'ERROR: Failed to download file. Status code: ${streamedResponse.statusCode}',
        );
        client.close();
        return null;
      }
    } catch (e) {
      print('ERROR: Failed to download and save file: $e');
      return null;
    }
  }

  // Check if a file is already downloaded for a specific message
  Future<String?> getLocalFilePathForMessage({
    required String chatId,
    required String messageId,
    required String fileName,
  }) async {
    try {
      final chatDir = Directory(path.join(cacheDirectory.path, chatId));
      if (!await chatDir.exists()) {
        return null;
      }

      // Look for existing files for this message
      final files = await chatDir.list().toList();
      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          // Check if this file belongs to the message (contains messageId)
          if (fileName.contains(messageId)) {
            return file.path;
          }
        }
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get local file path for message: $e');
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
