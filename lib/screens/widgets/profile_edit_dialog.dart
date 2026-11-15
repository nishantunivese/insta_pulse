import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/instagram_profile.dart';
import '../../providers/profile_provider.dart';

class ProfileEditDialog extends ConsumerStatefulWidget {
  final InstagramProfile profile;

  const ProfileEditDialog({super.key, required this.profile});

  static void show(BuildContext context, InstagramProfile profile) {
    showDialog(
      context: context,
      builder: (_) => ProfileEditDialog(profile: profile),
    );
  }

  @override
  ConsumerState<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _followersController;
  late TextEditingController _followingController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.displayFullName);
    _bioController = TextEditingController(text: p.displayBio);
    _followersController = TextEditingController(text: p.displayFollowers.toString());
    _followingController = TextEditingController(text: p.displayFollowing.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _followersController.dispose();
    _followingController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final f = int.tryParse(_followersController.text) ?? widget.profile.followersCount;
    final fg = int.tryParse(_followingController.text) ?? widget.profile.followingCount;

    await ref.read(profileProvider.notifier).updateLocalProfile(
          profileId: widget.profile.id,
          editedFullName: _nameController.text.trim(),
          editedBio: _bioController.text.trim(),
          editedFollowers: f,
          editedFollowing: fg,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.deltaPositive,
          content: Text('Profile customized locally in your workspace!'),
        ),
      );
    }
  }

  Future<void> _handleReset() async {
    await ref.read(profileProvider.notifier).resetProfile(widget.profile.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryBlue,
          content: Text('Restored original source profile data.'),
        ),
      );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Edit @${widget.profile.username}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Customize how this profile appears in your local workspace. Test different follower tiers and bios.',
                style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
              ),
              const SizedBox(height: 16),

              // Full Name
              const Text('Display Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                ),
              ),

              const SizedBox(height: 14),

              // Bio
              const Text('Bio Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 14),

              // Followers & Following Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Followers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              'Orig: ${Formatters.compact(widget.profile.followersCount)}',
                              style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _followersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.people_outline, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Following', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              'Orig: ${widget.profile.followingCount}',
                              style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _followingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_add_outlined, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (widget.profile.isEdited) ...[
                    OutlinedButton(
                      onPressed: _handleReset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.likeRed,
                        side: const BorderSide(color: AppColors.likeRed),
                      ),
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                    ),
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
