import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class PulseCampusApp extends StatefulWidget {
  const PulseCampusApp({super.key});

  @override
  State<PulseCampusApp> createState() => _PulseCampusAppState();
}

class _PulseCampusAppState extends State<PulseCampusApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // TODO: Check if user is logged in from SharedPreferences/Firebase
    // For now, simulate loading and show login screen
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isLoggedIn = false; // Set to false to show login screen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return const LoginScreen();
    }

    // User is logged in, show home screen
    return const HomeScreen();
  }
}
