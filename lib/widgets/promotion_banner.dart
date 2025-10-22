import 'package:flutter/material.dart';
import 'package:supermarket_delivery_app/data/mock_data.dart';

class PromotionBanner extends StatelessWidget {
  final String? imagePath;
  const PromotionBanner({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Usar la imagen local si existe, si no, usar la primera imagen de productos destacados
    final productos = MockData.getProducts(null);
    final String fallbackImage =
        productos.isNotEmpty ? productos.first.imagenes.first : '';
    final String img = imagePath ?? 'assets/images/ofertas_semana_25.png';
    Widget imageWidget;
    if (img.startsWith('assets/') && img != '') {
      imageWidget = Image.asset(img, fit: BoxFit.cover);
    } else if (fallbackImage.startsWith('assets/')) {
      imageWidget = Image.asset(fallbackImage, fit: BoxFit.cover);
    } else if (fallbackImage.startsWith('http')) {
      imageWidget = Image.network(fallbackImage, fit: BoxFit.cover);
    } else {
      imageWidget = Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.image, size: 48, color: Colors.grey)),
      );
    }
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageWidget,
    );
  }
}
