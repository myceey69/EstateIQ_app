import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/location_data.dart';
import '../models/city_location.dart';
import '../providers/property_provider.dart';
import '../theme/theme.dart';
import '../widgets/property_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  bool _showSkeleton = true;

  // Bottom-sheet local state (held here so we can read after sheet close)
  RangeValues _priceRange = const RangeValues(200000, 2000000);
  int _minBeds = 0; // 0 = Any
  String? _selectedStateCode;
  CityLocation? _selectedCity;
  int _radiusMiles = 25;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  static const _chips = [
    'All',
    'Low Risk',
    'High Growth',
    'Best ROI',
    'Undervalued',
    'Emerging',
  ];

  // ── Price formatter ───────────────────────────────────────────────────────
  String _fmtPrice(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    return '\$${(v / 1000).toStringAsFixed(0)}K';
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    final provider = context.read<PropertyProvider>();
    RangeValues sheetRange = _priceRange;
    int sheetBeds = _minBeds;
    String? sheetStateCode = _selectedStateCode;
    CityLocation? sheetCity = _selectedCity;
    int sheetRadiusMiles = _radiusMiles;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final hasGeo = sheetStateCode != null && sheetCity != null;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Filters',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                const Text('Location',
                    style: TextStyle(
                        color: AppColors.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: sheetStateCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Select a state',
                    prefixIcon: Icon(Icons.map_outlined, size: 18),
                  ),
                  items: usStates.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text('${entry.value} (${entry.key})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setSheetState(() {
                    sheetStateCode = value;
                    sheetCity = null;
                  }),
                ),
                const SizedBox(height: 12),
                Autocomplete<CityLocation>(
                  key: ValueKey(sheetStateCode),
                  displayStringForOption: (city) => city.name,
                  optionsBuilder: (value) {
                    if (sheetStateCode == null) return const Iterable.empty();
                    final query = value.text.trim().toLowerCase();
                    return cityLocations
                        .where((city) =>
                            city.stateCode == sheetStateCode &&
                            (query.isEmpty ||
                                city.name.toLowerCase().contains(query)))
                        .take(12);
                  },
                  onSelected: (city) => setSheetState(() => sheetCity = city),
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    if (sheetCity != null && controller.text.isEmpty) {
                      controller.text = sheetCity!.name;
                    }
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: sheetStateCode != null,
                      decoration: InputDecoration(
                        hintText: sheetStateCode == null
                            ? 'Select state first'
                            : 'Search city',
                        prefixIcon: const Icon(Icons.location_city, size: 18),
                        suffixIcon: sheetCity != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  controller.clear();
                                  setSheetState(() => sheetCity = null);
                                },
                              )
                            : null,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: AppColors.bg1,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(10),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 220,
                            maxWidth: 340,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final city = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(city.label),
                                onTap: () => onSelected(city),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distance Radius',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600)),
                    Text(
                      hasGeo ? '$sheetRadiusMiles miles' : 'Choose city',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [5, 10, 25, 50, 100].map((radius) {
                    return ChoiceChip(
                      label: Text('$radius mi'),
                      selected: sheetRadiusMiles == radius,
                      selectedColor: AppColors.accent.withOpacity(0.25),
                      labelStyle: TextStyle(
                        color: sheetRadiusMiles == radius
                            ? AppColors.accent
                            : AppColors.muted,
                      ),
                      backgroundColor: AppColors.panel,
                      side: BorderSide(
                        color: sheetRadiusMiles == radius
                            ? AppColors.accent
                            : AppColors.line,
                      ),
                      onSelected: sheetCity == null
                          ? null
                          : (_) =>
                              setSheetState(() => sheetRadiusMiles = radius),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Price range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Price Range',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600)),
                    Text(
                      '${_fmtPrice(sheetRange.start)} – ${_fmtPrice(sheetRange.end)}',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 13),
                    ),
                  ],
                ),
                RangeSlider(
                  values: sheetRange,
                  min: 200000,
                  max: 2000000,
                  divisions: 36,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.panel,
                  onChanged: (v) => setSheetState(() => sheetRange = v),
                ),

                const SizedBox(height: 16),
                const Text('Min Bedrooms',
                    style: TextStyle(
                        color: AppColors.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                // Beds chips
                Wrap(
                  spacing: 8,
                  children:
                      ['Any', '1+', '2+', '3+', '4+'].asMap().entries.map((e) {
                    final idx = e.key;
                    final label = e.value;
                    return ChoiceChip(
                      label: Text(label),
                      selected: sheetBeds == idx,
                      selectedColor: AppColors.accent.withOpacity(0.25),
                      labelStyle: TextStyle(
                        color: sheetBeds == idx
                            ? AppColors.accent
                            : AppColors.muted,
                      ),
                      backgroundColor: AppColors.panel,
                      side: BorderSide(
                          color: sheetBeds == idx
                              ? AppColors.accent
                              : AppColors.line),
                      onSelected: (_) => setSheetState(() => sheetBeds = idx),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),
                Row(
                  children: [
                    // Reset
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setSheetState(() {
                            sheetRange = const RangeValues(200000, 2000000);
                            sheetBeds = 0;
                            sheetStateCode = null;
                            sheetCity = null;
                            sheetRadiusMiles = 25;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.line),
                          foregroundColor: AppColors.muted,
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() {
                            _priceRange = sheetRange;
                            _minBeds = sheetBeds;
                            _selectedStateCode = sheetStateCode;
                            _selectedCity = sheetCity;
                            _radiusMiles = sheetRadiusMiles;
                          });
                          final minP = sheetRange.start > 200000 + 1
                              ? sheetRange.start.toInt()
                              : null;
                          final maxP = sheetRange.end < 2000000 - 1
                              ? sheetRange.end.toInt()
                              : null;
                          provider.setPriceRange(minP, maxP);
                          provider.setMinBeds(sheetBeds > 0 ? sheetBeds : null);
                          provider.setGeoFilter(
                            stateCode: sheetStateCode,
                            city: sheetCity,
                            radiusMiles: sheetRadiusMiles,
                          );
                          if (sheetCity != null) {
                            await provider.refreshSaleListings(
                              city: sheetCity!.name,
                              state: sheetCity!.stateCode,
                            );
                          }
                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${provider.filteredProperties.length} properties match your filters',
                              ),
                              duration: const Duration(milliseconds: 1200),
                              backgroundColor: AppColors.good,
                            ),
                          );
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAdvancedFilters = _minBeds > 0 ||
        _priceRange.start > 200000 + 1 ||
        _priceRange.end < 2000000 - 1 ||
        _selectedCity != null;
    return Column(
      children: [
        // ── Search + filters ─────────────────────────────────────────────
        Container(
          color: AppColors.bg1,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (v) =>
                    context.read<PropertyProvider>().setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search properties, areas...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<PropertyProvider>().setSearchQuery('');
                          },
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              // Filter chips row + Filters button
              Consumer<PropertyProvider>(
                builder: (context, provider, _) => Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _chips
                              .map((chip) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(chip,
                                          style: const TextStyle(fontSize: 12)),
                                      selected: provider.activeFilter == chip,
                                      selectedColor:
                                          AppColors.accent.withOpacity(0.2),
                                      checkmarkColor: AppColors.accent,
                                      labelStyle: TextStyle(
                                        color: provider.activeFilter == chip
                                            ? AppColors.accent
                                            : AppColors.muted,
                                      ),
                                      backgroundColor: AppColors.panel,
                                      side: BorderSide(
                                        color: provider.activeFilter == chip
                                            ? AppColors.accent
                                            : AppColors.line,
                                      ),
                                      onSelected: (_) =>
                                          provider.setActiveFilter(chip),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tune (filters) button
                    SizedBox(
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasAdvancedFilters
                                ? AppColors.accent.withOpacity(0.2)
                                : AppColors.panel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasAdvancedFilters
                                  ? AppColors.accent
                                  : AppColors.line,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune, size: 18),
                            tooltip: 'Open filters',
                            color: hasAdvancedFilters
                                ? AppColors.accent
                                : AppColors.muted,
                            onPressed: () => _showFilterSheet(context),
                            padding: const EdgeInsets.all(8),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Result count ─────────────────────────────────────────────────
        Consumer<PropertyProvider>(
          builder: (context, provider, _) => Container(
            color: AppColors.bg0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  provider.usingLiveListings
                      ? Icons.cloud_done_outlined
                      : Icons.storage_outlined,
                  color: provider.usingLiveListings
                      ? AppColors.good
                      : AppColors.muted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${provider.filteredProperties.length} properties found',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                if (_selectedCity != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${_selectedCity!.name} • $_radiusMiles mi',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (provider.isLoadingListings)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    tooltip: 'Refresh listings',
                    color: AppColors.muted,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints.tightFor(width: 32, height: 28),
                    padding: EdgeInsets.zero,
                    onPressed: provider.refreshSaleListings,
                  ),
              ],
            ),
          ),
        ),

        // ── Property list ─────────────────────────────────────────────────
        Expanded(
          child: Consumer<PropertyProvider>(
            builder: (context, provider, _) {
              if (_showSkeleton) return _PropertyListSkeleton();
              final props = provider.filteredProperties;
              if (props.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 56, color: AppColors.muted),
                      const SizedBox(height: 16),
                      Text(
                        'No properties found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try adjusting your filters',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: props.length,
                itemBuilder: (context, i) => PropertyCard(
                  property: props[i],
                  onTap: () {
                    provider.setSelectedProperty(props[i]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DetailScreen()),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PropertyListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5,
      itemBuilder: (context, _) => Container(
        height: 130,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
      ),
    );
  }
}
