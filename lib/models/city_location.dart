class CityLocation {
  const CityLocation({
    required this.name,
    required this.stateCode,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String stateCode;
  final double latitude;
  final double longitude;

  String get label => '$name, $stateCode';
}
