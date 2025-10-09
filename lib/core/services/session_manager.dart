// Core Service - Session Manager for Persistent Authentication
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'supabase_auth_service.dart';

class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();

  SessionManager._();

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userTypeKey = 'user_type';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginKey = 'last_login';
  static const String _autoLoginEnabledKey = 'auto_login_enabled';

  SharedPreferences? _prefs;

  // Initialize shared preferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // Save login session
  Future<void> saveLoginSession({
    required String userId,
    required String email,
    required String userType,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await _getPrefs();

      await Future.wait([
        prefs.setBool(_isLoggedInKey, true),
        prefs.setString(_userIdKey, userId),
        prefs.setString(_userEmailKey, email),
        prefs.setString(_userTypeKey, userType),
        prefs.setBool(_rememberMeKey, rememberMe),
        prefs.setString(_lastLoginKey, DateTime.now().toIso8601String()),
        prefs.setBool(_autoLoginEnabledKey, rememberMe),
      ]);

      debugPrint('SessionManager: Login session saved successfully');
    } catch (e) {
      debugPrint('SessionManager: Failed to save login session: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await _getPrefs();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      // If remember me is disabled, check session validity (24 hours)
      if (isLoggedIn && !rememberMe) {
        final lastLoginString = prefs.getString(_lastLoginKey);
        if (lastLoginString != null) {
          final lastLogin = DateTime.parse(lastLoginString);
          final sessionExpired = DateTime.now().difference(lastLogin).inHours > 24;

          if (sessionExpired) {
            await clearSession();
            return false;
          }
        }
      }

      return isLoggedIn;
    } catch (e) {
      debugPrint('SessionManager: Failed to check login status: $e');
      return false;
    }
  }

  // Get stored user information
  Future<Map<String, String?>> getUserInfo() async {
    try {
      final prefs = await _getPrefs();

      return {
        'userId': prefs.getString(_userIdKey),
        'email': prefs.getString(_userEmailKey),
        'userType': prefs.getString(_userTypeKey),
        'lastLogin': prefs.getString(_lastLoginKey),
      };
    } catch (e) {
      debugPrint('SessionManager: Failed to get user info: $e');
      return {};
    }
  }

  // Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      debugPrint('SessionManager: Failed to check remember me status: $e');
      return false;
    }
  }

  // Check if auto login is enabled
  Future<bool> isAutoLoginEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_autoLoginEnabledKey) ?? false;
    } catch (e) {
      debugPrint('SessionManager: Failed to check auto login status: $e');
      return false;
    }
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    try {
      final prefs = await _getPrefs();

      await Future.wait([
        prefs.remove(_isLoggedInKey),
        prefs.remove(_userIdKey),
        prefs.remove(_userEmailKey),
        prefs.remove(_userTypeKey),
        prefs.remove(_rememberMeKey),
        prefs.remove(_lastLoginKey),
        prefs.remove(_autoLoginEnabledKey),
      ]);

      debugPrint('SessionManager: Session cleared successfully');
    } catch (e) {
      debugPrint('SessionManager: Failed to clear session: $e');
    }
  }

  // Update remember me preference
  Future<void> updateRememberMe(bool rememberMe) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_rememberMeKey, rememberMe);
      await prefs.setBool(_autoLoginEnabledKey, rememberMe);

      debugPrint('SessionManager: Remember me updated to: $rememberMe');
    } catch (e) {
      debugPrint('SessionManager: Failed to update remember me: $e');
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());

      debugPrint('SessionManager: Last login updated');
    } catch (e) {
      debugPrint('SessionManager: Failed to update last login: $e');
    }
  }

  // Get session expiry time
  Future<DateTime?> getSessionExpiry() async {
    try {
      final prefs = await _getPrefs();
      final lastLoginString = prefs.getString(_lastLoginKey);
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (lastLoginString != null) {
        final lastLogin = DateTime.parse(lastLoginString);

        // If remember me is enabled, session doesn't expire
        if (rememberMe) {
          return null; // No expiry
        }

        // Otherwise, session expires after 24 hours
        return lastLogin.add(const Duration(hours: 24));
      }

      return null;
    } catch (e) {
      debugPrint('SessionManager: Failed to get session expiry: $e');
      return null;
    }
  }

  // Check if session is about to expire (within 1 hour)
  Future<bool> isSessionNearExpiry() async {
    try {
      final expiry = await getSessionExpiry();
      if (expiry == null) return false; // No expiry if remember me is enabled

      final now = DateTime.now();
      final timeUntilExpiry = expiry.difference(now);

      return timeUntilExpiry.inHours <= 1 && timeUntilExpiry.inMinutes > 0;
    } catch (e) {
      debugPrint('SessionManager: Failed to check session near expiry: $e');
      return false;
    }
  }

  // Extend session (refresh last login)
  Future<void> extendSession() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      if (isLoggedIn) {
        await updateLastLogin();
        debugPrint('SessionManager: Session extended');
      }
    } catch (e) {
      debugPrint('SessionManager: Failed to extend session: $e');
    }
  }

  // Logout and clear all data
  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await SupabaseAuthService.instance.signOut();

      // Clear local session
      await clearSession();

      debugPrint('SessionManager: User logged out successfully');
    } catch (e) {
      debugPrint('SessionManager: Failed to logout: $e');
      rethrow;
    }
  }

  // Check if user has valid authentication with Supabase
  Future<bool> validateSupabaseSession() async {
    try {
      final authService = SupabaseAuthService.instance;
      return authService.isAuthenticated;
    } catch (e) {
      debugPrint('SessionManager: Failed to validate Supabase session: $e');
      return false;
    }
  }

  // Sync session with Supabase auth state
  Future<bool> syncWithSupabaseAuth() async {
    try {
      final authService = SupabaseAuthService.instance;
      final isSupabaseAuthenticated = authService.isAuthenticated;
      final isLocallyLoggedIn = await isLoggedIn();

      // If Supabase says not authenticated but locally logged in, clear local session
      if (!isSupabaseAuthenticated && isLocallyLoggedIn) {
        await clearSession();
        debugPrint('SessionManager: Cleared stale local session');
        return false;
      }

      // If Supabase says authenticated but not locally logged in, this is an edge case
      // We'll rely on the login flow to re-establish the local session

      return isSupabaseAuthenticated;
    } catch (e) {
      debugPrint('SessionManager: Failed to sync with Supabase auth: $e');
      return false;
    }
  }

  // Get time remaining until session expires
  Future<Duration?> getTimeUntilExpiry() async {
    try {
      final expiry = await getSessionExpiry();
      if (expiry == null) return null; // No expiry

      final now = DateTime.now();
      final timeRemaining = expiry.difference(now);

      return timeRemaining.isNegative ? Duration.zero : timeRemaining;
    } catch (e) {
      debugPrint('SessionManager: Failed to get time until expiry: $e');
      return null;
    }
  }
}