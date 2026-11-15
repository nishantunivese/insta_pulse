import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_post.dart';

class FeedState {
  final List<FeedPost> posts;
  final List<StoryItem> stories;

  const FeedState({
    this.posts = const [],
    this.stories = const [],
  });

  FeedState copyWith({
    List<FeedPost>? posts,
    List<StoryItem>? stories,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      stories: stories ?? this.stories,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    _initFeed();
  }

  void _initFeed() {
    final initialStories = [
      const StoryItem(
        id: 'story_me',
        username: 'Your story',
        userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        hasUnseenStory: false,
        isCurrentUser: true,
      ),
      const StoryItem(
        id: 'story_1',
        username: 'mrbeast',
        userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        hasUnseenStory: true,
        isLive: true,
      ),
      const StoryItem(
        id: 'story_2',
        username: 'cristiano',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        hasUnseenStory: true,
      ),
      const StoryItem(
        id: 'story_3',
        username: 'mkbhd',
        userAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        hasUnseenStory: true,
      ),
      const StoryItem(
        id: 'story_4',
        username: 'natgeo',
        userAvatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400',
        hasUnseenStory: true,
      ),
      const StoryItem(
        id: 'story_5',
        username: 'nike',
        userAvatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
        hasUnseenStory: false,
      ),
    ];

    final initialPosts = [
      const FeedPost(
        id: 'post_1',
        username: 'mrbeast',
        userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        location: 'Greenville, North Carolina',
        imageUrls: [
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1000',
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1000',
        ],
        caption: 'We just gave away 100 houses! ❤️ Seeing the reaction of families having a roof over their head for the first time is why we do what we do. New video is live!',
        likesCount: 3845920,
        commentsCount: 42100,
        isVerified: true,
        timeAgo: '3h',
      ),
      const FeedPost(
        id: 'post_2',
        username: 'cristiano',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        location: 'Riyadh, Saudi Arabia',
        imageUrls: [
          'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=1000',
        ],
        caption: 'Great win tonight! ⚽🔥 Proud of the whole team. Thank you to all the fans for the amazing energy! SIUUU! 💛💙',
        likesCount: 9240100,
        commentsCount: 112500,
        isVerified: true,
        timeAgo: '6h',
      ),
      const FeedPost(
        id: 'post_3',
        username: 'mkbhd',
        userAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        location: 'Studio 55',
        imageUrls: [
          'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1000',
        ],
        caption: 'The Blind Smartphone Camera Test is officially back. Guess which camera took this shot? Link in bio to vote! 📸⚡',
        likesCount: 412000,
        commentsCount: 8900,
        isVerified: true,
        timeAgo: '1d',
      ),
    ];

    state = FeedState(posts: initialPosts, stories: initialStories);
  }

  void toggleLike(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          final isLiked = !p.isLiked;
          return p.copyWith(
            isLiked: isLiked,
            likesCount: isLiked ? p.likesCount + 1 : p.likesCount - 1,
          );
        }
        return p;
      }).toList(),
    );
  }

  void toggleSave(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(isSaved: !p.isSaved);
        }
        return p;
      }).toList(),
    );
  }

  void addPost(FeedPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
