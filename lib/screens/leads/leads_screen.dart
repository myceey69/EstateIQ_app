import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/theme.dart';

enum LeadStatus { newLead, contacted, qualified, closed }

class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String propertyInterest;
  final String notes;
  LeadStatus status;
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.propertyInterest,
    this.notes = '',
    this.status = LeadStatus.newLead,
    required this.createdAt,
  });
}

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({Key? key}) : super(key: key);

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final List<Lead> _leads = [
    Lead(
      id: 'lead-1',
      name: 'Jennifer Park',
      email: 'jpark@email.com',
      phone: '(408) 555-1234',
      propertyInterest: 'Willow Glen Craftsman',
      notes: 'Interested in 3BR homes, budget up to \$950K',
      status: LeadStatus.qualified,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Lead(
      id: 'lead-2',
      name: 'Marcus Williams',
      email: 'mwilliams@gmail.com',
      phone: '(650) 555-5678',
      propertyInterest: 'Downtown Modern Condo',
      notes: 'First-time buyer, pre-approved at \$800K',
      status: LeadStatus.contacted,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Lead(
      id: 'lead-3',
      name: 'Sarah Chen',
      email: 'schen@invest.co',
      phone: '(415) 555-9012',
      propertyInterest: 'Berryessa Duplex',
      notes: 'Investor looking for cap rate > 5%',
      status: LeadStatus.newLead,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Lead(
      id: 'lead-4',
      name: 'David Kim',
      email: 'dkim@techcorp.com',
      phone: '(408) 555-3456',
      propertyInterest: 'Almaden Valley Estate',
      notes: 'Relocating from NYC, needs to close by June',
      status: LeadStatus.closed,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Lead(
      id: 'lead-5',
      name: 'Priya Sharma',
      email: 'priya.s@email.com',
      phone: '(510) 555-7890',
      propertyInterest: 'Santana Row Luxury',
      notes: 'High-net-worth buyer, cash offer possible',
      status: LeadStatus.contacted,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  LeadStatus? _filterStatus;

  List<Lead> get _filteredLeads => _filterStatus == null
      ? _leads
      : _leads.where((l) => l.status == _filterStatus).toList();

  @override
  Widget build(BuildContext context) {
    final statusCounts = {
      for (final s in LeadStatus.values)
        s: _leads.where((l) => l.status == s).length
    };
    final conversionRate = _leads.isEmpty
        ? 0
        : (_leads.where((l) => l.status == LeadStatus.closed).length /
                _leads.length *
                100)
            .round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _showAddLeadSheet,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(
                    child: _statCard(
                        'Total Leads', '${_leads.length}', AppColors.accent)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        'Conversion', '$conversionRate%', AppColors.good)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard('Avg Response', '2.4h', AppColors.warn)),
              ],
            ),
            const SizedBox(height: 16),

            // Pipeline status tabs
            Text('Pipeline', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _statusChip(null, 'All', _leads.length, AppColors.accent),
                  const SizedBox(width: 8),
                  _statusChip(LeadStatus.newLead, 'New',
                      statusCounts[LeadStatus.newLead]!, AppColors.accent2),
                  const SizedBox(width: 8),
                  _statusChip(LeadStatus.contacted, 'Contacted',
                      statusCounts[LeadStatus.contacted]!, AppColors.warn),
                  const SizedBox(width: 8),
                  _statusChip(LeadStatus.qualified, 'Qualified',
                      statusCounts[LeadStatus.qualified]!, AppColors.good),
                  const SizedBox(width: 8),
                  _statusChip(LeadStatus.closed, 'Closed',
                      statusCounts[LeadStatus.closed]!, AppColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Lead list
            ..._filteredLeads.map((lead) => _LeadCard(
                  lead: lead,
                  onStatusChange: (s) => setState(() => lead.status = s),
                  onTap: () => _showLeadDetail(lead),
                )),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _statusChip(LeadStatus? status, String label, int count, Color color) {
    final selected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(
          () => _filterStatus = _filterStatus == status ? null : status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppColors.bg1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: selected ? color : AppColors.muted,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLeadSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String? selectedProperty;

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
            final props = context.read<PropertyProvider>().allProperties;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Lead',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(hintText: 'Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(hintText: 'Phone'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedProperty,
                  dropdownColor: AppColors.bg1,
                  style: const TextStyle(color: AppColors.text),
                  decoration:
                      const InputDecoration(hintText: 'Property Interest'),
                  items: props
                      .map((p) => DropdownMenuItem(
                            value: p.title,
                            child: Text(p.title,
                                style: const TextStyle(
                                    color: AppColors.text, fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => ss(() => selectedProperty = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(hintText: 'Notes'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _leads.insert(
                          0,
                          Lead(
                            id: 'lead-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            propertyInterest: selectedProperty ?? 'Unknown',
                            notes: notesCtrl.text.trim(),
                            createdAt: DateTime.now(),
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Lead added!'),
                            backgroundColor: AppColors.good),
                      );
                    },
                    child: const Text('Add Lead'),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _showLeadDetail(Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, ss) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead.name,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _detailRow(Icons.email_outlined, lead.email),
                _detailRow(Icons.phone_outlined, lead.phone),
                _detailRow(Icons.home_outlined, lead.propertyInterest),
                if (lead.notes.isNotEmpty)
                  _detailRow(Icons.note_outlined, lead.notes),
                const SizedBox(height: 14),
                const Text('Change Status',
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: LeadStatus.values.map((s) {
                    final selected = lead.status == s;
                    final color = _statusColor(s);
                    return ChoiceChip(
                      label: Text(_statusLabel(s),
                          style: TextStyle(
                              color: selected ? color : AppColors.muted,
                              fontSize: 12)),
                      selected: selected,
                      selectedColor: color.withOpacity(0.2),
                      backgroundColor: AppColors.panel,
                      side:
                          BorderSide(color: selected ? color : AppColors.line),
                      onSelected: (_) {
                        setState(() => lead.status = s);
                        ss(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 13))),
        ],
      ),
    );
  }

  String _statusLabel(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.qualified:
        return 'Qualified';
      case LeadStatus.closed:
        return 'Closed';
    }
  }

  Color _statusColor(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return AppColors.accent2;
      case LeadStatus.contacted:
        return AppColors.warn;
      case LeadStatus.qualified:
        return AppColors.good;
      case LeadStatus.closed:
        return AppColors.muted;
    }
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  final ValueChanged<LeadStatus> onStatusChange;
  final VoidCallback onTap;

  const _LeadCard({
    required this.lead,
    required this.onStatusChange,
    required this.onTap,
  });

  Color _statusColor(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return AppColors.accent2;
      case LeadStatus.contacted:
        return AppColors.warn;
      case LeadStatus.qualified:
        return AppColors.good;
      case LeadStatus.closed:
        return AppColors.muted;
    }
  }

  String _statusLabel(LeadStatus s) {
    switch (s) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.qualified:
        return 'Qualified';
      case LeadStatus.closed:
        return 'Closed';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(lead.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
                Text(lead.name,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_statusLabel(lead.status),
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(lead.email,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.home_outlined,
                    size: 12, color: AppColors.accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(lead.propertyInterest,
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
                Text(_timeAgo(lead.createdAt),
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
