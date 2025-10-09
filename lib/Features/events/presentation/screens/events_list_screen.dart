// Presentation Layer - Events List Screen
import 'package:flutter/material.dart';
import '../widgets/events_header.dart';
import '../widgets/events_category_tabs.dart';
import '../widgets/upcoming_events.dart';
import '../widgets/events_list.dart';
import 'events_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Most Recent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter functionality
            },
            icon: Icon(Icons.tune_rounded, color: Colors.grey[600], size: 22),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to create event screen
            },
            icon: Icon(Icons.add_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Events Header with Search
          EventsHeader(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterPressed: () {
              // TODO: Show filter modal
            },
          ),

          // Category Tabs
          EventsCategoryTabs(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          // Scrollable Content with Upcoming Events and Main Events
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Upcoming Events
                  const UpcomingEvents(),

                  // Main Events Feed
                  EventsList(
                    category: _selectedCategory,
                    searchQuery: _searchQuery,
                    sortBy: _sortBy,
                    onEventTap: (event) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EventsDetailScreen(event: event),
                        ),
                      );
                    },
                    onSortChanged: (sort) {
                      setState(() {
                        _sortBy = sort;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
