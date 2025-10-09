// Domain Layer - Event Model
import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String category;
  final String image;
  final String dateTime;
  final String location;
  final int rsvpCount;
  final String? tag;
  final String action;
  final bool isRsvpRequired;
  final List<String> images;
  final String? price;
  final String? contactInfo;
  final bool isOnline;
  final String? meetingLink;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.category,
    required this.image,
    required this.dateTime,
    required this.location,
    required this.rsvpCount,
    this.tag,
    required this.action,
    required this.isRsvpRequired,
    this.images = const [],
    this.price,
    this.contactInfo,
    this.isOnline = false,
    this.meetingLink,
  });
}

class EventCategory {
  final String name;
  final IconData icon;
  final Color color;
  final int eventCount;

  EventCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.eventCount,
  });
}

class EventFilter {
  final String category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? type;
  final String? location;
  final bool freeOnly;
  final bool onlineOnly;

  EventFilter({
    required this.category,
    this.startDate,
    this.endDate,
    this.type,
    this.location,
    this.freeOnly = false,
    this.onlineOnly = false,
  });
}

enum EventSortOption { mostRecent, soonestFirst, mostPopular, mostRsvps }

class EventOrganizer {
  final String id;
  final String name;
  final String type; // club, guild, department, etc.
  final String? logoUrl;
  final double rating;
  final int totalEvents;
  final bool isVerified;

  EventOrganizer({
    required this.id,
    required this.name,
    required this.type,
    this.logoUrl,
    required this.rating,
    required this.totalEvents,
    required this.isVerified,
  });
}

class EventRsvp {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final DateTime rsvpDate;
  final bool isAttending;
  final String? notes;

  EventRsvp({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.rsvpDate,
    required this.isAttending,
    this.notes,
  });
}
