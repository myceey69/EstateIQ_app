import '../models/property.dart';

class YearlyPrediction {
  final int year;
  final double predictedPrice;
  final double lowerBound;
  final double upperBound;
  final double growthPercent;

  const YearlyPrediction({
    required this.year,
    required this.predictedPrice,
    required this.lowerBound,
    required this.upperBound,
    required this.growthPercent,
  });
}

class PricePrediction {
  final double basePrice;
  final List<YearlyPrediction> yearly;
  final double locationMultiplier;
  final double neighborhoodMultiplier;
  final double marketMultiplier;
  final String reasoning;

  const PricePrediction({
    required this.basePrice,
    required this.yearly,
    required this.locationMultiplier,
    required this.neighborhoodMultiplier,
    required this.marketMultiplier,
    required this.reasoning,
  });
}

class PredictionService {
  PricePrediction predict(Property property) {
    // Step 1 — Base Annual Growth Rate
    double rate = 0.035;

    // Step 2 — Market Signal adjustment
    switch (property.signal) {
      case 'High Growth':
        rate += 0.035;
        break;
      case 'Undervalued':
        rate += 0.025;
        break;
      case 'High ROI':
        rate += 0.020;
        break;
      case 'Emerging':
        rate += 0.030;
        break;
      case 'Low Risk':
        rate += 0.010;
        break;
      case 'Premium':
        rate += 0.015;
        break;
    }

    // Step 3 — Risk adjustment
    final riskLower = property.risk.toLowerCase();
    if (riskLower == 'low') {
      rate += 0.005;
    } else if (riskLower == 'high') {
      rate -= 0.010;
    }

    // Step 4 — Neighborhood composite score adjustment
    final n = property.neighborhood;
    final composite =
        (n.safety + n.schools + n.commute + n.amenities + n.stability) / 5.0;
    double neighborhoodMultiplier;
    if (composite >= 85) {
      rate += 0.015;
      neighborhoodMultiplier = 1.015;
    } else if (composite >= 70) {
      rate += 0.008;
      neighborhoodMultiplier = 1.008;
    } else if (composite >= 55) {
      rate += 0.002;
      neighborhoodMultiplier = 1.002;
    } else {
      rate -= 0.005;
      neighborhoodMultiplier = 0.995;
    }

    // Step 5 — Growth field
    switch (property.growth) {
      case 'High':
        rate += 0.015;
        break;
      case 'Medium':
        rate += 0.005;
        break;
      case 'Low':
        rate -= 0.005;
        break;
    }

    // Step 6 — Cap rate proxy
    final capRateStr = property.capRate.replaceAll('%', '').trim();
    final capRate = double.tryParse(capRateStr) ?? 0.0;
    if (capRate > 5.0) {
      rate += 0.005;
    } else if (capRate < 3.5) {
      rate -= 0.003;
    }

    // Location multiplier
    final addressLower = property.address.toLowerCase();
    double locationMultiplier;
    if (addressLower.contains('palo alto')) {
      locationMultiplier = 1.15;
    } else if (addressLower.contains('mountain view')) {
      locationMultiplier = 1.12;
    } else if (addressLower.contains('sunnyvale')) {
      locationMultiplier = 1.10;
    } else if (addressLower.contains('san jose')) {
      locationMultiplier = 1.08;
    } else {
      locationMultiplier = 1.0;
    }

    final marketMultiplier = 1.0 + rate;
    final basePrice = property.price.toDouble() * locationMultiplier;

    // Confidence interval base widths
    final Map<int, double> ciBase = {
      1: 0.03,
      2: 0.05,
      3: 0.07,
      5: 0.10,
      7: 0.13,
      10: 0.16,
    };
    double ciAdjust = 0.0;
    if (riskLower == 'high') ciAdjust = 0.02;
    if (riskLower == 'low') ciAdjust = -0.01;

    const years = [1, 2, 3, 5, 7, 10];
    final yearly = <YearlyPrediction>[];

    for (final year in years) {
      final predicted = basePrice * _pow(1 + rate, year);
      final ci = (ciBase[year] ?? 0.10) + ciAdjust;
      final lower = predicted * (1 - ci);
      final upper = predicted * (1 + ci);
      final growthPct = ((predicted / property.price) - 1) * 100;
      yearly.add(YearlyPrediction(
        year: year,
        predictedPrice: predicted,
        lowerBound: lower,
        upperBound: upper,
        growthPercent: growthPct,
      ));
    }

    final annualRatePct = (rate * 100).toStringAsFixed(1);
    final compositeRounded = composite.round();
    String locationContext = '';
    if (addressLower.contains('san jose')) {
      locationContext = 'San Jose continues to benefit from strong tech sector demand.';
    } else if (addressLower.contains('palo alto')) {
      locationContext = 'Palo Alto commands premium valuations driven by elite schools and tech proximity.';
    }

    final reasoning =
        'Based on ${property.signal} signal, ${property.risk} risk profile, and neighborhood score of '
        '$compositeRounded/100, this property is projected to grow at $annualRatePct% annually. '
        '$locationContext';

    return PricePrediction(
      basePrice: basePrice,
      yearly: yearly,
      locationMultiplier: locationMultiplier,
      neighborhoodMultiplier: neighborhoodMultiplier,
      marketMultiplier: marketMultiplier,
      reasoning: reasoning,
    );
  }

  double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
