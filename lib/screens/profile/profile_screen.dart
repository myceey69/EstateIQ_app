import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../models/user.dart';
import '../../theme/theme.dart';
import '../subscription/subscription_screen.dart';
import '../reports/reports_screen.dart';
import '../api_access/api_access_screen.dart';
import '../admin/admin_console_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _budgetMinCtrl;
  late TextEditingController _budgetMaxCtrl;
  late TextEditingController _regionCtrl;
  late List<String> _regions;
  late String _riskTolerance;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _budgetMinCtrl = TextEditingController(
        text: '${user?.preferences.budgetMin ?? 0}');
    _budgetMaxCtrl = TextEditingController(
        text: '${user?.preferences.budgetMax ?? 2000000}');
    _regionCtrl = TextEditingController();
    _regions =
        List<String>.from(user?.preferences.preferredRegions ?? []);
    _riskTolerance = user?.preferences.riskTolerance ?? 'medium';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    auth.updateProfile(user.copyWith(name: _nameCtrl.text.trim()));
    auth.updatePreferences(
      user.preferences.copyWith(
        budgetMin:
            int.tryParse(_budgetMinCtrl.text.replaceAll(',', '')) ?? 0,
        budgetMax:
            int.tryParse(_budgetMaxCtrl.text.replaceAll(',', '')) ??
                2000000,
        preferredRegions: List<String>.from(_regions),
        riskTolerance: _riskTolerance,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: AppColors.good),
    );
  }

  void _addRegion() {
    final text = _regionCtrl.text.trim();
    if (text.isNotEmpty && !_regions.contains(text)) {
      setState(() {
        _regions.add(text);
        _regionCtrl.clear();
      });
    }
  }

  String _planLabel(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.professional:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  Color _planColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return AppColors.muted;
      case SubscriptionPlan.basic:
        return AppColors.accent2;
      case SubscriptionPlan.professional:
        return AppColors.accent;
      case SubscriptionPlan.enterprise:
        return AppColors.warn;
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return 'Buyer';
      case UserRole.investor:
        return 'Investor';
      case UserRole.agent:
        return 'Agent';
      case UserRole.admin:
        return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        if (user == null) {
          return const Center(
            child: Text('Not logged in',
                style: TextStyle(color: AppColors.muted)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar + identity ─────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.avatarInitials.isNotEmpty
                              ? user.avatarInitials
                              : user.name
                                  .split(' ')
                                  .map((w) =>
                                      w.isNotEmpty ? w[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _badge(_roleLabel(user.role), AppColors.accent2),
                        const SizedBox(width: 8),
                        _badge(
                            _planLabel(user.plan), _planColor(user.plan)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Edit Profile ──────────────────────────────────────────
              _sectionHeader(context, 'Edit Profile'),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Display Name',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: AppColors.text),
                      decoration:
                          const InputDecoration(hintText: 'Your name'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Preferences ───────────────────────────────────────────
              _sectionHeader(context, 'Preferences'),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget range
                    const Text('Budget Range',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Min (\$)',
                                  style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _budgetMinCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    color: AppColors.text, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Max (\$)',
                                  style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _budgetMaxCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    color: AppColors.text, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: '2000000',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Preferred regions
                    const Text('Preferred Regions',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 8),
                    if (_regions.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _regions
                            .map(
                              (r) => Chip(
                                label: Text(r,
                                    style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 12)),
                                backgroundColor: AppColors.accent
                                    .withOpacity(0.15),
                                side: const BorderSide(
                                    color: AppColors.accent),
                                deleteIcon: const Icon(Icons.close,
                                    size: 14, color: AppColors.muted),
                                onDeleted: () =>
                                    setState(() => _regions.remove(r)),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _regionCtrl,
                            style: const TextStyle(
                                color: AppColors.text, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Add region (e.g. Palo Alto)',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onSubmitted: (_) => _addRegion(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addRegion,
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Risk tolerance
                    const Text('Risk Tolerance',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['low', 'medium', 'high'].map((r) {
                        final selected = _riskTolerance == r;
                        final label = r[0].toUpperCase() + r.substring(1);
                        final color = r == 'low'
                            ? AppColors.good
                            : r == 'medium'
                                ? AppColors.warn
                                : AppColors.bad;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label,
                                style: TextStyle(
                                    color: selected
                                        ? color
                                        : AppColors.muted,
                                    fontSize: 12)),
                            selected: selected,
                            selectedColor: color.withOpacity(0.2),
                            backgroundColor: AppColors.panel,
                            side: BorderSide(
                                color:
                                    selected ? color : AppColors.line),
                            onSelected: (_) =>
                                setState(() => _riskTolerance = r),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Saved Searches ────────────────────────────────────────
              _sectionHeader(context, 'Saved Searches'),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.savedSearches.isEmpty)
                      const Text('No saved searches yet.',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 13))
                    else
                      ...user.savedSearches.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: AppColors.muted, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(s,
                                    style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 13)),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.bad,
                                    size: 18),
                                onPressed: () =>
                                    auth.removeSavedSearch(s),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final q = context
                              .read<PropertyProvider>()
                              .searchQuery;
                          final f = context
                              .read<PropertyProvider>()
                              .activeFilter;
                          final save = q.isNotEmpty
                              ? q
                              : (f != 'All' ? 'Filter: $f' : null);
                          if (save != null) {
                            auth.addSavedSearch(save);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Saved search: "$save"'),
                                backgroundColor: AppColors.good,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Enter a search query first'),
                                backgroundColor: AppColors.warn,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.bookmark_add_outlined,
                            size: 16),
                        label: const Text('Save Current Search'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent),
                          foregroundColor: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Subscription card ─────────────────────────────────────
              _sectionHeader(context, 'Subscription'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _planColor(user.plan).withOpacity(0.25),
                      AppColors.bg1,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _planColor(user.plan).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _planColor(user.plan).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.workspace_premium,
                          color: _planColor(user.plan), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_planLabel(user.plan)} Plan',
                              style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const Text('Manage your subscription',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                      child: const Text('Manage',
                          style: TextStyle(color: AppColors.warn)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Quick links ───────────────────────────────────────────
              _sectionHeader(context, 'Account'),
              const SizedBox(height: 10),
              _profileLink(
                context,
                icon: Icons.description_outlined,
                label: 'Reports',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen())),
              ),
              if (user.role == UserRole.agent ||
                  user.plan == SubscriptionPlan.enterprise)
                _profileLink(
                  context,
                  icon: Icons.api_outlined,
                  label: 'API Access',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ApiAccessScreen())),
                ),
              if (user.role == UserRole.admin)
                _profileLink(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin Console',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminConsoleScreen())),
                ),
              const SizedBox(height: 16),

              // ── Save + Sign out ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.bad),
                    foregroundColor: AppColors.bad,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _profileLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.muted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
