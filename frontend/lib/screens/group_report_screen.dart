import 'package:flutter/material.dart';
import 'package:mentalhealthai/constants/app_colors.dart';
import 'package:mentalhealthai/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class GroupReportScreen extends StatefulWidget {
  const GroupReportScreen({super.key});

  @override
  State<GroupReportScreen> createState() => _GroupReportScreenState();
}

class _GroupReportScreenState extends State<GroupReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AuthService.getGroupReport();
      if (data.containsKey('error')) {
        setState(() {
          _error = data['error'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _reportData = data;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      appBar: AppBar(
        title: Text(_reportData?['group_name'] ?? "Group Report"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : RefreshIndicator(
                  onRefresh: _fetchReport,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCard(),
                        const SizedBox(height: 30),
                        const Text(
                          "📈 Weekly Mood Trend",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildTrendChart(),
                        const SizedBox(height: 30),
                        const Text(
                          "📊 Member-wise Status",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...(_reportData?['members'] as List).map((m) => _buildMemberCard(m)).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewCard() {
    final stats = _reportData?['stats'];
    final stressLevel = stats?['stress_level'] ?? 'Unknown';
    final balance = stats?['emotional_balance'] ?? 0;

    Color stressColor = Colors.green;
    if (stressLevel == 'High') stressColor = Colors.red;
    else if (stressLevel == 'Medium') stressColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text("🧠 Family Mental Health Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Stress Level", stressLevel, stressColor),
              _buildStatItem("Balance Score", "$balance%", Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrendChart() {
    final trend = _reportData?['stats']?['weekly_trend'] as List?;
    if (trend == null || trend.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("No data")));

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 20, top: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < trend.length) return Text(trend[idx]['day']);
                  return const Text("");
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['score'].toDouble())).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final status = member['status'] ?? 'Unknown';
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle_outline;

    if (status == 'High Risk') {
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
    } else if (status == 'Moderate Stress' || status == 'Mild') {
      statusColor = Colors.orange;
      statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Text(member['name'][0], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Last Test: ${member['last_assessment']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (status == 'High Risk') const Text("⚠️ ", style: TextStyle(fontSize: 16)),
                  Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Text("${member['mood_count']} logs this week", style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
