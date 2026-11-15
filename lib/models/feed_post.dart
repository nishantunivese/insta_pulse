class FeedPost {
  final String id;
  final String username;
  final String userAvatarUrl;
  final String location;
  final List<String> imageUrls;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final bool isVerified;
  final String timeAgo;

  const FeedPost({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    this.location = '',
    required this.imageUrls,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isVerified = false,
    this.timeAgo = '2h',
  });

  FeedPost copyWith({
    String? id,
    String? username,
    String? userAvatarUrl,
    String? location,
    List<String>? imageUrls,
    String? caption,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    bool? isVerified,
    String? timeAgo,
  }) {
    return FeedPost(
      id: id ?? this.id,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isVerified: isVerified ?? this.isVerified,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}

class StoryItem {
  final String id;
  final String username;
  final String userAvatarUrl;
  final bool hasUnseenStory;
  final bool isLive;
  final bool isCurrentUser;

  const StoryItem({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    this.hasUnseenStory = true,
    this.isLive = false,
    this.isCurrentUser = false,
  });
}
