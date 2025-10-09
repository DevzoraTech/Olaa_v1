// Presentation Layer - Event Image Carousel Widget
import 'package:flutter/material.dart';

class EventImageCarousel extends StatefulWidget {
  final List<String> images;

  const EventImageCarousel({super.key, required this.images});

  @override
  State<EventImageCarousel> createState() => _EventImageCarouselState();
}

class _EventImageCarouselState extends State<EventImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Stack(
        children: [
          // Image Carousel
          PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: Center(
                  child: Text(
                    widget.images[index],
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              );
            },
          ),

          // Page Indicators
          if (widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
