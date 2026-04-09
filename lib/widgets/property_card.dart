import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme/theme.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Title and Signal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.meta,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: property.getSignalColor().withOpacity(0.15),
                      border: Border.all(
                        color: property.getSignalColor(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.signal,
                      style: TextStyle(
                        color: property.getSignalColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Price and Quick Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        property.priceFormatted,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent2,
                        ),
                      ),
                    ],
                  ),
                  _QuickStat(
                    label: 'Risk',
                    value: property.risk,
                    color: property.getRiskColor(),
                  ),
                  _QuickStat(
                    label: 'Growth',
                    value: property.growth,
                    color: AppColors.accent,
                  ),
                  _QuickStat(
                    label: 'Cap Rate',
                    value: property.capRate,
                    color: AppColors.accent2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
