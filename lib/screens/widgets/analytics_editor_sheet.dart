import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/instagram_reel.dart';
import '../../providers/reels_provider.dart';
import 'comparison_view_dialog.dart';

class AnalyticsEditorSheet extends ConsumerStatefulWidget {
  final InstagramReel reel;

  const AnalyticsEditorSheet({
    super.key,
    required this.reel,
  });

  static Future<void> show(BuildContext context, InstagramReel reel) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnalyticsEditorSheet(reel: reel),
    );
  }

  @override
  ConsumerState<AnalyticsEditorSheet> createState() => _AnalyticsEditorSheetState();
}

class _AnalyticsEditorSheetState extends ConsumerState<AnalyticsEditorSheet> {
  late TextEditingController _viewsController;
  late TextEditingController _likesController;
  late TextEditingController _commentsController;
  late TextEditingController _sharesController;
  late TextEditingController _savesController;
  late TextEditingController _reachController;
  late TextEditingController _watchTimeController;
  late TextEditingController _customNameController;
  late TextEditingController _customValController;
  late TextEditingController _notesController;

  late double _calculatedER;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.reel;
    _viewsController = TextEditingController(text: r.displayViews.toString());
    _likesController = TextEditingController(text: r.displayLikes.toString());
    _commentsController = TextEditingController(text: r.displayComments.toString());
    _sharesController = TextEditingController(text: r.displayShares.toString());
    _savesController = TextEditingController(text: r.displaySaves.toString());
    _reachController = TextEditingController(text: r.displayReach.toString());
    _watchTimeController = TextEditingController(text: r.displayWatchTime);
    _customNameController = TextEditingController(text: r.customMetricName ?? 'Brand ROI Score');
    _customValController = TextEditingController(text: r.customMetricValue ?? '4.8x');
    _notesController = TextEditingController(text: r.notes ?? '');

    _calculatedER = r.displayEngagementRate;

