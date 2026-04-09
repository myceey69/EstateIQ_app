import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;

  const ScoreBar({
    Key? key,
    required this.label,
    required this.score,
    this.maxScore = 100,
  }) : super(key: key);

  Color get _scoreColor {
    if (score >= 80) return AppColors.good;
    if (score >= 60) return AppColors.accent2;
    if (score >= 40) return AppColors.warn;
    return AppColors.bad;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$score/$maxScore',
              style: TextStyle(
                color: _scoreColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score / maxScore,
            minHeight: 6,
            backgroundColor: AppColors.panel,
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
          ),
        ),
      ],
    );
  }
}
