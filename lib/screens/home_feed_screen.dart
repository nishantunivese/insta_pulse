import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/feed_provider.dart';
import '../providers/theme_provider.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/notifications_sheet.dart';
import 'widgets/story_avatar.dart';

class HomeFeedScreen extends ConsumerWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 27,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Theme Switcher Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          // Heart / Notifications Icon with dot
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, size: 26),
                onPressed: () => NotificationsSheet.show(context),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.likeRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Direct Messages Icon
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Direct Messages: All creator conversations synced.')),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            // Stories Tray
            SliverToBoxAdapter(
              child: Container(
                height: 106,
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 0.8,
                    ),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: feedState.stories.length,
                  itemBuilder: (ctx, i) {
                    final story = feedState.stories[i];
                    return StoryAvatar(
                      story: story,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening @${story.username}\'s Story...')),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Feed Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final post = feedState.posts[i];
                  return FeedPostCard(
                    post: post,
                    onLike: () => ref.read(feedProvider.notifier).toggleLike(post.id),
                    onSave: () => ref.read(feedProvider.notifier).toggleSave(post.id),
                    onComment: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comments for @${post.username}\'s post')),
                      );
                    },
                    onShare: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sharing @${post.username}\'s post...')),
                      );
                    },
                  );
                },
                childCount: feedState.posts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
