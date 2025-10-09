// Domain Models for Roommate Request Steps
import 'package:flutter/material.dart';

enum RoommateRequestStep {
  personalInfo,
  accommodationDetails,
  lifestylePreferences,
  roommatePreferences,
  contactAndPhotos,
  reviewAndSubmit,
}

class StepData {
  final RoommateRequestStep step;
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const StepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
    this.isActive = false,
  });

  StepData copyWith({bool? isCompleted, bool? isActive}) {
    return StepData(
      step: step,
      title: title,
      description: description,
      icon: icon,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}

class PersonalInfoData {
  final String bio;
  final String profilePictureUrl;
  final String nickname;

  const PersonalInfoData({
    this.bio = '',
    this.profilePictureUrl = '',
    this.nickname = '',
  });

  PersonalInfoData copyWith({
    String? bio,
    String? profilePictureUrl,
    String? nickname,
  }) {
    return PersonalInfoData(
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      nickname: nickname ?? this.nickname,
    );
  }

  bool get isValid => bio.isNotEmpty;
}

class AccommodationData {
  final List<String>
  preferredLocations; // Changed to support multiple locations
  final double budgetMin;
  final double budgetMax;
  final String preferredHostel;
  final DateTime? moveInDate;
  final String urgency;
  final String leaseDuration;
  final List<String> desiredAmenities;
  final bool isAlreadyInHostel;
  final String currentHostel;
  final String hostelLocation;
  final double? hostelLatitude;
  final double? hostelLongitude;

  const AccommodationData({
    this.preferredLocations = const [], // Changed to list
    this.budgetMin = 0.0,
    this.budgetMax = 1000000.0,
    this.preferredHostel = '',
    this.moveInDate,
    this.urgency = '',
    this.leaseDuration = '',
    this.desiredAmenities = const [],
    this.isAlreadyInHostel = false,
    this.currentHostel = '',
    this.hostelLocation = '',
    this.hostelLatitude,
    this.hostelLongitude,
  });

  AccommodationData copyWith({
    List<String>? preferredLocations,
    double? budgetMin,
    double? budgetMax,
    String? preferredHostel,
    DateTime? moveInDate,
    String? urgency,
    String? leaseDuration,
    List<String>? desiredAmenities,
    bool? isAlreadyInHostel,
    String? currentHostel,
    String? hostelLocation,
    double? hostelLatitude,
    double? hostelLongitude,
  }) {
    return AccommodationData(
      preferredLocations: preferredLocations ?? this.preferredLocations,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      preferredHostel: preferredHostel ?? this.preferredHostel,
      moveInDate: moveInDate ?? this.moveInDate,
      urgency: urgency ?? this.urgency,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      desiredAmenities: desiredAmenities ?? this.desiredAmenities,
      isAlreadyInHostel: isAlreadyInHostel ?? this.isAlreadyInHostel,
      currentHostel: currentHostel ?? this.currentHostel,
      hostelLocation: hostelLocation ?? this.hostelLocation,
      hostelLatitude: hostelLatitude ?? this.hostelLatitude,
      hostelLongitude: hostelLongitude ?? this.hostelLongitude,
    );
  }

  bool get isValid {
    // If already in hostel, urgency, current hostel, and location are required
    if (isAlreadyInHostel) {
      return urgency.isNotEmpty &&
          currentHostel.isNotEmpty &&
          hostelLocation.isNotEmpty;
    }

    // If looking for new accommodation, require at least one location, budget, and urgency
    return preferredLocations.isNotEmpty &&
        budgetMin > 0 &&
        budgetMax > budgetMin &&
        urgency.isNotEmpty;
  }
}

class LifestyleData {
  final String sleepSchedule;
  final String lifestylePreference;
  final String smokingPreference;
  final String drinkingPreference;
  final String sharingStyle;
  final List<String> interests;

  const LifestyleData({
    this.sleepSchedule = '',
    this.lifestylePreference = '',
    this.smokingPreference = '',
    this.drinkingPreference = '',
    this.sharingStyle = '',
    this.interests = const [],
  });

  LifestyleData copyWith({
    String? sleepSchedule,
    String? lifestylePreference,
    String? smokingPreference,
    String? drinkingPreference,
    String? sharingStyle,
    List<String>? interests,
  }) {
    return LifestyleData(
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      lifestylePreference: lifestylePreference ?? this.lifestylePreference,
      smokingPreference: smokingPreference ?? this.smokingPreference,
      drinkingPreference: drinkingPreference ?? this.drinkingPreference,
      sharingStyle: sharingStyle ?? this.sharingStyle,
      interests: interests ?? this.interests,
    );
  }

  bool get isValid =>
      sleepSchedule.isNotEmpty &&
      lifestylePreference.isNotEmpty &&
      smokingPreference.isNotEmpty &&
      drinkingPreference.isNotEmpty &&
      sharingStyle.isNotEmpty;
}

class RoommatePreferencesData {
  final String preferredAgeRange;
  final String petPreference;
  final String otherPreferences;

  const RoommatePreferencesData({
    this.preferredAgeRange = '',
    this.petPreference = '',
    this.otherPreferences = '',
  });

  RoommatePreferencesData copyWith({
    String? preferredAgeRange,
    String? petPreference,
    String? otherPreferences,
  }) {
    return RoommatePreferencesData(
      preferredAgeRange: preferredAgeRange ?? this.preferredAgeRange,
      petPreference: petPreference ?? this.petPreference,
      otherPreferences: otherPreferences ?? this.otherPreferences,
    );
  }

  bool get isValid => true; // Optional fields
}

class ContactAndPhotosData {
  final String phoneNumber;
  final bool isPhoneShared;
  final List<String> photos;

  const ContactAndPhotosData({
    this.phoneNumber = '',
    this.isPhoneShared = false,
    this.photos = const [],
  });

  ContactAndPhotosData copyWith({
    String? phoneNumber,
    bool? isPhoneShared,
    List<String>? photos,
  }) {
    return ContactAndPhotosData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneShared: isPhoneShared ?? this.isPhoneShared,
      photos: photos ?? this.photos,
    );
  }

  bool get isValid => true; // Optional fields
}

