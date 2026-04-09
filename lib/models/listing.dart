enum ListingStatus { draft, active, underContract, sold }

class Listing {
  final String id;
  final String title;
  final String description;
  final String address;
  final int price;
  final int beds;
  final double baths;
  final int sqft;
  final String propertyType;
  final ListingStatus status;
  final List<String> images;
  final String agentId;
  final int? aiSuggestedPrice;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.propertyType,
    this.status = ListingStatus.draft,
    this.images = const [],
    required this.agentId,
    this.aiSuggestedPrice,
    required this.createdAt,
  });

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    int? price,
    int? beds,
    double? baths,
    int? sqft,
    String? propertyType,
    ListingStatus? status,
    List<String>? images,
    String? agentId,
    int? aiSuggestedPrice,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      price: price ?? this.price,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      propertyType: propertyType ?? this.propertyType,
      status: status ?? this.status,
      images: images ?? this.images,
      agentId: agentId ?? this.agentId,
      aiSuggestedPrice: aiSuggestedPrice ?? this.aiSuggestedPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'address': address,
        'price': price,
        'beds': beds,
        'baths': baths,
        'sqft': sqft,
        'propertyType': propertyType,
        'status': status.name,
        'images': images,
        'agentId': agentId,
        'aiSuggestedPrice': aiSuggestedPrice,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      price: map['price'] ?? 0,
      beds: map['beds'] ?? 0,
      baths: (map['baths'] ?? 0).toDouble(),
      sqft: map['sqft'] ?? 0,
      propertyType: map['propertyType'] ?? '',
      status: ListingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ListingStatus.draft,
      ),
      images: List<String>.from(map['images'] ?? []),
      agentId: map['agentId'] ?? '',
      aiSuggestedPrice: map['aiSuggestedPrice'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
