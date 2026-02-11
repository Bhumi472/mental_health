import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/constants/app_text_styles.dart';
import 'package:mentalhealthai/widgets/app_button.dart';
import 'package:mentalhealthai/providers/signup_provider.dart';
import 'package:mentalhealthai/providers/language_provider.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);
    final lp = Provider.of<LanguageProvider>(context);
    String selectedType = signupProvider.userType;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              lp.translate('sign_up'),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "${lp.translate('step')} 1 ${lp.translate('of')} 5",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.2,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              lp.translate('welcome'),
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 10),
            Text(
              lp.translate('user_type_title'),
              style: AppTextStyles.subHeading,
            ),
            const SizedBox(height: 30),
            _buildTypeCard(
              title: lp.translate('org'),
              subtitle: "For workplace mental health",
              icon: Icons.business,
              type: "organization",
              selectedType: selectedType,
              onTap: (type) => signupProvider.setUserType(type),
            ),
            const SizedBox(height: 16),
            _buildTypeCard(
              title: lp.translate('fam'),
              subtitle: "Family wellness plan",
              icon: Icons.family_restroom,
              type: "family",
              selectedType: selectedType,
              onTap: (type) => signupProvider.setUserType(type),
            ),
            const SizedBox(height: 16),
            _buildTypeCard(
              title: lp.translate('ind'),
              subtitle: "Personal mental health journey",
              icon: Icons.person_outline,
              type: "individual",
              selectedType: selectedType,
              onTap: (type) => signupProvider.setUserType(type),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: lp.translate('next'),
                icon: Icons.chevron_right,
                onPressed: selectedType.isEmpty 
                  ? null 
                  : () => Navigator.pushNamed(context, '/age-consent'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
    required String selectedType,
    required Function(String) onTap,
  }) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
