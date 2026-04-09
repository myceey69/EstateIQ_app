import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing.dart';
import '../../theme/theme.dart';

class ListingManagementScreen extends StatelessWidget {
  const ListingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingProvider>(
      builder: (context, listingProvider, _) {
        final listings = listingProvider.listings;
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Listings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accent,
            onPressed: () => _showListingForm(context, listingProvider, null),
            child: const Icon(Icons.add_home_outlined, color: Colors.white),
          ),
          body: listings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_work_outlined,
                          size: 64, color: AppColors.muted),
                      SizedBox(height: 16),
                      Text('No listings yet',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text('Tap + to create your first listing',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (ctx, i) {
                    final listing = listings[i];
                    return _ListingCard(
                      listing: listing,
                      onEdit: () =>
                          _showListingForm(context, listingProvider, listing),
                      onDelete: () => listingProvider.deleteListing(listing.id),
                      onStatusChange: (s) =>
                          listingProvider.changeStatus(listing.id, s),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showListingForm(
      BuildContext context, ListingProvider provider, Listing? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null ? '${existing.price}' : '');
    final bedsCtrl =
        TextEditingController(text: existing != null ? '${existing.beds}' : '');
    final bathsCtrl = TextEditingController(
        text: existing != null ? '${existing.baths}' : '');
    final sqftCtrl =
        TextEditingController(text: existing != null ? '${existing.sqft}' : '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String selectedType = existing?.propertyType ?? 'Single Family';
    int? aiSuggestedPrice = existing?.aiSuggestedPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: StatefulBuilder(builder: (ctx2, ss) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing != null ? 'Edit Listing' : 'Create Listing',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(hintText: 'Address'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.text),
                          decoration:
                              const InputDecoration(hintText: 'Price (\$)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          dropdownColor: AppColors.bg1,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(hintText: 'Type'),
                          items: const [
                            'Single Family',
                            'Condo',
                            'Multi-Family',
                            'Townhouse',
                            'Land',
                          ]
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) => ss(() => selectedType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bedsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(hintText: 'Beds'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: bathsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(hintText: 'Baths'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: sqftCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.text),
                          decoration: const InputDecoration(hintText: 'Sqft'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(hintText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  // AI Pricing Guidance
                  OutlinedButton.icon(
                    onPressed: () {
                      final sqft = int.tryParse(sqftCtrl.text) ?? 1500;
                      final addr = addressCtrl.text.toLowerCase();
                      double priceSqft = 600;
                      if (addr.contains('palo alto')) {
                        priceSqft = 1500;
                      } else if (addr.contains('mountain view')) {
                        priceSqft = 1200;
                      } else if (addr.contains('sunnyvale')) {
                        priceSqft = 1050;
                      } else if (addr.contains('san jose')) {
                        priceSqft = 750;
                      }
                      final suggested = (sqft * priceSqft).round();
                      ss(() => aiSuggestedPrice = suggested);
                      final formatted = suggested.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('AI suggests: \$$formatted ± 10%'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AI Pricing Guidance'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                  if (aiSuggestedPrice != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        'AI Suggested: \$${aiSuggestedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;
                        final listing = Listing(
                          id: existing?.id ??
                              'lst-${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          description: descCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          price: int.tryParse(priceCtrl.text) ?? 0,
                          beds: int.tryParse(bedsCtrl.text) ?? 0,
                          baths: double.tryParse(bathsCtrl.text) ?? 0,
                          sqft: int.tryParse(sqftCtrl.text) ?? 0,
                          propertyType: selectedType,
                          agentId: 'demo-agent',
                          aiSuggestedPrice: aiSuggestedPrice,
                          createdAt: existing?.createdAt ?? DateTime.now(),
                          status: existing?.status ?? ListingStatus.draft,
                        );
                        if (existing != null) {
                          provider.updateListing(listing);
                        } else {
                          provider.addListing(listing);
                        }
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(existing != null
                                ? 'Listing updated!'
                                : 'Listing created!'),
                            backgroundColor: AppColors.good,
                          ),
                        );
                      },
                      child: Text(
                          existing != null ? 'Save Changes' : 'Create Listing'),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<ListingStatus> onStatusChange;

  const _ListingCard({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  Color _statusColor(ListingStatus s) {
    switch (s) {
      case ListingStatus.draft:
        return AppColors.muted;
      case ListingStatus.active:
        return AppColors.good;
      case ListingStatus.underContract:
        return AppColors.warn;
      case ListingStatus.sold:
        return AppColors.accent;
    }
  }

  String _statusLabel(ListingStatus s) {
    switch (s) {
      case ListingStatus.draft:
        return 'Draft';
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.underContract:
        return 'Under Contract';
      case ListingStatus.sold:
        return 'Sold';
    }
  }

  ListingStatus? _nextStatus(ListingStatus s) {
    switch (s) {
      case ListingStatus.draft:
        return ListingStatus.active;
      case ListingStatus.active:
        return ListingStatus.underContract;
      case ListingStatus.underContract:
        return ListingStatus.sold;
      case ListingStatus.sold:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(listing.status);
    final price = listing.price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(listing.title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel(listing.status),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(listing.address,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('\$$price',
                  style: const TextStyle(
                      color: AppColors.accent2,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(width: 12),
              Text('${listing.beds}bd / ${listing.baths.toStringAsFixed(1)}ba',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const Spacer(),
              if (listing.aiSuggestedPrice != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('AI',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_nextStatus(listing.status) != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        onStatusChange(_nextStatus(listing.status)!),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      foregroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Text(
                        'Mark ${_statusLabel(_nextStatus(listing.status)!)}',
                        style: const TextStyle(fontSize: 11)),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit listing',
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.accent, size: 20),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.bg1,
                      title: const Text('Delete Listing?',
                          style: TextStyle(color: AppColors.text)),
                      content: Text(
                          'Are you sure you want to delete "${listing.title}"?',
                          style: const TextStyle(color: AppColors.muted)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onDelete();
                            Navigator.pop(context);
                          },
                          child: const Text('Delete',
                              style: TextStyle(color: AppColors.bad)),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Delete listing',
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.bad, size: 20),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
