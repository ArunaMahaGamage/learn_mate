import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_mate/models/settings.dart';
import 'package:learn_mate/viewmodels/settings_provider.dart';
import 'package:learn_mate/views/signup_screen.dart';
import 'package:learn_mate/views/subject_screen.dart';
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
import 'views/profile_screen.dart';
import 'views/settings_screen.dart';
import 'views/ai_assistant_screen.dart';
import 'views/flashcard_screen.dart';
import 'views/stopwatch_screen.dart';



class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Rural Student Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
        brightness: Brightness.light, // Base light theme
      ),
      darkTheme: ThemeData(
        // Define a dark theme
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
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
        Routes.subject: (_) => const SubjectsScreen(),
        Routes.resourceDetail: (_) => const ResourceDetailScreen(),
        Routes.forum: (_) => const ForumScreen(),
        Routes.questionDetail: (_) => const QuestionDetailScreen(),
        Routes.quiz: (_) => const QuizScreen(),
        Routes.quizCreation: (_) => const QuizCreationScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.settings: (_) => const SettingsScreen(),
        Routes.aiAssistant: (context) => const AIAssistantScreen(),
        Routes.flashcards: (context) => const FlashcardScreen(),
        Routes.stopwatch: (context) => const StopwatchScreen(),
      
   
      },
    );
  }
}
