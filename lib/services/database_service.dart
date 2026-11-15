import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/instagram_profile.dart';
import '../models/instagram_reel.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'instapulse_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Profiles Table
    await db.execute('''
      CREATE TABLE imported_profiles (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE,
        full_name TEXT,
        bio TEXT,
        profile_pic_url TEXT,
        followers_count INTEGER,
        following_count INTEGER,
        posts_count INTEGER,
        is_verified INTEGER,
        category TEXT,
        external_url TEXT,
        is_edited INTEGER DEFAULT 0,
        edited_full_name TEXT,
        edited_bio TEXT,
        edited_followers_count INTEGER,
        edited_following_count INTEGER,
        imported_at TEXT,
        updated_at TEXT
      )
    ''');

    // 2. Reels Table (Stores original imported values)
    await db.execute('''
      CREATE TABLE imported_reels (
        id TEXT PRIMARY KEY,
        profile_id TEXT,
        username TEXT,
        user_avatar_url TEXT,
        reel_url TEXT,
        thumbnail_url TEXT,
        caption TEXT,
        duration_seconds INTEGER,
        audio_title TEXT,
        published_at TEXT,
        imported_at TEXT,
        original_views INTEGER,
        original_likes INTEGER,
        original_comments INTEGER,
        original_shares INTEGER,
        original_saves INTEGER,
        original_reach INTEGER,
        original_watch_time TEXT,
        original_engagement_rate REAL,
        FOREIGN KEY (profile_id) REFERENCES imported_profiles(id) ON DELETE CASCADE
      )
    ''');

    // 3. Edited Reels Analytics Table (Separated for data integrity)
    await db.execute('''
      CREATE TABLE edited_reels_analytics (
        reel_id TEXT PRIMARY KEY,
        profile_id TEXT,
        is_edited INTEGER DEFAULT 1,
        edited_views INTEGER,
        edited_likes INTEGER,
        edited_comments INTEGER,
        edited_shares INTEGER,
        edited_saves INTEGER,
        edited_reach INTEGER,
        edited_watch_time TEXT,
        edited_engagement_rate REAL,
        custom_metric_name TEXT,
        custom_metric_value TEXT,
        notes TEXT,
        edited_at TEXT,
        FOREIGN KEY (reel_id) REFERENCES imported_reels(id) ON DELETE CASCADE
      )
    ''');

    // Seed default verified Instagram profiles and viral reels
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    // 1. MrBeast
    final mrBeastId = 'profile_mrbeast_001';
    await db.insert('imported_profiles', {
      'id': mrBeastId,
      'username': 'mrbeast',
      'full_name': 'Jimmy Donaldson',
      'bio': 'I want to make the world a better place before I die. Giving away cars, islands, and building 100 wells in Africa.',
      'profile_pic_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      'followers_count': 61500000,
      'following_count': 324,
      'posts_count': 185,
      'is_verified': 1,
      'category': 'Entertainment & Philanthropy',
      'external_url': 'beastgames.com',
      'is_edited': 0,
      'imported_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 3)).toIso8601String(),
    });

    final mrBeastReels = [
      {
        'id': 'reel_mb_1',
        'profile_id': mrBeastId,
        'username': 'mrbeast',
        'user_avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        'reel_url': 'https://instagram.com/reel/C89xYz1',
        'thumbnail_url': 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600',
        'caption': 'I survived 7 days in a solitary cube submerged underwater! 🌊 Watch till the end!',
        'duration_seconds': 58,
        'audio_title': 'MrBeast Suspense Original',
        'published_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'original_views': 84250000,
        'original_likes': 5820000,
        'original_comments': 94500,
        'original_shares': 620000,
        'original_saves': 310000,
        'original_reach': 92000000,
        'original_watch_time': '0:42',
        'original_engagement_rate': 8.12,
      },
      {
        'id': 'reel_mb_2',
        'profile_id': mrBeastId,
        'username': 'mrbeast',
        'user_avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        'reel_url': 'https://instagram.com/reel/C89xYz2',
        'thumbnail_url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
        'caption': 'Gave 100 people a Lamborghini and told them whoever touches it last keeps it! 🏎️',
        'duration_seconds': 45,
        'audio_title': 'Fast Pace Cinematic Beat',
        'published_at': now.subtract(const Duration(days: 9)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'original_views': 114800000,
        'original_likes': 8900000,
        'original_comments': 142000,
        'original_shares': 940000,
        'original_saves': 512000,
        'original_reach': 125000000,
        'original_watch_time': '0:38',
        'original_engagement_rate': 9.14,
      },
      {
        'id': 'reel_mb_3',
        'profile_id': mrBeastId,
        'username': 'mrbeast',
        'user_avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        'reel_url': 'https://instagram.com/reel/C89xYz3',
        'thumbnail_url': 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
        'caption': 'Built 100 houses and gave them away to families in need for free! ❤️',
        'duration_seconds': 52,
        'audio_title': 'Emotional Piano Theme',
        'published_at': now.subtract(const Duration(days: 14)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'original_views': 96400000,
        'original_likes': 7450000,
        'original_comments': 118000,
        'original_shares': 830000,
        'original_saves': 640000,
        'original_reach': 105000000,
        'original_watch_time': '0:46',
        'original_engagement_rate': 9.37,
      },
      {
        'id': 'reel_mb_4',
        'profile_id': mrBeastId,
        'username': 'mrbeast',
        'user_avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        'reel_url': 'https://instagram.com/reel/C89xYz4',
        'thumbnail_url': 'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=600',
        'caption': 'Whoever stops holding this briefcase with 1,000,000 in cash first loses it all!',
        'duration_seconds': 39,
        'audio_title': 'Action Countdown Drums',
        'published_at': now.subtract(const Duration(days: 20)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'original_views': 67500000,
        'original_likes': 4900000,
        'original_comments': 72000,
        'original_shares': 450000,
        'original_saves': 230000,
        'original_reach': 74000000,
        'original_watch_time': '0:32',
        'original_engagement_rate': 8.37,
      },
    ];

    for (var r in mrBeastReels) {
      await db.insert('imported_reels', r);
    }

    // Pre-seed an edited analytics record for reel_mb_1 to demonstrate feature out of the box!
    await db.insert('edited_reels_analytics', {
      'reel_id': 'reel_mb_1',
      'profile_id': mrBeastId,
      'is_edited': 1,
      'edited_views': 95000000,
      'edited_likes': 7100000,
      'edited_comments': 112000,
      'edited_shares': 780000,
      'edited_saves': 420000,
      'edited_reach': 108000000,
      'edited_watch_time': '0:49',
      'edited_engagement_rate': 8.85,
      'custom_metric_name': 'Viral Coefficient',
      'custom_metric_value': '3.4x',
      'notes': 'Projected analytics test for brand sponsorship deck pitch.',
      'edited_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
    });

    // 2. Cristiano Ronaldo
    final cristianoId = 'profile_cristiano_002';
    await db.insert('imported_profiles', {
      'id': cristianoId,
      'username': 'cristiano',
      'full_name': 'Cristiano Ronaldo',
      'bio': 'Join my journey. SIUUU! ⚽🇵🇹 @alnassr | @urcristiano YouTube',
      'profile_pic_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'followers_count': 638000000,
      'following_count': 578,
      'posts_count': 3712,
      'is_verified': 1,
      'category': 'Athlete',
      'external_url': 'cristianoronaldo.com',
      'is_edited': 0,
      'imported_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
    });

    final cristianoReels = [
      {
        'id': 'reel_cr_1',
        'profile_id': cristianoId,
        'username': 'cristiano',
        'user_avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'reel_url': 'https://instagram.com/reel/C71xYz1',
        'thumbnail_url': 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600',
        'caption': 'Focus, dedication, and passion. Always ready for the next match! 💪⚽ #AlNassr',
        'duration_seconds': 28,
        'audio_title': 'Champions League Motivation',
        'published_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'original_views': 142000000,
        'original_likes': 12400000,
        'original_comments': 168000,
        'original_shares': 1100000,
        'original_saves': 890000,
        'original_reach': 165000000,
        'original_watch_time': '0:26',
        'original_engagement_rate': 10.25,
      },
      {
        'id': 'reel_cr_2',
        'profile_id': cristianoId,
        'username': 'cristiano',
        'user_avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'reel_url': 'https://instagram.com/reel/C71xYz2',
        'thumbnail_url': 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=600',
        'caption': 'Family time is everything. Grateful for these moments! ❤️🏖️',
        'duration_seconds': 22,
        'audio_title': 'Summer Acoustic Guitar',
        'published_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        'imported_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'original_views': 98500000,
        'original_likes': 10100000,
        'original_comments': 135000,
        'original_shares': 620000,
        'original_saves': 540000,
        'original_reach': 118000000,
        'original_watch_time': '0:20',
        'original_engagement_rate': 11.57,
      },
    ];

    for (var r in cristianoReels) {
      await db.insert('imported_reels', r);
    }
  }

  // --- Profile Operations ---
  Future<List<InstagramProfile>> getProfiles() async {
    final db = await database;
    final maps = await db.query('imported_profiles', orderBy: 'imported_at DESC');
    return maps.map((m) => InstagramProfile.fromMap(m)).toList();
  }

  Future<InstagramProfile?> getProfile(String id) async {
    final db = await database;
    final maps = await db.query(
      'imported_profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return InstagramProfile.fromMap(maps.first);
  }

  Future<InstagramProfile?> getProfileByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'imported_profiles',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase().trim()],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return InstagramProfile.fromMap(maps.first);
  }

  Future<void> updateLocalProfile({
    required String profileId,
    required String editedFullName,
    required String editedBio,
    required int editedFollowers,
    required int editedFollowing,
  }) async {
    final db = await database;
    await db.update(
      'imported_profiles',
      {
        'is_edited': 1,
        'edited_full_name': editedFullName,
        'edited_bio': editedBio,
        'edited_followers_count': editedFollowers,
        'edited_following_count': editedFollowing,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [profileId],
    );
  }

  Future<void> resetProfileToOriginal(String profileId) async {
    final db = await database;
    await db.update(
      'imported_profiles',
      {
        'is_edited': 0,
        'edited_full_name': null,
        'edited_bio': null,
        'edited_followers_count': null,
        'edited_following_count': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [profileId],
    );
  }

  Future<void> deleteProfile(String profileId) async {
    final db = await database;
    await db.delete('edited_reels_analytics', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('imported_reels', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('imported_profiles', where: 'id = ?', whereArgs: [profileId]);
  }

  // --- Dynamic Public Profile Search & Import ---
  Future<InstagramProfile> searchAndImportProfile(String rawUsername) async {
    final cleanUsername = rawUsername.replaceAll('@', '').trim().toLowerCase();
    
    // Check if already in DB
    final existing = await getProfileByUsername(cleanUsername);
    if (existing != null) {
      return existing;
    }

    // Generate realistic public profile and 6 public reels for this creator
    final random = Random();
    final profileId = 'profile_${cleanUsername}_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final names = {
      'selenagomez': 'Selena Gomez',
      'kyliejenner': 'Kylie Jenner',
      'leomessi': 'Leo Messi',
      'therock': 'Dwayne Johnson',
      'arianagrande': 'Ariana Grande',
      'kimkardashian': 'Kim Kardashian',
      'beyonce': 'Beyoncé',
      'khaby00': 'Khaby Lame',
      'mkbhd': 'Marques Brownlee',
      'natgeo': 'National Geographic',
      'nike': 'Nike',
    };

    final formattedName = names[cleanUsername] ?? 
        (cleanUsername.isNotEmpty 
            ? cleanUsername[0].toUpperCase() + cleanUsername.substring(1) 
            : 'Creator');

    final followers = 500000 + random.nextInt(25000000);
    final following = 150 + random.nextInt(850);
    final posts = 45 + random.nextInt(400);

    final avatarUrl = 'https://images.unsplash.com/photo-${1500000000000 + random.nextInt(99999999)}?w=400';

    final newProfile = InstagramProfile(
      id: profileId,
      username: cleanUsername,
      fullName: formattedName,
      bio: 'Official Instagram account of $formattedName. Visual stories, creative moments & behind the scenes.',
      profilePicUrl: avatarUrl,
      followersCount: followers,
      followingCount: following,
      postsCount: posts,
      isVerified: followers > 1000000,
      category: 'Public Figure',
      externalUrl: 'linktr.ee/$cleanUsername',
      importedAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    final db = await database;
    await db.insert('imported_profiles', newProfile.toMap());

    // Generate 4 to 6 public reels for this profile
    final sampleCaptions = [
      'Big announcement coming next week! Can you guess what it is? 👀✨',
      'Behind the scenes of our latest production. Hard work always pays off! 🔥',
      'Quick tutorial on how we shot this sequence on mobile. Save this for later! 📱🎬',
      'Thank you for all the incredible support lately! You guys are the best ❤️',
      'Testing out new gear in the wild. Nature never fails to inspire 🌲☀️',
      'Weekend vibes with the team. Never stop creating! 🚀',
    ];

    final sampleThumbnails = [
      'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600',
      'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
      'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
      'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=600',
      'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600',
      'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=600',
    ];

    for (int i = 0; i < 4; i++) {
      final views = (followers * (0.15 + random.nextDouble() * 0.45)).toInt();
      final likes = (views * (0.06 + random.nextDouble() * 0.04)).toInt();
      final comments = (likes * 0.015).toInt();
      final shares = (likes * 0.08).toInt();
      final saves = (likes * 0.05).toInt();
      final reach = (views * 1.15).toInt();
      final er = InstagramReel.calculateEngagementRate(
        views: views,
        likes: likes,
        comments: comments,
        shares: shares,
        saves: saves,
      );

      final reel = InstagramReel(
        id: 'reel_${cleanUsername}_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
        profileId: profileId,
        username: cleanUsername,
        userAvatarUrl: avatarUrl,
        reelUrl: 'https://instagram.com/reel/${_uuid.v4().substring(0, 8)}',
        thumbnailUrl: sampleThumbnails[i % sampleThumbnails.length],
        caption: sampleCaptions[i % sampleCaptions.length],
        durationSeconds: 20 + random.nextInt(35),
        audioTitle: 'Trending Sound #${i + 1}',
        publishedAt: now.subtract(Duration(days: (i + 1) * 3)).toIso8601String(),
        importedAt: now.toIso8601String(),
        originalViews: views,
        originalLikes: likes,
        originalComments: comments,
        originalShares: shares,
        originalSaves: saves,
        originalReach: reach,
        originalWatchTime: '0:${20 + random.nextInt(25)}',
        originalEngagementRate: er,
      );

      await db.insert('imported_reels', {
        'id': reel.id,
        'profile_id': reel.profileId,
        'username': reel.username,
        'user_avatar_url': reel.userAvatarUrl,
        'reel_url': reel.reelUrl,
        'thumbnail_url': reel.thumbnailUrl,
        'caption': reel.caption,
        'duration_seconds': reel.durationSeconds,
        'audio_title': reel.audioTitle,
        'published_at': reel.publishedAt,
        'imported_at': reel.importedAt,
        'original_views': reel.originalViews,
        'original_likes': reel.originalLikes,
        'original_comments': reel.originalComments,
        'original_shares': reel.originalShares,
        'original_saves': reel.originalSaves,
        'original_reach': reel.originalReach,
        'original_watch_time': reel.originalWatchTime,
        'original_engagement_rate': reel.originalEngagementRate,
      });
    }

    return newProfile;
  }

  // --- Reels & Analytics Operations ---
  Future<List<InstagramReel>> getReels({String? profileId}) async {
    final db = await database;
    
    // Left join with edited_reels_analytics so we get edited values seamlessly
    String query = '''
      SELECT 
        r.*,
        e.is_edited AS e_is_edited,
        e.edited_views,
        e.edited_likes,
        e.edited_comments,
        e.edited_shares,
        e.edited_saves,
        e.edited_reach,
        e.edited_watch_time,
        e.edited_engagement_rate,
        e.custom_metric_name,
        e.custom_metric_value,
        e.notes,
        e.edited_at
      FROM imported_reels r
      LEFT JOIN edited_reels_analytics e ON r.id = e.reel_id
    ''';

    List<dynamic> args = [];
    if (profileId != null && profileId.isNotEmpty) {
      query += ' WHERE r.profile_id = ?';
      args.add(profileId);
    }
    query += ' ORDER BY r.published_at DESC';

    final rows = await db.rawQuery(query, args);

    return rows.map((row) {
      final isEdited = (row['e_is_edited'] as int? ?? 0) == 1;
      return InstagramReel(
        id: row['id'] as String,
        profileId: row['profile_id'] as String,
        username: row['username'] as String? ?? '',
        userAvatarUrl: row['user_avatar_url'] as String? ?? '',
        reelUrl: row['reel_url'] as String? ?? '',
        thumbnailUrl: row['thumbnail_url'] as String? ?? '',
        caption: row['caption'] as String? ?? '',
        durationSeconds: (row['duration_seconds'] as num?)?.toInt() ?? 30,
        audioTitle: row['audio_title'] as String? ?? 'Original Audio',
        publishedAt: row['published_at'] as String? ?? '',
        importedAt: row['imported_at'] as String? ?? '',
        originalViews: (row['original_views'] as num?)?.toInt() ?? 0,
        originalLikes: (row['original_likes'] as num?)?.toInt() ?? 0,
        originalComments: (row['original_comments'] as num?)?.toInt() ?? 0,
        originalShares: (row['original_shares'] as num?)?.toInt() ?? 0,
        originalSaves: (row['original_saves'] as num?)?.toInt() ?? 0,
        originalReach: (row['original_reach'] as num?)?.toInt() ?? 0,
        originalWatchTime: row['original_watch_time'] as String? ?? '0:18',
        originalEngagementRate: (row['original_engagement_rate'] as num?)?.toDouble() ?? 0.0,
        isEdited: isEdited,
        editedViews: (row['edited_views'] as num?)?.toInt(),
        editedLikes: (row['edited_likes'] as num?)?.toInt(),
        editedComments: (row['edited_comments'] as num?)?.toInt(),
        editedShares: (row['edited_shares'] as num?)?.toInt(),
        editedSaves: (row['edited_saves'] as num?)?.toInt(),
        editedReach: (row['edited_reach'] as num?)?.toInt(),
        editedWatchTime: row['edited_watch_time'] as String?,
        editedEngagementRate: (row['edited_engagement_rate'] as num?)?.toDouble(),
        customMetricName: row['custom_metric_name'] as String?,
        customMetricValue: row['custom_metric_value'] as String?,
        notes: row['notes'] as String?,
        editedAt: row['edited_at'] as String?,
      );
    }).toList();
  }

  Future<void> saveEditedAnalytics({
    required String reelId,
    required String profileId,
    required int editedViews,
    required int editedLikes,
    required int editedComments,
    required int editedShares,
    required int editedSaves,
    required int editedReach,
    required String editedWatchTime,
    required double editedEngagementRate,
    String? customMetricName,
    String? customMetricValue,
    String? notes,
  }) async {
    final db = await database;
    final nowIso = DateTime.now().toIso8601String();

    await db.insert(
      'edited_reels_analytics',
      {
        'reel_id': reelId,
        'profile_id': profileId,
        'is_edited': 1,
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
        'edited_at': nowIso,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> resetEditedAnalytics(String reelId) async {
    final db = await database;
    await db.delete(
      'edited_reels_analytics',
      where: 'reel_id = ?',
      whereArgs: [reelId],
    );
  }

  // --- Executive Dashboard Statistics ---
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final profiles = await getProfiles();
    final reels = await getReels();

    int totalProfiles = profiles.length;
    int totalReels = reels.length;

    int totalOriginalViews = 0;
    int totalEditedViews = 0;
    int totalOriginalLikes = 0;
    int totalEditedLikes = 0;
    double sumOriginalER = 0.0;
    double sumEditedER = 0.0;
    int editedReelsCount = 0;

    for (var r in reels) {
      totalOriginalViews += r.originalViews;
      totalEditedViews += r.displayViews;
      totalOriginalLikes += r.originalLikes;
      totalEditedLikes += r.displayLikes;
      sumOriginalER += r.originalEngagementRate;
      sumEditedER += r.displayEngagementRate;
      if (r.isEdited) editedReelsCount++;
    }

    double avgOriginalER = totalReels > 0 ? (sumOriginalER / totalReels) : 0.0;
    double avgEditedER = totalReels > 0 ? (sumEditedER / totalReels) : 0.0;

    return {
      'totalProfiles': totalProfiles,
      'totalReels': totalReels,
      'editedReelsCount': editedReelsCount,
      'totalOriginalViews': totalOriginalViews,
      'totalEditedViews': totalEditedViews,
      'viewsDelta': totalEditedViews - totalOriginalViews,
      'totalOriginalLikes': totalOriginalLikes,
      'totalEditedLikes': totalEditedLikes,
      'avgOriginalER': avgOriginalER,
      'avgEditedER': avgEditedER,
      'profiles': profiles,
      'recentReels': reels.take(10).toList(),
    };
  }
}
