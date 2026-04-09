import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/property.dart';
import '../../services/prediction_service.dart';
import '../../theme/theme.dart';

class ROICalculatorScreen extends StatefulWidget {
  final Property? property;
  const ROICalculatorScreen({Key? key, this.property}) : super(key: key);

  @override
  State<ROICalculatorScreen> createState() => _ROICalculatorScreenState();
}

class _ROICalculatorScreenState extends State<ROICalculatorScreen> {
  // Inputs
  late double _purchasePrice;
  double _downPaymentPct = 20;
  double _mortgageRate = 7.0;
  int _loanTerm = 30;
  double _monthlyRent = 3500;
  double _hoaMonthly = 300;
  double _propertyTaxPct = 1.2;
  double _insuranceMonthly = 150;
  double _maintenanceMonthly = 200;
  double _annualAppreciationPct = 4.0;
  double _vacancyRatePct = 5.0;

  @override
  void initState() {
    super.initState();
    _purchasePrice = (widget.property?.price ?? 850000).toDouble();
    if (widget.property != null) {
      final pred = PredictionService().predict(widget.property!);
      // approximate annual rate from year 1
      if (pred.yearly.isNotEmpty) {
        final yr1 = pred.yearly.first;
        _annualAppreciationPct = yr1.growthPercent.clamp(1.0, 15.0);
      }
    }
  }

  // ── Calculations ────────────────────────────────────────────────────────────
  double get _downPaymentAmount => _purchasePrice * _downPaymentPct / 100;
  double get _loanAmount => _purchasePrice - _downPaymentAmount;

  double get _monthlyMortgage {
    final r = _mortgageRate / 100 / 12;
    final n = _loanTerm * 12;
    if (r == 0) return _loanAmount / n;
    return _loanAmount * r * _pow(1 + r, n) / (_pow(1 + r, n) - 1);
  }

  double get _monthlyPropertyTax => _purchasePrice * _propertyTaxPct / 100 / 12;
  double get _totalMonthlyExpenses =>
      _monthlyMortgage +
      _hoaMonthly +
      _monthlyPropertyTax +
      _insuranceMonthly +
      _maintenanceMonthly;

  double get _effectiveMonthlyRent => _monthlyRent * (1 - _vacancyRatePct / 100);
  double get _monthlyCashFlow => _effectiveMonthlyRent - _totalMonthlyExpenses;
  double get _annualCashFlow => _monthlyCashFlow * 12;

  double get _cocReturn =>
      _downPaymentAmount > 0 ? (_annualCashFlow / _downPaymentAmount) * 100 : 0;

  double get _annualNOI =>
      (_effectiveMonthlyRent - _hoaMonthly - _monthlyPropertyTax - _insuranceMonthly - _maintenanceMonthly) *
      12;

  double get _capRate =>
      _purchasePrice > 0 ? (_annualNOI / _purchasePrice) * 100 : 0;

  double get _grm =>
      (_monthlyRent * 12) > 0 ? _purchasePrice / (_monthlyRent * 12) : 0;

  double get _breakEvenOccupancy =>
      _effectiveMonthlyRent > 0
          ? (_totalMonthlyExpenses / _effectiveMonthlyRent) * 100
          : 100;

  double _equityAtYear(int year) {
    final appValue = _purchasePrice * _pow(1 + _annualAppreciationPct / 100, year);
    final r = _mortgageRate / 100 / 12;
    final n = _loanTerm * 12;
    double remainingLoan;
    if (r == 0) {
      remainingLoan = _loanAmount - (_loanAmount / n) * year * 12;
    } else {
      final paid = year * 12;
      remainingLoan = _loanAmount *
          (_pow(1 + r, n) - _pow(1 + r, paid)) /
          (_pow(1 + r, n) - 1);
    }
    return appValue - remainingLoan.clamp(0, double.infinity);
  }

  double get _totalROI10 {
    final equity10 = _equityAtYear(10);
    final totalCashFlow = _annualCashFlow * 10;
    final totalInvested = _downPaymentAmount;
    return totalInvested > 0
        ? ((equity10 - _purchasePrice + totalCashFlow) / totalInvested) * 100
        : 0;
  }

