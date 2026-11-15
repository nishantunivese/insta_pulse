import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/reels_provider.dart';
import 'widgets/analytics_editor_sheet.dart';
import 'widgets/username_search_dialog.dart';

class SearchExploreScreen extends ConsumerStatefulWidget {
  const SearchExploreScreen({super.key});

  @override
  ConsumerState<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends ConsumerState<SearchExploreScreen> {
  final _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final _filters = ['For You', 'Reels', 'Creators', 'Analytics', 'Trending'];

  final _exploreImages = [
    'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=600',
    'https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=600',
    'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600',
    'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=600',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=600',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reelsState = ref.watch(reelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search creators, reels, hashtags...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                UsernameSearchDialog.show(context);
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primaryBlue),
            tooltip: 'Import Instagram Profile',
            onPressed: () => UsernameSearchDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedFilterIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                    onSelected: (val) => setState(() => _selectedFilterIndex = i),
                  ),
                );
              },
            ),
          ),

          // Import Public Instagram Username Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.18),
                  AppColors.analyticsPurple.withOpacity(0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Instagram Username Lookup',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Import public profile & reels metrics into workspace',
                        style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => UsernameSearchDialog.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('IMPORT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          // Explore Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: reelsState.reels.isNotEmpty ? reelsState.reels.length : _exploreImages.length,
              itemBuilder: (ctx, i) {
                if (reelsState.reels.isNotEmpty && i < reelsState.reels.length) {
                  final reel = reelsState.reels[i];
                  return GestureDetector(
                    onTap: () => AnalyticsEditorSheet.show(context, reel),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          reel.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                        ),
                        // Reel icon badge
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(Icons.videocam, color: Colors.white, size: 18),
                        ),
                        // Edit Badge if edited
                        if (reel.isEdited)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.editedBadge,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'EDITED',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return Image.network(
                    _exploreImages[i % _exploreImages.length],
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
