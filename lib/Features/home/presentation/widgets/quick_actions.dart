// Presentation Layer - Quick Actions Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../posting/presentation/screens/step_by_step_marketplace_posting_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      QuickActionItem(
        icon: Icons.home,
        title: 'Find Hostel',
        color: AppTheme.primaryColor,
        onTap: () {
          // TODO: Navigate to hostel search
        },
      ),
      QuickActionItem(
        icon: Icons.people,
        title: 'Find Roommate',
        color: Colors.blue[600]!,
        onTap: () {
          // TODO: Navigate to roommate finder
        },
      ),
      QuickActionItem(
        icon: Icons.event,
        title: 'Campus Events',
        color: Colors.orange[600]!,
        onTap: () {
          // TODO: Navigate to events
        },
      ),
      QuickActionItem(
        icon: Icons.shopping_cart,
        title: 'Marketplace',
        color: Colors.purple[600]!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StepByStepMarketplacePostingScreen(),
            ),
          );
        },
      ),
      QuickActionItem(
        icon: Icons.poll,
        title: 'Polls & Votes',
        color: Colors.red[600]!,
        onTap: () {
          // TODO: Navigate to polls
        },
      ),
      QuickActionItem(
        icon: Icons.chat,
        title: 'Chats',
        color: Colors.green[600]!,
        onTap: () {
          // TODO: Navigate to chats
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4), // Reduced padding
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      6,
                    ), // Reduced border radius
                  ),
                  child: Icon(
                    Icons.dashboard_customize,
                    color: AppTheme.primaryColor,
                    size: 14, // Reduced icon size
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 15, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ), // Reduced padding
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  10,
                ), // Reduced border radius
              ),
              child: Text(
                '${actions.length} actions',
                style: TextStyle(
                  fontSize: 9, // Reduced font size
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Reduced spacing
        SizedBox(
          height: 85, // Further reduced height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right:
                      index < actions.length - 1
                          ? 6
                          : 0, // Further reduced spacing
                ),
                child: actions[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65, // Further reduced width
        child: Column(
          children: [
            Container(
              width: 50, // Further reduced width
              height: 50, // Further reduced height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [color.withOpacity(0.25), color.withOpacity(0.15)]
                          : [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  12, // Further reduced border radius
                ),
                border: Border.all(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? color.withOpacity(0.3)
                          : color.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? color.withOpacity(0.2)
                            : color.withOpacity(0.15),
                    blurRadius: 5, // Further reduced blur
                    offset: const Offset(0, 2), // Further reduced offset
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ), // Further reduced icon size
              ),
            ),
            const SizedBox(height: 4), // Further reduced spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 9, // Further reduced font size
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
