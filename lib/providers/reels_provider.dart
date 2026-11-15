import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/instagram_reel.dart';
import '../services/database_service.dart';

class ReelsState {
  final List<InstagramReel> reels;
  final bool isLoading;
  final String? filterProfileId;
  final String? errorMessage;

  const ReelsState({
    this.reels = const [],
    this.isLoading = false,
    this.filterProfileId,
    this.errorMessage,
  });

  ReelsState copyWith({
    List<InstagramReel>? reels,
    bool? isLoading,
    String? filterProfileId,
    String? errorMessage,
  }) {
    return ReelsState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      filterProfileId: filterProfileId ?? this.filterProfileId,
      errorMessage: errorMessage,
    );
  }
}

class ReelsNotifier extends StateNotifier<ReelsState> {
  ReelsNotifier() : super(const ReelsState()) {
    loadReels();
  }

  Future<void> loadReels({String? profileId}) async {
    state = state.copyWith(isLoading: true, filterProfileId: profileId);
    try {
      final list = await DatabaseService.instance.getReels(profileId: profileId);
      state = state.copyWith(reels: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
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
    try {
      await DatabaseService.instance.saveEditedAnalytics(
        reelId: reelId,
        profileId: profileId,
        editedViews: editedViews,
        editedLikes: editedLikes,
        editedComments: editedComments,
        editedShares: editedShares,
        editedSaves: editedSaves,
        editedReach: editedReach,
        editedWatchTime: editedWatchTime,
        editedEngagementRate: editedEngagementRate,
        customMetricName: customMetricName,
        customMetricValue: customMetricValue,
        notes: notes,
      );
      await loadReels(profileId: state.filterProfileId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save edited analytics: $e');
    }
  }

  Future<void> resetEditedAnalytics(String reelId) async {
    try {
      await DatabaseService.instance.resetEditedAnalytics(reelId);
      await loadReels(profileId: state.filterProfileId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to reset analytics: $e');
    }
  }
}

final reelsProvider = StateNotifierProvider<ReelsNotifier, ReelsState>((ref) {
  return ReelsNotifier();
});

// Analytics Dashboard Provider
class AnalyticsState {
  final Map<String, dynamic> stats;
  final bool isLoading;

  const AnalyticsState({
    this.stats = const {},
    this.isLoading = false,
  });

  AnalyticsState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
  }) {
    return AnalyticsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    refreshStats();
  }

  Future<void> refreshStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final metrics = await DatabaseService.instance.getDashboardMetrics();
      state = state.copyWith(stats: metrics, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
