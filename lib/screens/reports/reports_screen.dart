import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<_GeneratedReport> _generated = [
    _GeneratedReport(
      id: 'r1',
      title: 'Willow Glen Comparables Report',
      type: 'Comparables',
      date: 'Jan 15, 2025',
    ),
    _GeneratedReport(
      id: 'r2',
      title: 'San Jose Market Analysis Q4 2024',
      type: 'Market Analysis',
      date: 'Dec 30, 2024',
    ),
  ];

  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final plan = auth.currentUser?.plan ?? SubscriptionPlan.free;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _generating
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text('Generating report...',
                      style: TextStyle(color: AppColors.muted)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available reports
                  Text('Available Reports',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _ReportCard(
                    title: 'Comparables Report',
                    description:
                        'Analyze recent comparable sales in your area with market pricing.',
                    requiredPlan: 'Basic',
                    icon: Icons.compare_outlined,
                    color: AppColors.accent2,
                    canGenerate: plan != SubscriptionPlan.free,
                    onGenerate: () =>
                        _generate('Comparables Report', plan),
                  ),
                  _ReportCard(
                    title: 'Market Analysis Report',
                    description:
                        'Comprehensive market trends, price history, and forecasts.',
                    requiredPlan: 'Professional',
                    icon: Icons.analytics_outlined,
                    color: AppColors.accent,
                    canGenerate: plan == SubscriptionPlan.professional ||
                        plan == SubscriptionPlan.enterprise,
                    onGenerate: () =>
                        _generate('Market Analysis Report', plan),
                  ),
                  _ReportCard(
                    title: 'Investment Brief',
                    description:
                        'ROI analysis, cash flow projections, and investment recommendations.',
                    requiredPlan: 'Professional',
                    icon: Icons.monetization_on_outlined,
                    color: AppColors.good,
                    canGenerate: plan == SubscriptionPlan.professional ||
                        plan == SubscriptionPlan.enterprise,
                    onGenerate: () =>
                        _generate('Investment Brief', plan),
                  ),
                  _ReportCard(
                    title: 'Portfolio Summary',
                    description:
                        'Aggregate analysis of your entire property portfolio.',
                    requiredPlan: 'Enterprise',
                    icon: Icons.folder_outlined,
                    color: AppColors.warn,
                    canGenerate: plan == SubscriptionPlan.enterprise,
                    onGenerate: () =>
                        _generate('Portfolio Summary', plan),
                  ),
                  const SizedBox(height: 20),

                  // Generated reports
                  Text('Generated Reports',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (_generated.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No reports generated yet',
                            style: TextStyle(color: AppColors.muted)),
                      ),
                    )
                  else
                    ..._generated.map(
                      (r) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bg1,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description_outlined,
                                  color: AppColors.accent, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.title,
                                      style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(r.date,
                                      style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _viewReport(r),
                              child: const Text('View',
                                  style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Future<void> _generate(String type, SubscriptionPlan plan) async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _generating = false;
      _generated.insert(
        0,
        _GeneratedReport(
          id: 'r${_generated.length + 1}',
          title: '$type — ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
          type: type,
          date: 'Just now',
        ),
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: AppColors.good),
      );
    }
  }

  void _viewReport(_GeneratedReport r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ReportViewScreen(report: r)),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final String requiredPlan;
  final IconData icon;
  final Color color;
  final bool canGenerate;
  final VoidCallback onGenerate;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.requiredPlan,
    required this.icon,
    required this.color,
    required this.canGenerate,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: canGenerate
                ? color.withOpacity(0.3)
                : AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: canGenerate
                                ? AppColors.text
                                : AppColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(requiredPlan,
                          style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                    maxLines: 2),
              ],
            ),
          ),
          const SizedBox(width: 8),
          canGenerate
              ? ElevatedButton(
                  onPressed: onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Generate',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11)),
                )
              : OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Upgrade to $requiredPlan plan to generate this report'),
                        backgroundColor: AppColors.warn,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.warn),
                    foregroundColor: AppColors.warn,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Upgrade',
                      style: TextStyle(fontSize: 11)),
                ),
        ],
      ),
    );
  }
}

class _GeneratedReport {
  final String id;
  final String title;
  final String type;
  final String date;
  const _GeneratedReport({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
  });
}

class _ReportViewScreen extends StatelessWidget {
  final _GeneratedReport report;
  const _ReportViewScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.type),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Generated: ${report.date}',
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 16),

            // Mock report content
            _reportSection('Executive Summary',
                'This report analyzes 15 comparable properties in the San Jose area. Market conditions remain favorable with a 4.2% year-over-year price increase. Properties are selling at 98.5% of list price on average.'),
            const SizedBox(height: 14),

            // Mock chart
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Distribution',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: 10,
                        barGroups: [
                          _barGroup(0, 3, '\$600K-700K'),
                          _barGroup(1, 7, '\$700K-800K'),
                          _barGroup(2, 9, '\$800K-900K'),
                          _barGroup(3, 5, '\$900K-1M'),
                          _barGroup(4, 2, '\$1M+'),
                        ],
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const labels = [
                                  '600K', '700K', '800K', '900K', '1M+'
                                ];
                                final i = v.toInt();
                                return i < labels.length
                                    ? Text(labels[i],
                                        style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 8))
                                    : const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _reportSection('Key Metrics',
                '• Median Sale Price: \$879,000\n• Average Days on Market: 14\n• Sale-to-List Ratio: 98.5%\n• Price per Sqft: \$612\n• Active Listings: 32\n• Closed Sales (30 days): 18'),
            const SizedBox(height: 14),
            _reportSection('Market Outlook',
                'The San Jose market continues to show resilience with strong tech sector employment supporting demand. Limited inventory combined with population growth suggests continued appreciation of 4-6% annually over the next 12-18 months.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.accent,
          width: 26,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _reportSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.6)),
        ],
      ),
    );
  }
}
