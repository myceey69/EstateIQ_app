import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/theme.dart';

class ApiAccessScreen extends StatefulWidget {
  const ApiAccessScreen({super.key});

  @override
  State<ApiAccessScreen> createState() => _ApiAccessScreenState();
}

class _ApiAccessScreenState extends State<ApiAccessScreen> {
  final List<_ApiKey> _keys = [
    const _ApiKey(
      id: 'key-1',
      name: 'Production Key',
      key: 'sk_live_xxxx...4a2b',
      createdAt: 'Jan 1, 2025',
      lastUsed: '2 hours ago',
      isActive: true,
    ),
    const _ApiKey(
      id: 'key-2',
      name: 'Development Key',
      key: 'sk_dev_xxxx...8f3c',
      createdAt: 'Dec 15, 2024',
      lastUsed: '1 day ago',
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Access'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usage Stats
            Text('Usage This Month',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _metricCard(
                        'API Calls', '42,817', AppColors.accent)),
                const SizedBox(width: 10),
                Expanded(
                    child: _metricCard(
                        'Rate Limit', '100K/mo', AppColors.good)),
                const SizedBox(width: 10),
                Expanded(
                    child: _metricCard(
                        'Endpoints', '8 used', AppColors.accent2)),
              ],
            ),
            const SizedBox(height: 16),

            // Usage chart
            _sectionHeader(context, 'Daily Calls (7 days)'),
            const SizedBox(height: 12),
            _card(
              child: SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: 9000,
                    barGroups: _buildBars(),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.line.withOpacity(0.3),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) =>
                          const FlLine(color: Colors.transparent),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = [
                              'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                            ];
                            final i = v.toInt();
                            return i < days.length
                                ? Text(days[i],
                                    style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 9))
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text(
                            '${(v / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 9),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // API Keys
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('API Keys',
                    style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: _showCreateKeyDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('New Key',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._keys.map((key) => _ApiKeyCard(
                  apiKey: key,
                  onCopy: (value) async {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        backgroundColor: AppColors.good,
                      ),
                    );
                  },
                  onRevoke: () => setState(() => _keys.remove(key)),
                )),
            const SizedBox(height: 16),

            // Documentation links
            _sectionHeader(context, 'Documentation'),
            const SizedBox(height: 12),
            ...[
              const _DocLink(
                  'Search API',
                  Icons.search_outlined,
                  '/v1/search — Find properties by location, price, and criteria'),
              const _DocLink(
                  'Valuation API',
                  Icons.auto_awesome_outlined,
                  '/v1/valuation — Get AI-powered property valuations'),
              const _DocLink(
                  'Market Data API',
                  Icons.trending_up_outlined,
                  '/v1/market — Access regional market trends and forecasts'),
              const _DocLink(
                  'Webhooks',
                  Icons.webhook_outlined,
                  '/v1/webhooks — Subscribe to real-time property events'),
            ].map((doc) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(doc.icon, color: AppColors.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.title,
                                style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Text(doc.description,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: AppColors.muted, size: 14),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBars() {
    const data = [5200, 6800, 7100, 4900, 8200, 3400, 7700];
    return List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].toDouble(),
            color: AppColors.accent,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  void _showCreateKeyDialog() {
    final nameCtrl = TextEditingController();
    final permissions = <String, bool>{
      'Search': true,
      'Valuation': true,
      'Market Data': false,
      'Webhooks': false,
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg1,
        title: const Text('Create New API Key',
            style: TextStyle(color: AppColors.text)),
        content: StatefulBuilder(builder: (ctx2, ss) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.text),
                decoration:
                    const InputDecoration(hintText: 'Key Name'),
              ),
              const SizedBox(height: 12),
              const Text('Permissions',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 6),
              ...permissions.entries.map(
                (e) => CheckboxListTile(
                  value: e.value,
                  onChanged: (v) =>
                      ss(() => permissions[e.key] = v ?? false),
                  title: Text(e.key,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 13)),
                  activeColor: AppColors.accent,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _keys.add(_ApiKey(
                    id: 'key-${_keys.length + 1}',
                    name: name,
                    key: 'sk_new_xxxx...${name.hashCode.abs() % 9999}',
                    createdAt: 'Today',
                    lastUsed: 'Never',
                    isActive: true,
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('API key created!'),
                      backgroundColor: AppColors.good),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  fontSize: 14)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _ApiKey {
  final String id;
  final String name;
  final String key;
  final String createdAt;
  final String lastUsed;
  final bool isActive;

  const _ApiKey({
    required this.id,
    required this.name,
    required this.key,
    required this.createdAt,
    required this.lastUsed,
    required this.isActive,
  });
}

class _DocLink {
  final String title;
  final IconData icon;
  final String description;
  const _DocLink(this.title, this.icon, this.description);
}

class _ApiKeyCard extends StatefulWidget {
  final _ApiKey apiKey;
  final ValueChanged<String> onCopy;
  final VoidCallback onRevoke;

  const _ApiKeyCard({
    required this.apiKey,
    required this.onCopy,
    required this.onRevoke,
  });

  @override
  State<_ApiKeyCard> createState() => _ApiKeyCardState();
}

class _ApiKeyCardState extends State<_ApiKeyCard> {
  bool _visible = false;

  String _maskKey(String value) {
    if (value.length <= 8) return '••••••••';
    final last = value.substring(value.length - 4);
    return '••••••••••••$last';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              const Icon(Icons.key_outlined,
                  color: AppColors.accent, size: 16),
              const SizedBox(width: 8),
              Text(widget.apiKey.name,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.good.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Active',
                    style: TextStyle(
                        color: AppColors.good,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _visible ? widget.apiKey.key : _maskKey(widget.apiKey.key),
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.muted,
                  size: 18,
                ),
                onPressed: () => setState(() => _visible = !_visible),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: _visible ? 'Hide key' : 'Show key',
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined,
                    color: AppColors.accent, size: 18),
                onPressed: () => widget.onCopy(widget.apiKey.key),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Created: ${widget.apiKey.createdAt}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 10)),
              const SizedBox(width: 12),
              Text('Last used: ${widget.apiKey.lastUsed}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 10)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.bg1,
                      title: const Text('Revoke Key?',
                          style: TextStyle(color: AppColors.text)),
                      content: Text(
                          'Are you sure you want to revoke "${widget.apiKey.name}"?',
                          style:
                              const TextStyle(color: AppColors.muted)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onRevoke();
                            Navigator.pop(context);
                          },
                          child: const Text('Revoke',
                              style:
                                  TextStyle(color: AppColors.bad)),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text('Revoke',
                    style: TextStyle(
                        color: AppColors.bad, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
