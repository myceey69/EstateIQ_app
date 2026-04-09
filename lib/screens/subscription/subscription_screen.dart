import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final currentPlan = user?.plan ?? SubscriptionPlan.free;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscription Plans'),
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
                // Header
                Center(
                  child: Column(
                    children: [
                      const Text('Choose Your Plan',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.4)),
                        ),
                        child: Text(
                          'Current: ${_planLabel(currentPlan)}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Plan cards
                _PlanCard(
                  name: 'Basic',
                  price: '\$29',
                  features: const [
                    'Up to 50 property searches/mo',
                    'Basic AI valuation',
                    'Email alerts',
                    'Comparables report',
                    '1 saved search',
                  ],
                  color: AppColors.accent2,
                  plan: SubscriptionPlan.basic,
                  currentPlan: currentPlan,
                  isPopular: false,
                  onUpgrade: () =>
                      _showCheckout(context, auth, SubscriptionPlan.basic),
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  name: 'Professional',
                  price: '\$79',
                  features: const [
                    'Unlimited searches',
                    'Advanced AI analytics',
                    'Real-time alerts',
                    'All reports',
                    'ROI Calculator',
                    'Market analysis',
                    '10 saved searches',
                  ],
                  color: AppColors.accent,
                  plan: SubscriptionPlan.professional,
                  currentPlan: currentPlan,
                  isPopular: true,
                  onUpgrade: () => _showCheckout(
                      context, auth, SubscriptionPlan.professional),
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  name: 'Enterprise',
                  price: '\$199',
                  features: const [
                    'Everything in Pro',
                    'API access',
                    'Portfolio analytics',
                    'Lead management',
                    'Custom reports',
                    'Priority support',
                    'Unlimited saved searches',
                  ],
                  color: AppColors.warn,
                  plan: SubscriptionPlan.enterprise,
                  currentPlan: currentPlan,
                  isPopular: false,
                  onUpgrade: () => _showCheckout(
                      context, auth, SubscriptionPlan.enterprise),
                ),
                const SizedBox(height: 24),

                // Features comparison table
                Text('Features Comparison',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _ComparisonTable(),
                const SizedBox(height: 24),

                // FAQ
                Text('FAQ',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const _FAQItem(
                  question: 'Can I cancel anytime?',
                  answer:
                      'Yes! You can cancel your subscription at any time. Your plan will remain active until the end of your billing period.',
                ),
                const _FAQItem(
                  question: 'Will I be charged immediately?',
                  answer:
                      'Your card will be charged when you confirm the upgrade. Subsequent charges occur on the same day each month.',
                ),
                const _FAQItem(
                  question: 'Can I switch plans?',
                  answer:
                      'Absolutely. You can upgrade or downgrade your plan at any time. Prorated credits are applied for mid-cycle changes.',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _planLabel(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.professional:
        return 'Professional';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  void _showCheckout(
      BuildContext context, AuthProvider auth, SubscriptionPlan plan) {
    String planName;
    String price;
    switch (plan) {
      case SubscriptionPlan.basic:
        planName = 'Basic';
        price = '\$29/mo';
        break;
      case SubscriptionPlan.professional:
        planName = 'Professional';
        price = '\$79/mo';
        break;
      case SubscriptionPlan.enterprise:
        planName = 'Enterprise';
        price = '\$199/mo';
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upgrade to $planName',
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$planName Plan',
                            style: const TextStyle(
                                color: AppColors.text, fontSize: 14)),
                        Text(price,
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card_outlined,
                        color: AppColors.accent2, size: 20),
                    const SizedBox(width: 10),
                    const Text('Card ending in 4242',
                        style: TextStyle(
                            color: AppColors.text, fontSize: 14)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.good.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Mock',
                          style: TextStyle(
                              color: AppColors.good,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (auth.currentUser != null) {
                      auth.updateProfile(
                          auth.currentUser!.copyWith(plan: plan));
                    }
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.bg1,
                        title: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.good),
                            SizedBox(width: 8),
                            Text('Upgrade Successful!',
                                style: TextStyle(color: AppColors.text)),
                          ],
                        ),
                        content: Text(
                            'Welcome to $planName! Your new features are now active.',
                            style: const TextStyle(
                                color: AppColors.muted)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Great!',
                                style: TextStyle(
                                    color: AppColors.accent)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Confirm Upgrade'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final List<String> features;
  final Color color;
  final SubscriptionPlan plan;
  final SubscriptionPlan currentPlan;
  final bool isPopular;
  final VoidCallback onUpgrade;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    required this.color,
    required this.plan,
    required this.currentPlan,
    required this.isPopular,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = plan == currentPlan;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCurrent
                ? color
                : color.withOpacity(0.3),
            width: isCurrent ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Popular',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Current Plan',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const Text('/mo',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: color, size: 14),
                    const SizedBox(width: 8),
                    Text(f,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color.withOpacity(0.3)),
                      foregroundColor: color,
                    ),
                    child: const Text('Current Plan'),
                  )
                : ElevatedButton(
                    onPressed: onUpgrade,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: color),
                    child: const Text('Upgrade',
                        style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      ['Property Searches', '50/mo', 'Unlimited', 'Unlimited'],
      ['AI Valuation', 'Basic', 'Advanced', 'Advanced'],
      ['Alerts', 'Email', 'Real-time', 'Real-time'],
      ['Reports', 'Comps', 'All', 'All + Custom'],
      ['API Access', '✗', '✗', '✓'],
      ['Lead Mgmt', '✗', '✗', '✓'],
      ['Support', 'Email', 'Priority', '24/7'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
            ),
            children: ['Feature', 'Basic', 'Pro', 'Enterprise']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: Text(h,
                          style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          ...features.map(
            (row) => TableRow(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.line, width: 0.5)),
              ),
              children: row
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(e.value,
                            style: TextStyle(
                                color: e.key == 0
                                    ? AppColors.text
                                    : e.value == '✓'
                                        ? AppColors.good
                                        : e.value == '✗'
                                            ? AppColors.bad
                                            : AppColors.muted,
                                fontSize: 11)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.question,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            trailing: Icon(
              _expanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.muted,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(widget.answer,
                  style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.5)),
            ),
        ],
      ),
    );
  }
}
