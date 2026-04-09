import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;

  late UserRole _role;
  RangeValues _budget = const RangeValues(450000, 1200000);
  String _risk = 'medium';
  final Set<String> _regions = <String>{};

  static const _regionOptions = <String>[
    'Willow Glen',
    'Downtown SJ',
    'Berryessa',
    'Cambrian Park',
    'Rose Garden',
    'Santana Row',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _role = user?.role ?? UserRole.buyer;
    _budget = RangeValues(
      (user?.preferences.budgetMin ?? 450000).toDouble().clamp(200000, 4000000),
      (user?.preferences.budgetMax ?? 1200000)
          .toDouble()
          .clamp(200000, 4000000),
    );
    _risk = user?.preferences.riskTolerance ?? 'medium';
    _regions.addAll(user?.preferences.preferredRegions ?? const []);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _fmtPrice(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    return '\$${(value / 1000).toStringAsFixed(0)}K';
  }

  Future<void> _next() async {
    if (_step < 3) {
      setState(() => _step += 1);
      await _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    auth.updateRole(_role);
    final current = auth.currentUser;
    if (current != null) {
      auth.updatePreferences(
        current.preferences.copyWith(
          budgetMin: _budget.start.round(),
          budgetMax: _budget.end.round(),
          preferredRegions: _regions.toList(),
          riskTolerance: _risk,
        ),
      );
    }
    auth.completeOnboarding();
  }

  Future<void> _back() async {
    if (_step == 0) return;
    setState(() => _step -= 1);
    await _pageCtrl.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final canFinish = watchlist.watchedIds.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to EstateIQ',
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 6),
              const Text(
                'Set up your experience in 4 quick steps.',
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(4, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _roleStep(),
                    _budgetRiskStep(),
                    _regionsStep(),
                    _saveFirstPropertyStep(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_step == 3 && !canFinish) ? null : _next,
                      child: Text(_step == 3 ? 'Finish Setup' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Choose your role',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We tailor insights and workflows by role.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...[
          (UserRole.buyer, 'Buyer', Icons.home_outlined),
          (UserRole.investor, 'Investor', Icons.trending_up),
          (UserRole.agent, 'Agent', Icons.badge_outlined),
        ].map((item) {
          final role = item.$1;
          final selected = _role == role;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _role = role),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withOpacity(0.2)
                      : AppColors.bg1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.line,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(item.$3,
                        color: selected ? AppColors.accent : AppColors.muted),
                    const SizedBox(width: 10),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: selected ? AppColors.accent : AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _budgetRiskStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Budget and risk',
          style: TextStyle(
              color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Budget: ${_fmtPrice(_budget.start)} – ${_fmtPrice(_budget.end)}',
          style: const TextStyle(color: AppColors.accent, fontSize: 15),
        ),
        RangeSlider(
          min: 200000,
          max: 4000000,
          divisions: 38,
          values: _budget,
          onChanged: (v) => setState(() => _budget = v),
        ),
        const SizedBox(height: 8),
        const Text('Risk tolerance',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['low', 'medium', 'high'].map((value) {
            final selected = _risk == value;
            return ChoiceChip(
              label: Text(value[0].toUpperCase() + value.substring(1)),
              selected: selected,
              selectedColor: AppColors.accent.withOpacity(0.25),
              side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.line),
              onSelected: (_) => setState(() => _risk = value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _regionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Preferred areas',
          style: TextStyle(
              color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Pick a few neighborhoods to personalize recommendations.',
            style: TextStyle(color: AppColors.muted, fontSize: 14)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _regionOptions.map((region) {
            final selected = _regions.contains(region);
            return FilterChip(
              label: Text(region),
              selected: selected,
              selectedColor: AppColors.accent.withOpacity(0.25),
              side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.line),
              onSelected: (v) => setState(() {
                if (v) {
                  _regions.add(region);
                } else {
                  _regions.remove(region);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _saveFirstPropertyStep() {
    final properties =
        context.watch<PropertyProvider>().allProperties.take(4).toList();
    final watchlist = context.watch<WatchlistProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Save your first property',
          style: TextStyle(
              color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Save at least one listing so we can power alerts and recommendations.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            'Saved: ${watchlist.watchedIds.length}',
            key: ValueKey<int>(watchlist.watchedIds.length),
            style: const TextStyle(
                color: AppColors.good, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, i) {
              final p = properties[i];
              final saved = watchlist.isWatched(p.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.priceFormatted,
                            style: const TextStyle(color: AppColors.accent2),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (saved) {
                          watchlist.removeFromWatchlist(p.id);
                        } else {
                          watchlist.addToWatchlist(p.id);
                        }
                      },
                      icon: Icon(saved ? Icons.check : Icons.bookmark_border,
                          size: 16),
                      label: Text(saved ? 'Saved' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            saved ? AppColors.good : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
