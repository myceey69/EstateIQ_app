import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/neighborhood_scores.dart';

class PropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  Property? _selectedProperty;
  String _searchQuery = '';
  String _activeFilter = 'All';
  String? _locationFilter;
  int? _minPrice;
  int? _maxPrice;
  int? _minBeds;

  PropertyProvider() {
    _initializeDemoData();
  }

  // ── AI ranking score ──────────────────────────────────────────────────────
  double _rankScore(Property p) {
    double score = 0;
    if (p.signal.contains('High')) score += 30;
    if (p.risk == 'Low') score += 20;
    if (p.risk == 'Medium') score += 10;
    if (p.growth == 'High') score += 25;
    if (p.growth == 'Medium') score += 15;
    final cap = double.tryParse(p.capRate.replaceAll('%', '').trim()) ?? 0;
    score += cap * 5;
    final avg = (p.neighborhood.safety +
            p.neighborhood.schools +
            p.neighborhood.commute +
            p.neighborhood.amenities +
            p.neighborhood.stability) /
        5;
    score += avg / 10;
    return score;
  }

  // ── Filtered + ranked list ────────────────────────────────────────────────
  List<Property> get filteredProperties {
    var result = List<Property>.from(_properties);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.meta.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))
          .toList();
    }

    switch (_activeFilter) {
      case 'Low Risk':
        result = result.where((p) => p.risk == 'Low').toList();
        break;
      case 'High Growth':
        result = result.where((p) => p.growth == 'High').toList();
        break;
      case 'Best ROI':
        result = result.where((p) {
          final cap =
              double.tryParse(p.capRate.replaceAll('%', '').trim()) ?? 0;
          return cap >= 4.5;
        }).toList();
        break;
      case 'Undervalued':
        result = result.where((p) => p.signal.contains('Undervalued')).toList();
        break;
      case 'Emerging':
        result = result.where((p) => p.signal.contains('Emerging')).toList();
        break;
    }

    if (_locationFilter != null && _locationFilter!.isNotEmpty) {
      final loc = _locationFilter!.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(loc) ||
              p.address.toLowerCase().contains(loc) ||
              p.meta.toLowerCase().contains(loc))
          .toList();
    }

    if (_minPrice != null) {
      result = result.where((p) => p.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      result = result.where((p) => p.price <= _maxPrice!).toList();
    }
    if (_minBeds != null && _minBeds! > 0) {
      result = result.where((p) => p.beds >= _minBeds!).toList();
    }

    result.sort((a, b) => _rankScore(b).compareTo(_rankScore(a)));
    return result;
  }

  /// Backward-compat alias.
  List<Property> get properties => filteredProperties;
  List<Property> get allProperties => List.unmodifiable(_properties);

  // ── Getters ───────────────────────────────────────────────────────────────
  Property? get selectedProperty => _selectedProperty;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  String? get locationFilter => _locationFilter;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  int? get minBeds => _minBeds;

  // ── Setters ───────────────────────────────────────────────────────────────
  void setSelectedProperty(Property? property) {
    _selectedProperty = property;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _locationFilter = location;
    notifyListeners();
  }

  void setPriceRange(int? min, int? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setMinBeds(int? beds) {
    _minBeds = beds;
    notifyListeners();
  }

  // ── Demo data ─────────────────────────────────────────────────────────────
  void _initializeDemoData() {
    _properties = [
      Property(
        id: 'SJ1',
        title: 'Willow Glen Craftsman',
        meta: '3 bd • 2 ba • 1,640 sqft • Schools: A-',
        price: 879000,
        signal: 'Undervalued',
        risk: 'Low',
        growth: 'Medium',
        capRate: '3.8%',
        neighborhood: NeighborhoodScores(
            safety: 74, schools: 88, commute: 78, amenities: 82, stability: 76),
        pin: {'x': 28, 'y': 38},
        address: '1425 Rosemary Ave, Willow Glen, San Jose, CA 95125',
        beds: 3,
        baths: 2,
        sqft: 1640,
        yearBuilt: 1948,
        description:
            'Charming craftsman in the heart of Willow Glen. Updated kitchen, original hardwood floors, large backyard perfect for entertaining.',
        imageGradientIndex: 0,
      ),
      Property(
        id: 'SJ2',
        title: 'Downtown Modern Condo',
        meta: '2 bd • 2 ba • 1,120 sqft • Schools: B',
        price: 735000,
        signal: 'High Growth',
        risk: 'Medium',
        growth: 'High',
        capRate: '4.2%',
        neighborhood: NeighborhoodScores(
            safety: 66, schools: 74, commute: 90, amenities: 88, stability: 68),
        pin: {'x': 62, 'y': 44},
        address: '88 S 1st St #412, Downtown, San Jose, CA 95113',
        beds: 2,
        baths: 2,
        sqft: 1120,
        yearBuilt: 2018,
        description:
            'Sleek downtown condo with city views. Open floor plan, gourmet kitchen, rooftop amenities. Steps from tech campuses and transit.',
        imageGradientIndex: 1,
      ),
      Property(
        id: 'SJ3',
        title: 'Berryessa Duplex',
        meta: '4 bd • 3 ba • 2 units • Schools: B+',
        price: 925000,
        signal: 'High ROI',
        risk: 'Medium',
        growth: 'Medium',
        capRate: '5.5%',
        neighborhood: NeighborhoodScores(
            safety: 70, schools: 78, commute: 75, amenities: 72, stability: 71),
        pin: {'x': 76, 'y': 70},
        address: '2201 Penitencia Creek Rd, Berryessa, San Jose, CA 95132',
        beds: 4,
        baths: 3,
        sqft: 2100,
        yearBuilt: 1972,
        description:
            'Income-generating duplex in established Berryessa neighborhood. Both units tenant-occupied. Strong rental history with 5.5% cap rate.',
        imageGradientIndex: 2,
      ),
      Property(
        id: 'SJ4',
        title: 'Cambrian Park Ranch',
        meta: '3 bd • 2 ba • 1,510 sqft • Schools: A',
        price: 842000,
        signal: 'Low Risk',
        risk: 'Low',
        growth: 'Low',
        capRate: '3.5%',
        neighborhood: NeighborhoodScores(
            safety: 81, schools: 86, commute: 72, amenities: 75, stability: 84),
        pin: {'x': 44, 'y': 52},
        address: '4892 Union Ave, Cambrian Park, San Jose, CA 95124',
        beds: 3,
        baths: 2,
        sqft: 1510,
        yearBuilt: 1962,
        description:
            'Solid ranch home in coveted Cambrian Park. Award-winning schools, quiet street, remodeled bathrooms. Perfect for families.',
        imageGradientIndex: 3,
      ),
      Property(
        id: 'SJ5',
        title: 'Tech Hub Apartment',
        meta: '1 bd • 1 ba • 800 sqft • Schools: B-',
        price: 645000,
        signal: 'Emerging',
        risk: 'Medium',
        growth: 'High',
        capRate: '4.8%',
        neighborhood: NeighborhoodScores(
            safety: 72, schools: 68, commute: 95, amenities: 92, stability: 65),
        pin: {'x': 55, 'y': 35},
        address: '333 W San Fernando St #9A, SoFA District, San Jose, CA 95110',
        beds: 1,
        baths: 1,
        sqft: 800,
        yearBuilt: 2020,
        description:
            'Modern apartment in the emerging SoFA tech corridor. Smart home features, coworking lounge, bike storage. High demand from tech renters.',
        imageGradientIndex: 4,
      ),
      Property(
        id: 'SJ6',
        title: 'Suburban Family Home',
        meta: '4 bd • 3 ba • 2,200 sqft • Schools: A+',
        price: 995000,
        signal: 'Premium',
        risk: 'Low',
        growth: 'Medium',
        capRate: '3.2%',
        neighborhood: NeighborhoodScores(
            safety: 89, schools: 94, commute: 68, amenities: 70, stability: 88),
        pin: {'x': 35, 'y': 60},
        address: '1730 Leigh Ave, Blossom Valley, San Jose, CA 95124',
        beds: 4,
        baths: 3,
        sqft: 2200,
        yearBuilt: 1985,
        description:
            'Premium family home in top-rated Blossom Valley. Spacious backyard, 3-car garage, recently renovated kitchen. Excellent school district.',
        imageGradientIndex: 5,
      ),
      Property(
        id: 'SJ7',
        title: 'Rose Garden Victorian',
        meta: '4 bd • 2 ba • 1,890 sqft • Schools: A',
        price: 1150000,
        signal: 'Undervalued',
        risk: 'Low',
        growth: 'High',
        capRate: '3.6%',
        neighborhood: NeighborhoodScores(
            safety: 78, schools: 91, commute: 82, amenities: 85, stability: 80),
        pin: {'x': 20, 'y': 45},
        address: '1602 Naglee Ave, Rose Garden, San Jose, CA 95126',
        beds: 4,
        baths: 2,
        sqft: 1890,
        yearBuilt: 1910,
        description:
            'Stunning Victorian in the historic Rose Garden district. Original architectural details, fully modernized systems, walking distance to downtown.',
        imageGradientIndex: 1,
      ),
      Property(
        id: 'SJ8',
        title: 'Almaden Valley Estate',
        meta: '5 bd • 4 ba • 3,200 sqft • Schools: A+',
        price: 1750000,
        signal: 'Premium',
        risk: 'Low',
        growth: 'Medium',
        capRate: '2.8%',
        neighborhood: NeighborhoodScores(
            safety: 92, schools: 96, commute: 65, amenities: 74, stability: 90),
        pin: {'x': 18, 'y': 72},
        address: '6834 Winona Ct, Almaden Valley, San Jose, CA 95120',
        beds: 5,
        baths: 4,
        sqft: 3200,
        yearBuilt: 1998,
        description:
            'Luxurious estate in prestigious Almaden Valley. Pool, 4-car garage, chef kitchen, panoramic hillside views. Top-ranked schools in the region.',
        imageGradientIndex: 3,
      ),
      Property(
        id: 'SJ9',
        title: 'East Side Investment',
        meta: '3 bd • 2 ba • 1,380 sqft • Schools: B-',
        price: 695000,
        signal: 'High ROI',
        risk: 'Medium',
        growth: 'High',
        capRate: '5.8%',
        neighborhood: NeighborhoodScores(
            safety: 62, schools: 66, commute: 80, amenities: 70, stability: 60),
        pin: {'x': 85, 'y': 55},
        address: '2547 King Rd, East San Jose, CA 95122',
        beds: 3,
        baths: 2,
        sqft: 1380,
        yearBuilt: 1967,
        description:
            'Turnkey investment property in rapidly gentrifying East Side. New roof and HVAC, long-term tenants in place. Strong rental yield.',
        imageGradientIndex: 2,
      ),
      Property(
        id: 'SJ10',
        title: 'Santana Row Luxury',
        meta: '2 bd • 2 ba • 1,350 sqft • Schools: A-',
        price: 1285000,
        signal: 'High Growth',
        risk: 'Medium',
        growth: 'High',
        capRate: '3.9%',
        neighborhood: NeighborhoodScores(
            safety: 80, schools: 85, commute: 88, amenities: 96, stability: 75),
        pin: {'x': 40, 'y': 30},
        address: '378 Santana Row #510, West San Jose, CA 95128',
        beds: 2,
        baths: 2,
        sqft: 1350,
        yearBuilt: 2005,
        description:
            'Upscale condo steps from Santana Row shops and dining. Concierge service, rooftop terrace, high-end finishes throughout. Strong appreciation trend.',
        imageGradientIndex: 0,
      ),
    ];
  }
}
