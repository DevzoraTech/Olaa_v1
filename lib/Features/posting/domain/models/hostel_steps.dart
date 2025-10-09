// Domain Layer - Hostel Posting Steps Data Models
import 'package:flutter/material.dart';

// Step 1: Basic Information
class HostelBasicInfoData {
  final String title;
  final String description;
  final String address;
  final String contactInfo;
  final String campus;

  const HostelBasicInfoData({
    this.title = '',
    this.description = '',
    this.address = '',
    this.contactInfo = '',
    this.campus = '',
  });

  HostelBasicInfoData copyWith({
    String? title,
    String? description,
    String? address,
    String? contactInfo,
    String? campus,
  }) {
    return HostelBasicInfoData(
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      contactInfo: contactInfo ?? this.contactInfo,
      campus: campus ?? this.campus,
    );
  }

  bool get isValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        contactInfo.trim().isNotEmpty &&
        campus.trim().isNotEmpty;
  }
}

// Step 2: Room Details
class HostelRoomDetailsData {
  final String roomType;
  final String genderPreference;
  final String furnishing;
  final String utilities;
  final int capacity;
  final double roomSize;

  const HostelRoomDetailsData({
    this.roomType = '',
    this.genderPreference = '',
    this.furnishing = '',
    this.utilities = '',
    this.capacity = 1,
    this.roomSize = 0.0,
  });

  HostelRoomDetailsData copyWith({
    String? roomType,
    String? genderPreference,
    String? furnishing,
    String? utilities,
    int? capacity,
    double? roomSize,
  }) {
    return HostelRoomDetailsData(
      roomType: roomType ?? this.roomType,
      genderPreference: genderPreference ?? this.genderPreference,
      furnishing: furnishing ?? this.furnishing,
      utilities: utilities ?? this.utilities,
      capacity: capacity ?? this.capacity,
      roomSize: roomSize ?? this.roomSize,
    );
  }

  bool get isValid {
    return roomType.isNotEmpty &&
        genderPreference.isNotEmpty &&
        furnishing.isNotEmpty &&
        utilities.isNotEmpty &&
        capacity > 0;
  }
}

// Step 3: Pricing & Terms
class HostelPricingData {
  final double monthlyRent;
  final double securityDeposit;
  final String currency;
  final String paymentSchedule;
  final bool utilitiesIncluded;
  final double utilitiesCost;
  final String leaseDuration;
  final String moveInDate;

  const HostelPricingData({
    this.monthlyRent = 0.0,
    this.securityDeposit = 0.0,
    this.currency = 'UGX',
    this.paymentSchedule = 'Monthly',
    this.utilitiesIncluded = false,
    this.utilitiesCost = 0.0,
    this.leaseDuration = '',
    this.moveInDate = '',
  });

  HostelPricingData copyWith({
    double? monthlyRent,
    double? securityDeposit,
    String? currency,
    String? paymentSchedule,
    bool? utilitiesIncluded,
    double? utilitiesCost,
    String? leaseDuration,
    String? moveInDate,
  }) {
    return HostelPricingData(
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      currency: currency ?? this.currency,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      utilitiesIncluded: utilitiesIncluded ?? this.utilitiesIncluded,
      utilitiesCost: utilitiesCost ?? this.utilitiesCost,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      moveInDate: moveInDate ?? this.moveInDate,
    );
  }

  bool get isValid {
    return monthlyRent > 0 &&
        securityDeposit >= 0 &&
        currency.isNotEmpty &&
        paymentSchedule.isNotEmpty &&
        leaseDuration.isNotEmpty;
  }
}

// Step 4: Amenities & Features
class HostelAmenitiesData {
  final List<String> amenities;
  final List<String> nearbyFacilities;
  final String parkingInfo;
  final String securityFeatures;
  final String internetSpeed;
  final String laundryFacilities;

  const HostelAmenitiesData({
    this.amenities = const [],
    this.nearbyFacilities = const [],
    this.parkingInfo = '',
    this.securityFeatures = '',
    this.internetSpeed = '',
    this.laundryFacilities = '',
  });

