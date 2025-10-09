// Data Layer - Data Sources
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String email, String password);
  Future<User> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
}

abstract class AuthLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getCachedUser();
  Future<void> clearUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

// Mock implementation for development
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<User> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful login
    return User(
      id: 'user_123',
      email: email,
      firstName: 'John',
      lastName: 'Doe',
      phone: '+1234567890',
      userType: 'student',
      selectedUniversity: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<User> register(Map<String, dynamic> userData) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful registration
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: userData['email'] as String,
      firstName: userData['firstName'] as String,
      lastName: userData['lastName'] as String,
      phone: userData['phone'] as String?,
      userType: userData['userType'] as String,
      selectedUniversity: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock logout
  }

  @override
  Future<User?> getCurrentUser() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return null to simulate no logged-in user
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock user update
  }
}

class MockAuthLocalDataSource implements AuthLocalDataSource {
  User? _cachedUser;
  String? _token;

  @override
  Future<void> saveUser(User user) async {
    _cachedUser = user;
  }

  @override
  Future<User?> getCachedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
  }

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}

