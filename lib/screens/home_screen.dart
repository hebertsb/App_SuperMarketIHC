import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_delivery_app/data/producto.dart';
import 'package:supermarket_delivery_app/screens/products/detalle_producto.dart';
import 'package:supermarket_delivery_app/widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';
import '../widgets/promotion_banner.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entregar en',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: const [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Text(
                  'Av. Arce, La Paz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente y buscador
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE53935),
                    Color(0xFFD32F2F),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomSearchBar(
                  hintText: 'Busca productos',
                  onChanged: (value) {
                    // Lógica de búsqueda
                  },
                ),
              ),
            ),

            const PromotionBanner(),

            // Pedidos Activos
            _buildActiveOrders(ref, context),

            // Categorías
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChip(
                          label: 'Frutas',
                          icon: Icons.apple,
                          color: Colors.green,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Lácteos',
                          icon: Icons.local_drink,
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Cereales',
                          icon: Icons.rice_bowl,
                          color: Colors.orange,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Snacks',
                          icon: Icons.fastfood,
                          color: Colors.purple,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Limpieza',
                          icon: Icons.cleaning_services,
                          color: Colors.teal,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ofertas de la semana
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¡Ofertas de la semana!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/products'),
                        child: const Text('Ver Todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '25%',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descuento en frutas y verduras',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Válido hasta el domingo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 Productos destacados (reemplaza los supermercados)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos destacados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grilla de productos
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      return ProductoCard(
                        producto: producto,
                        onVerDetalle: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: DetalleProducto(
                                  producto: producto,
                                  masProductos: productos
                                      .where((p) => p.id != producto.id)
                                      .take(6)
                                      .toList(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActiveOrders(WidgetRef ref, BuildContext context) {
    final activeOrders = ref.watch(activeOrdersProvider);

    if (activeOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pedidos Activos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar a pantalla de todos los pedidos
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                return _buildOrderCard(order, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.estado) {
      case OrderStatus.confirmado:
        statusColor = Colors.blue;
        statusText = 'Confirmado';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.preparando:
        statusColor = Colors.orange;
        statusText = 'Preparando';
        statusIcon = Icons.restaurant;
        break;
      case OrderStatus.enCamino:
        statusColor = Colors.green;
        statusText = 'En camino';
        statusIcon = Icons.delivery_dining;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Pendiente';
        statusIcon = Icons.schedule;
    }

    return GestureDetector(
      onTap: () {
        context.push('/tracking/${order.id}');
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${order.id.substring(order.id.length - 6)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        order.nombreTienda,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} productos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Seguir',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFFE53935),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
