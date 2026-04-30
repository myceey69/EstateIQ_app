import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/neighborhood_scores.dart';
import '../models/property.dart';

class PropertyListingService {
  PropertyListingService({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('RENTCAST_API_KEY');

  final http.Client _client;
  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<Property>> fetchSaleListings({
    String city = 'San Jose',
    String state = 'CA',
    int limit = 20,
  }) async {
    if (!isConfigured) {
      return const [];
    }

    final uri = Uri.https('api.rentcast.io', '/v1/listings/sale', {
      'city': city,
      'state': state,
      'limit': '$limit',
    });

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'X-Api-Key': _apiKey,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PropertyListingException(
        'RentCast request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    final rows = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
            ? ((decoded['listings'] as List<dynamic>?) ??
                (decoded['data'] as List<dynamic>?) ??
                const [])
            : const [];

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_fromRentCastListing)
        .toList();
  }

  Property _fromRentCastListing(Map<String, dynamic> json) {
    final id =
        '${json['id'] ?? json['listingId'] ?? json['propertyId'] ?? json.hashCode}';
    final addressLine = _compact([
      json['formattedAddress'],
      json['addressLine1'],
      json['city'],
      json['state'],
      json['zipCode'],
    ]);
    final beds = _toInt(json['bedrooms']);
    final baths = _toInt(json['bathrooms']);
    final sqft = _toInt(json['squareFootage'] ?? json['livingArea']);
    final price = _toInt(json['price'] ?? json['listPrice']);
    final yearBuilt = _toInt(json['yearBuilt']);
    final title = _titleFromAddress(addressLine, json);
    final growth = _growthFor(price, sqft);
    final risk = _riskFor(price, beds);
    final capRate = _capRateFor(price, beds, baths);

    return Property(
      id: id,
      title: title,
      meta: '${beds > 0 ? '$beds bd' : 'Beds n/a'} • '
          '${baths > 0 ? '$baths ba' : 'Baths n/a'} • '
          '${sqft > 0 ? '$sqft sqft' : 'Sqft n/a'} • Source: RentCast',
      price: price,
      signal: growth == 'High' ? 'High Growth' : 'Live Listing',
      risk: risk,
      growth: growth,
      capRate: capRate,
      neighborhood: NeighborhoodScores(
        safety: 68 + id.length % 18,
        schools: 70 + title.length % 18,
        commute: 72 + beds % 18,
        amenities: 74 + baths % 16,
        stability:
            70 + max(0, min(18, yearBuilt > 0 ? (2026 - yearBuilt) ~/ 4 : 10)),
      ),
      pin: {
        'x': 20 + id.length % 65,
        'y': 25 + title.length % 55,
      },
      address: addressLine,
      beds: beds,
      baths: baths,
      sqft: sqft,
      yearBuilt: yearBuilt,
      description:
          '${json['status'] ?? 'Active'} listing imported from RentCast. '
          'EstateIQ adds provisional risk, growth, and cap-rate estimates for screening.',
      imageGradientIndex:
          id.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 6,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  String _titleFromAddress(String address, Map<String, dynamic> json) {
    if (address.isNotEmpty) return address.split(',').first;
    if (json['propertyType'] is String) {
      return '${json['propertyType']} in ${json['city'] ?? 'Market'}';
    }
    return 'Imported Property';
  }

  String _compact(List<dynamic> values) {
    return values
        .whereType<Object>()
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .join(', ');
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return double.tryParse(value)?.round() ?? 0;
    return 0;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _growthFor(int price, int sqft) {
    if (sqft > 0 && price / sqft < 650) return 'High';
    if (price < 900000) return 'Medium';
    return 'Low';
  }

  String _riskFor(int price, int beds) {
    if (price > 1300000 || beds == 0) return 'Medium';
    return 'Low';
  }

  String _capRateFor(int price, int beds, int baths) {
    if (price <= 0) return 'N/A';
    final estimatedMonthlyRent = max(2200, beds * 1150 + baths * 450);
    final annualRent = estimatedMonthlyRent * 12;
    final capRate = (annualRent / price) * 100;
    return '${capRate.clamp(2.0, 7.5).toStringAsFixed(1)}%';
  }
}

class PropertyListingException implements Exception {
  const PropertyListingException(this.message);
  final String message;

  @override
  String toString() => message;
}
