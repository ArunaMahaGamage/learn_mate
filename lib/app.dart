import 'package:flutter/material.dart';
import 'package:learn_mate/views/signup_screen.dart';
import 'core/routes.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/home_screen.dart';
import 'views/planner_screen.dart';
import 'views/planner_detail_screen.dart';
import 'views/resource_library_screen.dart';
import 'views/resource_detail_screen.dart';
import 'views/forum_screen.dart';
import 'views/question_detail_screen.dart';
import 'views/quiz_screen.dart';
import 'views/quiz_creation_screen.dart';
import 'views/favorites_screen.dart';
import 'views/notifications_screen.dart';
import 'views/profile_screen.dart';
import 'views/progress_tracker_screen.dart';
import 'views/settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rural Student Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
      ),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.signUp: (_) => const SignupScreen(),
        Routes.onboarding: (_) => const OnboardingScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.planner: (_) => const PlannerScreen(),
        Routes.plannerDetail: (_) => const PlannerDetailScreen(),
        Routes.resources: (_) => const ResourceLibraryScreen(),
        Routes.resourceDetail: (_) => const ResourceDetailScreen(),
        Routes.forum: (_) => const ForumScreen(),
        Routes.questionDetail: (_) => const QuestionDetailScreen(),
        Routes.quiz: (_) => const QuizScreen(),
        Routes.quizCreation: (_) => const QuizCreationScreen(),
        Routes.favorites: (_) => const FavoritesScreen(),
        Routes.notifications: (_) => const NotificationsScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.progress: (_) => const ProgressTrackerScreen(),
        Routes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
