// Domain Layer - Roommate Request Models
import 'package:flutter/material.dart';

enum SleepSchedule { earlyRiser, nightOwl, flexible }

enum LifestylePreference { quiet, social, musicLover, partyLover, studious }

enum SmokingPreference { nonSmoker, smoker, okayWithSmoking }

enum DrinkingPreference {
  nonDrinker,
  socialDrinker,
  regularDrinker,
  okayWithDrinking,
}

enum SharingStyle { private, okayWithVisitors, verySocial, minimalInteraction }

enum RequestStatus { active, matched, expired, cancelled }

class CompatibilityInfo {
  final SleepSchedule sleepSchedule;
  final LifestylePreference lifestylePreference;
  final SmokingPreference smokingPreference;
  final DrinkingPreference drinkingPreference;
  final SharingStyle sharingStyle;
  final int? compatibilityScore; // 0-100 percentage

  const CompatibilityInfo({
    required this.sleepSchedule,
    required this.lifestylePreference,
    required this.smokingPreference,
    required this.drinkingPreference,
    required this.sharingStyle,
    this.compatibilityScore,
  });

  String get sleepScheduleText {
    switch (sleepSchedule) {
      case SleepSchedule.earlyRiser:
        return 'Early Riser (6-8 AM)';
      case SleepSchedule.nightOwl:
        return 'Night Owl (11 PM-1 AM)';
      case SleepSchedule.flexible:
        return 'Flexible Schedule';
    }
  }

  String get lifestyleText {
    switch (lifestylePreference) {
      case LifestylePreference.quiet:
        return 'Quiet & Peaceful';
      case LifestylePreference.social:
        return 'Social & Friendly';
      case LifestylePreference.musicLover:
        return 'Music Enthusiast';
      case LifestylePreference.partyLover:
        return 'Party Lover';
      case LifestylePreference.studious:
        return 'Studious & Focused';
    }
  }

  String get smokingText {
    switch (smokingPreference) {
      case SmokingPreference.nonSmoker:
        return 'Non-Smoker';
      case SmokingPreference.smoker:
        return 'Smoker';
      case SmokingPreference.okayWithSmoking:
        return 'Okay with Smoking';
    }
  }

  String get drinkingText {
    switch (drinkingPreference) {
      case DrinkingPreference.nonDrinker:
        return 'Non-Drinker';
      case DrinkingPreference.socialDrinker:
        return 'Social Drinker';
      case DrinkingPreference.regularDrinker:
        return 'Regular Drinker';
      case DrinkingPreference.okayWithDrinking:
        return 'Okay with Drinking';
    }
  }

  String get sharingText {
    switch (sharingStyle) {
      case SharingStyle.private:
        return 'Prefers Privacy';
      case SharingStyle.okayWithVisitors:
        return 'Okay with Visitors';
      case SharingStyle.verySocial:
        return 'Very Social';
      case SharingStyle.minimalInteraction:
        return 'Minimal Interaction';
    }
  }
}

class RequestDetails {
  final String preferredLocation;
  final String budgetRange;
  final String? preferredHostel;
  final DateTime? moveInDate;
  final String urgency; // "Immediately", "Next Semester", etc.
  final String leaseDuration;

  const RequestDetails({
    required this.preferredLocation,
    required this.budgetRange,
    this.preferredHostel,
    this.moveInDate,
    required this.urgency,
    required this.leaseDuration,
  });
}

class RoommateRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String? nickname;
  final String campus;
  final String yearOfStudy;
  final String bio;
  final String? profilePictureUrl;
  final RequestDetails requestDetails;
  final CompatibilityInfo compatibilityInfo;
  final List<String> photos;
  final List<String> hostelListings;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phoneNumber;
  final bool isPhoneShared;

  const RoommateRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.nickname,
    required this.campus,
    required this.yearOfStudy,
    required this.bio,
    this.profilePictureUrl,
    required this.requestDetails,
    required this.compatibilityInfo,
    this.photos = const [],
    this.hostelListings = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.isPhoneShared = false,
  });

  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return '$studentName "$nickname"';
    }
    return studentName;
  }

  String get campusAndYear {
    return '$campus • $yearOfStudy';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isActive => status == RequestStatus.active;
  bool get isMatched => status == RequestStatus.matched;
  bool get isExpired => status == RequestStatus.expired;
  bool get isCancelled => status == RequestStatus.cancelled;
}
