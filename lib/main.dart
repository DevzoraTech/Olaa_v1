import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'core/services/session_manager.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'Features/auth/presentation/screens/unified_signup_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/management/presentation/screens/management_dashboard_screen.dart';
import 'Features/roommate/presentation/screens/roommate_request_detail_screen.dart';
import 'Features/hostel/presentation/screens/hostel_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize Session Manager
  await SessionManager.instance.initialize();

  runApp(const OlaaApp());
}

class OlaaApp extends StatelessWidget {
  const OlaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // For now, we'll use light theme only
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/signup': (context) => const UnifiedSignUpScreen(),
        '/roommate-request': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final requestId = args?['requestId'] ?? 'default_request_id';
          return RoommateRequestDetailScreen(requestId: requestId);
        },
        '/hostel-detail': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final hostelData = args?['hostelData'] ?? {};
          return HostelDetailScreen(hostelData: hostelData);
        },
        '/management': (context) => const ManagementDashboardScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Logo scale animation (starts small, grows to normal size)
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Fade animation for the entire screen
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start logo animation
    _logoController.forward();
  }

  void _navigateToNextScreen() async {
    // Wait for logo animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      // Start fade out animation
      _fadeController.forward();

      // Wait for fade animation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Check authentication status and navigate accordingly
        final sessionManager = SessionManager.instance;
        final isLoggedIn = await sessionManager.isLoggedIn();
        final isSupabaseAuthenticated =
            await sessionManager.validateSupabaseSession();

        // Sync session state with Supabase
        final isValidSession = await sessionManager.syncWithSupabaseAuth();

        if (isLoggedIn && isSupabaseAuthenticated && isValidSession) {
          // User has valid session, navigate to home
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // No valid session, navigate to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _fadeController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/images/olaa-logo.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to a beautiful circular container with 'O'
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.primaryColor.withOpacity(
                                              0.8,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'O',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // App Name with subtle animation
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Text(
                            'Olaa',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                              letterSpacing: -1.0,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Tagline with subtle animation
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacityAnimation.value * 0.8,
                          child: Text(
                            'Your Campus. Your People.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.2,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
