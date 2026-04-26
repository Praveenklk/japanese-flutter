import 'package:flutter/material.dart';

import '/main_screen.dart'; // ✅ IMPORTANT

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';

import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/quiz/screens/quiz_screen.dart';

/// RouteGenerator - Centralized route management
class RouteGenerator {
  RouteGenerator._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/home';
  static const String learn = '/learn';
  static const String quiz = '/quiz';
  static const String activity = '/activity';
  static const String bookmark = '/bookmark';

  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// 🔹 AUTH FLOW (normal navigation)
      case splash:
        return _buildRoute(const SplashScreen());

      case onboarding:
        return _buildRoute(const OnboardingScreen());

      case login:
        return _buildRoute(const LoginScreen());

      case signup:
        return _buildRoute(const SignupScreen());

      /// 🔹 MAIN APP (WITH BOTTOM NAV)
      case home:
        return _buildRoute(const MainScreen(initialIndex: 0));

      case learn:
        return _buildRoute(const MainScreen(initialIndex: 1));

      case quiz:
        final args = settings.arguments as Map<String, dynamic>?;

        // 👉 If quiz is opened from tab → go to tab
        if (args == null) {
          return _buildRoute(const MainScreen(initialIndex: 2));
        }

        // 👉 If quiz is opened as detail → open screen directly
        return _buildRoute(
          QuizScreen(
            level: args['level'] ?? 'N5',
            category: args['category'] ?? 'Vocabulary',
          ),
        );

      case activity:
        return _buildRoute(const MainScreen(initialIndex: 3));

      case bookmark:
        return _buildRoute(const MainScreen(initialIndex: 4));

      /// 🔹 OTHER SCREENS (normal navigation)
      case profile:
        return _buildRoute(const ProfileScreen());

      case RouteGenerator.settings:
        return _buildRoute(const SettingsScreen());

      /// 🔹 DEFAULT
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  /// Page transition
  static Route<dynamic> _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}