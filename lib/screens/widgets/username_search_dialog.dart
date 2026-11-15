import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/reels_provider.dart';

class UsernameSearchDialog extends ConsumerStatefulWidget {
  const UsernameSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const UsernameSearchDialog(),
    );
  }

  @override
  ConsumerState<UsernameSearchDialog> createState() => _UsernameSearchDialogState();
}

class _UsernameSearchDialogState extends ConsumerState<UsernameSearchDialog> {
  final _controller = TextEditingController();
  bool _isSearching = false;

  final _popularAccounts = [
    'mrbeast',
    'cristiano',
    'leomessi',
    'mkbhd',
    'selenagomez',
    'natgeo',
    'nike',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleImport(String username) async {
    final clean = username.replaceAll('@', '').trim();
    if (clean.isEmpty) return;

    setState(() => _isSearching = true);
    final profile = await ref.read(profileProvider.notifier).importProfile(clean);
    await ref.read(reelsProvider.notifier).loadReels();
    await ref.read(analyticsProvider.notifier).refreshStats();

    if (mounted) {
      setState(() => _isSearching = false);
      if (profile != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.deltaPositive,
            content: Text('🎉 Imported @${profile.username} with public reels!'),
          ),
        );
      }
    }
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
                const Icon(Icons.person_search_rounded, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Import Instagram Profile',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter any public Instagram handle to import their profile info, public reels, and analytics into your workspace.',
              style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
            ),
            const SizedBox(height: 16),

            // Username Input Field
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. mrbeast or @cristiano',
                prefixIcon: const Icon(Icons.alternate_email, size: 20, color: AppColors.primaryBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryBlue),
                  onPressed: _isSearching ? null : () => _handleImport(_controller.text),
                ),
              ),
              onSubmitted: (val) => _handleImport(val),
            ),

            const SizedBox(height: 16),
            const Text(
              'Quick Select Popular Creators:',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.darkTextMuted),
            ),
            const SizedBox(height: 8),

            // Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _popularAccounts.map((user) {
                return ActionChip(
                  label: Text('@$user', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  avatar: const Icon(Icons.touch_app_outlined, size: 14),
                  backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  onPressed: _isSearching ? null : () => _handleImport(user),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Big Import Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : () => _handleImport(_controller.text),
                icon: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                  _isSearching ? 'Importing Public Data...' : 'Import Profile & Reels',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
