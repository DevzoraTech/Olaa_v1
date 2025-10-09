// Core Service - Roommate Posting Service
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class RoommatePostingService {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Upload photos to Supabase storage
  static Future<List<String>> uploadPhotos({
    required List<String> photoPaths,
    required String userId,
  }) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < photoPaths.length; i++) {
        final filePath = photoPaths[i];
        final fileName =
            'roommate_request_${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storagePath = 'roommate-requests/$fileName';

        print('DEBUG: Uploading photo $i: $filePath to $storagePath');

        // Upload file to storage
        await _client.storage
            .from(SupabaseConfig.roommatePhotosBucket)
            .upload(storagePath, File(filePath));

        // Get public URL - construct it manually to ensure it's correct
        final publicUrl =
            '${SupabaseConfig.supabaseUrl}/storage/v1/object/public/${SupabaseConfig.roommatePhotosBucket}/$storagePath';

        print('DEBUG: Generated public URL: $publicUrl');

        uploadedUrls.add(publicUrl);
      }

      print('DEBUG: All uploaded URLs: $uploadedUrls');
      return uploadedUrls;
    } catch (e) {
      print('Error uploading photos: $e');
      throw Exception('Failed to upload photos: $e');
    }
  }

  /// Create a roommate request
  static Future<Map<String, dynamic>> createRoommateRequest({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      // Insert into roommate_requests table
      final response =
          await _client
              .from('roommate_requests')
              .insert(requestData)
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating roommate request: $e');
      throw Exception('Failed to create roommate request: $e');
    }
  }

  /// Get a single roommate request by ID
  static Future<Map<String, dynamic>?> getRoommateRequestById({
    required String requestId,
  }) async {
    try {
      final response =
          await _client
              .from('roommate_requests')
              .select()
              .eq('id', requestId)
              .single();

      print('DEBUG: Service - Raw response from database: $response');
      return response;
    } catch (e) {
      print('Error fetching roommate request by ID: $e');
      throw Exception('Failed to fetch roommate request: $e');
    }
  }

  /// Get recent roommate requests for highlights
  static Future<List<Map<String, dynamic>>> getRecentRoommateRequests({
    int limit = 5,
  }) async {
    try {
      final response = await _client
          .from('roommate_requests')
          .select()
          .eq('status', 'Active')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent roommate requests: $e');
      return [];
    }
  }

  /// Get user's roommate requests
  static Future<List<Map<String, dynamic>>> getUserRoommateRequests({
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('roommate_requests')
          .select()
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user roommate requests: $e');
      throw Exception('Failed to fetch roommate requests: $e');
    }
  }

  /// Get user's current hostel information
  static Future<Map<String, dynamic>?> getUserCurrentHostel({
    required String userId,
  }) async {
    try {
      final response =
          await _client
              .from('profiles')
              .select('current_hostel_id, current_hostel_name')
              .eq('id', userId)
              .single();

      return response;
    } catch (e) {
      print('Error getting user hostel info: $e');
      return null;
    }
  }

  /// Get available hostels for selection
  static Future<List<Map<String, dynamic>>> getAvailableHostels() async {
    try {
      final response = await _client
          .from('hostel_listings')
          .select('id, title, address, monthly_rent')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting hostels: $e');
      return [];
    }
  }

  /// Update user's current hostel
  static Future<void> updateUserCurrentHostel({
    required String userId,
    required String hostelId,
    required String hostelName,
  }) async {
    try {
      await _client
          .from('profiles')
          .update({
            'current_hostel_id': hostelId,
            'current_hostel_name': hostelName,
          })
          .eq('id', userId);
    } catch (e) {
      print('Error updating user hostel: $e');
      throw Exception('Failed to update user hostel: $e');
    }
  }
}
