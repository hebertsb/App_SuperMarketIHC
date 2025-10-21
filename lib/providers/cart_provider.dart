import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/producto.dart';

// Provider para el carrito agrupado por tienda
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, List<CartItem>>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<String, List<CartItem>>> {
  CartNotifier() : super({});

  // Agregar producto al carrito
  void addProduct(Producto producto, {int cantidad = 1, String? notas}) {
    final idTienda = producto.idTienda;
    final currentCart = Map<String, List<CartItem>>.from(state);
    
    if (!currentCart.containsKey(idTienda)) {
      currentCart[idTienda] = [];
    }

    final existingItemIndex = currentCart[idTienda]!
        .indexWhere((item) => item.producto.id == producto.id);

    if (existingItemIndex >= 0) {
      // Producto ya existe, actualizar cantidad
      final existingItem = currentCart[idTienda]![existingItemIndex];
      currentCart[idTienda]![existingItemIndex] = existingItem.copyWith(
        cantidad: existingItem.cantidad + cantidad,
        notas: notas ?? existingItem.notas,
      );
    } else {
      // Agregar nuevo producto
      currentCart[idTienda]!.add(CartItem(
        producto: producto,
        cantidad: cantidad,
        notas: notas,
      ));
    }

    state = currentCart;
  }

  // Actualizar cantidad de un producto
  void updateQuantity(String idTienda, String idProducto, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      removeProduct(idTienda, idProducto);
      return;
    }

    final currentCart = Map<String, List<CartItem>>.from(state);
    if (!currentCart.containsKey(idTienda)) return;

    final itemIndex = currentCart[idTienda]!
        .indexWhere((item) => item.producto.id == idProducto);

    if (itemIndex >= 0) {
      currentCart[idTienda]![itemIndex] = currentCart[idTienda]![itemIndex]
          .copyWith(cantidad: nuevaCantidad);
      state = currentCart;
    }
  }

  // Eliminar producto del carrito
  void removeProduct(String idTienda, String idProducto) {
    final currentCart = Map<String, List<CartItem>>.from(state);
    if (!currentCart.containsKey(idTienda)) return;

    currentCart[idTienda]!
        .removeWhere((item) => item.producto.id == idProducto);

    if (currentCart[idTienda]!.isEmpty) {
      currentCart.remove(idTienda);
    }

    state = currentCart;
  }

  // Limpiar carrito de una tienda específica
  void clearStoreCart(String idTienda) {
    final currentCart = Map<String, List<CartItem>>.from(state);
    currentCart.remove(idTienda);
    state = currentCart;
  }

  // Limpiar todo el carrito
  void clearAll() {
    state = {};
  }

  // Obtener items de una tienda específica
  List<CartItem> getStoreItems(String idTienda) {
    return state[idTienda] ?? [];
  }

  // Obtener subtotal de una tienda
  double getStoreSubtotal(String idTienda) {
    final items = getStoreItems(idTienda);
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Obtener cantidad total de productos en una tienda
  int getStoreItemCount(String idTienda) {
    final items = getStoreItems(idTienda);
    return items.fold(0, (sum, item) => sum + item.cantidad);
  }

  // Obtener cantidad total de productos en todo el carrito
  int getTotalItemCount() {
    return state.values.fold(
      0,
      (sum, items) => sum + items.fold(0, (s, item) => s + item.cantidad),
    );
  }
}

// Provider para contar items totales en el carrito
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.values.fold(
    0,
    (sum, items) => sum + items.fold(0, (s, item) => s + item.cantidad),
  );
});

// Provider para verificar si un producto está en el carrito
final isProductInCartProvider = Provider.family<bool, String>((ref, productId) {
  final cart = ref.watch(cartProvider);
  return cart.values.any(
    (items) => items.any((item) => item.producto.id == productId),
  );
});
