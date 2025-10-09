// Promotions Manager Widget
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class PromotionsManager extends StatefulWidget {
  final String filter;

  const PromotionsManager({super.key, required this.filter});

  @override
  State<PromotionsManager> createState() => _PromotionsManagerState();
}

class _PromotionsManagerState extends State<PromotionsManager> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Promotions Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon! Manage your promotional campaigns.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
