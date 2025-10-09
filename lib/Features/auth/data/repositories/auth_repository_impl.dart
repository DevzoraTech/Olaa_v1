// Data Layer - Repository Implementation
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../datasources/auth_datasources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.saveUser(user);
      await localDataSource.saveToken('mock_token_${user.id}');
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? phone,
  }) async {
    try {
      final userData = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'phone': phone,
      };

      final user = await remoteDataSource.register(userData);
      await localDataSource.saveUser(user);
      await localDataSource.saveToken('mock_token_${user.id}');
      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearUser();
      await localDataSource.clearToken();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // First check local cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }

      // If no cached user, check remote
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.saveUser(user);
      }
      return user;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      await localDataSource.saveUser(user);
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await remoteDataSource.updateUser(user);
      await localDataSource.saveUser(user);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> selectUniversity(String universityId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = currentUser.copyWith(
        selectedUniversity: universityId,
        updatedAt: DateTime.now(),
      );

      await updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to select university: ${e.toString()}');
    }
  }
}
