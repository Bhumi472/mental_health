import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/constants/app_text_styles.dart';
import 'package:mentalhealthai/widgets/app_button.dart';
import 'package:mentalhealthai/providers/signup_provider.dart';
import 'package:mentalhealthai/providers/language_provider.dart';

class AgeConsentScreen extends StatefulWidget {
  const AgeConsentScreen({super.key});

  @override
  State<AgeConsentScreen> createState() => _AgeConsentScreenState();
}

class _AgeConsentScreenState extends State<AgeConsentScreen> {
  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);
    final lp = Provider.of<LanguageProvider>(context);
    String selectedAgeGroup = signupProvider.ageGroup;

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
              "${lp.translate('step')} 2 ${lp.translate('of')} 5",
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
                value: 0.4,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              lp.translate('age_group_title'),
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 30),
            _buildAgeCard(
              title: "18 and above",
              type: "above18",
              selectedAgeGroup: selectedAgeGroup,
              onTap: (group) => signupProvider.setAgeGroup(group),
            ),
            const SizedBox(height: 16),
            _buildAgeCard(
              title: "Under 18",
              type: "under18",
              selectedAgeGroup: selectedAgeGroup,
              onTap: (group) => signupProvider.setAgeGroup(group),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.black87, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Users under 18 require parental consent to use this platform.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: lp.translate('next'),
                icon: Icons.chevron_right,
                onPressed: selectedAgeGroup.isEmpty 
                  ? null 
                  : () {
                    if (signupProvider.userType == 'individual') {
                      Navigator.pushNamed(context, '/language');
                    } else {
                      Navigator.pushNamed(context, '/token');
                    }
                  },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeCard({
    required String title,
    required String type,
    required String selectedAgeGroup,
    required Function(String) onTap,
  }) {
    bool isSelected = selectedAgeGroup == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
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
