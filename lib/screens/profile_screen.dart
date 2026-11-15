import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/instagram_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/reels_provider.dart';
import 'widgets/analytics_editor_sheet.dart';
import 'widgets/create_post_sheet.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/username_search_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final reelsState = ref.watch(reelsProvider);

    final activeProfile = profileState.activeProfile;

    if (activeProfile == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => UsernameSearchDialog.show(context),
            child: const Text('Import a Creator Profile'),
          ),
        ),
      );
    }

    // Filter reels for this active profile
    final profileReels = reelsState.reels
        .where((r) => r.username.toLowerCase() == activeProfile.username.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showProfileSwitcher(context, ref, profileState.profiles),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activeProfile.username,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (activeProfile.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 16),
              ],
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, size: 24),
            onPressed: () => CreatePostSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_search_outlined, size: 24),
            tooltip: 'Import Profile',
            onPressed: () => UsernameSearchDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: () => _showMenuBottomSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Stats Row
                    Row(
                      children: [
                        // Avatar with Story Ring
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: AppColors.storyGradient),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.scaffoldBackgroundColor,
                            child: CircleAvatar(
                              radius: 37,
                              backgroundImage: NetworkImage(activeProfile.profilePicUrl),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Stats Columns
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Posts', activeProfile.postsCount.toString()),
                              _buildStatColumn('Followers', Formatters.compact(activeProfile.displayFollowers)),
                              _buildStatColumn('Following', activeProfile.displayFollowing.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Name & Verified Badge
                    Row(
                      children: [
                        Text(
                          activeProfile.displayFullName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                        if (activeProfile.isEdited) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.editedBadge.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.editedBadge, width: 0.8),
                            ),
                            child: const Text(
                              'CUSTOM OVERRIDE',
                              style: TextStyle(color: AppColors.editedBadge, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Category
                    if (activeProfile.category.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        activeProfile.category,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.darkTextMuted),
                      ),
                    ],

                    // Bio
                    if (activeProfile.displayBio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        activeProfile.displayBio,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],

                    // Link
                    if (activeProfile.externalUrl.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.link, size: 14, color: AppColors.primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            activeProfile.externalUrl,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Action Buttons Row (Edit Local Profile, Share Profile, Switch)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ProfileEditDialog.show(context, activeProfile),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                              foregroundColor: isDark ? Colors.white : Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                            ),
                            child: const Text('Edit Local Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profile link copied: instagram.com/${activeProfile.username}')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                              foregroundColor: isDark ? Colors.white : Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                            ),
                            child: const Text('Share Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.person_add_outlined, size: 20),
                            onPressed: () => UsernameSearchDialog.show(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Story Highlights Tray
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildHighlightItem('Highlights', 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400'),
                          _buildHighlightItem('Travel', 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400'),
                          _buildHighlightItem('Reels BTS', 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400'),
                          _buildHighlightItem('Awards', 'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=400'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: isDark ? Colors.white : Colors.black,
                  indicatorWeight: 1.5,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on_sharp, size: 22)),
                    Tab(icon: Icon(Icons.movie_creation_outlined, size: 22)),
                    Tab(icon: Icon(Icons.person_pin_outlined, size: 24)),
                  ],
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Grid Posts
            _buildReelsGrid(profileReels),
            // Tab 2: Reels Dedicated Tab
            _buildReelsGrid(profileReels),
            // Tab 3: Tagged
            const Center(child: Text('Photos and videos of you', style: TextStyle(color: AppColors.darkTextMuted))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _buildHighlightItem(String title, String imageUrl) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder, width: 1.2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid(List<dynamic> reels) {
    if (reels.isEmpty) {
      return const Center(
        child: Text('No reels found for this profile.', style: TextStyle(color: AppColors.darkTextMuted)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: reels.length,
      itemBuilder: (ctx, i) {
        final reel = reels[i];
        return GestureDetector(
          onTap: () => AnalyticsEditorSheet.show(context, reel),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                reel.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      Formatters.compact(reel.displayViews),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (reel.isEdited)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.editedBadge,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('EDITED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileSwitcher(BuildContext context, WidgetRef ref, List<InstagramProfile> profiles) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('Switch Active Workspace Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            const Divider(),
            ...profiles.map(
              (p) => ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(p.profilePicUrl)),
                title: Text('@${p.username}', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${Formatters.compact(p.displayFollowers)} followers'),
                onTap: () {
                  ref.read(profileProvider.notifier).setActiveProfile(p);
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: const Text('Import New Profile', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
              onTap: () {
                Navigator.pop(ctx);
                UsernameSearchDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings and privacy'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.insights_rounded, color: AppColors.analyticsPurple),
              title: const Text('Open Analytics Studio'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('QR code'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
