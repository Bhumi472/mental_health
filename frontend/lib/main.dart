import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'screens/test_results_provider.dart';
import 'providers/signup_provider.dart';
import 'providers/language_provider.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';

// Screens
import 'screens/landing1.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/user_type_screen.dart';
import 'screens/auth/age_consent_screen.dart';
import 'screens/auth/language_select_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/token_screen.dart';
import 'screens/home.dart'; // Original complex home screen
import 'screens/Tests.dart';
import 'screens/dynamictest.dart';
import 'screens/additional_tests_page.dart';
import 'screens/journal.dart';
import 'screens/profile_screen.dart';
import 'screens/activities.dart';
import 'screens/games/games_page.dart';
import 'screens/community/community_page.dart';
import 'screens/group_report_screen.dart';
import 'screens/my_group_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.getUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TestResultsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Mental Health AI',
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: themeService.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Landing1(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user-type': (context) => const UserTypeScreen(),
        '/age-consent': (context) => const AgeConsentScreen(),
        '/token': (context) => const TokenScreen(),
        '/language': (context) => const LanguageSelectScreen(),
        '/home': (context) => const HomeScreen(),
        '/tests': (context) => TestsPage(),
        '/additional-tests': (context) => const AdditionalTestsPage(),
        '/journal': (context) => const JournalPage(),
        '/test/baseline': (context) => const DynamicTestPage(testId: 'baseline'),
        '/test/anxiety-screening': (context) => const DynamicTestPage(testId: 'anxiety-screening'),
        '/test/depression-screening': (context) => const DynamicTestPage(testId: 'depression-screening'),
        '/test/stress-resilience': (context) => const DynamicTestPage(testId: 'stress-resilience'),
        '/profile': (context) => const ProfileScreen(), 
        '/activities': (context) => const ActivitiesPage(), 
        '/community': (context) => const CommunityPage(), 
        '/games': (context) => const GamesPage(),
        '/group-report': (context) => const GroupReportScreen(),
        '/my-group': (context) => const MyGroupScreen(),
      },
    );
  }
}
