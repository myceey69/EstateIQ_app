enum ReportType { comparables, marketReport, investmentBrief }

class Report {
  final String id;
  final String title;
  final ReportType type;
  final String propertyId;
  final DateTime generatedAt;
  final bool isDownloaded;
  final bool isPremium;

  const Report({
    required this.id,
    required this.title,
    required this.type,
    required this.propertyId,
    required this.generatedAt,
    this.isDownloaded = false,
    this.isPremium = false,
  });

  Report copyWith({
    String? id,
    String? title,
    ReportType? type,
    String? propertyId,
    DateTime? generatedAt,
    bool? isDownloaded,
    bool? isPremium,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      propertyId: propertyId ?? this.propertyId,
      generatedAt: generatedAt ?? this.generatedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'propertyId': propertyId,
        'generatedAt': generatedAt.toIso8601String(),
        'isDownloaded': isDownloaded,
        'isPremium': isPremium,
      };

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: ReportType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ReportType.marketReport,
      ),
      propertyId: map['propertyId'] ?? '',
      generatedAt: DateTime.tryParse(map['generatedAt'] ?? '') ?? DateTime.now(),
      isDownloaded: map['isDownloaded'] ?? false,
      isPremium: map['isPremium'] ?? false,
    );
  }
}
