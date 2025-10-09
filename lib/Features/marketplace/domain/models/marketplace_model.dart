// Domain Layer - Marketplace Model
import 'package:flutter/material.dart';

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final String sellerName;
  final String sellerYear;
  final String category;
  final String image;
  final String timePosted;
  final int views;
  final String? badge;
  final bool isNegotiable;
  final List<String> images;
  final String condition;
  final String location;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerName,
    required this.sellerYear,
    required this.category,
    required this.image,
    required this.timePosted,
    required this.views,
    this.badge,
    required this.isNegotiable,
    this.images = const [],
    this.condition = 'Good',
    this.location = 'Campus',
  });
}

class MarketplaceCategory {
  final String name;
  final IconData icon;
  final Color color;
  final int itemCount;

  MarketplaceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.itemCount,
  });
}

class MarketplaceFilter {
  final String category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? location;
  final bool negotiableOnly;

  MarketplaceFilter({
    required this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.negotiableOnly = false,
  });
}

enum MarketplaceSortOption {
  mostRecent,
  lowestPrice,
  highestPrice,
  mostPopular,
}

class SellerProfile {
  final String id;
  final String name;
  final String year;
  final String major;
  final String? profileImageUrl;
  final double rating;
  final int totalSales;
  final bool isVerified;

  SellerProfile({
    required this.id,
    required this.name,
    required this.year,
    required this.major,
    this.profileImageUrl,
    required this.rating,
    required this.totalSales,
    required this.isVerified,
  });
}
