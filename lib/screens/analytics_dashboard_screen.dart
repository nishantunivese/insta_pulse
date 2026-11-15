import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/instagram_profile.dart';
import '../models/instagram_reel.dart';
import '../providers/profile_provider.dart';
import '../providers/reels_provider.dart';
import 'widgets/analytics_editor_sheet.dart';
import 'widgets/comparison_view_dialog.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/username_search_dialog.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final analyticsState = ref.watch(analyticsProvider);
    final profileState = ref.watch(profileProvider);
    final reelsState = ref.watch(reelsProvider);

    final stats = analyticsState.stats;

    final totalProfiles = stats['totalProfiles'] as int? ?? profileState.profiles.length;
    final totalReels = stats['totalReels'] as int? ?? reelsState.reels.length;
    final totalOrigViews = stats['totalOriginalViews'] as int? ?? 0;
    final totalEditedViews = stats['totalEditedViews'] as int? ?? 0;
    final viewsDelta = stats['viewsDelta'] as int? ?? 0;
    final avgOrigER = stats['avgOriginalER'] as double? ?? 0.0;
    final avgEditedER = stats['avgEditedER'] as double? ?? 0.0;
    final editedCount = stats['editedReelsCount'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.insights_rounded, color: AppColors.analyticsPurple, size: 24),
            SizedBox(width: 8),
            Text('Analytics Studio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primaryBlue),
            tooltip: 'Import Profile',
            onPressed: () => UsernameSearchDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsProvider.notifier).refreshStats();
              ref.read(reelsProvider.notifier).loadReels();
              ref.read(profileProvider.notifier).loadProfiles();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(analyticsProvider.notifier).refreshStats();
          await ref.read(reelsProvider.notifier).loadReels();
          await ref.read(profileProvider.notifier).loadProfiles();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner: Local Workspace Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.analyticsPurple.withOpacity(0.18),
                      AppColors.primaryBlue.withOpacity(0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.analyticsPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: AppColors.analyticsPurple, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reels Performance & Analytics Workspace',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Track $totalProfiles imported profiles & $totalReels public reels. $editedCount customized locally.',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Executive Metrics 2x2 Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'Total Original Views',
                      value: Formatters.compact(totalOrigViews),
                      subtitle: 'Source Instagram metrics',
                      icon: Icons.visibility_outlined,
                      accentColor: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'Total Edited Views',
                      value: Formatters.compact(totalEditedViews),
                      subtitle: viewsDelta != 0
                          ? 'Delta: ${viewsDelta > 0 ? '+' : ''}${Formatters.compact(viewsDelta)}'
                          : 'Matches original',
                      icon: Icons.tune,
                      accentColor: AppColors.analyticsPurple,
                      isDeltaPositive: viewsDelta >= 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'Avg Engagement Rate',
                      value: Formatters.percentage(avgEditedER),
                      subtitle: 'Orig: ${Formatters.percentage(avgOrigER)}',
                      icon: Icons.bolt_rounded,
                      accentColor: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'Imported Creators',
                      value: '$totalProfiles Profiles',
                      subtitle: '$totalReels reels analyzed',
                      icon: Icons.people_alt_outlined,
                      accentColor: AppColors.deltaPositive,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Profile Management Section
              Row(
                children: [
                  const Text(
                    'Imported Profiles & Creators',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => UsernameSearchDialog.show(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Import', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (profileState.profiles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.person_search_outlined, size: 36, color: AppColors.darkTextMuted),
                        const SizedBox(height: 8),
                        const Text('No profiles imported yet'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => UsernameSearchDialog.show(context),
                          child: const Text('Search & Import Username'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...profileState.profiles.map((p) => _buildProfileCard(context, ref, p)),

              const SizedBox(height: 24),

              // Reels Analytics Management Table
              Row(
                children: [
                  const Text(
                    'Reels Analytics Management',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    '${reelsState.reels.length} Reels',
                    style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (reelsState.reels.isEmpty)
                const Center(child: Text('No reels found'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reelsState.reels.length,
                  itemBuilder: (ctx, i) {
                    final reel = reelsState.reels[i];
                    return _buildReelRowCard(context, reel);
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    bool? isDeltaPositive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDeltaPositive == null
                  ? AppColors.darkTextMuted
                  : (isDeltaPositive ? AppColors.deltaPositive : AppColors.deltaNegative),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, InstagramProfile p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.isEdited ? AppColors.editedBadge : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(p.profilePicUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${p.username}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    if (p.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 14),
                    ],
                    if (p.isEdited) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.editedBadge.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CUSTOM', style: TextStyle(color: AppColors.editedBadge, fontSize: 8.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                Text(
                  p.displayFullName,
                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.compact(p.displayFollowers)} followers • ${p.postsCount} posts',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Actions
          IconButton(
            icon: const Icon(Icons.edit_note, size: 22),
            tooltip: 'Edit Local Profile',
            onPressed: () => ProfileEditDialog.show(context, p),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.likeRed),
            tooltip: 'Delete Profile',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete @${p.username}?'),
                  content: const Text('This will remove this profile and all its imported reels from your workspace.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.likeRed),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(profileProvider.notifier).deleteProfile(p.id);
                await ref.read(reelsProvider.notifier).loadReels();
                await ref.read(analyticsProvider.notifier).refreshStats();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReelRowCard(BuildContext context, InstagramReel reel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reel.isEdited ? AppColors.editedBadge : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              reel.thumbnailUrl,
              width: 55,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 55,
                height: 75,
                color: Colors.grey[900],
                child: const Icon(Icons.videocam, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${reel.username}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const Spacer(),
                    if (reel.isEdited)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.editedBadge.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.editedBadge, width: 0.8),
                        ),
                        child: const Text(
                          'EDITED',
                          style: TextStyle(
                            color: AppColors.editedBadge,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reel.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Views: ${Formatters.compact(reel.displayViews)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Likes: ${Formatters.compact(reel.displayLikes)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.darkTextMuted),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ER: ${Formatters.percentage(reel.displayEngagementRate)}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.analyticsPurple, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => AnalyticsEditorSheet.show(context, reel),
                      icon: const Icon(Icons.edit, size: 13),
                      label: const Text('Edit Analytics', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => ComparisonViewDialog.show(context, reel),
                      icon: const Icon(Icons.compare_arrows, size: 13),
                      label: const Text('Compare', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: AppColors.analyticsPurple),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
