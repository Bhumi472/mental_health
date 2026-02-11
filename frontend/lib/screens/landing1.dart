import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/app_button.dart';

class Landing1 extends StatelessWidget {
  const Landing1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7AAAD8),
              Color(0xFF9BC5C3),
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),

            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const Icon(
                Icons.self_improvement,
                size: 70,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Welcome to MindfulCare",
              style: AppTextStyles.heading.copyWith(color: Colors.white),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Your personalized mental health companion",
                textAlign: TextAlign.center,
                style: AppTextStyles.subHeading.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _Dot(active: true),
                _Dot(active: false),
                _Dot(active: false),
                _Dot(active: false),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: "Continue",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');

                  },
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white54,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../constants/app_colors.dart';
// import '../../constants/app_text_styles.dart';
// import '../../widgets/app_button.dart';
// import '../../services/api_service.dart';
// import '../../services/auth_service.dart';

// class Landing1 extends StatefulWidget {
//   const Landing1({super.key});

//   @override
//   State<Landing1> createState() => _Landing1State();
// }

// class _Landing1State extends State<Landing1> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF7AAAD8),
//               Color(0xFF9BC5C3),
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             const Spacer(),

//             CircleAvatar(
//               radius: 70,
//               backgroundColor: Colors.white.withOpacity(0.3),
//               child: const Icon(
//                 Icons.self_improvement,
//                 size: 70,
//                 color: Colors.white,
//               ),
//             ),

//             const SizedBox(height: 30),

//             Text(
//               "Welcome to MindfulCare",
//               style: AppTextStyles.heading.copyWith(color: Colors.white),
//             ),

//             const SizedBox(height: 12),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               child: Text(
//                 "Your personalized mental health companion",
//                 textAlign: TextAlign.center,
//                 style: AppTextStyles.subHeading.copyWith(
//                   color: Colors.white70,
//                 ),
//               ),
//             ),

//             const Spacer(),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _dot(true),
//                 _dot(false),
//                 _dot(false),
//                 _dot(false),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 🔘 Continue Button (NOW CONNECTED)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: AppButton(
//                   text: "Continue",
//                   onPressed: () async {
//                     await _testSignup();
//                   },
//                 ),
//               ),
//             ),

//             // Additional test buttons for different methods
//             const SizedBox(height: 10),
            
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   onPressed: () async {
//                     await _testSignupWithoutAge();
//                   },
//                   child: const Text("Test without age"),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),
            
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   onPressed: () async {
//                     await _testLogin();
//                   },
//                   child: const Text("Test Login"),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   // Test signup with all required fields
//   Future<void> _testSignup() async {
//     try {
//       // Calculate date of birth from age (20 years old)
//       final now = DateTime.now();
//       final dateOfBirth = DateTime(now.year - 20, now.month, now.day);
      
//       debugPrint("Testing signup with date of birth: $dateOfBirth");
      
//       final res = await AuthService.signupIndividual(
//         username: "rutuja_test",
//         email: "rutuja@test.com",
//         password: "password123",
//         age: 20,
//         firstName: "Rutuja",
//         lastName: "Test",
//         dateOfBirth: dateOfBirth,
//         city: "Mumbai", // ✅ Added
//       );
//       debugPrint("Signup response: $res");
      
//       // Show result in a dialog
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Signup Result"),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("Response:"),
//                 const SizedBox(height: 10),
//                 Text(
//                   res.toString(),
//                   style: const TextStyle(fontFamily: 'monospace'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error: $e");
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Error"),
//           content: Text("Signup failed: $e"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   // Test signup without age (backend might calculate from date_of_birth)
//   Future<void> _testSignupWithoutAge() async {
//     try {
//       // Note: This method requires signupIndividualWithoutAge to be defined in AuthService
//       final now = DateTime.now();
//       final dateOfBirth = DateTime(now.year - 20, now.month, now.day);
      
//       debugPrint("Testing signup without age parameter");
      
//       // First try with date string format
//       final dateString = DateFormat('yyyy-MM-dd').format(dateOfBirth);
      
//       debugPrint("Using date string: $dateString");
      
//       // If signupIndividualWithoutAge is not defined, use this workaround:
//       final requestBody = {
//         "account_type": "individual",
//         "username": "rutuja_test2",
//         "email": "rutuja2@test.com",
//         "password": "password123",
//         "first_name": "Rutuja",
//         "last_name": "Test",
//         "date_of_birth": dateString,
//         "city": "Mumbai",
//       };
      
//       debugPrint("Sending: $requestBody");
      
//       // You would typically call your API here
//       // For now, show a message
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Test Without Age"),
//           content: const Text("This would send signup without age_group field.\n\nBackend should calculate age from date_of_birth."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint("Error: $e");
//     }
//   }

//   // Test login functionality
//   Future<void> _testLogin() async {
//     try {
//       debugPrint("Testing login functionality");
      
//       final res = await AuthService.login(
//         usernameOrEmail: "rutuja_test",
//         password: "password123",
//       );
      
//       debugPrint("Login response: $res");
      
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Login Result"),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("Response:"),
//                 const SizedBox(height: 10),
//                 Text(
//                   res.toString(),
//                   style: const TextStyle(fontFamily: 'monospace'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       debugPrint("Login error: $e");
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Login Error"),
//           content: Text("Login failed: $e"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _dot(bool active) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: active ? 16 : 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: active ? AppColors.primary : Colors.white54,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
// }

