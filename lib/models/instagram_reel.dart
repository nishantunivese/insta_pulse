class InstagramReel {
  final String id;
  final String profileId;
  final String username;
  final String userAvatarUrl;
  final String reelUrl;
  final String thumbnailUrl;
  final String caption;
  final int durationSeconds;
  final String audioTitle;
  final String publishedAt;
  final String importedAt;

  // Original Imported Metrics (Source)
  final int originalViews;
  final int originalLikes;
  final int originalComments;
  final int originalShares;
  final int originalSaves;
  final int originalReach;
  final String originalWatchTime;
  final double originalEngagementRate;

  // Local Edited Analytics (User overrides)
  final bool isEdited;
  final int? editedViews;
  final int? editedLikes;
  final int? editedComments;
  final int? editedShares;
  final int? editedSaves;
  final int? editedReach;
  final String? editedWatchTime;
  final double? editedEngagementRate;
  final String? customMetricName;
  final String? customMetricValue;
  final String? notes;
  final String? editedAt;

  const InstagramReel({
    required this.id,
    required this.profileId,
    required this.username,
    this.userAvatarUrl = '',
    required this.reelUrl,
    required this.thumbnailUrl,
    required this.caption,
    this.durationSeconds = 30,
    this.audioTitle = 'Original Audio',
    required this.publishedAt,
    required this.importedAt,
    required this.originalViews,
    required this.originalLikes,
    required this.originalComments,
    required this.originalShares,
    required this.originalSaves,
    required this.originalReach,
    this.originalWatchTime = '0:18',
    required this.originalEngagementRate,
    this.isEdited = false,
    this.editedViews,
    this.editedLikes,
    this.editedComments,
    this.editedShares,
    this.editedSaves,
    this.editedReach,
    this.editedWatchTime,
    this.editedEngagementRate,
    this.customMetricName,
    this.customMetricValue,
    this.notes,
    this.editedAt,
  });

  // Active Getters respecting edited state
  int get displayViews => (isEdited && editedViews != null) ? editedViews! : originalViews;
  int get displayLikes => (isEdited && editedLikes != null) ? editedLikes! : originalLikes;
  int get displayComments => (isEdited && editedComments != null) ? editedComments! : originalComments;
  int get displayShares => (isEdited && editedShares != null) ? editedShares! : originalShares;
  int get displaySaves => (isEdited && editedSaves != null) ? editedSaves! : originalSaves;
  int get displayReach => (isEdited && editedReach != null) ? editedReach! : originalReach;
  String get displayWatchTime => (isEdited && editedWatchTime != null) ? editedWatchTime! : originalWatchTime;
  double get displayEngagementRate => (isEdited && editedEngagementRate != null) ? editedEngagementRate! : originalEngagementRate;

  // Deltas for comparison view
  int get viewsDelta => (editedViews ?? originalViews) - originalViews;
  int get likesDelta => (editedLikes ?? originalLikes) - originalLikes;
  int get commentsDelta => (editedComments ?? originalComments) - originalComments;
  int get sharesDelta => (editedShares ?? originalShares) - originalShares;

  static double calculateEngagementRate({
    required int views,
    required int likes,
    required int comments,
    required int shares,
    required int saves,
  }) {
    if (views <= 0) return 0.0;
    int interactions = likes + comments + shares + saves;
    return (interactions / views) * 100.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'username': username,
      'user_avatar_url': userAvatarUrl,
      'reel_url': reelUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'duration_seconds': durationSeconds,
      'audio_title': audioTitle,
      'published_at': publishedAt,
      'imported_at': importedAt,
      'original_views': originalViews,
      'original_likes': originalLikes,
      'original_comments': originalComments,
      'original_shares': originalShares,
      'original_saves': originalSaves,
      'original_reach': originalReach,
      'original_watch_time': originalWatchTime,
      'original_engagement_rate': originalEngagementRate,
      'is_edited': isEdited ? 1 : 0,
      'edited_views': editedViews,
      'edited_likes': editedLikes,
      'edited_comments': editedComments,
      'edited_shares': editedShares,
      'edited_saves': editedSaves,
      'edited_reach': editedReach,
      'edited_watch_time': editedWatchTime,
      'edited_engagement_rate': editedEngagementRate,
      'custom_metric_name': customMetricName,
      'custom_metric_value': customMetricValue,
      'notes': notes,
      'edited_at': editedAt,
    };
  }

  factory InstagramReel.fromMap(Map<String, dynamic> map) {
    return InstagramReel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      username: map['username'] as String? ?? 'creator',
      userAvatarUrl: map['user_avatar_url'] as String? ?? '',
      reelUrl: map['reel_url'] as String? ?? '',
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      caption: map['caption'] as String? ?? '',
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 30,
      audioTitle: map['audio_title'] as String? ?? 'Original Audio',
      publishedAt: map['published_at'] as String? ?? DateTime.now().toIso8601String(),
      importedAt: map['imported_at'] as String? ?? DateTime.now().toIso8601String(),
      originalViews: (map['original_views'] as num?)?.toInt() ?? 0,
      originalLikes: (map['original_likes'] as num?)?.toInt() ?? 0,
      originalComments: (map['original_comments'] as num?)?.toInt() ?? 0,
      originalShares: (map['original_shares'] as num?)?.toInt() ?? 0,
      originalSaves: (map['original_saves'] as num?)?.toInt() ?? 0,
      originalReach: (map['original_reach'] as num?)?.toInt() ?? 0,
      originalWatchTime: map['original_watch_time'] as String? ?? '0:18',
      originalEngagementRate: (map['original_engagement_rate'] as num?)?.toDouble() ?? 0.0,
      isEdited: (map['is_edited'] as int? ?? 0) == 1,
      editedViews: (map['edited_views'] as num?)?.toInt(),
      editedLikes: (map['edited_likes'] as num?)?.toInt(),
      editedComments: (map['edited_comments'] as num?)?.toInt(),
      editedShares: (map['edited_shares'] as num?)?.toInt(),
      editedSaves: (map['edited_saves'] as num?)?.toInt(),
      editedReach: (map['edited_reach'] as num?)?.toInt(),
      editedWatchTime: map['edited_watch_time'] as String?,
      editedEngagementRate: (map['edited_engagement_rate'] as num?)?.toDouble(),
      customMetricName: map['custom_metric_name'] as String?,
      customMetricValue: map['custom_metric_value'] as String?,
      notes: map['notes'] as String?,
      editedAt: map['edited_at'] as String?,
    );
  }

  InstagramReel copyWith({
    String? id,
    String? profileId,
    String? username,
    String? userAvatarUrl,
    String? reelUrl,
    String? thumbnailUrl,
    String? caption,
    int? durationSeconds,
    String? audioTitle,
    String? publishedAt,
    String? importedAt,
    int? originalViews,
    int? originalLikes,
    int? originalComments,
    int? originalShares,
    int? originalSaves,
    int? originalReach,
    String? originalWatchTime,
    double? originalEngagementRate,
    bool? isEdited,
    int? editedViews,
    int? editedLikes,
    int? editedComments,
    int? editedShares,
    int? editedSaves,
    int? editedReach,
    String? editedWatchTime,
    double? editedEngagementRate,
    String? customMetricName,
    String? customMetricValue,
    String? notes,
    String? editedAt,
  }) {
    return InstagramReel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      reelUrl: reelUrl ?? this.reelUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioTitle: audioTitle ?? this.audioTitle,
      publishedAt: publishedAt ?? this.publishedAt,
      importedAt: importedAt ?? this.importedAt,
      originalViews: originalViews ?? this.originalViews,
      originalLikes: originalLikes ?? this.originalLikes,
      originalComments: originalComments ?? this.originalComments,
      originalShares: originalShares ?? this.originalShares,
      originalSaves: originalSaves ?? this.originalSaves,
      originalReach: originalReach ?? this.originalReach,
      originalWatchTime: originalWatchTime ?? this.originalWatchTime,
      originalEngagementRate: originalEngagementRate ?? this.originalEngagementRate,
      isEdited: isEdited ?? this.isEdited,
      editedViews: editedViews ?? this.editedViews,
      editedLikes: editedLikes ?? this.editedLikes,
      editedComments: editedComments ?? this.editedComments,
      editedShares: editedShares ?? this.editedShares,
      editedSaves: editedSaves ?? this.editedSaves,
      editedReach: editedReach ?? this.editedReach,
      editedWatchTime: editedWatchTime ?? this.editedWatchTime,
      editedEngagementRate: editedEngagementRate ?? this.editedEngagementRate,
      customMetricName: customMetricName ?? this.customMetricName,
      customMetricValue: customMetricValue ?? this.customMetricValue,
      notes: notes ?? this.notes,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