  HostelAmenitiesData copyWith({
    List<String>? amenities,
    List<String>? nearbyFacilities,
    String? parkingInfo,
    String? securityFeatures,
    String? internetSpeed,
    String? laundryFacilities,
  }) {
    return HostelAmenitiesData(
      amenities: amenities ?? this.amenities,
      nearbyFacilities: nearbyFacilities ?? this.nearbyFacilities,
      parkingInfo: parkingInfo ?? this.parkingInfo,
      securityFeatures: securityFeatures ?? this.securityFeatures,
      internetSpeed: internetSpeed ?? this.internetSpeed,
      laundryFacilities: laundryFacilities ?? this.laundryFacilities,
    );
  }

  bool get isValid {
    return amenities.isNotEmpty;
  }
}

// Step 5: Rules & Policies
class HostelRulesData {
  final List<String> houseRules;
  final String additionalRules;
  final String visitorPolicy;
  final String smokingPolicy;
  final String petPolicy;
  final String noisePolicy;
  final String cleaningPolicy;

  const HostelRulesData({
    this.houseRules = const [],
    this.additionalRules = '',
    this.visitorPolicy = '',
    this.smokingPolicy = '',
    this.petPolicy = '',
    this.noisePolicy = '',
    this.cleaningPolicy = '',
  });

  HostelRulesData copyWith({
    List<String>? houseRules,
    String? additionalRules,
    String? visitorPolicy,
    String? smokingPolicy,
    String? petPolicy,
    String? noisePolicy,
    String? cleaningPolicy,
  }) {
    return HostelRulesData(
      houseRules: houseRules ?? this.houseRules,
      additionalRules: additionalRules ?? this.additionalRules,
      visitorPolicy: visitorPolicy ?? this.visitorPolicy,
      smokingPolicy: smokingPolicy ?? this.smokingPolicy,
      petPolicy: petPolicy ?? this.petPolicy,
      noisePolicy: noisePolicy ?? this.noisePolicy,
      cleaningPolicy: cleaningPolicy ?? this.cleaningPolicy,
    );
  }

  bool get isValid {
    return houseRules.isNotEmpty;
  }
}

// Step 6: Photos & Media
class HostelPhotosData {
  final List<String> photos;
  final String virtualTour;
  final String floorPlan;
  final String neighborhoodMap;

  const HostelPhotosData({
    this.photos = const [],
    this.virtualTour = '',
    this.floorPlan = '',
    this.neighborhoodMap = '',
  });

  HostelPhotosData copyWith({
    List<String>? photos,
    String? virtualTour,
    String? floorPlan,
    String? neighborhoodMap,
  }) {
    return HostelPhotosData(
      photos: photos ?? this.photos,
      virtualTour: virtualTour ?? this.virtualTour,
      floorPlan: floorPlan ?? this.floorPlan,
      neighborhoodMap: neighborhoodMap ?? this.neighborhoodMap,
    );
  }

  bool get isValid {
    return photos.isNotEmpty;
  }
}

// Main Form Data Container
class HostelFormData {
  final HostelBasicInfoData basicInfo;
  final HostelRoomDetailsData roomDetails;
  final HostelPricingData pricing;
  final HostelAmenitiesData amenities;
  final HostelRulesData rules;
  final HostelPhotosData photos;

  const HostelFormData({
    this.basicInfo = const HostelBasicInfoData(),
    this.roomDetails = const HostelRoomDetailsData(),
    this.pricing = const HostelPricingData(),
    this.amenities = const HostelAmenitiesData(),
    this.rules = const HostelRulesData(),
    this.photos = const HostelPhotosData(),
  });

  HostelFormData copyWith({
    HostelBasicInfoData? basicInfo,
    HostelRoomDetailsData? roomDetails,
    HostelPricingData? pricing,
    HostelAmenitiesData? amenities,
    HostelRulesData? rules,
    HostelPhotosData? photos,
  }) {
    return HostelFormData(
      basicInfo: basicInfo ?? this.basicInfo,
      roomDetails: roomDetails ?? this.roomDetails,
      pricing: pricing ?? this.pricing,
      amenities: amenities ?? this.amenities,
      rules: rules ?? this.rules,
      photos: photos ?? this.photos,
    );
  }

