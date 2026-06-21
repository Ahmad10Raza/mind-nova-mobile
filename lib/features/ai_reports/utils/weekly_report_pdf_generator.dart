import 'dart:math' as math;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/weekly_report_model.dart';

class WeeklyReportPdfGenerator {
  static Future<void> exportAndShare(WeeklyReport report) async {
    final pdf = pw.Document();

    // Load fonts to support Unicode and Emojis
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final emoji = await PdfGoogleFonts.notoColorEmoji();

    final dateRange = '${DateFormat('MMMM d').format(report.weekStartDate)} - ${DateFormat('MMMM d, yyyy').format(report.weekEndDate)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          fontFallback: [emoji],
        ),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('MindNova AI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
                    pw.SizedBox(height: 4),
                    pw.Text('Weekly Clinical Insight Report', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(dateRange, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 2, color: PdfColors.deepPurple200),
            pw.SizedBox(height: 24),

            // AI Assessment Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(report.aiTitle ?? 'Executive Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: _getRiskColor(report.crisisRiskLevel),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text('RISK: ${report.crisisRiskLevel}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    report.aiSummary,
                    style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                  ),
                  if (report.aiWhatHelped != null && report.aiWhatHelped!.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    pw.Row(children: [
                      pw.Text('💡', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(width: 6),
                      pw.Text('What Helped', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Text(report.aiWhatHelped!, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColors.grey800)),
                  ],
                  if (report.aiChallenges != null && report.aiChallenges!.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    pw.Row(children: [
                      pw.Text('⚡', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(width: 6),
                      pw.Text('Challenges', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Text(report.aiChallenges!, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColors.grey800)),
                  ],
                  if (report.aiEncouragement != null && report.aiEncouragement!.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.deepPurple50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        report.aiEncouragement!,
                        style: pw.TextStyle(fontSize: 11, color: PdfColors.deepPurple900, lineSpacing: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // AI Recommendations
            if (report.aiRecommendations.isNotEmpty) ...[
              pw.Text('Actionable Recommendations', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 12),
              ...report.aiRecommendations.map((rec) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                    pw.Expanded(child: pw.Text(rec, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5))),
                  ],
                ),
              )),
              pw.SizedBox(height: 32),
            ],

            // Emotional Radar
            pw.Text('Emotional Radar (Scaled 1-5)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildRadarChart(report),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMetricBox('Mood', report.avgMoodScore.toStringAsFixed(1), 'Out of 5'),
                    pw.SizedBox(height: 8),
                    _buildMetricBox('Sleep', report.avgSleepHours != null ? report.avgSleepHours!.toStringAsFixed(1) : '0.0', 'Out of 5'),
                    pw.SizedBox(height: 8),
                    _buildMetricBox('Stability', (5 - (report.emotionalVolatility ?? 0)).toStringAsFixed(1), 'Out of 5'),
                    pw.SizedBox(height: 8),
                    _buildMetricBox('Recovery', ((report.recoveryScore ?? 0) / 20).toStringAsFixed(1), 'Out of 5'),
                    pw.SizedBox(height: 8),
                    _buildMetricBox('Engagement', ((report.engagementScore ?? 0) / 20).toStringAsFixed(1), 'Out of 5'),
                  ],
                ),
              ]
            ),
            pw.SizedBox(height: 32),

            // Core Metrics
            pw.Text('Core Health Metrics', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricBox('Avg Mood', report.avgMoodScore.toStringAsFixed(1), 'Out of 5.0'),
                if (report.wellnessScore != null)
                  _buildMetricBox('Wellness', '${report.wellnessScore!.toInt()}%', 'Overall Score'),
                if (report.recoveryScore != null)
                  _buildMetricBox('Recovery', '${report.recoveryScore!.toInt()}%', 'Resilience Score'),
                if (report.avgSleepHours != null)
                  _buildMetricBox('Sleep', '${report.avgSleepHours!.toStringAsFixed(1)} hrs', 'Daily Average'),
                if (report.engagementScore != null)
                  _buildMetricBox('Engagement', '${report.engagementScore!.toInt()}', 'App Usage Index'),
                if (report.emotionalVolatility != null)
                  _buildMetricBox('Volatility', report.emotionalVolatility!.toStringAsFixed(1), 'Emotional variance'),
                if (report.burnoutRisk != null)
                  _buildMetricBox('Burnout Risk', report.burnoutRisk!.toStringAsFixed(2), 'Risk Indicator'),
                if (report.cmhiWeeklyScore != null)
                  _buildMetricBox('CMHI', report.cmhiWeeklyScore!.toStringAsFixed(0), 'Health Index'),
              ],
            ),
            pw.SizedBox(height: 32),

            // Activity Overview
            pw.Text('Activity Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricBox('Time Spent', '${report.totalTimeSpentMinutes}m', 'Total Minutes'),
                _buildMetricBox('Sessions', '${report.totalAppSessions}', 'App Opens'),
                _buildMetricBox('Community', '${report.communityPostsCreated + report.communityComments}', 'Interactions'),
              ],
            ),
            pw.SizedBox(height: 32),

