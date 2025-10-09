import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoommateRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSendMessage;

  const RoommateRequestCard({
    super.key,
    required this.request,
    this.onViewProfile,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      request['profileImage'] ??
                          'https://images.unsplash.com/photo-1592188657297-c6473609e988?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTkyNTc3MDB8&ixlib=rb-4.1.0&q=80&w=1080',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.indigo[600],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['name'] ?? 'Sarah Chen',
                        style: GoogleFonts.interTight(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['major'] ?? 'Computer Science • Junior',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tags
                      Wrap(
                        spacing: 8,
                        children:
                            (request['tags'] as List<String>? ??
                                    ['Non-smoker', 'Clean'])
                                .map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getTagColor(tag),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.indigo[700],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['description'] ??
                      'Looking for a roommate for Spring 2024 semester. I\'m a quiet student who loves cooking and keeping things organized. Prefer someone who shares similar lifestyle habits.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Budget and Move-in Info
                Row(
                  children: [
                    // Budget
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request['budget'] ?? '\$800-900/month',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Move-in Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Move-in',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request['moveInDate'] ?? 'January 2024',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View Profile Button
                SizedBox(
                  width: 120,
                  height: 40,
                  child: OutlinedButton(
                    onPressed:
                        onViewProfile ??
                        () {
                          Navigator.pushNamed(
                            context,
                            '/roommate-request',
                            arguments: {
                              'requestId': request['id'] ?? 'default_id',
                            },
                          );
                        },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Text(
                      'View Profile',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Send Message Button
                SizedBox(
                  width: 140,
                  height: 40,
                  child: ElevatedButton(
                    onPressed:
                        onSendMessage ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sending message to ${request['name']}',
                              ),
                              backgroundColor: Colors.indigo[600],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Text(
                      'Send Message',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'non-smoker':
        return Colors.green[50]!;
      case 'clean':
        return Colors.blue[50]!;
      case 'quiet':
        return Colors.purple[50]!;
      case 'social':
        return Colors.orange[50]!;
      case 'studious':
        return Colors.indigo[50]!;
      default:
        return Colors.grey[50]!;
    }
  }
}