class RoommateRequestFormData {
  final PersonalInfoData personalInfo;
  final AccommodationData accommodation;
  final LifestyleData lifestyle;
  final RoommatePreferencesData roommatePreferences;
  final ContactAndPhotosData contactAndPhotos;

  const RoommateRequestFormData({
    required this.personalInfo,
    required this.accommodation,
    required this.lifestyle,
    required this.roommatePreferences,
    required this.contactAndPhotos,
  });

  RoommateRequestFormData copyWith({
    PersonalInfoData? personalInfo,
    AccommodationData? accommodation,
    LifestyleData? lifestyle,
    RoommatePreferencesData? roommatePreferences,
    ContactAndPhotosData? contactAndPhotos,
  }) {
    return RoommateRequestFormData(
      personalInfo: personalInfo ?? this.personalInfo,
      accommodation: accommodation ?? this.accommodation,
      lifestyle: lifestyle ?? this.lifestyle,
      roommatePreferences: roommatePreferences ?? this.roommatePreferences,
      contactAndPhotos: contactAndPhotos ?? this.contactAndPhotos,
    );
  }

  bool isStepValid(RoommateRequestStep step) {
    switch (step) {
      case RoommateRequestStep.personalInfo:
        return personalInfo.isValid;
      case RoommateRequestStep.accommodationDetails:
        return accommodation.isValid;
      case RoommateRequestStep.lifestylePreferences:
        return lifestyle.isValid;
      case RoommateRequestStep.roommatePreferences:
        return roommatePreferences.isValid;
      case RoommateRequestStep.contactAndPhotos:
        return contactAndPhotos.isValid;
      case RoommateRequestStep.reviewAndSubmit:
        return personalInfo.isValid &&
            accommodation.isValid &&
            lifestyle.isValid;
    }
  }

