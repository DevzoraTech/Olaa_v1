// Presentation Layer - Profile Summary Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/roommate_request_model.dart';

class ProfileSummary extends StatelessWidget {
  final RoommateRequest request;
  final VoidCallback onProfileTap;

  const ProfileSummary({
    super.key,
    required this.request,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture and Basic Info
                Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child:
                          request.profilePictureUrl != null &&
                                  request.profilePictureUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  request.profilePictureUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'DEBUG: ProfileSummary - Failed to load profile picture: $error',
                                    );
                                    print(
                                      'DEBUG: ProfileSummary - Profile picture URL: ${request.profilePictureUrl}',
                                    );
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                              : _buildDefaultAvatar(),
                    ),
                    const SizedBox(width: 16),

                    // Name and Campus Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.campusAndYear,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  request.isActive
                                      ? Colors.green[100]
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              request.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    request.isActive
                                        ? Colors.green[700]
                                        : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Ago
                    Text(
                      request.timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bio
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        request.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tap to view full profile hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to view full profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        request.studentName.isNotEmpty
            ? request.studentName[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
