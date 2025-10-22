import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _statusTimer;
  Timer? _locationTimer;
  double _driverLat = -17.7833;
  double _driverLng = -63.1821;
  final double _destinationLat = -17.7850;
  final double _destinationLng = -63.1800;
  int _rating = 0;
  bool _showRatingDialog = false;

  @override
  void initState() {
    super.initState();
    // Simular actualizaciones de estado cada 10 segundos (más rápido para pruebas)
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateOrderStatus();
    });

    // Simular movimiento del conductor cada 1 segundo
    _locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDriverLocation();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  void _updateOrderStatus() {
    final orders = ref.read(activeOrdersProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => Order(
        id: '',
        idTienda: '',
        nombreTienda: '',
        items: [],
        subtotal: 0,
        costoEnvio: 0,
        total: 0,
        estado: OrderStatus.pendiente,
        metodoPago: PaymentMethod.efectivo,
        infoEntrega: DeliveryInfo(
          direccion: '',
          referencia: '',
          latitud: 0,
          longitud: 0,
          telefono: '',
        ),
        fechaCreacion: DateTime.now(),
        tiempoEstimadoMin: 30,
      ),
    );

    if (order.id.isEmpty) return;

    // Progresión automática de estados
    OrderStatus nextStatus;
    switch (order.estado) {
      case OrderStatus.confirmado:
        nextStatus = OrderStatus.preparando;
        break;
      case OrderStatus.preparando:
        nextStatus = OrderStatus.enCamino;
        break;
      case OrderStatus.enCamino:
        nextStatus = OrderStatus.entregado;
        break;
      default:
        return;
    }

    ref.read(activeOrdersProvider.notifier).updateOrderStatus(
          widget.orderId,
          nextStatus,
        );

    // Si el pedido acaba de ser entregado, mostrar diálogo de calificación
    if (nextStatus == OrderStatus.entregado && !_showRatingDialog) {
      _statusTimer?.cancel();
      _locationTimer?.cancel();
      setState(() {
        _showRatingDialog = true;
      });
      // Usar addPostFrameCallback para asegurar que el diálogo se muestre después del build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRatingDialogModal();
        }
      });
    }
  }

  void _updateDriverLocation() {
    final orders = ref.read(activeOrdersProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => Order(
        id: '',
        idTienda: '',
        nombreTienda: '',
        items: [],
        subtotal: 0,
        costoEnvio: 0,
        total: 0,
        estado: OrderStatus.pendiente,
        metodoPago: PaymentMethod.efectivo,
        infoEntrega: DeliveryInfo(
          direccion: '',
          referencia: '',
          latitud: 0,
          longitud: 0,
          telefono: '',
        ),
        fechaCreacion: DateTime.now(),
        tiempoEstimadoMin: 30,
      ),
    );

    if (order.estado == OrderStatus.enCamino && order.id.isNotEmpty) {
      // Mover el conductor gradualmente hacia el destino
      final deltaLat = (_destinationLat - _driverLat) * 0.1;
      final deltaLng = (_destinationLng - _driverLng) * 0.1;

      // Solo actualizar si todavía no llegó al destino
      final distance = ((_destinationLat - _driverLat).abs() +
          (_destinationLng - _driverLng).abs());

      if (distance > 0.0001) {
        setState(() {
          _driverLat += deltaLat;
          _driverLng += deltaLng;
        });

        ref.read(activeOrdersProvider.notifier).updateDriverLocation(
              widget.orderId,
              _driverLat,
              _driverLng,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(activeOrdersProvider);
    final order = orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => Order(
        id: '',
        idTienda: '',
        nombreTienda: '',
        items: [],
        subtotal: 0,
        costoEnvio: 0,
        total: 0,
        estado: OrderStatus.pendiente,
        metodoPago: PaymentMethod.efectivo,
        infoEntrega: DeliveryInfo(
          direccion: '',
          referencia: '',
          latitud: 0,
          longitud: 0,
          telefono: '',
        ),
        fechaCreacion: DateTime.now(),
        tiempoEstimadoMin: 30,
      ),
    );

    // Detectar cuando el pedido cambia a entregado
    if (order.estado == OrderStatus.entregado && !_showRatingDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_showRatingDialog) {
          _statusTimer?.cancel();
          _locationTimer?.cancel();
          setState(() {
            _showRatingDialog = true;
          });
          _showRatingDialogModal();
        }
      });
    }

    if (order.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pedido no encontrado'),
        ),
        body: const Center(
          child: Text('No se encontró el pedido'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Pedido'),
        backgroundColor: const Color(0xFFE53935),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Llamar al conductor
              if (order.conductor != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Llamando a ${order.conductor!.nombre}: ${order.conductor!.telefono}'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mapa real con Flutter Map
            _buildFlutterMap(order),

            // Información del conductor
            if (order.conductor != null) _buildDriverInfo(order.conductor!),

            // Timeline del pedido
            _buildOrderTimeline(order),

            // Detalles del pedido
            _buildOrderDetails(order),
          ],
        ),
      ),
      floatingActionButton:
          order.estado == OrderStatus.entregado && !_showRatingDialog
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _statusTimer?.cancel();
                    _locationTimer?.cancel();
                    setState(() {
                      _showRatingDialog = true;
                    });
                    _showRatingDialogModal();
                  },
                  backgroundColor: const Color(0xFFE53935),
                  icon: const Icon(Icons.star),
                  label: const Text('Calificar'),
                )
              : null,
    );
  }

  Widget _buildFlutterMap(Order order) {
    // Coordenadas
    const storeLat = LatLng(-17.7833, -63.1821); // Tienda
    final homeLat = LatLng(_destinationLat, _destinationLng); // Tu casa
    final driverLatLng = LatLng(_driverLat, _driverLng); // Conductor

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            options: MapOptions(
              initialCenter: storeLat,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              // Capa de tiles (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.supermarket_delivery_app',
              ),
              // Polilínea (ruta)
              if (order.estado == OrderStatus.enCamino ||
                  order.estado == OrderStatus.entregado)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [storeLat, homeLat],
                      strokeWidth: 4.0,
                      color: const Color(0xFFE53935).withValues(alpha: 0.7),
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              // Marcadores
              MarkerLayer(
                markers: [
                  // Marcador de tienda
                  Marker(
                    point: storeLat,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tienda',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Marcador de casa
                  Marker(
                    point: homeLat,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tu Casa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Marcador del conductor (si está en camino)
                  if (order.estado == OrderStatus.enCamino &&
                      order.conductor != null)
                    Marker(
                      point: driverLatLng,
                      width: 100,
                      height: 50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE53935),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.two_wheeler,
                              color: Color(0xFFE53935),
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                order.conductor!.nombre.split(' ').first,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Overlay con tiempo estimado
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFFE53935)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getEstimatedTime(order),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (order.estado == OrderStatus.enCamino)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.two_wheeler,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'En camino',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(DriverInfo driver) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE53935),
            child: Text(
              driver.nombre.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${driver.vehiculo} - ${driver.placa}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFFE53935)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Llamando a ${driver.nombre}: ${driver.telefono}'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(Order order) {
    final steps = [
      (
        'Confirmado',
        OrderStatus.confirmado,
        Icons.check_circle,
        order.fechaConfirmacion
      ),
      (
        'Preparando',
        OrderStatus.preparando,
        Icons.restaurant,
        order.fechaConfirmacion
      ),
      (
        'En Camino',
        OrderStatus.enCamino,
        Icons.delivery_dining,
        order.fechaConfirmacion
      ),
      ('Entregado', OrderStatus.entregado, Icons.home, order.fechaEntrega),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Pedido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = _isStepActive(order.estado, step.$2);
            final isCompleted = _isStepCompleted(order.estado, step.$2);

            return _buildTimelineStep(
              step.$1,
              step.$3,
              isActive,
              isCompleted,
              isLast: index == steps.length - 1,
              timestamp: step.$4,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String label,
    IconData icon,
    bool isActive,
    bool isCompleted, {
    bool isLast = false,
    DateTime? timestamp,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? const Color(0xFFE53935)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? const Color(0xFFE53935) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isCompleted || isActive ? Colors.black : Colors.grey,
                  ),
                ),
                if (timestamp != null)
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido #${order.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Tienda', order.nombreTienda),
          _buildDetailRow('Productos', '${order.items.length} items'),
          _buildDetailRow(
              'Subtotal', 'Bs. ${order.subtotal.toStringAsFixed(2)}'),
          _buildDetailRow(
              'Envío', 'Bs. ${order.costoEnvio.toStringAsFixed(2)}'),
          const Divider(),
          _buildDetailRow(
            'Total',
            'Bs. ${order.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Dirección de entrega',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.infoEntrega.direccion,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          if (order.infoEntrega.referencia != null &&
              order.infoEntrega.referencia!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Ref: ${order.infoEntrega.referencia}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 15 : 14,
              color: isTotal ? const Color(0xFFE53935) : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _isStepActive(OrderStatus currentStatus, OrderStatus stepStatus) {
    return currentStatus == stepStatus;
  }

  bool _isStepCompleted(OrderStatus currentStatus, OrderStatus stepStatus) {
    final statusOrder = [
      OrderStatus.confirmado,
      OrderStatus.preparando,
      OrderStatus.enCamino,
      OrderStatus.entregado,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);

    return currentIndex > stepIndex;
  }

  String _getEstimatedTime(Order order) {
    if (order.estado == OrderStatus.entregado) {
      return 'Pedido entregado';
    }

    final now = DateTime.now();
    final elapsed = now.difference(order.fechaCreacion).inMinutes;
    final remaining = order.tiempoEstimadoMin - elapsed;

    if (remaining <= 0) {
      return 'Llegando pronto...';
    }

    return 'Llegada estimada: $remaining min';
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showRatingDialogModal() {
    if (!mounted) return;

    String? selectedDeliveryTime;
    String? selectedProductQuality;
    String? selectedPackaging;
    String? selectedDriverAttitude;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Pedido Entregado!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Califica tu experiencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Calificación general con estrellas
                    const Text(
                      'Calificación General',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcular tamaño de estrella basado en ancho disponible
                        final starSize =
                            (constraints.maxWidth * 0.12).clamp(24.0, 40.0);

                        return SizedBox(
                          height: starSize + 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    _rating = index + 1;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: starSize * 0.1),
                                  child: Icon(
                                    index < _rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: starSize,
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                    if (_rating > 0)
                      Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),

                    // Tiempo de entrega
                    _buildSectionTitle('¿Cómo fue el tiempo de entrega?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          '⚡ Muy rápido',
                          selectedDeliveryTime == 'Muy rápido',
                          () => setDialogState(
                              () => selectedDeliveryTime = 'Muy rápido'),
                        ),
                        _buildChip(
                          '✓ Puntual',
                          selectedDeliveryTime == 'Puntual',
                          () => setDialogState(
                              () => selectedDeliveryTime = 'Puntual'),
                        ),
                        _buildChip(
                          '⏱ Un poco tarde',
                          selectedDeliveryTime == 'Un poco tarde',
                          () => setDialogState(
                              () => selectedDeliveryTime = 'Un poco tarde'),
                        ),
                        _buildChip(
                          '⏰ Muy tarde',
                          selectedDeliveryTime == 'Muy tarde',
                          () => setDialogState(
                              () => selectedDeliveryTime = 'Muy tarde'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Calidad del producto
                    _buildSectionTitle(
                        '¿En qué estado llegaron los productos?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          '🌟 Excelente',
                          selectedProductQuality == 'Excelente',
                          () => setDialogState(
                              () => selectedProductQuality = 'Excelente'),
                        ),
                        _buildChip(
                          '👍 Bueno',
                          selectedProductQuality == 'Bueno',
                          () => setDialogState(
                              () => selectedProductQuality = 'Bueno'),
                        ),
                        _buildChip(
                          '👌 Aceptable',
                          selectedProductQuality == 'Aceptable',
                          () => setDialogState(
                              () => selectedProductQuality = 'Aceptable'),
                        ),
                        _buildChip(
                          '⚠️ Dañado',
                          selectedProductQuality == 'Dañado',
                          () => setDialogState(
                              () => selectedProductQuality = 'Dañado'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Empaque
                    _buildSectionTitle('¿Cómo estuvo el empaque?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          '📦 Perfecto',
                          selectedPackaging == 'Perfecto',
                          () => setDialogState(
                              () => selectedPackaging = 'Perfecto'),
                        ),
                        _buildChip(
                          '✅ Bien sellado',
                          selectedPackaging == 'Bien sellado',
                          () => setDialogState(
                              () => selectedPackaging = 'Bien sellado'),
                        ),
                        _buildChip(
                          '📋 Normal',
                          selectedPackaging == 'Normal',
                          () => setDialogState(
                              () => selectedPackaging = 'Normal'),
                        ),
                        _buildChip(
                          '❌ Mal sellado',
                          selectedPackaging == 'Mal sellado',
                          () => setDialogState(
                              () => selectedPackaging = 'Mal sellado'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actitud del repartidor
                    _buildSectionTitle('¿Cómo fue la actitud del repartidor?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          '😊 Muy amable',
                          selectedDriverAttitude == 'Muy amable',
                          () => setDialogState(
                              () => selectedDriverAttitude = 'Muy amable'),
                        ),
                        _buildChip(
                          '🙂 Amable',
                          selectedDriverAttitude == 'Amable',
                          () => setDialogState(
                              () => selectedDriverAttitude = 'Amable'),
                        ),
                        _buildChip(
                          '😐 Normal',
                          selectedDriverAttitude == 'Normal',
                          () => setDialogState(
                              () => selectedDriverAttitude = 'Normal'),
                        ),
                        _buildChip(
                          '😠 Poco amable',
                          selectedDriverAttitude == 'Poco amable',
                          () => setDialogState(
                              () => selectedDriverAttitude = 'Poco amable'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              // Mover a historial sin calificación
                              ref
                                  .read(orderHistoryProvider.notifier)
                                  .addToHistory(
                                    ref.read(activeOrdersProvider).firstWhere(
                                          (o) => o.id == widget.orderId,
                                        ),
                                  );
                              ref
                                  .read(activeOrdersProvider.notifier)
                                  .moveToHistory(widget.orderId);
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Omitir',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _rating > 0
                                ? () {
                                    Navigator.pop(dialogContext);

                                    // Guardar calificación
                                    ref
                                        .read(orderHistoryProvider.notifier)
                                        .addToHistory(
                                          ref
                                              .read(activeOrdersProvider)
                                              .firstWhere(
                                                (o) => o.id == widget.orderId,
                                              ),
                                        );
                                    ref
                                        .read(activeOrdersProvider.notifier)
                                        .moveToHistory(widget.orderId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '¡Gracias por tu calificación de $_rating estrellas!'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );

                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Enviar Calificación',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE53935).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53935) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFFE53935) : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return '⭐ Excelente';
      case 4:
        return '⭐ Muy bueno';
      case 3:
        return '⭐ Bueno';
      case 2:
        return '⭐ Regular';
      case 1:
        return '⭐ Malo';
      default:
        return '';
    }
  }
}
