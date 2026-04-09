import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../theme/theme.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({Key? key}) : super(key: key);

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: AppColors.bad),
              SizedBox(height: 16),
              Text('Access Denied',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Admin role required to access this area.',
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Subscriptions'),
            Tab(text: 'Listings'),
            Tab(text: 'Data Sources'),
            Tab(text: 'Audit Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _UsersTab(),
          _SubscriptionsTab(),
          _ListingsTab(),
          _DataSourcesTab(),
          _AuditLogTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Users Tab
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    // Hardcode the demo users since _users is private
    final demoUsers = [
      _UserRow(
          name: 'Alex Buyer',
          email: 'buyer@demo.com',
          role: 'Buyer',
          plan: 'Basic',
          roleColor: AppColors.accent2,
          planColor: AppColors.accent2),
      _UserRow(
          name: 'Morgan Investor',
          email: 'investor@demo.com',
          role: 'Investor',
          plan: 'Pro',
          roleColor: AppColors.good,
          planColor: AppColors.accent),
      _UserRow(
          name: 'Sam Agent',
          email: 'agent@demo.com',
          role: 'Agent',
          plan: 'Pro',
          roleColor: AppColors.warn,
          planColor: AppColors.accent),
      _UserRow(
          name: 'Admin User',
          email: 'admin@demo.com',
          role: 'Admin',
          plan: 'Enterprise',
          roleColor: AppColors.bad,
          planColor: AppColors.warn),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demoUsers.length,
      itemBuilder: (ctx, i) {
        final u = demoUsers[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent.withOpacity(0.2),
                radius: 20,
                child: Text(u.name[0],
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    Text(u.email,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              _badge(u.role, u.roleColor),
              const SizedBox(width: 6),
              _badge(u.plan, u.planColor),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                color: AppColors.bg1,
                icon: const Icon(Icons.more_vert,
                    color: AppColors.muted, size: 18),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Role',
                          style: TextStyle(color: AppColors.text))),
                  const PopupMenuItem(
                      value: 'suspend',
                      child: Text('Suspend',
                          style: TextStyle(color: AppColors.bad))),
                ],
                onSelected: (v) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${v == 'edit' ? 'Edit Role' : 'Suspend'} for ${u.name}'),
                        backgroundColor: AppColors.warn),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _UserRow {
  final String name;
  final String email;
  final String role;
  final String plan;
  final Color roleColor;
  final Color planColor;
  const _UserRow({
    required this.name,
    required this.email,
    required this.role,
    required this.plan,
    required this.roleColor,
    required this.planColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscriptions Tab
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionsTab extends StatelessWidget {
  const _SubscriptionsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Overview',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _revenueCard(
                      'Monthly Revenue', '\$62,450', AppColors.good)),
              const SizedBox(width: 10),
              Expanded(
                  child: _revenueCard(
                      'Churn Rate', '2.1%', AppColors.warn)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Plan Distribution',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          _planRow('Basic', 430, AppColors.accent2),
          _planRow('Professional', 320, AppColors.accent),
          _planRow('Enterprise', 97, AppColors.warn),
        ],
      ),
    );
  }

  Widget _revenueCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _planRow(String name, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(name,
              style: const TextStyle(
                  color: AppColors.text, fontSize: 13)),
          const Spacer(),
          Text('$count subscribers',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12)),
          const SizedBox(width: 8),
          Text('$count',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Listings Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ListingsTab extends StatelessWidget {
  const _ListingsTab();

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingProvider>().listings;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (ctx, i) {
        final l = listings[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
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
                    Text(l.title,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    Text(l.address,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Listing approved'),
                          backgroundColor: AppColors.good),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.good.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Approve',
                          style: TextStyle(
                              color: AppColors.good,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Listing rejected'),
                          backgroundColor: AppColors.bad),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bad.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(
                              color: AppColors.bad,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Sources Tab
// ─────────────────────────────────────────────────────────────────────────────
class _DataSourcesTab extends StatefulWidget {
  const _DataSourcesTab();

  @override
  State<_DataSourcesTab> createState() => _DataSourcesTabState();
}

class _DataSourcesTabState extends State<_DataSourcesTab> {
  final List<_DataSource> _sources = [
    _DataSource('MLS Feed', Icons.home_work_outlined,
        'MLS Bay Area', '2 hours ago', true),
    _DataSource('Zillow API', Icons.search_outlined,
        'Zillow Group', '1 hour ago', true),
    _DataSource('Walk Score', Icons.directions_walk_outlined,
        'Walk Score Inc', '6 hours ago', true),
    _DataSource('Census Data', Icons.bar_chart_outlined,
        'US Census Bureau', '24 hours ago', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sources.length,
      itemBuilder: (ctx, i) {
        final s = _sources[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bg1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(s.icon, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    Text('${s.provider} · Last sync: ${s.lastSync}',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 10)),
                  ],
                ),
              ),
              Switch(
                value: s.active,
                onChanged: (v) => setState(() => s.active = v),
                activeColor: AppColors.good,
                inactiveThumbColor: AppColors.muted,
                inactiveTrackColor: AppColors.line,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DataSource {
  final String name;
  final IconData icon;
  final String provider;
  final String lastSync;
  bool active;

  _DataSource(
      this.name, this.icon, this.provider, this.lastSync, this.active);
}

// ─────────────────────────────────────────────────────────────────────────────
// Audit Log Tab
// ─────────────────────────────────────────────────────────────────────────────
class _AuditLogTab extends StatelessWidget {
  const _AuditLogTab();

  static const _entries = [
    _AuditEntry(
        time: '2 min ago',
        user: 'admin@demo.com',
        action: 'Updated listing status → Active',
        resource: 'lst-1'),
    _AuditEntry(
        time: '15 min ago',
        user: 'agent@demo.com',
        action: 'Created new listing',
        resource: 'lst-3'),
    _AuditEntry(
        time: '1 hour ago',
        user: 'buyer@demo.com',
        action: 'Added property to watchlist',
        resource: 'prop-4'),
    _AuditEntry(
        time: '3 hours ago',
        user: 'investor@demo.com',
        action: 'Generated Comparables Report',
        resource: 'report-r1'),
    _AuditEntry(
        time: '1 day ago',
        user: 'admin@demo.com',
        action: 'Suspended user account',
        resource: 'user-xxx'),
    _AuditEntry(
        time: '2 days ago',
        user: 'agent@demo.com',
        action: 'Upgraded to Professional plan',
        resource: 'subscription'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.line, height: 1),
      itemBuilder: (ctx, i) {
        final e = _entries[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.history,
                    color: AppColors.accent, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.action,
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(e.user,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 10)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(e.resource,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(e.time,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

class _AuditEntry {
  final String time;
  final String user;
  final String action;
  final String resource;

  const _AuditEntry({
    required this.time,
    required this.user,
    required this.action,
    required this.resource,
  });
}
