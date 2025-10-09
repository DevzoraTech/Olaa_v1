// Trending Carousel Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TrendingCarousel extends StatefulWidget {
  const TrendingCarousel({super.key});

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  // Different trending items with different colors and products
  final List<TrendingItem> _trendingItems = [
    TrendingItem(
      title: 'MacBook Pro M2',
      subtitle: '30% off • Limited time',
      badge: 'HOT DEAL',
      emoji: '💻',
      gradient: [Colors.orange[400]!, Colors.deepOrange[500]!],
      buttonColor: Colors.orange[700]!,
    ),
    TrendingItem(
      title: 'iPhone 15 Pro',
      subtitle: 'Free AirPods • Student offer',
      badge: 'EXCLUSIVE',
      emoji: '📱',
      gradient: [Colors.blue[400]!, Colors.indigo[500]!],
      buttonColor: Colors.blue[700]!,
    ),
    TrendingItem(
      title: 'Samsung Galaxy S24',
      subtitle: 'Trade-in bonus • Save more',
      badge: 'TRADE-IN',
      emoji: '📲',
      gradient: [Colors.purple[400]!, Colors.deepPurple[500]!],
      buttonColor: Colors.purple[700]!,
    ),
    TrendingItem(
      title: 'iPad Air 5th Gen',
      subtitle: 'Education discount • Free pencil',
      badge: 'EDUCATION',
      emoji: '📱',
      gradient: [Colors.green[400]!, Colors.teal[500]!],
      buttonColor: Colors.green[700]!,
    ),
    TrendingItem(
      title: 'Dell XPS 13',
      subtitle: 'Back to school • Extended warranty',
      badge: 'SCHOOL',
      emoji: '💻',
      gradient: [Colors.red[400]!, Colors.pink[500]!],
      buttonColor: Colors.red[700]!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Start auto-rotation
    _startAutoRotation();
  }

  void _startAutoRotation() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  void _nextPage() {
    _currentIndex++;
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: null, // Infinite scroll
            itemBuilder: (context, index) {
              final item = _trendingItems[index % _trendingItems.length];
              return _buildTrendingCard(item);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _trendingItems.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex % _trendingItems.length == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    _currentIndex % _trendingItems.length == index
                        ? AppTheme.primaryColor
                        : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(TrendingItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: item.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.badge,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'View Deal',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.buttonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    );
  }
}

class TrendingItem {
  final String title;
  final String subtitle;
  final String badge;
  final String emoji;
  final List<Color> gradient;
  final Color buttonColor;

  TrendingItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.emoji,
    required this.gradient,
    required this.buttonColor,
  });
}
