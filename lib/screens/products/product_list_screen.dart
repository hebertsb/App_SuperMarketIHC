import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar.dart';

class ProductListScreen extends ConsumerWidget {
  final String storeId;

  const ProductListScreen({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: const Color(0xFFE53935),
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFFE53935),
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              hintText: 'Buscar productos...',
              onChanged: (value) {
                // Implementar búsqueda
              },
            ),
          ),
          
          // Categories filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                _buildCategoryFilter('Todos', true),
                _buildCategoryFilter('Frutas', false),
                _buildCategoryFilter('Verduras', false),
                _buildCategoryFilter('Lácteos', false),
                _buildCategoryFilter('Carnes', false),
                const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Products grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                final product = _mockProducts[index];
                return ProductCard(
                  product: product,
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} agregado al carrito'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Implementar filtro
        },
        selectedColor: const Color(0xFFE53935).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFFE53935),
      ),
    );
  }
}

// Mock products data
final List<Product> _mockProducts = [
  Product(
    id: '1',
    storeId: '1',
    name: 'Manzana Roja',
    description: 'Manzanas rojas frescas del valle',
    price: 12.50,
    originalPrice: 15.00,
    images: ['assets/images/apple.jpg'],
    category: 'Frutas',
    unit: 'kg',
    stock: 50,
    isAvailable: true,
    rating: 4.5,
    reviewCount: 25,
  ),
  Product(
    id: '2',
    storeId: '1',
    name: 'Leche Entera',
    description: 'Leche fresca entera 1L',
    price: 8.50,
    images: ['assets/images/milk.jpg'],
    category: 'Lácteos',
    unit: 'litro',
    stock: 30,
    isAvailable: true,
    rating: 4.2,
    reviewCount: 18,
  ),
  Product(
    id: '3',
    storeId: '1',
    name: 'Pan Integral',
    description: 'Pan integral artesanal',
    price: 6.00,
    images: ['assets/images/bread.jpg'],
    category: 'Panadería',
    unit: 'unidad',
    stock: 15,
    isAvailable: true,
    rating: 4.8,
    reviewCount: 42,
  ),
  Product(
    id: '4',
    storeId: '1',
    name: 'Tomate',
    description: 'Tomates frescos del altiplano',
    price: 8.00,
    originalPrice: 10.00,
    images: ['assets/images/tomato.jpg'],
    category: 'Verduras',
    unit: 'kg',
    stock: 25,
    isAvailable: true,
    rating: 4.0,
    reviewCount: 12,
  ),
];