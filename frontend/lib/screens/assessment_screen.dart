import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/mental_health_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Future<Map<String, dynamic>> _assessmentFuture;
  String? _userId;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _reportData; // stores fetched data for PDF

  @override
  void initState() {
    super.initState();
    // Use a known integer ID from your CSV for testing
    _userId = "9";
    if (_userId != null && _userId!.isNotEmpty) {
      _assessmentFuture = MentalHealthService().getUserAssessment(_userId!);
    } else {
      _assessmentFuture = Future.error('User not logged in or missing ID');
    }
  }

  // Color coding for risk levels
  Color _riskColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // Returns icon based on risk level
  IconData _riskIcon(String level) {
    switch (level) {
      case 'High':
        return Icons.warning_amber_rounded;
      case 'Medium':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  // Builds a section card with a title and optional trailing widget (for UI)
  Widget _buildSection(String title, List<Widget> children, {Widget? trailing}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // Builds a risk meter (linear progress with label)
  Widget _riskMeter(String level, double probability) {
    final color = _riskColor(level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Risk Level', style: Theme.of(context).textTheme.bodyMedium),
            Text('$level', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: probability.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text('${(probability * 100).toStringAsFixed(1)}% probability',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // Main report UI (unchanged)
  Widget _buildReportUI(Map<String, dynamic> data) {
    final risk = data['risk'];
    final condition = data['condition'];
    final trend = data['trend_forecast'];
    final alerts = List<String>.from(data['alerts']);
    final recommendations = List<String>.from(data['recommendations']);

    final riskLevel = risk['level'] as String;
    final riskProb = risk['probability'] as double;
    final riskColor = _riskColor(riskLevel);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header with PDF button and generation date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Health Report',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _reportData != null ? _generatePDF : null,
              tooltip: 'Download as PDF',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Risk Summary Card (prominent)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [riskColor.withOpacity(0.7), riskColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: riskColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_riskIcon(riskLevel), color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$riskLevel Risk',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(riskProb * 100).toStringAsFixed(1)}% probability',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Risk Meter & Condition
        _buildSection('Risk Assessment', [
          _riskMeter(riskLevel, riskProb),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Condition: ', style: Theme.of(context).textTheme.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor),
                ),
                child: Text(
                  condition['label'],
                  style: TextStyle(color: riskColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ]),

        // Forecast & Trend
        _buildSection('Forecast', [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Expected sentiment next week',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                trend['next_week_sentiment'].toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (trend['next_week_sentiment'] + 1) / 2,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              trend['next_week_sentiment'] >= 0 ? Colors.green : Colors.orange,
            ),
          ),
        ]),

        // Key Indicators (expand as needed)
        _buildSection('Key Indicators', [
          _indicatorRow(
            icon: Icons.sentiment_satisfied,
            label: 'Mood Score',
            value: '${(riskProb * 100).toStringAsFixed(1)}%',
          ),
          const Divider(),
          _indicatorRow(
            icon: Icons.show_chart,
            label: 'Forecast',
            value: trend['next_week_sentiment'].toStringAsFixed(2),
          ),
        ]),

        // Alerts Section (prominent notifications)
        if (alerts.isNotEmpty)
          _buildSection(
            'Alerts & Notifications',
            alerts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${alerts.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // Recommendations Section
        if (recommendations.isNotEmpty)
          _buildSection(
            'Recommendations',
            recommendations.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(r, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            )).toList(),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${recommendations.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // Detailed Analysis (placeholder for future expansion)
        _buildSection('Detailed Analysis', [
          const Text(
            'Additional metrics and history will appear here.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ]),
      ],
    );
  }

  // Helper row for Key Indicators (UI)
  Widget _indicatorRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // PDF generation – now uses the stored _reportData
  Future<void> _generatePDF() async {
    if (_reportData == null) return;
    await Printing.layoutPdf(
      onLayout: (format) async => await _buildPdf(format, _reportData!),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Extract data
    final risk = data['risk'];
    final condition = data['condition'];
    final trend = data['trend_forecast'];
    final alerts = List<String>.from(data['alerts']);
    final recommendations = List<String>.from(data['recommendations']);

    final riskLevel = risk['level'] as String;
    final riskProb = risk['probability'] as double;
    final riskColorFlutter = _riskColor(riskLevel);

    // Helper to get PdfColor with opacity
    PdfColor _pdfColorWithOpacity(Color color, double opacity) {
      return PdfColor.fromInt(color.withOpacity(opacity).value);
    }

    // Add a page
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Mental Health Clinical Report',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Patient Information
              pw.Text('Patient Information',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Patient ID: $_userId')),
                  pw.Expanded(child: pw.Text('Age: ${_userData?['age'] ?? '—'}')),
                  pw.Expanded(child: pw.Text('Gender: ${_userData?['gender'] ?? '—'}')),
                ],
              ),
              pw.SizedBox(height: 16),

              // Executive Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _pdfColorWithOpacity(riskColorFlutter, 0.2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColor.fromInt(riskColorFlutter.value)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EXECUTIVE SUMMARY',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(riskColorFlutter.value))),
                    pw.SizedBox(height: 4),
                    pw.Text('Risk Level: $riskLevel',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Probability: ${(riskProb * 100).toStringAsFixed(1)}%',
                        style: const pw.TextStyle(fontSize: 16)),
                    pw.Text('Condition: ${condition['label']}',
                        style: const pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Risk Analysis
              pw.Text('Risk Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Level: $riskLevel')),
                  pw.Expanded(child: pw.Text('Probability: ${(riskProb * 100).toStringAsFixed(1)}%')),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.LinearProgressIndicator(
                value: riskProb,
                backgroundColor: PdfColors.grey300,
                valueColor: PdfColor.fromInt(riskColorFlutter.value),
              ),
              pw.SizedBox(height: 16),

              // Condition Analysis
              pw.Text('Condition Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Predicted Condition: ${condition['label']}'),
              pw.Text('Severity Class: ${condition['class']}'),
              pw.Text('Clinical Implication: ${_conditionImplication(condition['label'])}'),
              pw.SizedBox(height: 16),

              // Trend Forecast
              pw.Text('Trend Forecast', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Projected Sentiment (next 7 days): ${trend['next_week_sentiment'].toStringAsFixed(2)}'),
              pw.SizedBox(height: 8),
              pw.LinearProgressIndicator(
                value: (trend['next_week_sentiment'] + 1) / 2,
                backgroundColor: PdfColors.grey300,
                valueColor: trend['next_week_sentiment'] >= 0 ? PdfColors.green : PdfColors.orange,
              ),
              pw.SizedBox(height: 16),

              // Key Behavioral Indicators
              pw.Text('Key Behavioral Indicators', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Indicator', 'Value'],
                data: [
                  ['Avg. Sentiment (7d)', '0.12'],
                  ['Avg. Test Score', '78.5'],
                  ['Game Activity (7d)', '23'],
                  ['Community Engagement', '5'],
                ],
              ),
              pw.SizedBox(height: 16),

              // Alerts
              if (alerts.isNotEmpty) ...[
                pw.Text('Clinical Alerts', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                pw.SizedBox(height: 8),
                ...alerts.map((a) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    border: pw.Border.all(color: PdfColors.red),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(a),
                )),
                pw.SizedBox(height: 16),
              ],

              // Recommendations
              if (recommendations.isNotEmpty) ...[
                pw.Text('Recommendations', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.amber)),
                pw.SizedBox(height: 8),
                ...recommendations.map((r) => pw.Text('• $r')),
                pw.SizedBox(height: 16),
              ],

              // Disclaimer
              pw.Divider(),
              pw.Text(
                'This report is generated by an AI‑assisted tool and should be reviewed by a qualified healthcare professional.',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Helper to return a clinical implication for the condition label
  String _conditionImplication(String label) {
    switch (label) {
      case 'Healthy':
        return 'No significant symptoms detected; routine monitoring advised.';
      case 'Mild':
        return 'Mild symptoms present; consider psychoeducation and self‑help strategies.';
      case 'Moderate':
        return 'Moderate symptoms; clinical review recommended, possibly therapy.';
      case 'Severe':
        return 'Severe symptoms; urgent clinical intervention needed.';
      default:
        return 'Further assessment required.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mental Health Report'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _assessmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }
          // Store data for PDF
          _reportData = snapshot.data;
          return _buildReportUI(snapshot.data!);
        },
      ),
    );
  }
}