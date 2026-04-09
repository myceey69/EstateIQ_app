import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/market_data.dart';
import '../../theme/theme.dart';

class MarketTrendsScreen extends StatefulWidget {
  const MarketTrendsScreen({Key? key}) : super(key: key);

  @override
  State<MarketTrendsScreen> createState() => _MarketTrendsScreenState();
}

class _MarketTrendsScreenState extends State<MarketTrendsScreen> {
  String _selectedRegion = 'All';
  final List<String> _regions = [
    'All', 'San Jose', 'Palo Alto', 'Mountain View', 'Sunnyvale', 'Santa Clara'
  ];

  final MarketData _data = MarketData.demo();

  // Region-specific data
  Map<String, Map<String, dynamic>> get _regionData => {
    'All': {'avgPrice': 985000, 'yoyChange': 5.1, 'inventory': 18},
    'San Jose': {'avgPrice': 879000, 'yoyChange': 4.2, 'inventory': 14},
    'Palo Alto': {'avgPrice': 2450000, 'yoyChange': 6.8, 'inventory': 8},
    'Mountain View': {'avgPrice': 1850000, 'yoyChange': 5.5, 'inventory': 10},
    'Sunnyvale': {'avgPrice': 1650000, 'yoyChange': 4.9, 'inventory': 12},
    'Santa Clara': {'avgPrice': 1350000, 'yoyChange': 3.8, 'inventory': 16},
  };

  Map<String, dynamic> get _current =>
      _regionData[_selectedRegion] ?? _regionData['All']!;

  List<PricePoint> get _priceHistory => _data.priceHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Region selector
          Text('Market Trends',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Bay Area Real Estate Analytics',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final r = _regions[i];
                final selected = r == _selectedRegion;
                return ChoiceChip(
                  label: Text(r,
                      style: TextStyle(
                          color: selected ? Colors.white : AppColors.muted,
                          fontSize: 12)),
                  selected: selected,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.bg1,
                  side: BorderSide(
                      color: selected
                          ? AppColors.accent
                          : AppColors.line),
                  onSelected: (_) =>
                      setState(() => _selectedRegion = r),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Key metrics
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  'Avg Price',
                  '\$${(_current['avgPrice'] as int) ~/ 1000}K',
                  AppColors.accent2,
                  Icons.home_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  'YoY Change',
                  '+${_current['yoyChange']}%',
                  AppColors.good,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  'Inventory',
                  '${_current['inventory']} days',
                  AppColors.warn,
                  Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price History Chart
          Text('Price History (12 months)',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _card(
            child: SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 11,
                  minY: 780,
                  maxY: 920,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _priceHistory
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value.price / 1000))
                          .toList(),
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.accent,
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withOpacity(0.08),
                      ),
                    ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.line.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: AppColors.line.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < _priceHistory.length) {
                            return Text(_priceHistory[idx].month,
                                style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 9));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (v, _) => Text(
                          '\$${v.toStringAsFixed(0)}K',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map((s) => LineTooltipItem(
                                '\$${(s.y).toStringAsFixed(0)}K',
                                const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Market Activity BarChart
          Text('Market Activity (6 months)',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _card(
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: 50,
                      barGroups: _buildBarGroups(),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.line.withOpacity(0.3),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => const FlLine(
                          color: Colors.transparent,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              const months = [
                                'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'
                              ];
                              final idx = v.toInt();
                              if (idx >= 0 && idx < months.length) {
                                return Text(months[idx],
                                    style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 10));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 9),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot('New Listings', AppColors.accent),
                    const SizedBox(width: 16),
                    _legendDot('Sales', AppColors.good),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Neighborhood Breakdown
          Text('Top Neighborhoods',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ..._data.trends.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_city_outlined,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.region,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(
                            '\$${(t.avgPrice / 1000).toStringAsFixed(0)}K avg',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          t.priceChange >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: t.priceChange >= 0
                              ? AppColors.good
                              : AppColors.bad,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${t.priceChange.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: t.priceChange >= 0
                                ? AppColors.good
                                : AppColors.bad,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // 12-Month Forecast
          Text('12-Month Forecast',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.good.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.good.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up,
                              color: AppColors.good, size: 14),
                          SizedBox(width: 4),
                          Text('Bullish',
                              style: TextStyle(
                                  color: AppColors.good,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('+9.8% projected',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Strong tech sector employment, limited housing supply, and continued migration to the Bay Area support continued price appreciation over the next 12 months. Interest rate stabilization expected to improve buyer demand.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Market Heat indicators
          Text('Market Heat Indicators',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heatPill('Days on Market', '${_current['inventory']}d',
                  AppColors.accent2),
              _heatPill('Price/SqFt', '\$612', AppColors.warn),
              _heatPill('Sale-to-List', '98.5%', AppColors.good),
              _heatPill('Inventory', '${_current['inventory']} days',
                  AppColors.accent),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    const newListings = [32, 28, 22, 18, 35, 42];
    const sales = [24, 21, 18, 14, 28, 38];
    return List.generate(6, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: newListings[i].toDouble(),
            color: AppColors.accent,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: sales[i].toDouble(),
            color: AppColors.good,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    });
  }

  Widget _metricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }

  Widget _heatPill(String label, String value, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}
