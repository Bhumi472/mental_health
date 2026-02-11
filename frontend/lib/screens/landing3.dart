import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentalhealthai/constants/app_text_styles.dart';
import 'package:mentalhealthai/providers/language_provider.dart';

class Landing3 extends StatelessWidget {
  const Landing3({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    return Column(
      children: [
        const Spacer(),
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(
            Icons.psychology,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          lp.translate('landing3_title'),
          style: AppTextStyles.heading.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            lp.translate('landing3_sub'),
            textAlign: TextAlign.center,
            style: AppTextStyles.subHeading.copyWith(
              color: Colors.white70,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
