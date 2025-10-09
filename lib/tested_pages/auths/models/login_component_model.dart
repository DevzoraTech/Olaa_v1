import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Focus nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;

  // Methods
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setRememberMe(bool remember) {
    _rememberMe = remember;
    notifyListeners();
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _isPasswordVisible = false;
    _isLoading = false;
    _rememberMe = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
