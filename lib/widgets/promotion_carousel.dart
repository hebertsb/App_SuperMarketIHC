import 'package:flutter/material.dart';

class PromotionCarousel extends StatefulWidget {
  const PromotionCarousel({super.key});

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  final List<String> images = [
    // Ofertas de la semana 25% (local)
    'assets/images/ofertas_semana_25.png',
    'assets/images/promocion1.png',
    'assets/images/promocion2.png',
    'assets/images/promocion3.png',
  ];

  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
  Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      int nextIndex = (currentIndex + 1) % images.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        currentIndex = nextIndex;
      });
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.transparent,
                  child: images[index].startsWith('assets/')
                      ? Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
