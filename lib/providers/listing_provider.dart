import 'package:flutter/foundation.dart';
import '../models/listing.dart';

class ListingProvider extends ChangeNotifier {
  final List<Listing> _listings = [];

  ListingProvider() {
    _seedListings();
  }

  List<Listing> get listings => List.unmodifiable(_listings);

  void _seedListings() {
    _listings.addAll([
      Listing(
        id: 'lst-1',
        title: 'Willow Glen Craftsman',
        description: 'Charming 3BR craftsman in prime Willow Glen location.',
        address: '1425 Rosemary Ave, San Jose, CA 95125',
        price: 879000,
        beds: 3,
        baths: 2,
        sqft: 1640,
        propertyType: 'Single Family',
        status: ListingStatus.active,
        agentId: 'demo-agent',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Listing(
        id: 'lst-2',
        title: 'Downtown Modern Condo',
        description: 'Sleek 2BR condo with city views and rooftop amenities.',
        address: '88 S 1st St #412, San Jose, CA 95113',
        price: 735000,
        beds: 2,
        baths: 2,
        sqft: 1120,
        propertyType: 'Condo',
        status: ListingStatus.underContract,
        agentId: 'demo-agent',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Listing(
        id: 'lst-3',
        title: 'Berryessa Investment Duplex',
        description: 'Income-generating duplex with strong rental history.',
        address: '2201 Penitencia Creek Rd, San Jose, CA 95132',
        price: 925000,
        beds: 4,
        baths: 3,
        sqft: 2100,
        propertyType: 'Multi-Family',
        status: ListingStatus.draft,
        agentId: 'demo-agent',
        aiSuggestedPrice: 910000,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  void addListing(Listing listing) {
    _listings.insert(0, listing);
    notifyListeners();
  }

  void updateListing(Listing updated) {
    final idx = _listings.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      _listings[idx] = updated;
      notifyListeners();
    }
  }

  void deleteListing(String id) {
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void changeStatus(String id, ListingStatus status) {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _listings[idx] = _listings[idx].copyWith(status: status);
      notifyListeners();
    }
  }
}
