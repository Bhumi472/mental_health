import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/test_api_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  String userName = "";
  String username = "";
  String email = "";
  String profilePicture = ""; 
  DateTime memberSince = DateTime.now();
  
  // Stats
  int streakDays = 0;
  int totalDays = 0;
  double completionRate = 0.0;
  int badges = 0;
  List<dynamic> assessmentHistory = [];
  
  // Settings
  bool notificationsEnabled = true;
  bool dailyReminders = true;
  bool moodReminders = true;
  bool activitySuggestions = true;
  String selectedLanguage = "English";
  String selectedTheme = "Light";
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final fName = user['first_name']?.toString() ?? "";
      final lName = user['last_name']?.toString() ?? "";
      final oName = user['organization_name']?.toString() ?? "";
      final faName = user['family_name']?.toString() ?? "";
      final uName = user['username']?.toString() ?? "";

      String computedName = "";
      if (fName.isNotEmpty || lName.isNotEmpty) {
        computedName = "$fName $lName".trim();
      } else if (oName.isNotEmpty) {
        computedName = oName;
      } else if (faName.isNotEmpty) {
        computedName = faName;
      } else {
        computedName = uName.isNotEmpty ? uName : "User";
      }

      // Update state if different
      if (mounted) {
        setState(() {
          userName = computedName;
          username = "@${uName.isNotEmpty ? uName : 'user'}";
          email = user['email'] ?? (userName.toLowerCase().replaceAll(" ", ".") + "@mindfulcare.ai");
          if (user['created_at'] != null) {
            memberSince = DateTime.parse(user['created_at']);
            totalDays = DateTime.now().difference(memberSince).inDays + 1;
          }
        });
      }
    }

    try {
      final history = await TestApiService.getAssessmentHistory();
      if (mounted) {
        setState(() {
          assessmentHistory = history;
          badges = (history.length > 0 ? 1 : 0) + (totalDays > 7 ? 1 : 0);
          completionRate = history.isNotEmpty ? 0.5 : 0.0; 
        });
      }
    } catch (e) {
      debugPrint("Error loading assessment history: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        profilePicture = prefs.getString('profile_picture') ?? "";
        notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        dailyReminders = prefs.getBool('daily_reminders') ?? true;
        selectedLanguage = prefs.getString('language') ?? "English";
        selectedTheme = prefs.getString('theme') ?? "Light";
        streakDays = prefs.getInt('streak_days') ?? 0;
      });
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture', profilePicture);
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('daily_reminders', dailyReminders);
    await prefs.setString('language', selectedLanguage);
    await prefs.setString('theme', selectedTheme);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        profilePicture = image.path;
      });
      _saveUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final user = auth.user;
        String displayHeaderName = "Mindful User";
        String displayHandle = "@user";
        
        if (user != null) {
          final fName = user['first_name']?.toString() ?? "";
          final lName = user['last_name']?.toString() ?? "";
          final oName = user['organization_name']?.toString() ?? "";
          final faName = user['family_name']?.toString() ?? "";
          final uName = user['username']?.toString() ?? "";

          if (fName.isNotEmpty || lName.isNotEmpty) {
            displayHeaderName = "$fName $lName".trim();
          } else if (oName.isNotEmpty) {
            displayHeaderName = oName;
          } else if (faName.isNotEmpty) {
            displayHeaderName = faName;
          } else {
            displayHeaderName = uName.isNotEmpty ? uName : "User";
          }
          displayHandle = "@${uName.isNotEmpty ? uName : 'user'}";
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F4EB),
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(displayHeaderName, displayHandle),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildAssessmentHistorySection(),
                const SizedBox(height: 24),
                _buildSettingsSection(),
                const SizedBox(height: 24),
                _buildAchievementsSection(),
                const SizedBox(height: 24),
                _buildDangerSection(),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: _showEditProfileDialog,
        ),
      ],
    );
  }

  Widget _buildHeader(String displayHeaderName, String displayHandle) {
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B9BD1), Color(0xFF8AB5DD)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B9BD1).withOpacity(0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B9BD1), Color(0xFF8AB5DD)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B9BD1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: profilePicture.isEmpty
                          ? Center(
                              child: Text(
                                displayHeaderName.isNotEmpty ? displayHeaderName[0].toUpperCase() : "U",
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                File(profilePicture),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfilePicture,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Color(0xFF6B9BD1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name
                Text(
                  displayHeaderName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Username
                Text(
                  displayHandle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Member since
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF6B9BD1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Member since ${_formatDate(memberSince)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            streakDays.toString(),
            'Day Streak',
            Icons.local_fire_department,
            const Color(0xFFF4C96F),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            '${(completionRate * 100).toInt()}%',
            'Complete',
            Icons.check_circle,
            const Color(0xFF7FC29B),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            badges.toString(),
            'Badges',
            Icons.emoji_events,
            const Color(0xFFF4A59C),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF6B9BD1)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF6B9BD1), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF718096),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E0)),
    );
  }

  Widget _buildAssessmentHistorySection() {
    return _buildSection(
      title: '📊 Assessment History',
      children: [
        _buildListTile(
          'View History',
          '${assessmentHistory.length} tests completed',
          Icons.history,
          _showHistoryDialog,
        ),
      ],
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assessment History'),
        content: SizedBox(
          width: double.maxFinite,
          child: assessmentHistory.isEmpty
              ? const Center(child: Text('No history found.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: assessmentHistory.length,
                  itemBuilder: (context, index) {
                    final item = assessmentHistory[index];
                    return ListTile(
                      title: Text(item['test_name'] ?? 'Assessment'),
                      subtitle: Text('Score: ${item['score'] ?? 'N/A'}'),
                      trailing: Text(_formatDate(DateTime.parse(item['created_at']))),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      title: '⚙️ Settings',
      children: [
        _buildListTile(
          'Language',
          selectedLanguage,
          Icons.language,
          _showLanguageSelector,
        ),
        _buildListTile(
          'Theme',
          selectedTheme,
          Icons.palette,
          _showThemeSelector,
        ),
        _buildListTile(
          'Notifications',
          notificationsEnabled ? 'Enabled' : 'Disabled',
          Icons.notifications,
          () {
            setState(() {
              notificationsEnabled = !notificationsEnabled;
            });
            _saveUserData();
          },
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return _buildSection(
      title: '🏆 Achievements',
      children: [
        _buildListTile(
          'View Badges',
          'You have $badges badges',
          Icons.emoji_events,
          () {},
        ),
      ],
    );
  }

  Widget _buildDangerSection() {
    return _buildSection(
      title: '⚠️ Danger Zone',
      children: [
        _buildListTile(
          'Clear Data',
          'Permanently delete history',
          Icons.delete_sweep,
          _confirmClearData,
          color: const Color(0xFFF4C96F),
        ),
        _buildListTile(
          'Delete Account',
          'Permanently remove account',
          Icons.delete_forever,
          _confirmDeleteAccount,
          color: const Color(0xFFE89E98),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _confirmLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE89E98),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFE89E98)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final usernameController = TextEditingController(text: username.replaceAll("@", ""));
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Note: In a real app, you would call an API here
              setState(() {
                userName = nameController.text;
                username = "@${usernameController.text}";
                email = emailController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil', 'Telugu'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(lang),
            onTap: () {
              setState(() => selectedLanguage = lang);
              _saveUserData();
              Navigator.pop(context);
            },
            trailing: selectedLanguage == lang ? const Icon(Icons.check, color: Color(0xFF6B9BD1)) : null,
          )).toList(),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              onTap: () {
                if (themeService.isDarkMode) themeService.toggleTheme();
                setState(() => selectedTheme = 'Light');
                Navigator.pop(context);
              },
              trailing: !themeService.isDarkMode ? const Icon(Icons.check, color: Color(0xFF6B9BD1)) : null,
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () {
                if (!themeService.isDarkMode) themeService.toggleTheme();
                setState(() => selectedTheme = 'Dark');
                Navigator.pop(context);
              },
              trailing: themeService.isDarkMode ? const Icon(Icons.check, color: Color(0xFF6B9BD1)) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Data?'),
        content: const Text('This will delete all your local records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4C96F)),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('Are you sure? This is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE89E98)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE89E98)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }
}