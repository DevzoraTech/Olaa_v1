// Data Layer - Supabase Database Service
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<String?> uploadFile({
    required String bucket,
    required String fileName,
    required String filePath,
  }) async {
    try {
      await SupabaseConfig.storageFrom(bucket).upload(fileName, filePath);
      return SupabaseConfig.storageFrom(bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading file: ${e.toString()}');
      return null;
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
