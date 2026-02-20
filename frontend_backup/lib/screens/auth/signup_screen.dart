import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/constants/app_text_styles.dart';
import 'package:mentalhealthai/widgets/app_button.dart';
import 'package:mentalhealthai/providers/signup_provider.dart';
import 'package:mentalhealthai/providers/language_provider.dart';
import 'package:mentalhealthai/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String? _selectedAgeGroup;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final List<String> _ageGroups = [
    "under_13",
    "13_17",
    "18_25",
    "26_35",
    "36_50",
    "51_65",
    "66_plus"
  ];

  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);
    final lp = Provider.of<LanguageProvider>(context);

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
              "${lp.translate('step')} 5 ${lp.translate('of')} 5",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                lp.translate('profile_title'),
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 20),
              _buildTextField(controller: _fullNameController, hint: "Full Name"),
              const SizedBox(height: 16),
              _buildTextField(controller: _usernameController, hint: "@username"),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController, 
                hint: "City / Location", 
                icon: Icons.location_on_outlined
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(controller: _passwordController, hint: "Password", isObscure: true),
              const SizedBox(height: 16),
              _buildTextField(controller: _confirmPasswordController, hint: "Confirm Password", isObscure: true),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "I agree to ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: _isLoading ? "Creating..." : lp.translate('create_account'),
                  onPressed: (_agreedToTerms && !_isLoading) ? _handleSignup : null,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "This field is required";
        }
        if (hint.toLowerCase().contains("password")) {
          if (value.length < 8) return "Password must be at least 8 characters";
          if (!value.contains(RegExp(r'[0-9]'))) return "Password must contain at least one digit";
          if (!value.contains(RegExp(r'[A-Z]'))) return "Password must contain at least one uppercase letter";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, color: AppColors.primary.withOpacity(0.5)) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeGroup,
          hint: const Text("Select Age-Group dropdown"),
          isExpanded: true,
          items: _ageGroups.map((String group) {
            return DropdownMenuItem<String>(
              value: group,
              child: Text(group),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAgeGroup = val),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an age group")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final names = _fullNameController.text.split(' ');
      final firstName = names[0];
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      // Using the user type and age group from provider if needed, 
      // but here we use the dropdown value for specificity in step 5
      
      final signupProvider = Provider.of<SignupProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

      final response = await AuthService.signupIndividual(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Defaulting for now
        city: _cityController.text,
        language: languageProvider.currentLanguage,
        termsAccepted: _agreedToTerms,
        privacyAccepted: _agreedToTerms, // Assuming one checkbox covers both as per UI
      );

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'])),
        );
      } else {
        final userId = response['user']?['id'] ?? 'Unknown';
        print("✅ User created with ID: $userId");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully! ID: $userId")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
