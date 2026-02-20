import 'package:flutter/material.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/constants/app_text_styles.dart';
import 'package:mentalhealthai/widgets/app_button.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology_outlined,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 40),
              const Text(
                "Welcome to MindfulCare",
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Your journey to mental wellness starts here",
                style: AppTextStyles.subHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // Button 1: Register
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: "New user? Register",
                  onPressed: () {
                    Navigator.pushNamed(context, '/user-type');
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Button 2: Login
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Existing user? Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
