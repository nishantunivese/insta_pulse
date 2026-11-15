import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/feed_post.dart';
import '../../providers/feed_provider.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  int _selectedMediaIndex = 0;

  final _sampleMedia = [
    'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1000',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1000',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1000',
    'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=1000',
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleShare() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a caption for your post.')),
      );
      return;
    }

    final newPost = FeedPost(
      id: 'post_custom_${const Uuid().v4().substring(0, 8)}',
      username: 'creator_studio',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Creator Studio HQ',
      imageUrls: [_sampleMedia[_selectedMediaIndex]],
      caption: caption,
      likesCount: 1,
      commentsCount: 0,
      isLiked: true,
      timeAgo: 'Just now',
    );

    ref.read(feedProvider.notifier).addPost(newPost);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.deltaPositive,
        content: Text('✨ Post shared to your Instagram Home Feed!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.add_box_outlined, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'New Post / Reel Draft',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _handleShare,
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Media Cover:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sampleMedia.length,
                      itemBuilder: (ctx, i) {
                        final isSelected = _selectedMediaIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMediaIndex = i),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                width: 2.5,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(_sampleMedia[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: isSelected
                                ? const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Caption', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption... #growth #creators #reels',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Add location (e.g. Los Angeles, California)',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
