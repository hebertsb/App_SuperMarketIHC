import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';

// Provider para pedidos activos (confirmado, preparando, en camino)
final activeOrdersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  return OrdersNotifier();
});

// Provider para historial de pedidos (entregados, cancelados)
final orderHistoryProvider = StateNotifierProvider<OrderHistoryNotifier, List<Order>>((ref) {
  return OrderHistoryNotifier();
});

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([]);

  // Crear un nuevo pedido
  void createOrder(Order order) {
    state = [...state, order];
  }

  // Actualizar estado de un pedido
  void updateOrderStatus(String orderId, OrderStatus newStatus, {DriverInfo? conductor}) {
    state = state.map((order) {
      if (order.id == orderId) {
        final now = DateTime.now();
        return order.copyWith(
          estado: newStatus,
          conductor: conductor ?? order.conductor,
          fechaConfirmacion: newStatus == OrderStatus.confirmado && order.fechaConfirmacion == null
              ? now
              : order.fechaConfirmacion,
          fechaEntrega: newStatus == OrderStatus.entregado ? now : order.fechaEntrega,
        );
      }
      return order;
    }).toList();
  }

  // Cancelar un pedido
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelado);
  }

  // Mover pedido al historial
  void moveToHistory(String orderId) {
    state = state.where((o) => o.id != orderId).toList();
    // El historial será manejado por orderHistoryProvider
  }

  // Obtener pedido por ID
  Order? getOrderById(String orderId) {
    try {
      return state.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Simular actualización de ubicación del conductor
  void updateDriverLocation(String orderId, double lat, double lng) {
    state = state.map((order) {
      if (order.id == orderId && order.conductor != null) {
        return order.copyWith(
          conductor: DriverInfo(
            nombre: order.conductor!.nombre,
            telefono: order.conductor!.telefono,
            vehiculo: order.conductor!.vehiculo,
            placa: order.conductor!.placa,
            latitudActual: lat,
            longitudActual: lng,
          ),
        );
      }
      return order;
    }).toList();
  }
}

class OrderHistoryNotifier extends StateNotifier<List<Order>> {
  OrderHistoryNotifier() : super([]);

  // Agregar pedido al historial
  void addToHistory(Order order) {
    state = [order, ...state];
  }

  // Obtener pedidos por estado
  List<Order> getOrdersByStatus(OrderStatus status) {
    return state.where((o) => o.estado == status).toList();
  }
}

// Provider para contar pedidos activos
final activeOrdersCountProvider = Provider<int>((ref) {
  final orders = ref.watch(activeOrdersProvider);
  return orders.length;
});

// Provider para obtener un pedido específico por ID
final orderByIdProvider = Provider.family<Order?, String>((ref, orderId) {
  final activeOrders = ref.watch(activeOrdersProvider);
  final historyOrders = ref.watch(orderHistoryProvider);
  
  try {
    return activeOrders.firstWhere((o) => o.id == orderId);
  } catch (e) {
    try {
      return historyOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }
});
