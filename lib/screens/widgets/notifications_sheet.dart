import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activities = [
      {
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        'text': 'mrbeast liked your reel analytics comparison report.',
        'time': '20m',
        'isNew': true,
      },
      {
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'text': 'cristiano published 2 new viral reels. Ready to import!',
        'time': '2h',
        'isNew': true,
      },
      {
        'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'text': 'mkbhd started following your analytics studio workspace.',
        'time': '5h',
        'isNew': false,
      },
      {
        'avatar': 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400',
        'text': 'InstaPulse: Successfully calibrated engagement rates for 6 reels.',
        'time': '1d',
        'isNew': false,
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                const Icon(Icons.favorite, color: AppColors.likeRed, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Notifications & Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: activities.length,
              itemBuilder: (ctx, i) {
                final act = activities[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(act['avatar'] as String),
                    radius: 20,
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      children: [
                        TextSpan(text: act['text'] as String),
                        TextSpan(
                          text: '  ${act['time']}',
                          style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  trailing: (act['isNew'] as bool)
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
