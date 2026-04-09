class MarketTrend {
  final String region;
  final double avgPrice;
  final double priceChange;
  final int inventory;
  final int daysOnMarket;
  final int hotScore;

  const MarketTrend({
    required this.region,
    required this.avgPrice,
    required this.priceChange,
    required this.inventory,
    required this.daysOnMarket,
    required this.hotScore,
  });

  Map<String, dynamic> toMap() => {
        'region': region,
        'avgPrice': avgPrice,
        'priceChange': priceChange,
        'inventory': inventory,
        'daysOnMarket': daysOnMarket,
        'hotScore': hotScore,
      };

  factory MarketTrend.fromMap(Map<String, dynamic> map) {
    return MarketTrend(
      region: map['region'] ?? '',
      avgPrice: (map['avgPrice'] ?? 0).toDouble(),
      priceChange: (map['priceChange'] ?? 0).toDouble(),
      inventory: map['inventory'] ?? 0,
      daysOnMarket: map['daysOnMarket'] ?? 0,
      hotScore: map['hotScore'] ?? 0,
    );
  }
}

class PricePoint {
  final String month;
  final double price;

  const PricePoint({required this.month, required this.price});
}

class RegionForecast {
  final String region;
  final double currentAvg;
  final double forecast3m;
  final double forecast6m;
  final double forecast12m;
  final String trend; // 'bullish' | 'bearish' | 'neutral'

  const RegionForecast({
    required this.region,
    required this.currentAvg,
    required this.forecast3m,
    required this.forecast6m,
    required this.forecast12m,
    required this.trend,
  });

  Map<String, dynamic> toMap() => {
        'region': region,
        'currentAvg': currentAvg,
        'forecast3m': forecast3m,
        'forecast6m': forecast6m,
        'forecast12m': forecast12m,
        'trend': trend,
      };

  factory RegionForecast.fromMap(Map<String, dynamic> map) {
    return RegionForecast(
      region: map['region'] ?? '',
      currentAvg: (map['currentAvg'] ?? 0).toDouble(),
      forecast3m: (map['forecast3m'] ?? 0).toDouble(),
      forecast6m: (map['forecast6m'] ?? 0).toDouble(),
      forecast12m: (map['forecast12m'] ?? 0).toDouble(),
      trend: map['trend'] ?? 'neutral',
    );
  }

  factory RegionForecast.demo() {
    return const RegionForecast(
      region: 'San Jose, CA',
      currentAvg: 879000,
      forecast3m: 895000,
      forecast6m: 920000,
      forecast12m: 965000,
      trend: 'bullish',
    );
  }
}

class MarketData {
  final List<MarketTrend> trends;
  final List<PricePoint> priceHistory;
  final List<RegionForecast> forecasts;

  const MarketData({
    required this.trends,
    required this.priceHistory,
    required this.forecasts,
  });

  factory MarketData.demo() {
    return const MarketData(
      trends: [
        MarketTrend(
          region: 'Willow Glen',
          avgPrice: 882000,
          priceChange: 4.2,
          inventory: 18,
          daysOnMarket: 14,
          hotScore: 87,
        ),
        MarketTrend(
          region: 'Downtown SJ',
          avgPrice: 745000,
          priceChange: 6.1,
          inventory: 32,
          daysOnMarket: 9,
          hotScore: 92,
        ),
        MarketTrend(
          region: 'Berryessa',
          avgPrice: 920000,
          priceChange: 2.8,
          inventory: 25,
          daysOnMarket: 21,
          hotScore: 74,
        ),
        MarketTrend(
          region: 'Cambrian Park',
          avgPrice: 855000,
          priceChange: 3.5,
          inventory: 14,
          daysOnMarket: 17,
          hotScore: 81,
        ),
      ],
      priceHistory: [
        PricePoint(month: 'Jan', price: 810000),
        PricePoint(month: 'Feb', price: 825000),
        PricePoint(month: 'Mar', price: 838000),
        PricePoint(month: 'Apr', price: 847000),
        PricePoint(month: 'May', price: 855000),
        PricePoint(month: 'Jun', price: 862000),
        PricePoint(month: 'Jul', price: 870000),
        PricePoint(month: 'Aug', price: 876000),
        PricePoint(month: 'Sep', price: 879000),
        PricePoint(month: 'Oct', price: 885000),
        PricePoint(month: 'Nov', price: 891000),
        PricePoint(month: 'Dec', price: 898000),
      ],
      forecasts: [
        RegionForecast(
          region: 'San Jose, CA',
          currentAvg: 879000,
          forecast3m: 895000,
          forecast6m: 920000,
          forecast12m: 965000,
          trend: 'bullish',
        ),
        RegionForecast(
          region: 'Santa Clara, CA',
          currentAvg: 1050000,
          forecast3m: 1060000,
          forecast6m: 1075000,
          forecast12m: 1095000,
          trend: 'neutral',
        ),
        RegionForecast(
          region: 'Milpitas, CA',
          currentAvg: 790000,
          forecast3m: 785000,
          forecast6m: 778000,
          forecast12m: 770000,
          trend: 'bearish',
        ),
      ],
    );
  }
}
