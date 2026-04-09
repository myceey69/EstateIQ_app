enum UserRole { buyer, investor, agent, admin }

enum SubscriptionPlan { free, basic, professional, enterprise }

class UserPreferences {
  final int budgetMin;
  final int budgetMax;
  final List<String> preferredRegions;
  final List<String> propertyTypes;
  final String riskTolerance;

  const UserPreferences({
    this.budgetMin = 0,
    this.budgetMax = 2000000,
    this.preferredRegions = const [],
    this.propertyTypes = const [],
    this.riskTolerance = 'medium',
  });

  UserPreferences copyWith({
    int? budgetMin,
    int? budgetMax,
    List<String>? preferredRegions,
    List<String>? propertyTypes,
    String? riskTolerance,
  }) {
    return UserPreferences(
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      preferredRegions: preferredRegions ?? this.preferredRegions,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      riskTolerance: riskTolerance ?? this.riskTolerance,
    );
  }

  Map<String, dynamic> toMap() => {
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'preferredRegions': preferredRegions,
        'propertyTypes': propertyTypes,
        'riskTolerance': riskTolerance,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      budgetMin: map['budgetMin'] ?? 0,
      budgetMax: map['budgetMax'] ?? 2000000,
      preferredRegions: List<String>.from(map['preferredRegions'] ?? []),
      propertyTypes: List<String>.from(map['propertyTypes'] ?? []),
      riskTolerance: map['riskTolerance'] ?? 'medium',
    );
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final UserRole role;
  final SubscriptionPlan plan;
  final String avatarInitials;
  final List<String> savedSearches;
  final UserPreferences preferences;
  final bool hasCompletedOnboarding;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.role = UserRole.buyer,
    this.plan = SubscriptionPlan.free,
    this.avatarInitials = '',
    this.savedSearches = const [],
    this.preferences = const UserPreferences(),
    this.hasCompletedOnboarding = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    UserRole? role,
    SubscriptionPlan? plan,
    String? avatarInitials,
    List<String>? savedSearches,
    UserPreferences? preferences,
    bool? hasCompletedOnboarding,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      savedSearches: savedSearches ?? this.savedSearches,
      preferences: preferences ?? this.preferences,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role.name,
        'plan': plan.name,
        'avatarInitials': avatarInitials,
        'savedSearches': savedSearches,
        'preferences': preferences.toMap(),
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.buyer,
      ),
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.name == map['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      avatarInitials: map['avatarInitials'] ?? '',
      savedSearches: List<String>.from(map['savedSearches'] ?? []),
      preferences: UserPreferences.fromMap(
          Map<String, dynamic>.from(map['preferences'] ?? {})),
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }
}
