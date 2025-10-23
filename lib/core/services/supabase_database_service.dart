// Data Layer - Supabase Database Service
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../../core/config/supabase_config.dart';

class SupabaseDatabaseService {
  static SupabaseDatabaseService? _instance;
  static SupabaseDatabaseService get instance =>
      _instance ??= SupabaseDatabaseService._();

  SupabaseDatabaseService._();

  // Generic CRUD Operations

  // Create a record
  Future<Map<String, dynamic>?> create({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response =
          await SupabaseConfig.from(table)
              .insert({
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                ...data,
              })
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating record in $table: ${e.toString()}');
      return null;
    }
  }

  // Read records
  Future<List<Map<String, dynamic>>> read({
    required String table,
    String? filterColumn,
    dynamic filterValue,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = SupabaseConfig.from(table).select();

      if (filterColumn != null && filterValue != null) {
        query = query.eq(filterColumn, filterValue);
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error reading records from $table: ${e.toString()}');
      return [];
    }
  }

  // Read single record
  Future<Map<String, dynamic>?> readSingle({
    required String table,
    required String idColumn,
    required dynamic idValue,
  }) async {
    try {
      final response =
          await SupabaseConfig.from(
            table,
          ).select().eq(idColumn, idValue).single();

      return response;
    } catch (e) {
      print('Error reading single record from $table: ${e.toString()}');
      return null;
    }
  }

  // Update record
  Future<Map<String, dynamic>?> update({
    required String table,
    required String idColumn,
    required dynamic idValue,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response =
          await SupabaseConfig.from(table)
              .update({'updated_at': DateTime.now().toIso8601String(), ...data})
              .eq(idColumn, idValue)
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error updating record in $table: ${e.toString()}');
      return null;
    }
  }

  // Delete record
  Future<bool> delete({
    required String table,
    required String idColumn,
    required dynamic idValue,
  }) async {
    try {
      await SupabaseConfig.from(table).delete().eq(idColumn, idValue);

      return true;
    } catch (e) {
      print('Error deleting record from $table: ${e.toString()}');
      return false;
    }
  }

  // Roommate Requests Operations

  Future<Map<String, dynamic>?> createRoommateRequest(
    Map<String, dynamic> data,
  ) async {
    return await create(
      table: SupabaseConfig.roommateRequestsTable,
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> getRoommateRequests({
    String? campus,
    String? userType,
    int? limit,
  }) async {
    dynamic query = SupabaseConfig.from(
      SupabaseConfig.roommateRequestsTable,
    ).select('*, profiles(*)').eq('status', 'active');

    if (campus != null) {
      query = query.eq('campus', campus);
    }

    if (userType != null) {
      query = query.eq('user_type', userType);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    query = query.order('created_at', ascending: false);

    try {
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting roommate requests: ${e.toString()}');
      return [];
    }
  }

  // Hostel Listings Operations

  Future<Map<String, dynamic>?> createHostelListing(
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await SupabaseConfig.from(SupabaseConfig.hostelListingsTable)
              .insert({
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                ...data,
              })
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating record in hostel_listings: ${e.toString()}');
      rethrow; // Re-throw the error so the UI can handle it
    }
  }

  Future<List<Map<String, dynamic>>> getHostelListings({
    String? campus,
    double? maxPrice,
    int? limit,
  }) async {
    dynamic query = SupabaseConfig.from(
      SupabaseConfig.hostelListingsTable,
    ).select('*, profiles(*)').eq('is_available', true);

    if (campus != null) {
      query = query.eq('campus', campus);
    }

    if (maxPrice != null) {
      query = query.lte('price_per_month', maxPrice);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    query = query.order('created_at', ascending: false);

    try {
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting hostel listings: ${e.toString()}');
      return [];
    }
  }

  // Upload hostel media (photos and videos)
  Future<List<String>> uploadHostelMedia({
    required List<String> filePaths,
    required String userId,
    required String hostelId,
  }) async {
    try {
      print(
        'DEBUG: Starting upload to bucket: ${SupabaseConfig.hostelMediaBucket}',
      );
      final List<String> uploadedUrls = [];

      for (int i = 0; i < filePaths.length; i++) {
        print('DEBUG: Processing file $i: ${filePaths[i]}');

        // Check if file exists
        final file = File(filePaths[i]);
        if (!await file.exists()) {
          print('ERROR: File does not exist: ${filePaths[i]}');
          continue;
        }

        final fileName =
            'hostel_${hostelId}_${userId}_${DateTime.now().millisecondsSinceEpoch}_$i';

        // Determine file extension
        String extension = '';
        if (filePaths[i].toLowerCase().contains('.mp4') ||
            filePaths[i].toLowerCase().contains('.mov') ||
            filePaths[i].toLowerCase().contains('.avi')) {
          extension = '.mp4';
        } else if (filePaths[i].toLowerCase().contains('.jpg') ||
            filePaths[i].toLowerCase().contains('.jpeg')) {
          extension = '.jpg';
        } else if (filePaths[i].toLowerCase().contains('.png')) {
          extension = '.png';
        } else {
          extension = '.jpg'; // Default
        }

        final fullFileName = '$fileName$extension';
        print('DEBUG: Uploading as: $fullFileName');

        // Read file bytes
        final fileBytes = await file.readAsBytes();
        print('DEBUG: File size: ${fileBytes.length} bytes');

        // Upload to storage
        final uploadResult = await SupabaseConfig.storageFrom(
          SupabaseConfig.hostelMediaBucket,
        ).uploadBinary(fullFileName, fileBytes);

        print('DEBUG: Upload result: $uploadResult');

        // Get public URL
        final publicUrl = SupabaseConfig.storageFrom(
          SupabaseConfig.hostelMediaBucket,
        ).getPublicUrl(fullFileName);

        print('DEBUG: Public URL: $publicUrl');
        uploadedUrls.add(publicUrl);
      }

      print('DEBUG: Successfully uploaded ${uploadedUrls.length} files');
      return uploadedUrls;
    } catch (e) {
      print('ERROR: Failed to upload hostel media: ${e.toString()}');
      print('ERROR: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Events Operations

  Future<Map<String, dynamic>?> createEvent(Map<String, dynamic> data) async {
    return await create(table: SupabaseConfig.eventsTable, data: data);
  }

  Future<List<Map<String, dynamic>>> getEvents({
    String? category,
    DateTime? startDate,
    int? limit,
  }) async {
    dynamic query = SupabaseConfig.from(SupabaseConfig.eventsTable)
        .select('*, profiles(*)')
        .gte('event_date', DateTime.now().toIso8601String());

    if (category != null) {
      query = query.eq('category', category);
    }

    if (startDate != null) {
      query = query.gte('event_date', startDate.toIso8601String());
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    query = query.order('event_date', ascending: true);

    try {
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting events: ${e.toString()}');
      return [];
    }
  }

  // Marketplace Operations

  Future<Map<String, dynamic>?> createMarketplaceItem(
    Map<String, dynamic> data,
  ) async {
    return await create(
      table: SupabaseConfig.marketplaceItemsTable,
      data: data,
    );
  }

  Future<List<Map<String, dynamic>>> getMarketplaceItems({
    String? category,
    double? maxPrice,
    int? limit,
  }) async {
    dynamic query = SupabaseConfig.from(
      SupabaseConfig.marketplaceItemsTable,
    ).select('*, profiles(*)').eq('is_available', true);

    if (category != null) {
      query = query.eq('category', category);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    query = query.order('created_at', ascending: false);

    try {
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting marketplace items: ${e.toString()}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserMarketplaceItems(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.from(
            SupabaseConfig.marketplaceItemsTable,
          )
          .select('*, profiles(*)')
          .eq('seller_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user marketplace items: ${e.toString()}');
      return [];
    }
  }

  // Increment view count for a marketplace item (only once per user)
  Future<void> incrementMarketplaceItemViews(
    String itemId,
    String userId,
  ) async {
    try {
      // Check if user has already viewed this item
      final existingView =
          await SupabaseConfig.from('marketplace_item_views')
              .select('id')
              .eq('item_id', itemId)
              .eq('user_id', userId)
              .maybeSingle();

      // If user hasn't viewed this item before, record the view
      if (existingView == null) {
        // Insert view record
        await SupabaseConfig.from('marketplace_item_views').insert({
          'item_id': itemId,
          'user_id': userId,
          'viewed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error incrementing marketplace item views: ${e.toString()}');
    }
  }

  // Get updated view count for a specific marketplace item
  Future<int> getMarketplaceItemViewCount(String itemId) async {
    try {
      // Count directly from marketplace_item_views table
      final response = await SupabaseConfig.from(
        'marketplace_item_views',
      ).select('id').eq('item_id', itemId);

      return response.length;
    } catch (e) {
      print('Error getting marketplace item view count: ${e.toString()}');
      return 0;
    }
  }

  // File Upload Operations

  // Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.avi':
        return 'video/avi';
      case '.mov':
        return 'video/quicktime';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.ppt':
        return 'application/vnd.ms-powerpoint';
      case '.pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.zip':
        return 'application/zip';
      case '.rar':
        return 'application/x-rar-compressed';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      default:
        return 'application/octet-stream';
    }
  }

  // Download file from Supabase Storage
  Future<Uint8List?> downloadFile(String fileUrl) async {
    try {
      print('DEBUG: Downloading file from: $fileUrl');

      // Extract file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 3) {
        print('ERROR: Invalid file URL format');
        return null;
      }

      // Reconstruct the file path
      final bucketName = pathSegments[pathSegments.length - 3];
      final fileName = pathSegments[pathSegments.length - 1];
      final chatId = pathSegments[pathSegments.length - 2];
      final filePath = '$chatId/$fileName';

      print('DEBUG: Downloading from bucket: $bucketName, path: $filePath');

      final response = await SupabaseConfig.client.storage
          .from(bucketName)
          .download(filePath);

      print(
        'DEBUG: File downloaded successfully, size: ${response.length} bytes',
      );
      return response;
    } catch (e) {
      print('ERROR: Failed to download file: ${e.toString()}');
      return null;
    }
  }

  // Chat Operations

  // Create a new chat
  Future<Map<String, dynamic>?> createChat({
    required bool isGroup,
    String? groupName,
    String? groupDescription,
    String? groupImageUrl,
  }) async {
    try {
      final response =
          await SupabaseConfig.from('chats')
              .insert({
                'is_group': isGroup,
                'group_name': groupName,
                'group_description': groupDescription,
                'group_image_url': groupImageUrl,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                'last_message_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating chat: ${e.toString()}');
      return null;
    }
  }

  // Create a direct chat between two users
  Future<String?> createDirectChat(String user1Id, String user2Id) async {
    try {
      // Use the database function to create direct chat (bypasses RLS issues)
      final response = await SupabaseConfig.client.rpc(
        'create_direct_chat',
        params: {'user1_uuid': user1Id, 'user2_uuid': user2Id},
      );

      return response as String?;
    } catch (e) {
      print('Error creating direct chat: ${e.toString()}');
      return null;
    }
  }

  // Add participant to chat
  Future<bool> addChatParticipant({
    required String chatId,
    required String userId,
    bool isAdmin = false,
  }) async {
    try {
      await SupabaseConfig.from('chat_participants').insert({
        'chat_id': chatId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'last_read_at': DateTime.now().toIso8601String(),
        'is_admin': isAdmin,
      });

      return true;
    } catch (e) {
      print('Error adding chat participant: ${e.toString()}');
      return false;
    }
  }

  // Get user's chats
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    print('DEBUG: getUserChats called for user: $userId');

    try {
      // First try the database function
      try {
        print('DEBUG: Attempting to call get_user_chats RPC function');
        final response = await SupabaseConfig.client.rpc(
          'get_user_chats',
          params: {'user_uuid': userId},
        );
        print(
          'DEBUG: RPC function succeeded, got ${(response as List).length} chats',
        );
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print('⚠️ WARNING: Database function get_user_chats failed: $e');
        print(
          '⚠️ This is expected if you haven\'t run MIGRATION_03_ADD_GET_USER_CHATS_FUNCTION.sql',
        );
        print('DEBUG: Falling back to direct query');

        // Fallback to direct query without joins
        final chatIds = await _getUserChatIds(userId);
        print('DEBUG: Found ${chatIds.length} chat IDs for user');

        if (chatIds.isEmpty) {
          print('DEBUG: No chat IDs found, returning empty list');
          return [];
        }

        final response = await SupabaseConfig.from('chats')
            .select('*')
            .inFilter('id', chatIds)
            .order('updated_at', ascending: false);

        print(
          'DEBUG: Direct query succeeded, got ${(response as List).length} chats',
        );
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('❌ ERROR: Failed to get user chats: ${e.toString()}');
      print('ERROR Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Helper method to get user's chat IDs
  Future<List<String>> _getUserChatIds(String userId) async {
    try {
      final response = await SupabaseConfig.from(
        'chat_participants',
      ).select('chat_id').eq('user_id', userId);

      return response.map((item) => item['chat_id'] as String).toList();
    } catch (e) {
      print('Error getting user chat IDs: $e');
      return [];
    }
  }

  // Get chat participants
  Future<List<Map<String, dynamic>>> getChatParticipants(String chatId) async {
    try {
      // First try the database function
      try {
        final response = await SupabaseConfig.client.rpc(
          'get_chat_participants_with_profiles',
          params: {'chat_uuid': chatId},
        );
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        print('Database function failed, trying direct query: $e');

        // Fallback to separate queries
        final participants = await SupabaseConfig.from(
          'chat_participants',
        ).select('*').eq('chat_id', chatId);

        if (participants.isEmpty) return [];

        final userIds = participants.map((p) => p['user_id']).toList();
        final profiles = await SupabaseConfig.from(
          'profiles',
        ).select('*').inFilter('id', userIds);

        final result = <Map<String, dynamic>>[];
        for (final participant in participants) {
          final profile = profiles.firstWhere(
            (p) => p['id'] == participant['user_id'],
            orElse: () => <String, dynamic>{},
          );
          result.add({...participant, 'profile': profile});
        }

        return result;
      }
    } catch (e) {
      print('Error getting chat participants: ${e.toString()}');
      return [];
    }
  }

  // Send a message
  Future<Map<String, dynamic>?> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    File? file,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? replyToMessageId,
    Function(double)? onUploadProgress,
  }) async {
    try {
      String? finalFileUrl = fileUrl;
      String? finalFileName = fileName;
      int? finalFileSize = fileSize;
      String? finalFileType = fileType;

      // If a file is provided, upload it first
      if (file != null) {
        print('DEBUG: Uploading file before sending message');

        finalFileUrl = await uploadFile(
          file: file,
          chatId: chatId,
          senderId: senderId,
          onProgress: onUploadProgress,
        );

        if (finalFileUrl == null) {
          print('ERROR: Failed to upload file');
          return null;
        }

        // Set file metadata if not provided
        finalFileName ??= path.basename(file.path);
        finalFileSize ??= await file.length();
        finalFileType ??= _getMimeType(path.extension(file.path));

        print('DEBUG: File uploaded successfully: $finalFileUrl');
      }

      // Build the insert data with all available fields
      final insertData = <String, dynamic>{
        'chat_id': chatId,
        'sender_id': senderId,
        'message': content,
        'type': type,
        'is_delivered': false,
        'is_read': false,
        'is_edited': false,
      };

      // Add optional fields if they have values
      if (finalFileUrl != null) insertData['file_url'] = finalFileUrl;
      if (finalFileName != null) insertData['file_name'] = finalFileName;
      if (finalFileSize != null) insertData['file_size'] = finalFileSize;
      if (finalFileType != null) insertData['file_type'] = finalFileType;
      if (replyToMessageId != null)
        insertData['reply_to_message_id'] = replyToMessageId;

      final response =
          await SupabaseConfig.from(
            'messages',
          ).insert(insertData).select().single();

      // Update the chat's last message information
      await _updateChatLastMessage(
        chatId: chatId,
        senderId: senderId,
        message: content,
        messageType: type,
      );

      return response;
    } catch (e) {
      print('Error sending message: ${e.toString()}');
      return null;
    }
  }

  // Helper method to update chat's last message
  Future<void> _updateChatLastMessage({
    required String chatId,
    required String senderId,
    required String message,
    required String messageType,
  }) async {
    try {
      print('DEBUG: Updating chat last message for chat: $chatId');

      // Create a display message based on message type
      String displayMessage = message;
      if (messageType == 'image') {
        displayMessage = '📷 Image';
      } else if (messageType == 'video') {
        displayMessage = '🎥 Video';
      } else if (messageType == 'voice') {
        displayMessage = '🎤 Voice message';
      } else if (messageType == 'file') {
        displayMessage = '📄 File';
      } else if (messageType == 'location') {
        displayMessage = '📍 Location';
      }

      await SupabaseConfig.from('chats')
          .update({
            'last_message': displayMessage,
            'last_message_sender_id': senderId,
            'last_message_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chatId);

      print('DEBUG: Chat last message updated successfully');
    } catch (e) {
      print('ERROR: Failed to update chat last message: $e');
    }
  }

  // Get chat messages
  /// Get chat messages with pagination support
  ///
  /// [chatId] - The chat ID to fetch messages for
  /// [limit] - Number of messages to fetch (default: 30)
  /// [beforeTimestamp] - Load messages before this timestamp (for loading older messages)
  ///
  /// Returns messages in DESCENDING order (newest first) for chat display
  Future<List<Map<String, dynamic>>> getChatMessages({
    required String chatId,
    int limit = 30,
    String? beforeTimestamp,
  }) async {
    try {
      // Start with base query - order by created_at DESC (newest first)
      dynamic query = SupabaseConfig.from(
        'messages',
      ).select('*').eq('chat_id', chatId).order('created_at', ascending: false);

      // If loading older messages, filter to messages before the given timestamp
      if (beforeTimestamp != null) {
        query = query.lt('created_at', beforeTimestamp);
      }

      // Apply limit
      query = query.limit(limit);

      final response = await query;

      print(
        'DEBUG: Loaded ${(response as List).length} messages for chat $chatId',
      );
      if (beforeTimestamp != null) {
        print('DEBUG: Loading messages before $beforeTimestamp');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('ERROR: Failed to get chat messages: ${e.toString()}');
      return [];
    }
  }

  // Search users for new chat
  Future<List<Map<String, dynamic>>> searchUsers({
    required String searchTerm,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.from('profiles')
          .select('*')
          .or(
            'first_name.ilike.%$searchTerm%,last_name.ilike.%$searchTerm%,email.ilike.%$searchTerm%',
          );

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching users: ${e.toString()}');
      return [];
    }
  }

  // Check if direct chat exists between two users
  Future<String?> getExistingDirectChat(String user1Id, String user2Id) async {
    try {
      // Use the database function to avoid RLS recursion
      final response = await SupabaseConfig.client.rpc(
        'get_existing_direct_chat',
        params: {'user1_uuid': user1Id, 'user2_uuid': user2Id},
      );

      return response as String?;
    } catch (e) {
      print('Error checking existing direct chat: ${e.toString()}');
      return null;
    }
  }

  // Update last read timestamp for a user in a chat
  Future<bool> updateLastReadAt({
    required String chatId,
    required String userId,
  }) async {
    try {
      await SupabaseConfig.from('chat_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('chat_id', chatId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error updating last read at: ${e.toString()}');
      return false;
    }
  }

  // Update user's last seen timestamp
  Future<bool> updateUserLastSeen(String userId) async {
    try {
      await SupabaseConfig.from('profiles')
          .update({'last_seen': DateTime.now().toIso8601String()})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating user last seen: ${e.toString()}');
      return false;
    }
  }

  // Update user's online status
  Future<bool> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await SupabaseConfig.from('profiles')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error updating user online status: ${e.toString()}');
      return false;
    }
  }

  // Get real-time user status
  Future<Map<String, dynamic>?> getUserStatus(String userId) async {
    try {
      final response =
          await SupabaseConfig.from(
            'profiles',
          ).select('is_online, last_seen').eq('id', userId).maybeSingle();

      return response;
    } catch (e) {
      print('Error getting user status: ${e.toString()}');
      return null;
    }
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId, String userId) async {
    try {
      final response = await SupabaseConfig.client.rpc(
        'mark_message_as_read',
        params: {'message_uuid': messageId, 'user_uuid': userId},
      );
      return response as bool;
    } catch (e) {
      print('Error marking message as read: ${e.toString()}');
      return false;
    }
  }

  // Mark all messages in a chat as read
  Future<int> markChatMessagesAsRead(String chatId, String userId) async {
    try {
      final response = await SupabaseConfig.client.rpc(
        'mark_chat_messages_as_read',
        params: {'chat_uuid': chatId, 'user_uuid': userId},
      );
      return response as int;
    } catch (e) {
      print('Error marking chat messages as read: ${e.toString()}');
      return 0;
    }
  }

  // Notifications Operations

  Future<Map<String, dynamic>?> createNotification(
    Map<String, dynamic> data,
  ) async {
    return await create(table: SupabaseConfig.notificationsTable, data: data);
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await SupabaseConfig.from(
            SupabaseConfig.notificationsTable,
          )
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user notifications: ${e.toString()}');
      return [];
    }
  }

  // Search Operations

  Future<List<Map<String, dynamic>>> search({
    required String table,
    required String searchColumn,
    required String searchTerm,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.from(
        table,
      ).select().ilike(searchColumn, '%$searchTerm%');

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching in $table: ${e.toString()}');
      return [];
    }
  }

  // File Upload Operations

  // Upload file to Supabase Storage
  Future<String?> uploadFile({
    required File file,
    required String chatId,
    required String senderId,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_${senderId}_$fileName';

      // Create folder path: chat-files/chatId/filename
      final filePath = '$chatId/$uniqueFileName';

      print('DEBUG: Uploading file: $fileName to path: $filePath');
      print('DEBUG: File size: ${await file.length()} bytes');

      // Check if bucket exists, create if not
      await _ensureBucketExists();

      // Upload file to Supabase Storage
      final response = await SupabaseConfig.client.storage
          .from('chat-files')
          .uploadBinary(
            filePath,
            await file.readAsBytes(),
            fileOptions: FileOptions(
              contentType: _getMimeType(fileExtension),
              upsert: false,
            ),
          );

      if (response.isNotEmpty) {
        // Get the public URL
        final publicUrl = SupabaseConfig.client.storage
            .from('chat-files')
            .getPublicUrl(filePath);

        print('DEBUG: File uploaded successfully: $publicUrl');
        return publicUrl;
      } else {
        print('ERROR: File upload failed - empty response');
        return null;
      }
    } catch (e) {
      print('ERROR: Failed to upload file: ${e.toString()}');

      // If bucket doesn't exist, provide helpful error message
      if (e.toString().contains('Bucket not found')) {
        print('ERROR: The chat-files storage bucket does not exist.');
        print(
          'ERROR: Please run the SETUP_CHAT_STORAGE_BUCKET.sql script in your Supabase dashboard.',
        );
      }

      return null;
    }
  }

  // Ensure the chat-files bucket exists
  Future<void> _ensureBucketExists() async {
    try {
      // Try to list files from the bucket to check if it exists
      await SupabaseConfig.client.storage.from('chat-files').list();
      print('DEBUG: chat-files bucket exists');
    } catch (e) {
      if (e.toString().contains('Bucket not found')) {
        print(
          'ERROR: chat-files bucket does not exist. Please create it first.',
        );
        print(
          'ERROR: Run the SETUP_CHAT_STORAGE_BUCKET.sql script in your Supabase dashboard.',
        );
        throw Exception(
          'Storage bucket not found. Please set up the chat-files bucket first.',
        );
      }
      rethrow;
    }
  }

  Future<bool> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      await SupabaseConfig.storageFrom(bucket).remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting file: ${e.toString()}');
      return false;
    }
  }

  // Get hostel listings by provider
  Future<List<Map<String, dynamic>>> getHostelListingsByProvider(
    String providerId,
  ) async {
    try {
      final response = await SupabaseConfig.from(
            SupabaseConfig.hostelListingsTable,
          )
          .select('*')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting hostel listings by provider: ${e.toString()}');
      return [];
    }
  }

  // Get roommate requests by user
  Future<List<Map<String, dynamic>>> getUserRoommateRequests(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.from(
            SupabaseConfig.roommateRequestsTable,
          )
          .select('*, profiles(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting user roommate requests: ${e.toString()}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEventsByOrganizer(
    String organizerId,
  ) async {
    try {
      final response = await SupabaseConfig.from(SupabaseConfig.eventsTable)
          .select('*')
          .eq('organizer_id', organizerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting events by organizer: ${e.toString()}');
      return [];
    }
  }
}
