import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';
import '../theme/theme.dart';
import 'detail_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  // ── Match score algorithm ─────────────────────────────────────────────────
  int _matchScore(Property p, dynamic user) {
    int score = 0;
    final prefs = user.preferences;

    // Budget match
    if (p.price >= prefs.budgetMin && p.price <= prefs.budgetMax) {
      score += 20;
    } else if (p.price >= (prefs.budgetMin * 0.8).toInt() &&
        p.price <= (prefs.budgetMax * 1.2).toInt()) {
      score += 10;
    }

    // Risk match
    if (prefs.riskTolerance.toLowerCase() == p.risk.toLowerCase()) {
      score += 25;
    }

    // High neighborhood scores
    final n = p.neighborhood;
    if (n.safety > 80) score += 10;
    if (n.schools > 80) score += 10;
    if (n.commute > 80) score += 10;
    if (n.amenities > 80) score += 10;
    if (n.stability > 80) score += 10;

    return score.clamp(0, 100);
  }

  String _whyRecommended(Property p, dynamic user) {
    final prefs = user.preferences;
    final reasons = <String>[];

    if (p.price >= prefs.budgetMin && p.price <= prefs.budgetMax) {
      reasons.add('Within your budget');
    }
    if (prefs.riskTolerance.toLowerCase() == p.risk.toLowerCase()) {
      reasons.add('Matches ${prefs.riskTolerance} risk tolerance');
    }
    if (p.neighborhood.schools > 80) reasons.add('Top-rated schools');
    if (p.neighborhood.commute > 80) reasons.add('Excellent commute');
    if (p.growth == 'High') reasons.add('High growth potential');
    if (p.neighborhood.safety > 80) reasons.add('Safe neighborhood');
    if (reasons.isEmpty) reasons.add('Strong investment fundamentals');

    return reasons.take(3).join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, PropertyProvider>(
        builder: (context, auth, propertyProvider, _) {
          if (!auth.isLoggedIn) {
            return const Center(
              child: Text('Log in to see personalized recommendations',
                  style: TextStyle(color: AppColors.muted)),
            );
          }

          final user = auth.currentUser!;
          final all = propertyProvider.allProperties;

          // Score and rank all properties
          final scored = all.map((p) {
            return _ScoredProperty(property: p, score: _matchScore(p, user));
          }).toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          final top5 = scored.take(5).toList();

          return Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Container(
                color: AppColors.bg1,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recommended for You',
                            style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                          'Hi ${user.name.split(' ').first}, based on your preferences',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Recommendation list ───────────────────────────────
              Expanded(
                child: top5.isEmpty
                    ? const Center(
                        child: Text('No recommendations yet',
                            style: TextStyle(color: AppColors.muted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: top5.length,
                        itemBuilder: (context, i) {
                          final sp = top5[i];
                          final reason = _whyRecommended(sp.property, user);
                          return _RecommendationCard(
                            scoredProperty: sp,
                            reason: reason,
                            rank: i + 1,
                            onTap: () {
                              propertyProvider.setSelectedProperty(sp.property);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DetailScreen()),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ScoredProperty {
  final Property property;
  final int score;

  _ScoredProperty({required this.property, required this.score});
}

// ── RecommendationCard ────────────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final _ScoredProperty scoredProperty;
  final String reason;
  final int rank;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.scoredProperty,
    required this.reason,
    required this.rank,
    required this.onTap,
  });

  Color _matchColor(int score) {
    if (score >= 70) return AppColors.good;
    if (score >= 50) return AppColors.warn;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    final p = scoredProperty.property;
    final score = scoredProperty.score;

    return Card(
      color: AppColors.bg1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank + match score
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _matchColor(score).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _matchColor(score).withOpacity(0.5)),
                    ),
                    child: Text(
                      '$score% match',
                      style: TextStyle(
                          color: _matchColor(score),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title + signal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(p.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.getSignalColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.getSignalColor()),
                    ),
                    child: Text(p.signal,
                        style: TextStyle(
                            color: p.getSignalColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Price
              Text(
                p.priceFormatted,
                style: const TextStyle(
                    color: AppColors.accent2,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Why recommended
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.good.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.good.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.good, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                            color: AppColors.good, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
