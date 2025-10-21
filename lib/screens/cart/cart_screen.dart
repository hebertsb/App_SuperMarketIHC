import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../data/mock_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Carrito'),
          backgroundColor: const Color(0xFFE53935),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu carrito está vacío',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega productos para empezar tu pedido',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Explorar Productos'),
              ),
            ],
          ),
        ),
      );
    }

    // Si hay items en el carrito, mostrar por tienda
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: const Color(0xFFE53935),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearCartDialog(context, ref);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: cart.keys.length,
        itemBuilder: (context, index) {
          final storeId = cart.keys.elementAt(index);
          final items = cart[storeId]!;
          final store = MockData.getStores().firstWhere((s) => s.id == storeId);

          return _StoreCartSection(
            storeId: storeId,
            storeName: store.name,
            items: items,
            deliveryFee: store.deliveryFee,
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar todo el carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

class _StoreCartSection extends ConsumerWidget {
  final String storeId;
  final String storeName;
  final List items;
  final double deliveryFee;

  const _StoreCartSection({
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.read(cartProvider.notifier).getStoreSubtotal(storeId);
    final total = subtotal + deliveryFee;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la tienda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: Color(0xFFE53935)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clearStoreCart(storeId);
                  },
                  child: const Text('Vaciar'),
                ),
              ],
            ),
          ),

          // Lista de productos
          ...items.map((item) => _CartItemTile(
                item: item,
                storeId: storeId,
              )),

          const Divider(),

          // Resumen de costos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(
                      'Bs ${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Costo de envío:'),
                    Text(
                      'Bs ${deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bs ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/checkout/$storeId');
                    },
                    child: const Text('Proceder al Pago'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item;
  final String storeId;

  const _CartItemTile({
    required this.item,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final producto = item.producto;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          color: Colors.grey[200],
          child: producto.imagenes.isNotEmpty &&
                  producto.imagenes.first.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: producto.imagenes.first,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image, color: Colors.grey),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
      ),
      title: Text(
        producto.nombre,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bs ${producto.precio.toStringAsFixed(2)} / ${producto.unidad}'),
          if (item.notas != null && item.notas!.isNotEmpty)
            Text(
              'Nota: ${item.notas}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .updateQuantity(storeId, producto.id, item.cantidad - 1);
            },
            color: const Color(0xFFE53935),
          ),
          Text(
            '${item.cantidad}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .updateQuantity(storeId, producto.id, item.cantidad + 1);
            },
            color: const Color(0xFFE53935),
          ),
        ],
      ),
    );
  }
}