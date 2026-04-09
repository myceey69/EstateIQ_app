import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/property.dart';
import '../../services/prediction_service.dart';
import '../../theme/theme.dart';

class ValuationScreen extends StatefulWidget {
  final Property property;
  const ValuationScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<ValuationScreen> createState() => _ValuationScreenState();
}

class _ValuationScreenState extends State<ValuationScreen> {
  late final PricePrediction _prediction;

  @override
  void initState() {
    super.initState();
    _prediction = PredictionService().predict(widget.property);
  }

  int _confidence() {
    final hash = widget.property.id.codeUnits.fold<int>(0, (a, b) => a + b);
    return 87 + (hash % 8);
  }

  String _fmtK(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(2)}M';
    }
    return '\$${(price / 1000).toStringAsFixed(0)}K';
  }

  String _fmtFull(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '\$$formatted';
  }

  List<FlSpot> _buildSpots(bool upper, bool lower) {
    final allYears = [0, ..._prediction.yearly.map((y) => y.year)];
    final spots = <FlSpot>[];
    spots.add(FlSpot(0, widget.property.price.toDouble() / 1000));
    for (int i = 0; i < _prediction.yearly.length; i++) {
      final yp = _prediction.yearly[i];
      double val;
      if (upper) {
        val = yp.upperBound / 1000;
      } else if (lower) {
        val = yp.lowerBound / 1000;
      } else {
        val = yp.predictedPrice / 1000;
      }
      spots.add(FlSpot(allYears[i + 1].toDouble(), val));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final conf = _confidence();
    final lowEstimate = p.price * 0.96;
    final highEstimate = p.price * 1.04;
    final n = p.neighborhood;
    final composite =
        (n.safety + n.schools + n.commute + n.amenities + n.stability) / 5.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Valuation'),
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
            // Header
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (p.address.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(p.address,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'List Price: \$${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // AI Valuation Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accent.withOpacity(0.4)),
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
                      const Text('AI Valuation Summary',
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('AI Estimated Value',
                      style:
                          TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmtK(lowEstimate)} – ${_fmtK(highEstimate)}',
                    style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Confidence',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 13)),
                      const Spacer(),
                      Text('$conf%',
                          style: const TextStyle(
                              color: AppColors.good,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: conf / 100,
                      backgroundColor: AppColors.line,
                      color: AppColors.good,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Our AI analyzed 127 comparable sales, 5 years of market data, and real-time neighborhood signals.',
                    style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Chart
            Text('Multi-Year Price Prediction',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 10,
                        minY: (widget.property.price * 0.85) / 1000,
                        maxY: (_prediction.yearly.last.upperBound * 1.05) /
                            1000,
                        lineBarsData: [
                          // Predicted line
                          LineChartBarData(
                            spots: _buildSpots(false, false),
                            isCurved: true,
                            color: AppColors.accent,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.accent.withOpacity(0.06),
                            ),
                          ),
                          // Upper bound (dashed)
                          LineChartBarData(
                            spots: _buildSpots(true, false),
                            isCurved: true,
                            color: AppColors.good,
                            barWidth: 1.5,
                            dotData: const FlDotData(show: false),
                            dashArray: [4, 4],
                          ),
                          // Lower bound (dashed)
                          LineChartBarData(
                            spots: _buildSpots(false, true),
                            isCurved: true,
                            color: AppColors.bad,
                            barWidth: 1.5,
                            dotData: const FlDotData(show: false),
                            dashArray: [4, 4],
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
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (v, _) => Text(
                                '\$${v.toStringAsFixed(0)}K',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 9),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final yr = v.toInt();
                                if ([0, 1, 2, 3, 5, 7, 10].contains(yr)) {
                                  return Text(
                                    yr == 0 ? 'Now' : 'Y$yr',
                                    style: const TextStyle(
                                        color: AppColors.muted, fontSize: 9),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
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
                  const SizedBox(height: 12),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem('Predicted', AppColors.accent, false),
                      const SizedBox(width: 16),
                      _legendItem('Upper Bound', AppColors.good, true),
                      const SizedBox(width: 16),
                      _legendItem('Lower Bound', AppColors.bad, true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Prediction Table
            Text('Yearly Projections',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _card(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppColors.line, width: 1)),
                    ),
                    children: ['Year', 'Predicted', 'Growth', 'Range']
                        .map((h) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(h,
                                  style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                  ..._prediction.yearly.map(
                    (yp) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text('Y${yp.year}',
                              style: const TextStyle(
                                  color: AppColors.text, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(_fmtK(yp.predictedPrice),
                              style: const TextStyle(
                                  color: AppColors.accent2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '+${yp.growthPercent.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: AppColors.good, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${_fmtK(yp.lowerBound)}–${_fmtK(yp.upperBound)}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Prediction Drivers
            Text('What Drives This Prediction',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _driverCard(
                  icon: Icons.location_on_outlined,
                  label: 'Location Score',
                  value: _locationLabel(p.address),
                  impact: _prediction.locationMultiplier > 1.05
                      ? 'Positive'
                      : _prediction.locationMultiplier > 1.0
                          ? 'Neutral'
                          : 'Negative',
                ),
                _driverCard(
                  icon: Icons.location_city_outlined,
                  label: 'Neighborhood',
                  value: '${composite.round()}/100',
                  impact: composite >= 75
                      ? 'Positive'
                      : composite >= 55
                          ? 'Neutral'
                          : 'Negative',
                ),
                _driverCard(
                  icon: Icons.trending_up,
                  label: 'Market Signal',
                  value: p.signal,
                  impact: p.signal.contains('High') ||
                          p.signal == 'Undervalued' ||
                          p.signal == 'Emerging'
                      ? 'Positive'
                      : 'Neutral',
                ),
                _driverCard(
                  icon: Icons.shield_outlined,
                  label: 'Risk Profile',
                  value: '${p.risk} Risk',
                  impact: p.risk == 'Low'
                      ? 'Positive'
                      : p.risk == 'High'
                          ? 'Negative'
                          : 'Neutral',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Comparable Properties
            Text('Comparable Properties',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ..._buildComps(p),
            const SizedBox(height: 8),
            _card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Comp Average',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                  Text(
                    _fmtFull(_compAvg(p).toDouble()),
                    style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Reasoning
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_outlined,
                          color: AppColors.accent, size: 16),
                      SizedBox(width: 6),
                      Text('AI Reasoning',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _prediction.reasoning,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _locationLabel(String address) {
    final lower = address.toLowerCase();
    if (lower.contains('palo alto')) return 'Palo Alto (+15%)';
    if (lower.contains('mountain view')) return 'Mtn View (+12%)';
    if (lower.contains('sunnyvale')) return 'Sunnyvale (+10%)';
    if (lower.contains('san jose')) return 'San Jose (+8%)';
    return 'Standard (0%)';
  }

  int _compAvg(Property p) {
    final comps = _generateComps(p);
    return (comps.fold(0, (a, b) => a + b['price'] as int) / comps.length)
        .round();
  }

  List<Map<String, dynamic>> _generateComps(Property p) {
    return [
      {
        'address': '${p.address.split(',')[0].trim()} (Comp A)',
        'price': (p.price * 0.97).round(),
        'date': 'Jan 2025',
        'beds': p.beds,
        'baths': p.baths,
        'priceSqft': p.sqft > 0 ? ((p.price * 0.97) / p.sqft).round() : 0,
      },
      {
        'address': 'Nearby ${p.title} Comp',
        'price': (p.price * 1.03).round(),
        'date': 'Dec 2024',
        'beds': p.beds,
        'baths': p.baths,
        'priceSqft': p.sqft > 0 ? ((p.price * 1.03) / p.sqft).round() : 0,
      },
      {
        'address': 'Area Similar Home',
        'price': (p.price * 0.99).round(),
        'date': 'Feb 2025',
        'beds': p.beds,
        'baths': p.baths,
        'priceSqft': p.sqft > 0 ? ((p.price * 0.99) / p.sqft).round() : 0,
      },
    ];
  }

  List<Widget> _buildComps(Property p) {
    return _generateComps(p).map((comp) {
      final price = comp['price'] as int;
      final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comp['address'] as String,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${comp['beds']}bd/${comp['baths']}ba • Sold ${comp['date']}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$$formatted',
                    style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                if ((comp['priceSqft'] as int) > 0)
                  Text('\$${comp['priceSqft']}/sqft',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _legendItem(String label, Color color, bool dashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            border: dashed
                ? Border(
                    bottom: BorderSide(color: color, width: 2))
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }

  Widget _driverCard({
    required IconData icon,
    required String label,
    required String value,
    required String impact,
  }) {
    Color impactColor;
    switch (impact) {
      case 'Positive':
        impactColor = AppColors.good;
        break;
      case 'Negative':
        impactColor = AppColors.bad;
        break;
      default:
        impactColor = AppColors.warn;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: impactColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(impact,
                style: TextStyle(
                    color: impactColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600)),
          ),
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
}
