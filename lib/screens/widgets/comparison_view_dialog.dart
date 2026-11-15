import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/instagram_reel.dart';

class ComparisonViewDialog extends StatelessWidget {
  final InstagramReel reel;

  const ComparisonViewDialog({super.key, required this.reel});

  static void show(BuildContext context, InstagramReel reel) {
    showDialog(
      context: context,
      builder: (_) => ComparisonViewDialog(reel: reel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows_rounded, color: AppColors.analyticsPurple, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Original vs Edited Delta',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Comparing source Instagram metrics with user workspace overrides for @${reel.username}\'s reel.',
              style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
            ),
            const SizedBox(height: 16),

            // Comparison Table
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground.withOpacity(0.5) : AppColors.lightSurface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Metric', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('Original', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                        Expanded(flex: 2, child: Text('Edited', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.analyticsPurple))),
                        Expanded(flex: 2, child: Text('Delta', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  _buildRow('Views', reel.originalViews, reel.displayViews),
                  _buildRow('Likes', reel.originalLikes, reel.displayLikes),
                  _buildRow('Comments', reel.originalComments, reel.displayComments),
                  _buildRow('Shares', reel.originalShares, reel.displayShares),
                  _buildRow('Saves', reel.originalSaves, reel.displaySaves),
                  _buildRow('Reach', reel.originalReach, reel.displayReach),
                  _buildErRow(
                    'Engage Rate',
                    reel.originalEngagementRate,
                    reel.displayEngagementRate,
                  ),
                ],
              ),
            ),

            if (reel.customMetricName != null && reel.customMetricValue != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.analyticsPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.analyticsPurple, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${reel.customMetricName}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    Text(
                      reel.customMetricValue!,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.analyticsPurple),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close Comparison', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, int original, int edited) {
    int diff = edited - original;
    bool isPositive = diff > 0;
    bool isZero = diff == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: Text(Formatters.compact(original), style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted))),
          Expanded(flex: 2, child: Text(Formatters.compact(edited), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          Expanded(
            flex: 2,
            child: Text(
              isZero ? '0' : (isPositive ? '+${Formatters.compact(diff)}' : Formatters.compact(diff)),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isZero
                    ? AppColors.darkTextMuted
                    : (isPositive ? AppColors.deltaPositive : AppColors.deltaNegative),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErRow(String label, double original, double edited) {
    double diff = edited - original;
    bool isPositive = diff > 0;
    bool isZero = diff == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: Text(Formatters.percentage(original), style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted))),
          Expanded(flex: 2, child: Text(Formatters.percentage(edited), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          Expanded(
            flex: 2,
            child: Text(
              isZero ? '0.0%' : (isPositive ? '+${diff.toStringAsFixed(1)}%' : '${diff.toStringAsFixed(1)}%'),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isZero
                    ? AppColors.darkTextMuted
                    : (isPositive ? AppColors.deltaPositive : AppColors.deltaNegative),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
