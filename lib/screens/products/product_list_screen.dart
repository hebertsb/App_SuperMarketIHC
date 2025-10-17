import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar.dart';
import '../../data/mock_data.dart';

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
            child: FutureBuilder<List<Product>>(
              future: _loadProducts(storeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
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

Future<List<Product>> _loadProducts(String storeId) async {
  // Simular un pequeño delay para mostrar el loading
  await Future.delayed(const Duration(milliseconds: 300));
  // Usar datos mock (funciona en web y nativo)
  return MockData.getProducts(storeId);
}