import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/signup_provider.dart';
import 'providers/language_provider.dart';
import 'screens/test_results_provider.dart';

// ✅ Screen imports
import 'screens/landing1.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/user_type_screen.dart';
import 'screens/auth/age_consent_screen.dart';
import 'screens/auth/language_select_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/token_screen.dart';
import 'screens/home_screen.dart';
import 'screens/Tests.dart';
import 'screens/dynamictest.dart';
import 'screens/additional_tests_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TestResultsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ✅ Named routes
      initialRoute: '/',

      routes: {
        '/': (context) => const Landing1(),
        '/auth-choice': (context) => const AuthChoiceScreen(),
        '/login': (context) => const LoginScreen(),
        '/user-type': (context) => const UserTypeScreen(),
        '/age-consent': (context) => const AgeConsentScreen(),
        '/token': (context) => const TokenScreen(),
        '/language': (context) => const LanguageSelectScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/tests': (context) => TestsPage(),
        '/dynamic-test': (context) => const DynamicTestPage(testId: 'stress'),
        '/additional-tests': (context) => const AdditionalTestsPage(),
      },
    );
  }
}
