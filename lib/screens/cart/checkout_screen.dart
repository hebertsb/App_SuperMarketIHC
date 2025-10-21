import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../data/mock_data.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String storeId;

  const CheckoutScreen({super.key, required this.storeId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.tarjetaCredito;
  final _direccionController = TextEditingController(
    text: 'Av. 2do Anillo Esq. Las Americas',
  );
  final _referenciaController = TextEditingController(
    text: 'Frente a cafetería Camila, casa blanca',
  );
  final _telefonoController = TextEditingController(text: '+591 77012884');

  @override
  void dispose() {
    _direccionController.dispose();
    _referenciaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider)[widget.storeId] ?? [];
    final store = MockData.getStores().firstWhere((s) => s.id == widget.storeId);
    final subtotal =
        ref.read(cartProvider.notifier).getStoreSubtotal(widget.storeId);
    final total = subtotal + store.deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        backgroundColor: const Color(0xFFE53935),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de tarjeta
            const Text(
              'Seleccionar Tarjeta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              PaymentMethod.tarjetaCredito,
              'BNB',
              'VISA',
              '0000 0000 0000 0000',
              Colors.black,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              PaymentMethod.tarjetaDebito,
              'BANCO GANADERO',
              'MASTERCARD',
              '0000 0000 0000 0000',
              Colors.orange,
            ),
            const SizedBox(height: 24),

            // Datos de entrega
            const Text(
              'Datos de entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDeliveryInfo(),
            const SizedBox(height: 24),

            // Resumen
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummary(items.length, subtotal, store.deliveryFee, total),
            const SizedBox(height: 24),

            // Botón pagar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _procesarPago(
                  store.name,
                  items,
                  subtotal,
                  store.deliveryFee,
                  total,
                  store.deliveryTime,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pagar Bs ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    String banco,
    String tipo,
    String numero,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  banco,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Spacer(),
            Text(
              numero,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tipo,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: Color(0xFFE53935)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delivery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver'),
              ),
            ],
          ),
          const Divider(),
            Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFE53935)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Domicilio',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _direccionController.text,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showEditAddressDialog();
                },
                child: const Text('Cambiar'),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.note, color: Color(0xFFE53935)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Referencia',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _referenciaController.text,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showEditAddressDialog();
                },
                child: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    int productos,
    double subtotal,
    double envio,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Productos', 'Bs. $productos'),
          const SizedBox(height: 8),
          _buildSummaryRow('Envío', 'Bs. ${envio.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Tarifa', 'Bs. 2'),
          const Divider(),
          _buildSummaryRow(
            'Total a Pagar',
            'Bs. ${(total + 2).toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFFE53935) : null,
          ),
        ),
      ],
    );
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar dirección'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _procesarPago(
    String nombreTienda,
    List<CartItem> items,
    double subtotal,
    double costoEnvio,
    double total,
    int tiempoEstimado,
  ) {
    // Crear orden
    final orderId = 'PD-${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      idTienda: widget.storeId,
      nombreTienda: nombreTienda,
      items: items,
      subtotal: subtotal,
      costoEnvio: costoEnvio,
      total: total + 2, // Incluir tarifa
      estado: OrderStatus.confirmado,
      metodoPago: _selectedPaymentMethod,
      infoEntrega: DeliveryInfo(
        direccion: _direccionController.text,
        referencia: _referenciaController.text,
        latitud: -17.7833,
        longitud: -63.1821,
        telefono: _telefonoController.text,
      ),
      fechaCreacion: DateTime.now(),
      fechaConfirmacion: DateTime.now(),
      tiempoEstimadoMin: tiempoEstimado,
    );

    // Agregar conductor simulado
    final orderWithDriver = order.copyWith(
      conductor: DriverInfo(
        nombre: 'Juan Ramón Morales',
        telefono: '77012884',
        vehiculo: 'Honda Super Cub',
        placa: 'JH1600',
      ),
    );

    // Guardar orden
    ref.read(activeOrdersProvider.notifier).createOrder(orderWithDriver);

    // Limpiar carrito de esta tienda
    ref.read(cartProvider.notifier).clearStoreCart(widget.storeId);

    // Mostrar confirmación y navegar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '! Pedido Confirmado !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Número de Pedido: #$orderId',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu producto tardará aproximadamente\nentre ${tiempoEstimado} min a ${tiempoEstimado + 15} min',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: const Text('Volver a mi Inicio'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/tracking/$orderId');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
              ),
              child: const Text('Seguir mi Pedido'),
            ),
          ),
        ],
      ),
    );
  }
}
