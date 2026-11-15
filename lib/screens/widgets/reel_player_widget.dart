import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/instagram_reel.dart';
import 'analytics_editor_sheet.dart';
import 'comparison_view_dialog.dart';

class ReelPlayerWidget extends StatefulWidget {
  final InstagramReel reel;

  const ReelPlayerWidget({super.key, required this.reel});

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  int _likesOffset = 0;
  bool _showHeart = false;
  late AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likesOffset = 1;
      });
    }
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reel;
    final displayLikes = r.displayLikes + _likesOffset;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Reel Background Thumbnail / Visualizer
        GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                r.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.videocam, color: Colors.white24, size: 80),
                  ),
                ),
              ),
              // Dark Gradient Overlays for readable text
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black38,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.2, 0.6, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              if (_showHeart)
                Center(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 110,
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.elasticOut)
                      .fadeOut(delay: 500.ms, duration: 300.ms),
                ),
            ],
          ),
        ),

        // 2. Top Bar (Reels Header + Mode Tag)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Row(
            children: [
              const Text(
                'Reels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (r.isEdited)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.editedBadge.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EDITED METRICS',
                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                  ),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // 3. Right Side Action Bar (Likes, Comments, Shares, Audio Disc, Edit Analytics!)
        Positioned(
          bottom: 24,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Analytics Floating Quick Button
              GestureDetector(
                onTap: () => AnalyticsEditorSheet.show(context, r),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.instagramGradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Edit',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              // Like Button
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppColors.likeRed : Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _likesOffset = _isLiked ? 1 : 0;
                  });
                },
              ),
              Text(
                Formatters.compact(displayLikes),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 14),

              // Comment Button
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined, color: Colors.white, size: 30),
                onPressed: () {},
              ),
              Text(
                Formatters.compact(r.displayComments),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 14),

              // Share Button
              IconButton(
                icon: const Icon(Icons.send_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              Text(
                Formatters.compact(r.displayShares),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 14),

              // Compare Button
              IconButton(
                icon: const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 28),
                onPressed: () => ComparisonViewDialog.show(context, r),
              ),
              const Text(
                'Delta',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 18),

              // Rotating Music Disc
              RotationTransition(
                turns: _discController,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(r.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Bottom Creator Info Overlay
        Positioned(
          left: 16,
          right: 80,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Creator Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(r.userAvatarUrl.isNotEmpty
                        ? r.userAvatarUrl
                        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    r.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Caption
              Text(
                r.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
              ),

              const SizedBox(height: 10),

              // Audio Title
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${r.audioTitle} • Original Audio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Analytics Mini-Pill Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPill(Icons.visibility, '${Formatters.compact(r.displayViews)} views'),
                    const SizedBox(width: 6),
                    _buildPill(Icons.radar, '${Formatters.compact(r.displayReach)} reach'),
                    const SizedBox(width: 6),
                    _buildPill(Icons.bolt, '${Formatters.percentage(r.displayEngagementRate)} ER'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