  bool isStepValid(HostelStep step) {
    switch (step) {
      case HostelStep.basicInfo:
        return basicInfo.isValid;
      case HostelStep.roomDetails:
        return roomDetails.isValid;
      case HostelStep.pricing:
        return pricing.isValid;
      case HostelStep.amenities:
        return amenities.isValid;
      case HostelStep.rules:
        return rules.isValid;
      case HostelStep.photos:
        return photos.isValid;
      case HostelStep.review:
        return basicInfo.isValid &&
            roomDetails.isValid &&
            pricing.isValid &&
            amenities.isValid &&
            rules.isValid &&
            photos.isValid;
    }
  }

  Map<String, dynamic> toPostingData({bool includeMedia = true}) {
    final data = {
      'title': basicInfo.title,
      'name': basicInfo.title, // Map title to name for database
      'description': basicInfo.description,
      'address': basicInfo.address,
      'contact_info': basicInfo.contactInfo,
      'campus': basicInfo.campus,
      'room_type': roomDetails.roomType,
      'gender_preference': roomDetails.genderPreference,
      'furnishing': roomDetails.furnishing,
      'utilities': roomDetails.utilities,
      'capacity': roomDetails.capacity,
      'room_size': roomDetails.roomSize,
      'monthly_rent': pricing.monthlyRent,
      'price_per_month': pricing.monthlyRent, // Map to database field
      'security_deposit': pricing.securityDeposit,
      'currency': pricing.currency,
      'payment_schedule': pricing.paymentSchedule,
      'utilities_included': pricing.utilitiesIncluded,
      'utilities_cost': pricing.utilitiesCost,
      'lease_duration': pricing.leaseDuration,
      'move_in_date': pricing.moveInDate,
      'amenities': amenities.amenities,
      'nearby_facilities': amenities.nearbyFacilities,
      'parking_info': amenities.parkingInfo,
      'security_features': amenities.securityFeatures,
      'internet_speed': amenities.internetSpeed,
      'laundry_facilities': amenities.laundryFacilities,
      'house_rules': rules.houseRules,
      'additional_rules': rules.additionalRules,
      'visitor_policy': rules.visitorPolicy,
      'smoking_policy': rules.smokingPolicy,
      'pet_policy': rules.petPolicy,
      'noise_policy': rules.noisePolicy,
      'cleaning_policy': rules.cleaningPolicy,
    };

    // Only include media fields if requested (for cases where we're not uploading)
    if (includeMedia) {
      data.addAll({
        'photos': photos.photos,
        'virtual_tour': photos.virtualTour,
        'floor_plan': photos.floorPlan,
        'neighborhood_map': photos.neighborhoodMap,
      });
    }

    return data;
  }
}

// Step Enumeration
enum HostelStep {
  basicInfo,
  roomDetails,
  pricing,
  amenities,
  rules,
  photos,
  review,
}

// Step Data for Progress Tracking
class HostelStepData {
  final HostelStep step;
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const HostelStepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
    this.isActive = false,
  });

  HostelStepData copyWith({
    HostelStep? step,
    String? title,
    String? description,
    IconData? icon,
    bool? isCompleted,
    bool? isActive,
  }) {
    return HostelStepData(
      step: step ?? this.step,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Constants for Hostel Steps
class HostelConstants {
  static const List<HostelStepData> steps = [
    HostelStepData(
      step: HostelStep.basicInfo,
      title: 'Basic Info',
      description: 'Hostel details and contact',
      icon: Icons.info_outline_rounded,
    ),
    HostelStepData(
      step: HostelStep.roomDetails,
      title: 'Room Details',
      description: 'Room type and specifications',
      icon: Icons.bed_rounded,
    ),
    HostelStepData(
      step: HostelStep.pricing,
      title: 'Pricing & Terms',
      description: 'Rent and payment details',
      icon: Icons.attach_money_rounded,
    ),
    HostelStepData(
      step: HostelStep.amenities,
      title: 'Amenities',
      description: 'Features and facilities',
      icon: Icons.home_work_outlined,
    ),
    HostelStepData(
      step: HostelStep.rules,
      title: 'Rules & Policies',
      description: 'House rules and policies',
      icon: Icons.rule_rounded,
    ),
    HostelStepData(
      step: HostelStep.photos,
      title: 'Photos & Media',
      description: 'Images and virtual tour',
      icon: Icons.photo_camera_rounded,
    ),
    HostelStepData(
      step: HostelStep.review,
      title: 'Review & Submit',
      description: 'Review and submit listing',
      icon: Icons.check_circle_outline_rounded,
    ),
  ];
}
