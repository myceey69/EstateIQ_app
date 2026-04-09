enum AlertType { priceChange, newMatch, marketShift }

class Alert {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final AlertType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.type,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  Alert copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    AlertType? type,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'type': type.name,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyTitle: map['propertyTitle'] ?? '',
      type: AlertType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AlertType.newMatch,
      ),
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
