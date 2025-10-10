import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/store_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';
import '../widgets/promotion_banner.dart';
import '../models/store.dart';

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
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Av. Arce, La Paz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16),
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
            // Header con gradiente
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
              child: Column(
                children: [
                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomSearchBar(
                      hintText: 'Busca productos y supermercados',
                      onChanged: (value) {
                        // Implementar búsqueda
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            // Banner de promociones
            const PromotionBanner(),
            
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
                          label: 'Frutas y Verduras',
                          icon: Icons.eco,
                          color: Colors.green,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Carnes',
                          icon: Icons.restaurant,
                          color: Colors.red,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Lácteos',
                          icon: Icons.local_drink,
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        CategoryChip(
                          label: 'Panadería',
                          icon: Icons.bakery_dining,
                          color: Colors.orange,
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
                        onPressed: () {},
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
                            horizontal: 8,
                            vertical: 4,
                          ),
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
            
            // Supermercados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supermercados cerca de ti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockStores.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final store = _mockStores[index];
                      return StoreCard(
                        store: store,
                        onTap: () => context.push('/products/${store.id}'),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Datos de prueba
final List<Store> _mockStores = [
  Store(
    id: '1',
    name: 'Hipermaxi',
    logo: 'assets/images/hipermaxi_logo.png',
    address: 'Av. Ballivián 1234',
    phone: '+591 2 123456',
    openHours: {'mon-fri': '8:00-22:00', 'sat-sun': '9:00-21:00'},
    rating: 4.5,
    deliveryTime: 30,
    deliveryFee: 15.0,
    isOpen: true,
    categories: ['Frutas', 'Verduras', 'Carnes', 'Lácteos'],
  ),
  Store(
    id: '2',
    name: 'Ketal',
    logo: 'assets/images/ketal_logo.png',
    address: 'Av. 6 de Agosto 2222',
    phone: '+591 2 234567',
    openHours: {'mon-fri': '7:30-22:30', 'sat-sun': '8:00-22:00'},
    rating: 4.2,
    deliveryTime: 25,
    deliveryFee: 12.0,
    isOpen: true,
    categories: ['Frutas', 'Verduras', 'Panadería', 'Bebidas'],
  ),
  Store(
    id: '3',
    name: 'Fidalga',
    logo: 'assets/images/fidalga_logo.png',
    address: 'Calle Comercio 567',
    phone: '+591 2 345678',
    openHours: {'mon-fri': '8:00-21:00', 'sat-sun': '9:00-20:00'},
    rating: 4.0,
    deliveryTime: 35,
    deliveryFee: 18.0,
    isOpen: false,
    categories: ['Carnes', 'Pollo', 'Embutidos'],
  ),
];