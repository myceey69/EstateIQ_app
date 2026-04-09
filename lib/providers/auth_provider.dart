import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const String _demoSalt = 'estateiq-demo-salt-v1';

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  final Map<String, AppUser> _users = {};

  AuthProvider() {
    _seedDemoUsers();
  }

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get hasCompletedOnboarding =>
      _currentUser?.hasCompletedOnboarding ?? false;
  bool get isAgent =>
      _currentUser?.role == UserRole.agent ||
      _currentUser?.role == UserRole.admin;

  void _seedDemoUsers() {
    final demoUsers = [
      AppUser(
        id: 'demo-buyer',
        name: 'Alex Buyer',
        email: 'buyer@demo.com',
        passwordHash: _hashPassword('demo123'),
        role: UserRole.buyer,
        plan: SubscriptionPlan.basic,
        avatarInitials: 'AB',
        savedSearches: const ['3bd San Jose under 900k'],
        preferences: const UserPreferences(
          budgetMin: 500000,
          budgetMax: 950000,
          preferredRegions: ['Willow Glen', 'Cambrian Park'],
          propertyTypes: ['Single Family', 'Condo'],
          riskTolerance: 'low',
        ),
        hasCompletedOnboarding: false,
      ),
      AppUser(
        id: 'demo-investor',
        name: 'Morgan Investor',
        email: 'investor@demo.com',
        passwordHash: _hashPassword('demo123'),
        role: UserRole.investor,
        plan: SubscriptionPlan.professional,
        avatarInitials: 'MI',
        savedSearches: const ['duplex high cap rate', 'tech hub apartments'],
        preferences: const UserPreferences(
          budgetMin: 700000,
          budgetMax: 2000000,
          preferredRegions: ['Downtown SJ', 'Berryessa'],
          propertyTypes: ['Multi-Family', 'Duplex', 'Condo'],
          riskTolerance: 'high',
        ),
        hasCompletedOnboarding: false,
      ),
      AppUser(
        id: 'demo-agent',
        name: 'Sam Agent',
        email: 'agent@demo.com',
        passwordHash: _hashPassword('demo123'),
        role: UserRole.agent,
        plan: SubscriptionPlan.professional,
        avatarInitials: 'SA',
        savedSearches: const [],
        preferences: const UserPreferences(
          budgetMin: 0,
          budgetMax: 5000000,
          preferredRegions: [],
          propertyTypes: [],
          riskTolerance: 'medium',
        ),
        hasCompletedOnboarding: false,
      ),
      AppUser(
        id: 'demo-admin',
        name: 'Admin User',
        email: 'admin@demo.com',
        passwordHash: _hashPassword('demo123'),
        role: UserRole.admin,
        plan: SubscriptionPlan.enterprise,
        avatarInitials: 'AU',
        savedSearches: const [],
        preferences: const UserPreferences(),
        hasCompletedOnboarding: false,
      ),
    ];

    for (final user in demoUsers) {
      _users[user.email] = user;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = _normalizeEmail(email);

    if (_users.containsKey(normalizedEmail)) {
      _error = 'An account with this email already exists.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final newUser = AppUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      role: role,
      plan: SubscriptionPlan.free,
      avatarInitials: initials,
      hasCompletedOnboarding: false,
    );

    _users[newUser.email] = newUser;
    _currentUser = newUser;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = _normalizeEmail(email);
    final user = _users[normalizedEmail];
    if (user == null || user.passwordHash != _hashPassword(password)) {
      _error = 'Invalid email or password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void updateProfile(AppUser updated) {
    _users[updated.email] = updated;
    if (_currentUser?.email == updated.email) {
      _currentUser = updated;
    }
    notifyListeners();
  }

  void addSavedSearch(String query) {
    if (_currentUser == null) return;
    final searches = List<String>.from(_currentUser!.savedSearches);
    if (!searches.contains(query)) {
      searches.add(query);
      _currentUser = _currentUser!.copyWith(savedSearches: searches);
      _users[_currentUser!.email] = _currentUser!;
      notifyListeners();
    }
  }

  void removeSavedSearch(String query) {
    if (_currentUser == null) return;
    final searches = List<String>.from(_currentUser!.savedSearches)
      ..remove(query);
    _currentUser = _currentUser!.copyWith(savedSearches: searches);
    _users[_currentUser!.email] = _currentUser!;
    notifyListeners();
  }

  void updatePreferences(UserPreferences prefs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(preferences: prefs);
    _users[_currentUser!.email] = _currentUser!;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateRole(UserRole role) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(role: role);
    _users[_currentUser!.email] = _currentUser!;
    notifyListeners();
  }

  void completeOnboarding() {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(hasCompletedOnboarding: true);
    _users[_currentUser!.email] = _currentUser!;
    notifyListeners();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hashPassword(String password) {
    final bytes = utf8.encode('$_demoSalt:${password.trim()}');
    return sha256.convert(bytes).toString();
  }
}