  Map<String, dynamic> toPostingData() {
    return {
      'bio': personalInfo.bio,
      'nickname': personalInfo.nickname,
      'preferred_locations': accommodation.preferredLocations,
      'budget_min': accommodation.budgetMin,
      'budget_max': accommodation.budgetMax,
      'preferred_hostel': accommodation.preferredHostel,
      'move_in_date': accommodation.moveInDate?.toIso8601String(),
      'urgency': accommodation.urgency,
      'lease_duration': accommodation.leaseDuration,
      'is_already_in_hostel': accommodation.isAlreadyInHostel,
      'current_hostel': accommodation.currentHostel,
      'hostel_location': accommodation.hostelLocation,
      'hostel_latitude': accommodation.hostelLatitude,
      'hostel_longitude': accommodation.hostelLongitude,
      'sleep_schedule': lifestyle.sleepSchedule,
      'lifestyle_preference': lifestyle.lifestylePreference,
      'smoking_preference': lifestyle.smokingPreference,
      'drinking_preference': lifestyle.drinkingPreference,
      'sharing_style': lifestyle.sharingStyle,
      'preferred_age_range': roommatePreferences.preferredAgeRange,
      'pet_preference': roommatePreferences.petPreference,
      'other_preferences': roommatePreferences.otherPreferences,
      'phone_number': contactAndPhotos.phoneNumber,
      'is_phone_shared': contactAndPhotos.isPhoneShared,
    };
  }
}

class RoommateRequestConstants {
  static const List<StepData> steps = [
    StepData(
      step: RoommateRequestStep.personalInfo,
      title: 'Personal Info',
      description: 'Tell us about yourself',
      icon: Icons.person_outline_rounded,
    ),
    StepData(
      step: RoommateRequestStep.accommodationDetails,
      title: 'Accommodation',
      description: 'Your housing preferences',
      icon: Icons.home_outlined,
    ),
    StepData(
      step: RoommateRequestStep.lifestylePreferences,
      title: 'Lifestyle',
      description: 'Your daily habits & preferences',
      icon: Icons.self_improvement_outlined,
    ),
    StepData(
      step: RoommateRequestStep.roommatePreferences,
      title: 'Roommate',
      description: 'What you\'re looking for',
      icon: Icons.people_outline_rounded,
    ),
    StepData(
      step: RoommateRequestStep.contactAndPhotos,
      title: 'Contact & Photos',
      description: 'Share your details & photos',
      icon: Icons.contact_phone_outlined,
    ),
    StepData(
      step: RoommateRequestStep.reviewAndSubmit,
      title: 'Review',
      description: 'Review & submit your request',
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  static const List<String> urgencyOptions = [
    'Very Urgent',
    'Urgent',
    'Moderate',
    'Flexible',
  ];

  static const List<String> leaseDurationOptions = [
    '1 Semester',
    '2 Semesters',
    '3 Semesters',
    '4 Semesters',
    '5+ Semesters',
    'Flexible',
  ];

  static const List<String> sleepScheduleOptions = [
    'Early Riser',
    'Night Owl',
    'Flexible',
  ];

  static const List<String> lifestyleOptions = [
    'Quiet',
    'Social',
    'Music Lover',
    'Study Focused',
  ];

  static const List<String> smokingOptions = [
    'Non-smoker',
    'Smoker',
    'Occasional',
  ];

  static const List<String> drinkingOptions = [
    'Non-drinker',
    'Social Drinker',
    'Regular Drinker',
  ];

  static const List<String> sharingStyleOptions = [
    'Private',
    'Okay with Visitors',
    'Very Social',
  ];

  static const List<String> interestOptions = [
    'Sports',
    'Music',
    'Gaming',
    'Reading',
    'Movies',
    'Cooking',
    'Fitness',
    'Art',
    'Travel',
    'Photography',
    'Technology',
    'Fashion',
  ];

  static const List<String> amenityOptions = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Gym',
    'Study Room',
    'Common Area',
    'Balcony',
    'Garden',
  ];
}
