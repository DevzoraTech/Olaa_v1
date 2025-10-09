// Data Layer - Supabase Auth Service
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  static SupabaseAuthService get instance =>
      _instance ??= SupabaseAuthService._();

  SupabaseAuthService._();

  // Helper method to format user type to match schema
  String _formatUserType(String userType) {
    switch (userType.toLowerCase()) {
      case 'student':
        return 'Student';
      case 'hostel_provider':
        return 'Hostel Provider';
      case 'event_organizer':
        return 'Event Organizer';
      case 'promoter':
        return 'Promoter';
      default:
        return 'Student'; // Default fallback
    }
  }

  // Get current user
  User? get currentUser => SupabaseConfig.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => SupabaseConfig.authStateChanges;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password - Basic method
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await SupabaseConfig.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'user_type': userType,
          ...?additionalData,
        },
      );

      if (response.user != null) {
        // Create user profile
        await _createOrUpdateProfile(response.user!.id, {
          'id': response.user!.id,
          'email': response.user!.email,
          'first_name': firstName,
          'last_name': lastName,
          'primary_role': _formatUserType(userType),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          ...?additionalData,
        });
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Complete signup with all user data
  Future<AuthResponse> completeSignUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    // Student specific fields
    String? campus,
    String? yearOfStudy,
    String? course,
    String? phone,
    String? gender,
    List<String>? interests,
    // Hostel provider specific fields
    String? businessName,
    String? primaryPhone,
    String? secondaryPhone,
    String? locationName,
    String? address,
    // Event organizer specific fields
    String? organizationName,
    String? organizationType,
    String? organizationDescription,
    String? organizationWebsite,
    String? organizationPhone,
    // Promoter specific fields
    String? agencyName,
    String? agencyType,
    String? agencyDescription,
    String? agencyWebsite,
    String? agencyPhone,
    // Profile picture
    String? profileImageUrl,
    // Image file for upload after authentication
    String? imagePath,
  }) async {
    try {
      // Split name into first and last name
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Sign up user with basic metadata to help trigger work
      print('DEBUG: Signing up user with email: $email');

      final response = await SupabaseConfig.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'primary_role': _formatUserType(userType),
        },
      );

      print('DEBUG: Signup response: ${response.user?.id}');

      if (response.user != null) {
        // Wait a moment for the trigger to create the profile
        await Future.delayed(const Duration(milliseconds: 500));

        // Convert userType to match schema format
        String formattedUserType = _formatUserType(userType);

        // Prepare complete profile data
        Map<String, dynamic> profileData = {
          'id': response.user!.id,
          'email': response.user!.email,
          'first_name': firstName,
          'last_name': lastName,
          'primary_role': formattedUserType,
          'is_verified': false,
          'is_active': true,
          'timezone': 'UTC',
          'language': 'en',
          'notification_preferences': <String, dynamic>{},
          'privacy_settings': <String, dynamic>{},
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Add role-specific data
        switch (userType.toLowerCase()) {
          case 'student':
            profileData.addAll({
              'campus': campus,
              'year_of_study': yearOfStudy,
              'course': course,
              'phone_number': phone,
              'gender': gender,
              'interests': interests,
            });
            break;
          case 'hostel_provider':
            profileData.addAll({
              'business_name': businessName,
              'primary_phone': primaryPhone,
              'secondary_phone': secondaryPhone,
              'location_name': locationName,
              'address': address,
              'phone_number': primaryPhone, // Use primary phone as main contact
            });
            break;
          case 'event_organizer':
            profileData.addAll({
              'organization_name': organizationName,
              'organization_type': organizationType,
              'organization_description': organizationDescription,
              'organization_website': organizationWebsite,
              'phone_number': organizationPhone,
            });
            break;
          case 'promoter':
            profileData.addAll({
              'agency_name': agencyName,
              'agency_type': agencyType,
              'agency_description': agencyDescription,
              'agency_website': agencyWebsite,
              'phone_number': agencyPhone,
            });
            break;
        }

        // Add profile image if provided
        if (profileImageUrl != null) {
          profileData['profile_image_url'] = profileImageUrl;
        }

        print('DEBUG: Complete profile data being sent: $profileData');

        // Create or update the profile
        try {
          await _createOrUpdateProfile(response.user!.id, profileData);
          print('DEBUG: Profile update completed successfully');

          // Verify the profile was actually updated
          final verifyResult =
              await SupabaseConfig.from(
                SupabaseConfig.profilesTable,
              ).select().eq('id', response.user!.id).single();
          print('DEBUG: Profile verification result: $verifyResult');
        } catch (e) {
          print('DEBUG: Profile update failed: $e');
          // Try direct update as fallback
          try {
            await _updateProfileDirectly(response.user!.id, profileData);
            print('DEBUG: Direct profile update completed successfully');

            // Verify the direct update worked
            final verifyResult =
                await SupabaseConfig.from(
                  SupabaseConfig.profilesTable,
                ).select().eq('id', response.user!.id).single();
            print('DEBUG: Direct update verification result: $verifyResult');
          } catch (directError) {
            print('DEBUG: Direct update also failed: $directError');
            throw Exception('Failed to save profile data: $directError');
          }
        }

        // Upload image after user is authenticated (if image path provided)
        if (imagePath != null && profileImageUrl == null) {
          try {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'profile_${response.user!.id}_${timestamp}.jpg';

            print('DEBUG: Uploading image after authentication...');
            final uploadedImageUrl = await uploadProfileImage(
              imagePath: imagePath,
              fileName: fileName,
            );

            if (uploadedImageUrl != null) {
              // Update profile with image URL
              await _updateUserProfile(response.user!.id, {
                'profile_image_url': uploadedImageUrl,
              });
              print('DEBUG: Profile image updated successfully');
            }
          } catch (e) {
            print('DEBUG: Failed to upload image after signup: $e');
            // Don't throw error - user is already created successfully
          }
        }
      }

      return response;
    } catch (e) {
      throw Exception('Complete signup failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await SupabaseConfig.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await SupabaseConfig.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await SupabaseConfig.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? email,
    String? password,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      final response = await SupabaseConfig.updateUser(
        email: email,
        password: password,
        data: profileData,
      );

      if (response.user != null && profileData != null) {
        // Update user profile in profiles table
        await _updateUserProfile(response.user!.id, profileData);
      }

      return response;
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await SupabaseConfig.from(
            SupabaseConfig.profilesTable,
          ).select().eq('id', userId).single();

      return response;
    } catch (e) {
      print('Error getting user profile: ${e.toString()}');
      return null;
    }
  }

  // Update user profile (public method)
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    await _updateUserProfile(userId, profileData);
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await SupabaseConfig.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  // Create or update user profile in profiles table
  Future<void> _createOrUpdateProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('DEBUG: Creating/updating profile for user: $userId');
      print('DEBUG: Profile data keys: ${profileData.keys.toList()}');

      // Remove id and created_at from update data to avoid conflicts
      final updateData = Map<String, dynamic>.from(profileData);
      updateData.remove('id');
      updateData.remove('created_at');
      updateData['updated_at'] = DateTime.now().toIso8601String();

      print('DEBUG: Update data being sent: $updateData');

      // Try to update first (most likely scenario since trigger creates basic profile)
      try {
        final result =
            await SupabaseConfig.from(
              SupabaseConfig.profilesTable,
            ).update(updateData).eq('id', userId).select();

        print('DEBUG: Profile update result: $result');

        // Verify the update by fetching the profile
        final verification =
            await SupabaseConfig.from(
              SupabaseConfig.profilesTable,
            ).select().eq('id', userId).single();

        print('DEBUG: Profile verification result: $verification');

        // Check if the update actually worked by comparing key fields
        bool updateWorked = true;
        for (String key in updateData.keys) {
          if (key != 'updated_at' && verification[key] != updateData[key]) {
            print(
              'DEBUG: Field $key not updated. Expected: ${updateData[key]}, Got: ${verification[key]}',
            );
            updateWorked = false;
          }
        }

        if (!updateWorked) {
          print('DEBUG: Update did not work properly, trying direct update');
          await _updateProfileDirectly(userId, profileData);
        }
      } catch (updateError) {
        print('DEBUG: Update failed, trying insert: $updateError');

        // If update fails, try to insert (profile might not exist)
        final insertData = Map<String, dynamic>.from(profileData);
        insertData['created_at'] = DateTime.now().toIso8601String();
        insertData['updated_at'] = DateTime.now().toIso8601String();

        final result =
            await SupabaseConfig.from(
              SupabaseConfig.profilesTable,
            ).insert(insertData).select();
        print('DEBUG: Profile created successfully: $result');
      }
    } catch (e) {
      print('DEBUG: Error creating/updating user profile: ${e.toString()}');
      rethrow; // Re-throw to trigger fallback
    }
  }

  /// Direct profile update method as fallback
  Future<void> _updateProfileDirectly(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('DEBUG: Direct profile update for user: $userId');

      // Remove id from update data to avoid conflicts
      final updateData = Map<String, dynamic>.from(profileData);
      updateData.remove('id');
      updateData.remove('created_at');
      updateData['updated_at'] = DateTime.now().toIso8601String();

      print('DEBUG: Direct update data: $updateData');

      // Try updating each field individually to identify problematic fields
      for (String key in updateData.keys) {
        if (key == 'updated_at') continue;

        try {
          final result =
              await SupabaseConfig.from(
                SupabaseConfig.profilesTable,
              ).update({key: updateData[key]}).eq('id', userId).select();

          print('DEBUG: Updated field $key: $result');
        } catch (fieldError) {
          print('DEBUG: Failed to update field $key: $fieldError');
        }
      }

      // Final verification
      final verification =
          await SupabaseConfig.from(
            SupabaseConfig.profilesTable,
          ).select().eq('id', userId).single();

      print('DEBUG: Final verification after direct update: $verification');
    } catch (e) {
      print('DEBUG: Direct update failed: $e');
      rethrow;
    }
  }

  // Update user profile in profiles table
  Future<void> _updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('DEBUG: Updating profile for user: $userId');
      print('DEBUG: Profile data: $profileData');

      await SupabaseConfig.from(SupabaseConfig.profilesTable)
          .update({
            'updated_at': DateTime.now().toIso8601String(),
            ...profileData,
          })
          .eq('id', userId);

      print('DEBUG: Profile updated successfully');
    } catch (e) {
      print('DEBUG: Error updating user profile: ${e.toString()}');
      // Don't throw error - this is not critical for signup
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Delete user profile
        await SupabaseConfig.from(
          SupabaseConfig.profilesTable,
        ).delete().eq('id', currentUser!.id);

        // Delete user from auth
        await SupabaseConfig.client.auth.admin.deleteUser(currentUser!.id);
      }
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String imagePath,
    required String fileName,
  }) async {
    try {
      print('DEBUG: SupabaseAuthService - Starting upload...');
      print('DEBUG: SupabaseAuthService - Image path: $imagePath');
      print('DEBUG: SupabaseAuthService - File name: $fileName');

      final file = File(imagePath);
      if (!await file.exists()) {
        print('DEBUG: SupabaseAuthService - File does not exist');
        throw Exception('Image file does not exist');
      }

      final bytes = await file.readAsBytes();
      print('DEBUG: SupabaseAuthService - File size: ${bytes.length} bytes');

      print(
        'DEBUG: SupabaseAuthService - Uploading to bucket: ${SupabaseConfig.profileImagesBucket}',
      );

      // Upload with public access for profile images during signup
      await SupabaseConfig.storageFrom(
        SupabaseConfig.profileImagesBucket,
      ).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      print(
        'DEBUG: SupabaseAuthService - Upload successful, getting public URL...',
      );
      final imageUrl = SupabaseConfig.storageFrom(
        SupabaseConfig.profileImagesBucket,
      ).getPublicUrl(fileName);

      print('DEBUG: SupabaseAuthService - Public URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('DEBUG: SupabaseAuthService - Upload error: ${e.toString()}');
      print('DEBUG: SupabaseAuthService - Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Get profile image URL
  String? getProfileImageUrl(String userId) {
    try {
      return SupabaseConfig.storageFrom(
        SupabaseConfig.profileImagesBucket,
      ).getPublicUrl('${userId}_profile.jpg');
    } catch (e) {
      print('Error getting profile image URL: ${e.toString()}');
      return null;
    }
  }

  // Add additional role to user profile
  Future<void> addUserRole({
    required String userId,
    required String role,
    String? verificationDocumentUrl,
    String? verificationNotes,
  }) async {
    try {
      await SupabaseConfig.from('user_roles').insert({
        'user_id': userId,
        'role': role,
        'is_active': true,
        'is_verified': false,
        'verification_document_url': verificationDocumentUrl,
        'verification_notes': verificationNotes,
      });
    } catch (e) {
      throw Exception('Failed to add user role: ${e.toString()}');
    }
  }

  // Get user roles
  Future<List<Map<String, dynamic>>> getUserRoles(String userId) async {
    try {
      final response = await SupabaseConfig.from('user_roles')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('added_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user roles: ${e.toString()}');
    }
  }

  // Update role verification status
  Future<void> updateRoleVerification({
    required String userId,
    required String role,
    required bool isVerified,
    String? verificationNotes,
  }) async {
    try {
      await SupabaseConfig.from('user_roles')
          .update({
            'is_verified': isVerified,
            'verification_notes': verificationNotes,
            'verified_at': isVerified ? DateTime.now().toIso8601String() : null,
          })
          .eq('user_id', userId)
          .eq('role', role);
    } catch (e) {
      throw Exception('Failed to update role verification: ${e.toString()}');
    }
  }

  // Deactivate user role
  Future<void> deactivateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await SupabaseConfig.from(
        'user_roles',
      ).update({'is_active': false}).eq('user_id', userId).eq('role', role);
    } catch (e) {
      throw Exception('Failed to deactivate user role: ${e.toString()}');
    }
  }

  // Update primary role
  Future<void> updatePrimaryRole({
    required String userId,
    required String newPrimaryRole,
  }) async {
    try {
      await SupabaseConfig.from(
        'profiles',
      ).update({'primary_role': newPrimaryRole}).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update primary role: ${e.toString()}');
    }
  }
}