            // Weekly Wins
            pw.Text('Behavioral Wins & Engagement', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (report.streakScore > 0) _buildWinPill('${report.streakScore} Day Streak'),
                if (report.meditationMinutes > 0) _buildWinPill('${report.meditationMinutes}m Meditation'),
                if (report.gratitudeCount > 0) _buildWinPill('${report.gratitudeCount} Gratitudes'),
                if (report.journalCount > 0) _buildWinPill('${report.journalCount} Journals'),
                if (report.groundingSessions > 0) _buildWinPill('${report.groundingSessions} Grounding Sessions'),
                if (report.audioMinutes > 0) _buildWinPill('${report.audioMinutes}m Audio Therapy'),
              ],
            ),
            pw.SizedBox(height: 32),

            // Mood Chart Data (Tabular for PDF)
            if (report.moodChartData.isNotEmpty) ...[
              pw.Text('Daily Mood Log (Chronological)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerHeight: 25,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
                headers: ['Day of Week', 'Average Score (1-5)'],
                data: report.moodChartData.map((d) => [d['day'].toString(), (d['score'] as num).toStringAsFixed(1)]).toList(),
              ),
              pw.SizedBox(height: 24),
              // Render Line Graph
              if (report.moodChartData.length > 1)
                pw.Container(
                  height: 150,
                  child: pw.Chart(
                    grid: pw.CartesianGrid(
                      xAxis: pw.FixedAxis.fromStrings(
                        List<String>.generate(report.moodChartData.length, (i) => report.moodChartData[i]['day'].toString()),
                        marginStart: 20,
                        marginEnd: 20,
                        ticks: true,
                      ),
                      yAxis: pw.FixedAxis(
                        [0, 1, 2, 3, 4, 5],
                        format: (v) => v.toInt().toString(),
                        ticks: true,
                      ),
                    ),
                    datasets: [
                      pw.LineDataSet(
                        data: List<pw.PointChartValue>.generate(
                          report.moodChartData.length,
                          (i) => pw.PointChartValue(i.toDouble(), (report.moodChartData[i]['score'] as num).toDouble()),
                        ),
                        lineColor: PdfColors.deepPurpleAccent,
                        pointColor: PdfColors.deepPurple,
                        pointSize: 4,
                        lineWidth: 2,
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 32),
            ],

            // Clinical Assessments
            if (report.assessmentHistory.isNotEmpty) ...[
              pw.Text('Clinical Assessments', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 12),
              ...report.assessmentHistory.map((a) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(a['type']?.toString().toUpperCase() ?? 'Assessment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Score: ${a['score']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
                  ],
                ),
              )),
              pw.SizedBox(height: 32),
            ],

            // Diary Entries
            if (report.diaryEntriesDetailed.isNotEmpty) ...[
              pw.Text('Journal Highlights', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 12),
              ...report.diaryEntriesDetailed.map((entry) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(12),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(entry['title'] ?? 'Entry', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple800)),
                    pw.SizedBox(height: 4),
                    pw.Text(entry['content'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800, lineSpacing: 1.5)),
                  ],
                ),
              )),
              pw.SizedBox(height: 32),
            ],

            // Professional Care
            if (report.therapistData.isNotEmpty) ...[
              pw.Text('Professional Care', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Therapist Data Synced', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple800)),
                    pw.SizedBox(height: 4),
                    pw.Text('Sessions this week: ${report.therapistData['sessionsThisWeek'] ?? 0}', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Data Shared: ${report.therapistData['dataShared'] == true ? "Yes" : "No"}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),
            ],
            
            // Footer
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('Generated securely by MindNova on ${DateFormat('MMM d, yyyy').format(DateTime.now())}. This report is intended for personal insight and is not a clinical diagnosis.', 
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center
              ),
            ),
          ];
        },
      ),
    );

    // Trigger sharing/downloading via Printing package
    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'MindNova_Weekly_Insight_${DateFormat('yyyyMMdd').format(report.weekStartDate)}.pdf');
  }

  static pw.Widget _buildRadarChart(WeeklyReport report) {
    final moodN = (report.avgMoodScore / 5.0).clamp(0.0, 1.0);
    final sleepN = ((report.avgSleepHours ?? 0) / 9.0).clamp(0.0, 1.0);
    final stabilityN = (1.0 - (report.emotionalVolatility ?? 0) / 2.0).clamp(0.0, 1.0);
    final recoveryN = ((report.recoveryScore ?? 0) / 100.0).clamp(0.0, 1.0);
    final engageN = ((report.engagementScore ?? 0) / 100.0).clamp(0.0, 1.0);

    final values = [moodN, sleepN, stabilityN, recoveryN, engageN];
    final labels = ['Mood', 'Sleep', 'Stability', 'Recovery', 'Engagement'];

    return pw.SizedBox(
      height: 240,
      width: 260,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          // Background Radar CustomPaint
          pw.Positioned.fill(
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                final center = PdfPoint(size.x / 2, size.y / 2);
                final radius = 75.0; // Fixed radius for the grid

                // Draw axes
                for (var i = 0; i < 5; i++) {
                  final angle = math.pi / 2 - (i * 2 * math.pi / 5);
                  canvas.moveTo(center.x, center.y);
                  canvas.lineTo(center.x + radius * math.cos(angle), center.y + radius * math.sin(angle));
                  canvas.setColor(PdfColors.grey300);
                  canvas.setLineWidth(1);
                  canvas.strokePath();
                }

                // Draw grid pentagons
                for (var step = 1; step <= 4; step++) {
                  final r = radius * (step / 4.0);
                  for (var i = 0; i < 5; i++) {
                    final angle = math.pi / 2 - (i * 2 * math.pi / 5);
                    if (i == 0) {
                      canvas.moveTo(center.x + r * math.cos(angle), center.y + r * math.sin(angle));
                    } else {
                      canvas.lineTo(center.x + r * math.cos(angle), center.y + r * math.sin(angle));
                    }
                  }
                  canvas.closePath();
                  canvas.setColor(PdfColors.grey300);
                  canvas.setLineWidth(1);
                  canvas.strokePath();
                }

                // Draw data border (No fill to keep it clean)
                for (var i = 0; i < 5; i++) {
                  final angle = math.pi / 2 - (i * 2 * math.pi / 5);
                  final valRadius = radius * values[i];
                  if (i == 0) {
                    canvas.moveTo(center.x + valRadius * math.cos(angle), center.y + valRadius * math.sin(angle));
                  } else {
                    canvas.lineTo(center.x + valRadius * math.cos(angle), center.y + valRadius * math.sin(angle));
                  }
                }
                canvas.closePath();
                canvas.setColor(PdfColors.deepPurple);
                canvas.setLineWidth(2.5);
                canvas.strokePath();

                // Draw dots at data points
                for (var i = 0; i < 5; i++) {
                  final angle = math.pi / 2 - (i * 2 * math.pi / 5);
                  final valRadius = radius * values[i];
                  final px = center.x + valRadius * math.cos(angle);
                  final py = center.y + valRadius * math.sin(angle);
                  canvas.drawEllipse(px, py, 4, 4);
                  canvas.setFillColor(PdfColors.deepPurple);
                  canvas.fillPath();
                }
              },
            ),
          ),
          
          // Text Labels using Positioned
          ...List.generate(5, (i) {
            final angle = math.pi / 2 - (i * 2 * math.pi / 5);
            final labelRadius = 95.0; // Distance of labels from center
            
            // pw.Stack uses Top-Left coordinate system.
            // Center is (130, 120) since size is 260x240
            final cx = 130.0;
            final cy = 120.0;
            
            final left = cx + labelRadius * math.cos(angle) - 30; // -30 to center text horizontally
            final top = cy - labelRadius * math.sin(angle) - 10; // -10 to center text vertically

            return pw.Positioned(
              left: left,
              top: top,
              child: pw.Container(
                width: 60,
                alignment: pw.Alignment.center,
                child: pw.Text(
                  labels[i],
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static PdfColor _getRiskColor(String risk) {
    if (risk == 'CRITICAL' || risk == 'HIGH') return PdfColors.red600;
    if (risk == 'MED') return PdfColors.orange500;
    return PdfColors.green600;
  }

  static pw.Widget _buildMetricBox(String label, String value, String subtitle) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.deepPurple200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple700)),
          pw.SizedBox(height: 4),
          pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildWinPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.deepPurple50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
        border: pw.Border.all(color: PdfColors.deepPurple200),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple800)),
    );
  }
}
