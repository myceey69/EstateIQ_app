import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/theme.dart';
import '../widgets/score_bar.dart';
import '../models/property.dart';
import 'roi/roi_calculator_screen.dart';
import 'tour/tour_screen.dart';
import 'valuation/valuation_screen.dart';

// ── Gradient presets for property image placeholder ────────────────────────
const List<List<Color>> _kGradients = [
  [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  [Color(0xFF10B981), Color(0xFF3B82F6)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
  [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  [Color(0xFF14B8A6), Color(0xFF6366F1)],
];

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, provider, _) {
        final property = provider.selectedProperty;
        if (property == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Property Details')),
            body: const Center(child: Text('No property selected')),
          );
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                property.title,
                style: const TextStyle(fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
              bottom: TabBar(
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.muted,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Neighborhood'),
                  Tab(text: 'AI Analysis'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OverviewTab(property: property),
                _NeighborhoodTab(property: property),
                _AIAnalysisTab(property: property),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview Tab
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Property property;
  const _OverviewTab({required this.property});

  @override
  Widget build(BuildContext context) {
    final colors =
        _kGradients[property.imageGradientIndex % _kGradients.length];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient image placeholder ────────────────────────────────
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.home_outlined,
                size: 72,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),

          // ── Title + address ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: Theme.of(context).textTheme.displayLarge),
                if (property.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(property.address,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // ── Info chips ────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (property.beds > 0) _infoChip('${property.beds} beds'),
                    if (property.baths > 0)
                      _infoChip('${property.baths} baths'),
                    if (property.sqft > 0) _infoChip('${property.sqft} sqft'),
                    if (property.yearBuilt > 0)
                      _infoChip('Built ${property.yearBuilt}'),
                  ],
                ),
              ],
            ),
          ),

          // ── Price + signal ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('List Price',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    Text(
                      property.priceFormatted,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent2),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: property.getSignalColor().withOpacity(0.15),
                    border: Border.all(color: property.getSignalColor()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.signal,
                    style: TextStyle(
                      color: property.getSignalColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Investment metrics ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Risk',
                    value: property.risk,
                    color: property.getRiskColor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Growth',
                    value: property.growth,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Cap Rate',
                    value: property.capRate,
                    color: AppColors.accent2,
                  ),
                ),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────────────────
          if (property.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this property',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

          // ── Action buttons ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Save to Watchlist
                Consumer<WatchlistProvider>(
                  builder: (ctx, watchlist, _) {
                    final watched = watchlist.isWatched(property.id);
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          late final bool nowSaved;
                          if (watched) {
                            watchlist.removeFromWatchlist(property.id);
                            nowSaved = false;
                          } else {
                            watchlist.addToWatchlist(property.id);
                            nowSaved = true;
                          }
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(nowSaved
                                  ? 'Saved to watchlist'
                                  : 'Removed from watchlist'),
                              duration: const Duration(milliseconds: 1100),
                              backgroundColor:
                                  nowSaved ? AppColors.good : AppColors.warn,
                            ),
                          );
                        },
                        icon: Icon(
                            watched ? Icons.bookmark : Icons.bookmark_border),
                        label: Text(watched
                            ? 'Saved to Watchlist'
                            : 'Save to Watchlist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              watched ? AppColors.good : AppColors.accent,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ROICalculatorScreen(property: property)),
                        ),
                        icon: const Icon(Icons.calculate_outlined, size: 16),
                        label: const Text('Calculate ROI'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent),
                          foregroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TourScreen(property: property)),
                        ),
                        icon:
                            const Icon(Icons.calendar_month_outlined, size: 16),
                        label: const Text('Request Tour'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent2),
                          foregroundColor: AppColors.accent2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neighborhood Tab
// ─────────────────────────────────────────────────────────────────────────────
class _NeighborhoodTab extends StatelessWidget {
  final Property property;
  const _NeighborhoodTab({required this.property});

