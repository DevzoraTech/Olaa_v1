// Roommate Requests Empty State Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class RoommateRequestsEmptyState extends StatelessWidget {
  final VoidCallback onAddNew;

  const RoommateRequestsEmptyState({super.key, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16), // Further reduced from 20
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Changed from center
          children: [
            const SizedBox(height: 24), // Further reduced from 40
            // Illustration
            Container(
              width: 80, // Further reduced from 100
              height: 80, // Further reduced from 100
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 40, // Further reduced from 50
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16), // Further reduced from 24
            // Title
            Text(
              'No Roommate Requests Yet',
              style: TextStyle(
                fontSize: 18, // Further reduced from 20
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6), // Further reduced from 8
            // Description
            Text(
              'Start your roommate search by creating your first request. Share your preferences and find the perfect roommate match.',
              style: TextStyle(
                fontSize: 13, // Further reduced from 14
                color: Colors.grey[600],
                height: 1.3, // Further reduced from 1.4
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16), // Further reduced from 24
            // Add Button
            ElevatedButton.icon(
              onPressed: onAddNew,
              icon: const Icon(
                Icons.add_rounded,
                size: 16, // Further reduced from 18
              ), // Reduced icon size
              label: const Text(
                'Create Roommate Request',
                style: TextStyle(fontSize: 13), // Further reduced from 14
              ), // Reduced font size
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Further reduced from 20
                  vertical: 10, // Further reduced from 12
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Further reduced from 10
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16), // Further reduced from 20
            // Tips
            Container(
              padding: const EdgeInsets.all(10), // Further reduced from 12
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(
                  8,
                ), // Further reduced from 10
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue[600],
                        size: 16, // Further reduced from 18
                      ),
                      const SizedBox(width: 4), // Further reduced from 6
                      Text(
                        'Tips for Better Matches',
                        style: TextStyle(
                          fontSize: 12, // Further reduced from 13
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Further reduced from 6
                  Text(
                    '• Be specific about your budget and location preferences\n'
                    '• Share your lifestyle habits and sleep schedule\n'
                    '• Include photos to make your profile more appealing\n'
                    '• Mention your study habits and social preferences',
                    style: TextStyle(
                      fontSize: 10, // Further reduced from 11
                      color: Colors.blue[700],
                      height: 1.2, // Further reduced from 1.3
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16), // Further reduced from 20
          ],
        ),
      ),
    );
  }
}
