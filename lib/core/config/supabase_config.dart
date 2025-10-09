// Core Configuration - Supabase Configuration
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase Project Configuration
  static const String supabaseUrl = 'https://pfdkolngneljkiagwvfw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmZGtvbG5nbmVsamtpYWd3dmZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMjkzMTQsImV4cCI6MjA3NDkwNTMxNH0.3J99gEyH2UpTPY6Jc7qWyWihQ6IeQh_Oh3jdB6yP2UE';

  // Database Tables
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String roommateRequestsTable = 'roommate_requests';
  static const String hostelListingsTable = 'hostel_listings';
  static const String eventsTable = 'events';
  static const String marketplaceItemsTable = 'marketplace_items';
  static const String notificationsTable = 'notifications';
  static const String chatsTable = 'chats';
  static const String messagesTable = 'messages';

  // Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String hostelImagesBucket = 'hostel-images';
  static const String hostelMediaBucket =
      'hostel-media'; // Use dedicated hostel media bucket
  static const String eventImagesBucket = 'event-images';
  static const String marketplaceImagesBucket = 'marketplace-images';
  static const String roommatePhotosBucket = 'roommate-photos';

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  // Get Supabase Client
  static SupabaseClient get client => Supabase.instance.client;

  // Get Supabase Auth
  static GoTrueClient get auth => Supabase.instance.client.auth;

  // Get Supabase Storage
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;

  // Get Supabase Database
  static SupabaseQueryBuilder get database => Supabase.instance.client.from('');

  // Database Helper Methods
  static SupabaseQueryBuilder from(String table) {
    return Supabase.instance.client.from(table);
  }

  // Storage Helper Methods
  static dynamic storageFrom(String bucket) {
    return Supabase.instance.client.storage.from(bucket);
  }

  // Auth Helper Methods
  static User? get currentUser => Supabase.instance.client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  static Future<void> resetPasswordForEmail(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  static Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await Supabase.instance.client.auth.updateUser(
      UserAttributes(email: email, password: password, data: data),
    );
  }
}
