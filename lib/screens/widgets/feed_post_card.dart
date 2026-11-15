import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/feed_post.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _showHeartAnimation = false;
  bool _isExpandedCaption = false;

  void _handleDoubleTap() {
    if (!widget.post.isLiked) {
      widget.onLike();
    }
    setState(() => _showHeartAnimation = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Post Header (Avatar, Username, Location, 3-dot)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: AppColors.storyGradient),
                ),
                padding: const EdgeInsets.all(1.5),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(widget.post.userAvatarUrl),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        if (widget.post.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 14),
                        ],
                      ],
                    ),
                    if (widget.post.location.isNotEmpty)
                      Text(
                        widget.post.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {
                  _showPostOptions(context);
                },
              ),
            ],
          ),
        ),

        // 2. Post Media / Image with Double Tap Heart Animation
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(
                  widget.post.imageUrls.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),
              if (_showHeartAnimation)
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100,
                )
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.elasticOut)
                    .fadeOut(delay: 500.ms, duration: 300.ms),
            ],
          ),
        ),

        // 3. Action Bar (Heart, Comment, Share, Bookmark)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? AppColors.likeRed : (isDark ? Colors.white : Colors.black),
                  size: 26,
                ),
                onPressed: widget.onLike,
              ),
              IconButton(
                icon: Icon(
                  Icons.mode_comment_outlined,
                  color: isDark ? Colors.white : Colors.black,
                  size: 24,
                ),
                onPressed: widget.onComment,
              ),
              IconButton(
                icon: Icon(
                  Icons.send_outlined,
                  color: isDark ? Colors.white : Colors.black,
                  size: 24,
                ),
                onPressed: widget.onShare,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: widget.post.isSaved ? AppColors.bookmarkYellow : (isDark ? Colors.white : Colors.black),
                  size: 26,
                ),
                onPressed: widget.onSave,
              ),
            ],
          ),
        ),

        // 4. Likes Counter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '${Formatters.withCommas(widget.post.likesCount)} likes',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ),

        // 5. Caption with "more" expandable
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: RichText(
            maxLines: _isExpandedCaption ? null : 2,
            overflow: _isExpandedCaption ? TextOverflow.visible : TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              children: [
                TextSpan(
                  text: '${widget.post.username} ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: widget.post.caption),
              ],
            ),
          ),
        ),

        // Expand button if caption is long
        if (!_isExpandedCaption && widget.post.caption.length > 70)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              onTap: () => setState(() => _isExpandedCaption = true),
              child: Text(
                'more',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          ),

        // 6. Comments Preview Link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: GestureDetector(
            onTap: widget.onComment,
            child: Text(
              'View all ${Formatters.withCommas(widget.post.commentsCount)} comments',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
        ),

        // 7. Time ago
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Text(
            '${widget.post.timeAgo} ago',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  void _showPostOptions(BuildContext context) {
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
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share to...'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: AppColors.analyticsPurple),
              title: const Text('Analyze Creator with InstaPulse'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred, color: AppColors.likeRed),
              title: const Text('Report post', style: TextStyle(color: AppColors.likeRed)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