    _viewsController.addListener(_recalcER);
    _likesController.addListener(_recalcER);
    _commentsController.addListener(_recalcER);
    _sharesController.addListener(_recalcER);
    _savesController.addListener(_recalcER);
  }

  void _recalcER() {
    final v = int.tryParse(_viewsController.text) ?? 0;
    final l = int.tryParse(_likesController.text) ?? 0;
    final c = int.tryParse(_commentsController.text) ?? 0;
    final s = int.tryParse(_sharesController.text) ?? 0;
    final sv = int.tryParse(_savesController.text) ?? 0;

    final er = InstagramReel.calculateEngagementRate(
      views: v,
      likes: l,
      comments: c,
      shares: s,
      saves: sv,
    );
    setState(() => _calculatedER = er);
  }

  @override
  void dispose() {
    _viewsController.dispose();
    _likesController.dispose();
    _commentsController.dispose();
    _sharesController.dispose();
    _savesController.dispose();
    _reachController.dispose();
    _watchTimeController.dispose();
    _customNameController.dispose();
    _customValController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final v = int.tryParse(_viewsController.text) ?? widget.reel.originalViews;
    final l = int.tryParse(_likesController.text) ?? widget.reel.originalLikes;
    final c = int.tryParse(_commentsController.text) ?? widget.reel.originalComments;
    final s = int.tryParse(_sharesController.text) ?? widget.reel.originalShares;
    final sv = int.tryParse(_savesController.text) ?? widget.reel.originalSaves;
    final r = int.tryParse(_reachController.text) ?? widget.reel.originalReach;

    await ref.read(reelsProvider.notifier).saveEditedAnalytics(
          reelId: widget.reel.id,
          profileId: widget.reel.profileId,
          editedViews: v,
          editedLikes: l,
          editedComments: c,
          editedShares: s,
          editedSaves: sv,
          editedReach: r,
          editedWatchTime: _watchTimeController.text.trim(),
          editedEngagementRate: _calculatedER,
          customMetricName: _customNameController.text.trim(),
          customMetricValue: _customValController.text.trim(),
          notes: _notesController.text.trim(),
        );

    await ref.read(analyticsProvider.notifier).refreshStats();

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.deltaPositive,
          content: Text('✅ Edited analytics saved permanently to local database!'),
        ),
      );
    }
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Original Data?'),
        content: const Text(
          'This will remove all custom overrides and restore verified imported Instagram metrics for this reel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.likeRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(reelsProvider.notifier).resetEditedAnalytics(widget.reel.id);
      await ref.read(analyticsProvider.notifier).refreshStats();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primaryBlue,
            content: Text('Restored original source metrics.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.analyticsPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppColors.analyticsPurple, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reels Analytics Editor',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      Text(
                        'Edit local metrics & simulate performance',
                        style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                      ),
                    ],
                  ),
                ),
                // Compare Button
                OutlinedButton.icon(
                  onPressed: () {
                    ComparisonViewDialog.show(context, widget.reel);
                  },
                  icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                  label: const Text('Compare', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: const BorderSide(color: AppColors.analyticsPurple),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Scrollable Editor Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reel Snapshot Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.reel.isEdited ? AppColors.editedBadge : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.reel.thumbnailUrl,
                            width: 50,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 65,
                              color: Colors.grey[800],
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
                                    '@${widget.reel.username}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  if (widget.reel.isEdited)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.editedBadge.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.editedBadge, width: 0.8),
                                      ),
                                      child: const Text(
                                        'EDITED RECORD',
                                        style: TextStyle(
                                          color: AppColors.editedBadge,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ORIGINAL SOURCE',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.reel.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Orig Views: ${Formatters.compact(widget.reel.originalViews)} • Orig Likes: ${Formatters.compact(widget.reel.originalLikes)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Calculated Engagement Rate Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.analyticsPurple.withOpacity(0.2),
                          AppColors.primaryBlue.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.analyticsPurple.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.analyticsPurple, size: 22),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calculated Engagement Rate',
                              style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                            ),
                            Text(
                              Formatters.percentage(_calculatedER),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.analyticsPurple),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Orig: ${Formatters.percentage(widget.reel.originalEngagementRate)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Core Metrics (Editable)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 12),

                  // Views & Reach Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Views',
                          controller: _viewsController,
                          icon: Icons.visibility_outlined,
                          original: widget.reel.originalViews,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Reach',
                          controller: _reachController,
                          icon: Icons.radar_outlined,
                          original: widget.reel.originalReach,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Likes & Comments Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Likes',
                          controller: _likesController,
                          icon: Icons.favorite_border,
                          original: widget.reel.originalLikes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Comments',
                          controller: _commentsController,
                          icon: Icons.mode_comment_outlined,
                          original: widget.reel.originalComments,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Shares & Saves Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Shares',
                          controller: _sharesController,
                          icon: Icons.send_outlined,
                          original: widget.reel.originalShares,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricInput(
                          label: 'Saves',
                          controller: _savesController,
                          icon: Icons.bookmark_border,
                          original: widget.reel.originalSaves,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Watch Time
                  _buildTextInput(
                    label: 'Avg Watch Time (e.g. 0:28)',
                    controller: _watchTimeController,
                    icon: Icons.timer_outlined,
                  ),

                  const SizedBox(height: 20),
                  const Text('Custom Metrics & Pitch Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 12),

                  // Custom Metric Name & Value
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextInput(
                          label: 'Custom Metric Name',
                          controller: _customNameController,
                          icon: Icons.label_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildTextInput(
                          label: 'Value',
                          controller: _customValController,
                          icon: Icons.tune,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Notes / Purpose
                  _buildTextInput(
                    label: 'Notes / Scenario Description',
                    controller: _notesController,
                    icon: Icons.notes,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  // Important Compliance Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Notice: Edited analytics are saved strictly in your local device database as simulation records. Source Instagram data remains untouched.',
                            style: TextStyle(fontSize: 11.5, color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                if (widget.reel.isEdited) ...[
                  OutlinedButton(
                    onPressed: _handleReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.likeRed,
                      side: const BorderSide(color: AppColors.likeRed),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save Edited Analytics',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required int original,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              'Orig: ${Formatters.compact(original)}',
              style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, size: 18) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
