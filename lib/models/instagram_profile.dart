class InstagramProfile {
  final String id;
  final String username;
  final String fullName;
  final String bio;
  final String profilePicUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final String category;
  final String externalUrl;
  
  // Local edit flags and overrides
  final bool isEdited;
  final String? editedFullName;
  final String? editedBio;
  final int? editedFollowersCount;
  final int? editedFollowingCount;
  final String importedAt;
  final String updatedAt;

  const InstagramProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.bio,
    required this.profilePicUrl,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    this.isVerified = false,
    this.category = 'Creator',
    this.externalUrl = '',
    this.isEdited = false,
    this.editedFullName,
    this.editedBio,
    this.editedFollowersCount,
    this.editedFollowingCount,
    required this.importedAt,
    required this.updatedAt,
  });

  // Dynamic getters respecting local edits
  String get displayFullName => (isEdited && editedFullName != null && editedFullName!.isNotEmpty) 
      ? editedFullName! 
      : fullName;

  String get displayBio => (isEdited && editedBio != null) 
      ? editedBio! 
      : bio;

  int get displayFollowers => (isEdited && editedFollowersCount != null) 
      ? editedFollowersCount! 
      : followersCount;

  int get displayFollowing => (isEdited && editedFollowingCount != null) 
      ? editedFollowingCount! 
      : followingCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'profile_pic_url': profilePicUrl,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_verified': isVerified ? 1 : 0,
      'category': category,
      'external_url': externalUrl,
      'is_edited': isEdited ? 1 : 0,
      'edited_full_name': editedFullName,
      'edited_bio': editedBio,
      'edited_followers_count': editedFollowersCount,
      'edited_following_count': editedFollowingCount,
      'imported_at': importedAt,
      'updated_at': updatedAt,
    };
  }

  factory InstagramProfile.fromMap(Map<String, dynamic> map) {
    return InstagramProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      profilePicUrl: map['profile_pic_url'] as String? ?? '',
      followersCount: (map['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (map['following_count'] as num?)?.toInt() ?? 0,
      postsCount: (map['posts_count'] as num?)?.toInt() ?? 0,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      category: map['category'] as String? ?? 'Creator',
      externalUrl: map['external_url'] as String? ?? '',
      isEdited: (map['is_edited'] as int? ?? 0) == 1,
      editedFullName: map['edited_full_name'] as String?,
      editedBio: map['edited_bio'] as String?,
      editedFollowersCount: (map['edited_followers_count'] as num?)?.toInt(),
      editedFollowingCount: (map['edited_following_count'] as num?)?.toInt(),
      importedAt: map['imported_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  InstagramProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? bio,
    String? profilePicUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    String? category,
    String? externalUrl,
    bool? isEdited,
    String? editedFullName,
    String? editedBio,
    int? editedFollowersCount,
    int? editedFollowingCount,
    String? importedAt,
    String? updatedAt,
  }) {
    return InstagramProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      category: category ?? this.category,
      externalUrl: externalUrl ?? this.externalUrl,
      isEdited: isEdited ?? this.isEdited,
      editedFullName: editedFullName ?? this.editedFullName,
      editedBio: editedBio ?? this.editedBio,
      editedFollowersCount: editedFollowersCount ?? this.editedFollowersCount,
      editedFollowingCount: editedFollowingCount ?? this.editedFollowingCount,
      importedAt: importedAt ?? this.importedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
