import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'neighborhood_scores.dart';

class Property {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  );

  final String id;
  final String title;
  final String meta;
  final int price;
  final String signal;
  final String risk;
  final String growth;
  final String capRate;
  final NeighborhoodScores neighborhood;
  final Map<String, int> pin;
  final String address;
  final int beds;
  final int baths;
  final int sqft;
  final int yearBuilt;
  final String description;
  final int imageGradientIndex;

  Property({
    required this.id,
    required this.title,
    required this.meta,
    required this.price,
    required this.signal,
    required this.risk,
    required this.growth,
    required this.capRate,
    required this.neighborhood,
    required this.pin,
    this.address = '',
    this.beds = 0,
    this.baths = 0,
    this.sqft = 0,
    this.yearBuilt = 0,
    this.description = '',
    this.imageGradientIndex = 0,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      meta: json['meta'] ?? '',
      price: json['price'] ?? 0,
      signal: json['signal'] ?? '',
      risk: json['risk'] ?? '',
      growth: json['growth'] ?? '',
      capRate: json['capRate'] ?? '',
      neighborhood: NeighborhoodScores.fromJson(json['neighborhood'] ?? {}),
      pin: Map<String, int>.from(json['pin'] ?? {}),
      address: json['address'] ?? '',
      beds: json['beds'] ?? 0,
      baths: json['baths'] ?? 0,
      sqft: json['sqft'] ?? 0,
      yearBuilt: json['yearBuilt'] ?? 0,
      description: json['description'] ?? '',
      imageGradientIndex: json['imageGradientIndex'] ?? 0,
    );
  }

  String get priceFormatted => _currencyFormatter.format(price);

  Color getRiskColor() {
    switch (risk.toLowerCase()) {
      case 'low':
        return const Color(0xFF10b981);
      case 'medium':
        return const Color(0xFFf59e0b);
      case 'high':
        return const Color(0xFFef4444);
      default:
        return const Color(0xFFc4cad9);
    }
  }

  Color getSignalColor() {
    if (signal.contains('High')) {
      return const Color(0xFF10b981);
    } else if (signal.contains('Low')) {
      return const Color(0xFFef4444);
    }
    return const Color(0xFFf59e0b);
  }
}
