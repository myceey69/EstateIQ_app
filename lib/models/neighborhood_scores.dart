class NeighborhoodScores {
  final int safety;
  final int schools;
  final int commute;
  final int amenities;
  final int stability;

  NeighborhoodScores({
    required this.safety,
    required this.schools,
    required this.commute,
    required this.amenities,
    required this.stability,
  });

  factory NeighborhoodScores.fromJson(Map<String, dynamic> json) {
    return NeighborhoodScores(
      safety: json['Safety'] ?? 0,
      schools: json['Schools'] ?? 0,
      commute: json['Commute'] ?? 0,
      amenities: json['Amenities'] ?? 0,
      stability: json['Stability'] ?? 0,
    );
  }

  Map<String, int> toMap() => {
        'Safety': safety,
        'Schools': schools,
        'Commute': commute,
        'Amenities': amenities,
        'Stability': stability,
      };
}
