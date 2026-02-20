import 'package:flutter/material.dart';

class StaticTestScreen extends StatefulWidget {
  final String title;
  final List<String> questions;

  const StaticTestScreen({super.key, required this.title, required this.questions});

  @override
  State<StaticTestScreen> createState() => _StaticTestScreenState();
}

class _StaticTestScreenState extends State<StaticTestScreen> {
  final Map<int, int?> _answers = {}; // Index of question to score (0-4 etc)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EB),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2AB5B4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Rate each statement based on your recent experiences:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...widget.questions.asMap().entries.map((entry) {
              int idx = entry.key;
              String question = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${idx + 1}. $question",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOption(idx, 0, "Not at all"),
                          _buildOption(idx, 1, "Sometimes"),
                          _buildOption(idx, 2, "Often"),
                          _buildOption(idx, 3, "Always"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _answers.length < widget.questions.length
                    ? null
                    : () {
                        int totalScore = _answers.values.fold(0, (sum, val) => sum + (val ?? 0));
                        _showResults(totalScore);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2AB5B4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit Test", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int questionIdx, int score, String label) {
    bool isSelected = _answers[questionIdx] == score;
    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[questionIdx] = score;
        });
      },
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
              color: isSelected ? const Color(0xFF2AB5B4) : Colors.transparent,
            ),
            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFF2AB5B4) : Colors.grey)),
        ],
      ),
    );
  }

  void _showResults(int score) {
    String interpretation = "";
    if (score < 10) interpretation = "Minimal concern";
    else if (score < 20) interpretation = "Mild concern";
    else if (score < 30) interpretation = "Moderate concern";
    else interpretation = "High concern";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Test Results"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Score: $score / ${widget.questions.length * 3}"),
            const SizedBox(height: 12),
            Text("Interpretation: $interpretation", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("⚠️ Reminder: This is not a clinical diagnosis. Please consult a professional."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Close Test"),
          ),
        ],
      ),
    );
  }
}