  double _pow(double base, num exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  List<FlSpot> _equitySpots() {
    return List.generate(11, (y) {
      return FlSpot(y.toDouble(), _equityAtYear(y) / 1000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cashFlowColor =
        _monthlyCashFlow >= 0 ? AppColors.good : AppColors.bad;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ROI Calculator'),
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
            // Results Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Live Results',
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _resultPill(
                          'Cash Flow/mo',
                          '${_monthlyCashFlow >= 0 ? '+' : ''}\$${_monthlyCashFlow.abs().toStringAsFixed(0)}',
                          cashFlowColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _resultPill(
                          'CoC Return',
                          '${_cocReturn.toStringAsFixed(1)}%',
                          _cocReturn > 0 ? AppColors.good : AppColors.bad,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _resultPill(
                          'Cap Rate',
                          '${_capRate.toStringAsFixed(1)}%',
                          _capRate > 5 ? AppColors.good : AppColors.warn,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inputs
            Text('Investment Inputs',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labeledSlider(
                    'Purchase Price',
                    '\$${(_purchasePrice / 1000).toStringAsFixed(0)}K',
                    _purchasePrice,
                    200000,
                    3000000,
                    (v) => setState(() => _purchasePrice = v),
                    divisions: 280,
                  ),
                  const Divider(color: AppColors.line, height: 24),
                  _labeledSlider(
                    'Down Payment',
                    '${_downPaymentPct.toStringAsFixed(0)}% (\$${(_downPaymentAmount / 1000).toStringAsFixed(0)}K)',
                    _downPaymentPct,
                    5,
                    30,
                    (v) => setState(() => _downPaymentPct = v),
                    divisions: 25,
                  ),
                  const Divider(color: AppColors.line, height: 24),
                  _labeledSlider(
                    'Mortgage Rate',
                    '${_mortgageRate.toStringAsFixed(1)}%',
                    _mortgageRate,
                    3,
                    10,
                    (v) => setState(() => _mortgageRate = v),
                    divisions: 70,
                  ),
                  const Divider(color: AppColors.line, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Loan Term',
                          style: TextStyle(
                              color: AppColors.text, fontSize: 13)),
                      ToggleButtons(
                        isSelected: [_loanTerm == 15, _loanTerm == 30],
                        onPressed: (i) =>
                            setState(() => _loanTerm = i == 0 ? 15 : 30),
                        borderColor: AppColors.line,
                        selectedBorderColor: AppColors.accent,
                        fillColor: AppColors.accent.withOpacity(0.15),
                        selectedColor: AppColors.accent,
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                        constraints: const BoxConstraints(
                            minWidth: 60, minHeight: 32),
                        children: const [
                          Text('15yr',
                              style: TextStyle(fontSize: 12)),
                          Text('30yr',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rental Income & Expenses',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 12),
                  _labeledSlider(
                    'Monthly Rent',
                    '\$${_monthlyRent.toStringAsFixed(0)}',
                    _monthlyRent,
                    500,
                    10000,
                    (v) => setState(() => _monthlyRent = v),
                    divisions: 190,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'HOA Monthly',
                    '\$${_hoaMonthly.toStringAsFixed(0)}',
                    _hoaMonthly,
                    0,
                    1000,
                    (v) => setState(() => _hoaMonthly = v),
                    divisions: 100,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'Property Tax',
                    '${_propertyTaxPct.toStringAsFixed(1)}%',
                    _propertyTaxPct,
                    0.5,
                    3.0,
                    (v) => setState(() => _propertyTaxPct = v),
                    divisions: 25,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'Insurance/mo',
                    '\$${_insuranceMonthly.toStringAsFixed(0)}',
                    _insuranceMonthly,
                    50,
                    500,
                    (v) => setState(() => _insuranceMonthly = v),
                    divisions: 45,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'Maintenance/mo',
                    '\$${_maintenanceMonthly.toStringAsFixed(0)}',
                    _maintenanceMonthly,
                    0,
                    1000,
                    (v) => setState(() => _maintenanceMonthly = v),
                    divisions: 100,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'Vacancy Rate',
                    '${_vacancyRatePct.toStringAsFixed(0)}%',
                    _vacancyRatePct,
                    0,
                    20,
                    (v) => setState(() => _vacancyRatePct = v),
                    divisions: 20,
                  ),
                  const SizedBox(height: 8),
                  _labeledSlider(
                    'Annual Appreciation',
                    '${_annualAppreciationPct.toStringAsFixed(1)}%',
                    _annualAppreciationPct,
                    0,
                    15,
                    (v) => setState(() => _annualAppreciationPct = v),
                    divisions: 150,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detailed breakdown
            Text('Detailed Breakdown',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _card(
              child: Column(
                children: [
                  _breakdownRow(
                      'Monthly Mortgage',
                      '\$${_monthlyMortgage.toStringAsFixed(0)}',
                      AppColors.bad),
                  _breakdownRow(
                      'Monthly Expenses (total)',
                      '\$${_totalMonthlyExpenses.toStringAsFixed(0)}',
                      AppColors.bad),
                  _breakdownRow(
                      'Effective Monthly Rent',
                      '\$${_effectiveMonthlyRent.toStringAsFixed(0)}',
                      AppColors.good),
                  const Divider(color: AppColors.line, height: 20),
                  _breakdownRow(
                      'Monthly Cash Flow',
                      '${_monthlyCashFlow >= 0 ? '+' : ''}\$${_monthlyCashFlow.toStringAsFixed(0)}',
                      cashFlowColor),
                  _breakdownRow(
                      'Annual Cash Flow',
                      '${_annualCashFlow >= 0 ? '+' : ''}\$${_annualCashFlow.toStringAsFixed(0)}',
                      cashFlowColor),
                  _breakdownRow('Gross Rent Multiplier',
                      _grm.toStringAsFixed(1), AppColors.accent),
                  _breakdownRow(
                      'Break-even Occupancy',
                      '${_breakEvenOccupancy.toStringAsFixed(1)}%',
                      AppColors.warn),
                  _breakdownRow(
                      '10-Year Equity',
                      '\$${(_equityAtYear(10) / 1000).toStringAsFixed(0)}K',
                      AppColors.good),
                  _breakdownRow('Total 10-Year ROI',
                      '${_totalROI10.toStringAsFixed(1)}%', AppColors.accent),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Equity Chart
            Text('10-Year Wealth Projection',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _card(
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _equitySpots(),
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
                            final yr = v.toInt();
                            if (yr % 2 == 0) {
                              return Text('Y$yr',
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
                          reservedSize: 50,
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
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analysis saved successfully!'),
                      backgroundColor: AppColors.good,
                    ),
                  );
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Analysis'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _labeledSlider(
    String label,
    String valueText,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int divisions = 100,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.text, fontSize: 12)),
            Text(valueText,
                style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.line,
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accent.withOpacity(0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _resultPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
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
