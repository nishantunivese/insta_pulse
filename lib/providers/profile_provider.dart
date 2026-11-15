import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/instagram_profile.dart';
import '../services/database_service.dart';

class ProfileState {
  final List<InstagramProfile> profiles;
  final InstagramProfile? activeProfile;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.profiles = const [],
    this.activeProfile,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    List<InstagramProfile>? profiles,
    InstagramProfile? activeProfile,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      activeProfile: activeProfile ?? this.activeProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await DatabaseService.instance.getProfiles();
      final active = list.isNotEmpty ? (state.activeProfile ?? list.first) : null;
      state = state.copyWith(
        profiles: list,
        activeProfile: active,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setActiveProfile(InstagramProfile profile) {
    state = state.copyWith(activeProfile: profile);
  }

  Future<InstagramProfile?> importProfile(String rawUsername) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await DatabaseService.instance.searchAndImportProfile(rawUsername);
      final list = await DatabaseService.instance.getProfiles();
      state = state.copyWith(
        profiles: list,
        activeProfile: profile,
        isLoading: false,
        successMessage: 'Successfully imported @${profile.username} and public reels!',
      );
      return profile;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to import profile: $e',
      );
      return null;
    }
  }

  Future<void> updateLocalProfile({
    required String profileId,
    required String editedFullName,
    required String editedBio,
    required int editedFollowers,
    required int editedFollowing,
  }) async {
    try {
      await DatabaseService.instance.updateLocalProfile(
        profileId: profileId,
        editedFullName: editedFullName,
        editedBio: editedBio,
        editedFollowers: editedFollowers,
        editedFollowing: editedFollowing,
      );
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update local profile: $e');
    }
  }

  Future<void> resetProfile(String profileId) async {
    try {
      await DatabaseService.instance.resetProfileToOriginal(profileId);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to reset profile: $e');
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      await DatabaseService.instance.deleteProfile(profileId);
      final list = await DatabaseService.instance.getProfiles();
      state = state.copyWith(
        profiles: list,
        activeProfile: list.isNotEmpty ? list.first : null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete profile: $e');
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
