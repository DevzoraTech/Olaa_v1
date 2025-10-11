// Domain Models - Marketplace Posting Steps
import 'package:flutter/material.dart';

// Step Enum
enum MarketplaceStep {
  itemInfo,
  itemDetails,
  pricingAndCondition,
  photosAndContact,
  reviewAndSubmit,
}

// Step Data Model
class StepData {
  final MarketplaceStep step;
  final String title;
  final String description;
  final IconData icon;

  const StepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Item Information Step Data
class ItemInfoData {
  final String title;
  final String description;
  final String category;

  const ItemInfoData({
    this.title = '',
    this.description = '',
    this.category = '',
  });

  ItemInfoData copyWith({
    String? title,
    String? description,
    String? category,
  }) {
    return ItemInfoData(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  bool get isValid {
    return title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        category.isNotEmpty;
  }
}

// Item Details Step Data
class ItemDetailsData {
  final String brand;
  final String model;
  final String specifications;
  final List<String> tags;

  const ItemDetailsData({
    this.brand = '',
    this.model = '',
    this.specifications = '',
    this.tags = const [],
  });

  ItemDetailsData copyWith({
    String? brand,
    String? model,
    String? specifications,
    List<String>? tags,
  }) {
    return ItemDetailsData(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
    );
  }

  bool get isValid {
    return true; // All fields are optional
  }
}

// Pricing and Condition Step Data
class PricingAndConditionData {
  final double price;
  final String currency;
  final String condition;
  final String paymentMethod;
  final bool isNegotiable;

  const PricingAndConditionData({
    this.price = 0.0,
    this.currency = 'UGX',
    this.condition = '',
    this.paymentMethod = '',
    this.isNegotiable = false,
  });

  PricingAndConditionData copyWith({
    double? price,
    String? currency,
    String? condition,
    String? paymentMethod,
    bool? isNegotiable,
  }) {
    return PricingAndConditionData(
      price: price ?? this.price,
      currency: currency ?? this.currency,
      condition: condition ?? this.condition,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isNegotiable: isNegotiable ?? this.isNegotiable,
    );
  }

  bool get isValid {
    return price > 0 && condition.isNotEmpty && paymentMethod.isNotEmpty;
  }
}

// Photos and Contact Step Data
class PhotosAndContactData {
  final List<String> photos;
  final String contactPhone;
  final String contactEmail;
  final bool isPhoneShared;
  final bool isEmailShared;

  const PhotosAndContactData({
    this.photos = const [],
    this.contactPhone = '',
    this.contactEmail = '',
    this.isPhoneShared = false,
    this.isEmailShared = false,
  });

  PhotosAndContactData copyWith({
    List<String>? photos,
    String? contactPhone,
    String? contactEmail,
    bool? isPhoneShared,
    bool? isEmailShared,
  }) {
    return PhotosAndContactData(
      photos: photos ?? this.photos,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      isPhoneShared: isPhoneShared ?? this.isPhoneShared,
      isEmailShared: isEmailShared ?? this.isEmailShared,
    );
  }

  bool get isValid {
    return photos.isNotEmpty; // At least one photo is required
  }
}

// Main Form Data Model
class MarketplaceFormData {
  final ItemInfoData itemInfo;
  final ItemDetailsData itemDetails;
  final PricingAndConditionData pricingAndCondition;
  final PhotosAndContactData photosAndContact;

  const MarketplaceFormData({
    required this.itemInfo,
    required this.itemDetails,
    required this.pricingAndCondition,
    required this.photosAndContact,
  });

  MarketplaceFormData copyWith({
    ItemInfoData? itemInfo,
    ItemDetailsData? itemDetails,
    PricingAndConditionData? pricingAndCondition,
    PhotosAndContactData? photosAndContact,
  }) {
    return MarketplaceFormData(
      itemInfo: itemInfo ?? this.itemInfo,
      itemDetails: itemDetails ?? this.itemDetails,
      pricingAndCondition: pricingAndCondition ?? this.pricingAndCondition,
      photosAndContact: photosAndContact ?? this.photosAndContact,
    );
  }

  bool get isValid {
    return itemInfo.isValid &&
        itemDetails.isValid &&
        pricingAndCondition.isValid &&
        photosAndContact.isValid;
  }

  Map<String, dynamic> toPostingData() {
    return {
      'title': itemInfo.title,
      'description': itemInfo.description,
      'category': itemInfo.category,
      'brand': itemDetails.brand,
      'model': itemDetails.model,
      'specifications': itemDetails.specifications,
      'tags': itemDetails.tags,
      'price': pricingAndCondition.price,
      'currency': pricingAndCondition.currency,
      'condition': pricingAndCondition.condition,
      'payment_method': pricingAndCondition.paymentMethod,
      'is_negotiable': pricingAndCondition.isNegotiable,
      'contact_phone': photosAndContact.contactPhone,
      'contact_email': photosAndContact.contactEmail,
      'is_phone_shared': photosAndContact.isPhoneShared,
      'is_email_shared': photosAndContact.isEmailShared,
    };
  }
}

// Constants
class MarketplaceConstants {
  static const List<StepData> steps = [
    StepData(
      step: MarketplaceStep.itemInfo,
      title: 'Item Information',
      description: 'Basic details about your item',
      icon: Icons.info_outline_rounded,
    ),
    StepData(
      step: MarketplaceStep.itemDetails,
      title: 'Item Details',
      description: 'Additional specifications and tags',
      icon: Icons.details_outlined,
    ),
    StepData(
      step: MarketplaceStep.pricingAndCondition,
      title: 'Pricing & Condition',
      description: 'Set your price and item condition',
      icon: Icons.attach_money_rounded,
    ),
    StepData(
      step: MarketplaceStep.photosAndContact,
      title: 'Photos & Contact',
      description: 'Add photos and contact information',
      icon: Icons.photo_camera_rounded,
    ),
    StepData(
      step: MarketplaceStep.reviewAndSubmit,
      title: 'Review & Submit',
      description: 'Review your listing and submit',
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  static const List<String> categories = [
    'Electronics',
    'Books & Study Materials',
    'Clothing & Fashion',
    'Furniture & Home',
    'Sports & Fitness',
    'Beauty & Personal Care',
    'Food & Beverages',
    'Transportation',
    'Services',
    'Other',
  ];

  static const List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Mobile Money',
    'Bank Transfer',
    'Card Payment',
    'All Methods',
  ];

  static const List<String> currencies = ['UGX', 'USD', 'EUR'];
}







