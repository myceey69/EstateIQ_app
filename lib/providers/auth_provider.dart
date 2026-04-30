import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _init();
  }

  UserRole _parseRole(dynamic value) {
    final role = value?.toString() ?? '';
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.buyer,
    );
  }

  SubscriptionPlan _parsePlan(dynamic value) {
    final plan = value?.toString() ?? '';
    return SubscriptionPlan.values.firstWhere(
      (e) => e.name == plan,
      orElse: () => SubscriptionPlan.free,
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'U';
    return parts.map((e) => e[0]).take(2).join().toUpperCase();
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  AppUser _buildUser(User user, Map<String, dynamic>? profile) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final name =
        (profile?['name'] ?? metadata['full_name'] ?? 'User').toString();
    final avatarInitials =
        (profile?['avatar_initials'] as String?) ?? _initialsFromName(name);
    final profileOnboarding = _toBool(profile?['has_completed_onboarding']) ||
        _toBool(profile?['hasCompletedOnboarding']);
    final metadataOnboarding = _toBool(metadata['has_completed_onboarding']) ||
        _toBool(metadata['hasCompletedOnboarding']);

    return AppUser(
      id: user.id,
      name: name,
      email: user.email ?? '',
      passwordHash: '',
      role: _parseRole(profile?['role'] ?? metadata['role']),
      plan: _parsePlan(profile?['plan'] ?? metadata['plan']),
      avatarInitials: avatarInitials,
      hasCompletedOnboarding: profileOnboarding || metadataOnboarding,
      savedSearches: List<String>.from(profile?['saved_searches'] ?? const []),
      preferences: UserPreferences.fromMap(
        Map<String, dynamic>.from(profile?['preferences'] ?? const {}),
      ),
    );
  }

  Future<void> _setCurrentUserFromAuth(User user) async {
    Map<String, dynamic>? profile;
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (response != null) {
        profile = Map<String, dynamic>.from(response);
      }
    } catch (_) {
      // Keep auth functional even if profile lookup fails.
    }
    _currentUser = _buildUser(user, profile);
    _error = null;
  }

  void _init() {
    final existingUser = _supabase.auth.currentUser;
    if (existingUser != null) {
      _setCurrentUserFromAuth(existingUser).then((_) => notifyListeners());
    }

    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final user = session?.user;
      if (user != null) {
        _isLoading = true;
        notifyListeners();

        try {
          await _setCurrentUserFromAuth(user);
        } catch (e) {
          _error = 'Error loading profile: $e';
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
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

  Future<bool> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': name.trim(),
          'role': role.toString().split('.').last,
          'has_completed_onboarding': false,
        },
      );

      if (response.user == null) {
        _error = 'Could not create account. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = response.user;
      if (user == null) {
        _error = 'Sign in succeeded but no user session was returned.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await _setCurrentUserFromAuth(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        _error = 'Please confirm your email before signing in.';
      } else {
        _error = e.message;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_currentUser == null) return;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'has_completed_onboarding': true},
        ),
      );
      _currentUser = _currentUser!.copyWith(hasCompletedOnboarding: true);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ... (keeping other methods or stubbing them for now)
  void updateProfile(AppUser updated) {
    _currentUser = updated;
    notifyListeners();
  }

  void addSavedSearch(String query) {
    if (_currentUser == null) return;
    final searches = List<String>.from(_currentUser!.savedSearches);
    if (!searches.contains(query)) {
      searches.add(query);
      _currentUser = _currentUser!.copyWith(savedSearches: searches);
      notifyListeners();
    }
  }

  void removeSavedSearch(String query) {
    if (_currentUser == null) return;
    final searches = List<String>.from(_currentUser!.savedSearches)
      ..remove(query);
    _currentUser = _currentUser!.copyWith(savedSearches: searches);
    notifyListeners();
  }

  void updatePreferences(UserPreferences prefs) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(preferences: prefs);
    notifyListeners();
  }

  void updateRole(UserRole role) async {
    if (_currentUser == null) return;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'role': role.toString().split('.').last},
        ),
      );
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
