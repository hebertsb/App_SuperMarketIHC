// lib/widgets/banner_carousel.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, this.aspectRatio = 0.28});

  /// Proporción alto/ancho para el banner (ej: 0.28)
  final double aspectRatio;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  List<String> banners = [];
  int _current = 0;
  late final PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0, viewportFraction: 1.0);
    _loadBannerImagesFromAssetManifest();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_controller.hasClients && banners.length > 1) {
        final next = (_current + 1) % banners.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadBannerImagesFromAssetManifest() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final imageKeys = manifestMap.keys
          .where((String key) => key.startsWith('assets/images/'))
          .where((k) =>
              k.toLowerCase().endsWith('.png') ||
              k.toLowerCase().endsWith('.jpg') ||
              k.toLowerCase().endsWith('.jpeg') ||
              k.toLowerCase().endsWith('.webp'))
          .toList()
        ..sort();
      setState(() {
        banners = List<String>.from(imageKeys);
      });
    } catch (e) {
      setState(() => banners = []);
      // debugPrint('Error cargando AssetManifest: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = width * widget.aspectRatio;

    if (banners.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: const Center(child: Text('No hay banners disponibles')),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.asset(
                  banners[i],
                  width: double.infinity,
                  height: height,
                  fit: BoxFit.cover,
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
              children: List.generate(banners.length, (i) {
                final bool active = _current == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.orange : Colors.white70,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: active
                        ? const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                                offset: Offset(0, 1))
                          ]
                        : null,
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
