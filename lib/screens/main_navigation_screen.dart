import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import 'home_feed_screen.dart';
import 'search_explore_screen.dart';
import 'reels_screen.dart';
import 'analytics_dashboard_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeFeedScreen(),
    SearchExploreScreen(),
    ReelsScreen(),
    AnalyticsDashboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final activeProfile = profileState.activeProfile;

    // Check if we are on the Reels screen (full-screen black aesthetic)
    final isReelsTab = _currentIndex == 2;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isReelsTab
              ? Colors.black
              : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
          border: Border(
            top: BorderSide(
              color: isReelsTab
                  ? Colors.white12
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                _buildNavItem(
                  index: 0,
                  activeIcon: Icons.home,
                  inactiveIcon: Icons.home_outlined,
                  isReelsTab: isReelsTab,
                  isDark: isDark,
                ),

                // 2. Search / Explore
                _buildNavItem(
                  index: 1,
                  activeIcon: Icons.search,
                  inactiveIcon: Icons.search_outlined,
                  isReelsTab: isReelsTab,
                  isDark: isDark,
                ),

                // 3. Reels
                _buildNavItem(
                  index: 2,
                  activeIcon: Icons.movie_creation,
                  inactiveIcon: Icons.movie_creation_outlined,
                  isReelsTab: isReelsTab,
                  isDark: isDark,
                ),

                // 4. Analytics Studio
                _buildNavItem(
                  index: 3,
                  activeIcon: Icons.insights_rounded,
                  inactiveIcon: Icons.insights_outlined,
                  isReelsTab: isReelsTab,
                  isDark: isDark,
                  badgeText: 'PRO',
                ),

                // 5. Profile
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 4),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentIndex == 4
                            ? (isReelsTab || isDark ? Colors.white : Colors.black)
                            : Colors.transparent,
                        width: 1.8,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(activeProfile?.profilePicUrl ??
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required bool isReelsTab,
    required bool isDark,
    String? badgeText,
  }) {
    final isSelected = _currentIndex == index;
    final color = isReelsTab
        ? (isSelected ? Colors.white : Colors.white60)
        : (isSelected
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextMuted));

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 26,
            ),
          ),
          if (badgeText != null)
            Positioned(
              top: 4,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.instagramGradient),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
