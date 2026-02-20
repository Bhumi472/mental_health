import 'package:flutter/material.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/services/auth_service.dart';

class MyGroupScreen extends StatefulWidget {
  const MyGroupScreen({super.key});

  @override
  State<MyGroupScreen> createState() => _MyGroupScreenState();
}

class _MyGroupScreenState extends State<MyGroupScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _groupData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AuthService.getMyGroup();
      if (data.containsKey('error')) {
        setState(() {
          _error = data['error'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _groupData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      appBar: AppBar(
        title: const Text("My Group"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error ?? "Unknown error occurred",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchGroupDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.groups, size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _groupData?['name'] ?? "Unknown Group",
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (_groupData?['type'] ?? 'individual').toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildInfoRow(Icons.vpn_key_outlined, "Token", _groupData?['token'] ?? ""),
                              const Divider(height: 32),
                              _buildInfoRow(Icons.people_outline, "Members Count", "${_groupData?['member_count']} current members"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Members List Section
                        if (_groupData?['members'] != null) ...[
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Group Members",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_groupData!['members'] as List).length,
                            itemBuilder: (context, index) {
                              final member = _groupData!['members'][index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: member['is_me'] == true ? AppColors.primary : Colors.grey[200],
                                    child: Text(
                                      (member['name'] as String).substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        color: member['is_me'] == true ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    member['name'] + (member['is_me'] == true ? " (You)" : ""),
                                    style: TextStyle(
                                      fontWeight: member['is_me'] == true ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: member['is_me'] == true 
                                      ? const Icon(Icons.person_pin, color: AppColors.primary) 
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 40),
                        const Text(
                          "Your activity is shared with the group admin to help them track collective wellness.",
                          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