  @override
  Widget build(BuildContext context) {
    final n = property.neighborhood;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Neighborhood Scores',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ScoreBar(label: 'Safety', score: n.safety),
          const SizedBox(height: 12),
          ScoreBar(label: 'Schools', score: n.schools),
          const SizedBox(height: 12),
          ScoreBar(label: 'Commute', score: n.commute),
          const SizedBox(height: 12),
          ScoreBar(label: 'Amenities', score: n.amenities),
          const SizedBox(height: 12),
          ScoreBar(label: 'Stability', score: n.stability),
          const SizedBox(height: 24),

          // ── Area Highlights ─────────────────────────────────────────
          _insightCard(
            context,
            icon: Icons.star_outline,
            color: AppColors.accent,
            title: 'Area Highlights',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _areaHighlights(n)
                  .map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 14, color: AppColors.good),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(h,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Investment Signals ──────────────────────────────────────
          _insightCard(
            context,
            icon: Icons.trending_up,
            color: AppColors.good,
            title: 'Investment Signals',
            child: Column(
              children: [
                _signalRow(
                    'Risk Level', property.risk, property.getRiskColor()),
                _signalRow('Growth Outlook', property.growth, AppColors.accent),
                _signalRow('Cap Rate', property.capRate, AppColors.accent2),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Market Position ─────────────────────────────────────────
          _insightCard(
            context,
            icon: Icons.bar_chart,
            color: AppColors.warn,
            title: 'Market Position',
            child: Text(
              _marketPosition(property.signal),
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _areaHighlights(dynamic n) {
    final highlights = <String>[];
    if (n.schools > 80) highlights.add('Top-rated schools nearby');
    if (n.commute > 85) highlights.add('Excellent transit access');
    if (n.safety > 80) highlights.add('Safe, low-crime neighborhood');
    if (n.amenities > 85) {
      highlights.add('Shopping & dining within walking distance');
    }
    if (n.stability > 80) highlights.add('Stable, established community');
    if (highlights.isEmpty) {
      highlights.add('Growing neighborhood with improving scores');
    }
    return highlights;
  }

  String _marketPosition(String signal) {
    switch (signal) {
      case 'Undervalued':
        return 'This property is approximately 12% below the area market average, presenting a strong entry point for investors looking to capture future appreciation.';
      case 'Premium':
        return 'Priced at a premium (~8% above market average) reflecting the superior school district, safety ratings, and neighborhood quality.';
      case 'High Growth':
      case 'Emerging':
        return 'Currently at market average pricing, with strong momentum indicators pointing to above-average appreciation over the next 12–24 months.';
      default:
        return 'Competitively priced within the current market. Neighborhood fundamentals support sustained value stability.';
    }
  }

  Widget _signalRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _insightCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required Widget child}) {
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
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Analysis Tab
// ─────────────────────────────────────────────────────────────────────────────
class _AIAnalysisTab extends StatelessWidget {
  final Property property;
  const _AIAnalysisTab({required this.property});

  int _confidence() {
    final hash = property.id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 85 + (hash % 10);
  }

  double _forecastPct() {
    if (property.growth == 'High') return 8.5;
    if (property.growth == 'Medium') return 4.2;
    return 1.8;
  }

  List<FlSpot> _spots() {
    final List<double> data;
    if (property.growth == 'High') {
      data = [0, 1.2, 2.8, 4.5, 6.1, 8.5];
    } else if (property.growth == 'Medium') {
      data = [0, 0.5, 1.2, 2.4, 3.1, 4.2];
    } else {
      data = [0, 0.2, 0.5, 1.0, 1.4, 1.8];
    }
    return data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  String _fmtPrice(int p) {
    if (p >= 1000000) {
      return '\$${(p / 1000000).toStringAsFixed(2)}M';
    }
    return '\$${(p / 1000).toStringAsFixed(0)}K';
  }

  @override
  Widget build(BuildContext context) {
    final low = (property.price * 0.95).toInt();
    final high = (property.price * 1.05).toInt();
    final conf = _confidence();
    final forecast = _forecastPct();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI Valuation card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppColors.accent, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('AI Valuation',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.good.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$conf% confidence',
                          style: const TextStyle(
                              color: AppColors.good,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Estimated Value Range',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${_fmtPrice(low)} – ${_fmtPrice(high)}',
                  style: const TextStyle(
                      color: AppColors.accent2,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('12-Month Forecast',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.trending_up,
                            color: AppColors.good, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+${forecast.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: AppColors.good,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Price forecast chart ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('6-Month Price Trend',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 5,
                      minY: -0.5,
                      maxY: 10,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots(),
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withOpacity(0.08),
                          ),
                        ),
                      ],
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['M1', 'M2', 'M3', 'M4', 'M5', 'M6']
                        .map((m) => Text(m,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 10)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── AI Insights ───────────────────────────────────────────────
          Text('AI Insights', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Why this matters',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _insightText(),
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text('Next best actions',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                ..._nextActions().map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(action,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── View Full Valuation button ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ValuationScreen(property: property)),
              ),
              icon: const Icon(Icons.assessment_outlined, size: 16),
              label: const Text('View Full Valuation Report'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _insightText() {
    if (property.signal.contains('High') || property.growth == 'High') {
      return 'This property demonstrates strong growth fundamentals with above-market appreciation potential. '
          'The combination of ${property.signal} signal and ${property.growth} growth outlook '
          'makes it a compelling opportunity in the current San Jose market.';
    }
    if (property.risk == 'Low') {
      return 'This property offers excellent risk-adjusted returns with a Low risk profile. '
          'The stable neighborhood metrics and consistent cap rate make it ideal '
          'for conservative investors seeking reliable income and capital preservation.';
    }
    return 'This property presents a balanced investment case with ${property.risk} risk '
        'and ${property.growth} growth potential. The ${property.capRate} cap rate '
        'is competitive relative to comparable San Jose properties.';
  }

  List<String> _nextActions() {
    final actions = [
      'Schedule a property inspection',
      'Review comparable sales in the neighborhood',
      'Analyze rental income potential and vacancy rates',
    ];
    if (property.growth == 'High') {
      actions.add('Evaluate short-term rental (Airbnb) opportunity');
    }
    if (property.risk == 'Low') {
      actions.add('Consider long-term hold strategy (5–10 year horizon)');
    }
    return actions;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
