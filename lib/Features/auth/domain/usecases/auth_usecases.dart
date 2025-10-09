// Domain Layer - Use Cases
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? phone,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
  Future<void> selectUniversity(String universityId);
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    return await repository.login(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? phone,
  }) async {
    // Validation
    if (email.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      throw Exception('All required fields must be filled');
    }

    if (userType != 'student' && userType != 'hostel_provider') {
      throw Exception('Invalid user type');
    }

    return await repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      userType: userType,
      phone: phone,
    );
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    await repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}

class SelectUniversityUseCase {
  final AuthRepository repository;

  SelectUniversityUseCase(this.repository);

  Future<void> call(String universityId) async {
    if (universityId.isEmpty) {
      throw Exception('University ID is required');
    }

    await repository.selectUniversity(universityId);
  }
}

