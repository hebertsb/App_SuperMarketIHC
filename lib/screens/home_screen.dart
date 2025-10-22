// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:supermarket_delivery_app/widgets/banner_carousel.dart';
import 'package:supermarket_delivery_app/data/producto.dart';
// import 'package:supermarket_delivery_app/data/mock_data.dart';
import 'package:supermarket_delivery_app/screens/products/detalle_producto.dart';
import 'package:supermarket_delivery_app/widgets/search_bar.dart';
import 'package:supermarket_delivery_app/providers/orders_provider.dart';
import 'package:supermarket_delivery_app/models/order.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Inicial sin selección para que al entrar no haya chips marcados
  String _selectedCategory = '';

  // Reemplaza la lista de categorías por esta estructura con iconos:
  final List<Map<String, dynamic>> _categoriesWithIcons = [
    {'label': 'Ofertas', 'icon': Icons.local_offer},
    {'label': 'Frutas y Verduras', 'icon': Icons.eco},
    {'label': 'Carnes', 'icon': Icons.set_meal},
    {'label': 'Panaderías', 'icon': Icons.bakery_dining},
    {'label': 'Limpieza', 'icon': Icons.cleaning_services},
    {'label': 'Bebidas', 'icon': Icons.local_bar},
    {'label': 'Snacks', 'icon': Icons.fastfood},
    {'label': 'Cereales', 'icon': Icons.rice_bowl},
    {'label': 'Congelados', 'icon': Icons.ac_unit},
    {'label': 'Hogar', 'icon': Icons.home},
    {'label': 'Bebés', 'icon': Icons.child_care},
  ];

  // Lista inicial fija de supermercados (ajusta 'logo' con los nombres / extensiones reales)
  // Cambia las rutas si tus archivos son .jpg en vez de .png
  final List<Map<String, dynamic>> _supermarketStores = [
    {
      'id': 'camino',
      'name': 'Camiño',
      'logo': 'assets/supermercados/camino.png',
      'rating': 4.3,
    },
    {
      'id': 'hipermaxi',
      'name': 'Hipermaxi',
      'logo': 'assets/supermercados/hipermaxi.png',
      'rating': 4.6,
    },
    {
      'id': 'supermarket',
      'name': 'Supermarket',
      'logo': 'assets/supermercados/supermarket.png',
      'rating': 4.0,
    },
    {
      'id': 'supermaxi',
      'name': 'Supermaxi',
      'logo': 'assets/supermercados/supermaxi.png',
      'rating': 4.4,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Llamada post-frame para precache asincrónico sin bloquear build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheLogosAndLoadManifest();
    });
  }

  Future<void> _precacheLogosAndLoadManifest() async {
    // 1) Precache la lista fija
    for (final s in _supermarketStores) {
      final path = s['logo'] as String;
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // Ignorar si el asset no existe o falla el precache
      }
    }

    // 2) Intentar leer AssetManifest.json y añadir assets de assets/supermercados/
    //    Esto permite añadir automáticamente logos sin declarar la lista manualmente.
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final manifestLogos = manifestMap.keys
          .where((k) => k.startsWith('assets/supermercados/'))
          .toList();
      var added = false;

      for (final p in manifestLogos) {
        final exists = _supermarketStores.any((s) => s['logo'] == p);
        if (!exists) {
          final id = _generateIdFromPath(p);
          final name = _prettyNameFromPath(p);
          _supermarketStores.add({
            'id': id,
            'name': name,
            'logo': p,
            'rating': 4.2, // rating por defecto; ajusta si tienes datos reales
          });
          try {
            await precacheImage(AssetImage(p), context);
          } catch (_) {}
          added = true;
        }
      }

      if (added && mounted) {
        setState(() {});
      }
    } catch (_) {
      // Si falla manifest (ej. en tests o configuración), no hacemos nada
    }
  }

  String _generateIdFromPath(String path) {
    final file = path.split('/').last;
    final name = file.split('.').first;
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  String _prettyNameFromPath(String path) {
    final file = path.split('/').last;
    final name = file.split('.').first;
    final pretty = name.replaceAll(RegExp(r'[_\-]+'), ' ');
    return pretty
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entregar en',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Av. Arce, La Paz',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline, color: Colors.white),
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
                child: Column(
                  children: [
                    CustomSearchBar(
                      hintText: 'Busca productos',
                      onChanged: (value) {
                        // Lógica de búsqueda (si aplica)
                      },
                    ),
                    const SizedBox(height: 12),
                    // CATEGORÍAS: justo debajo del buscador (ChoiceChips)
                    _buildCategoriesRow(context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Carrusel de banners con auto-scroll y responsivo
            const BannerCarousel(aspectRatio: 0.33),
            // Pedidos Activos
            _buildActiveOrdersSection(ref, context),
            const SizedBox(height: 8),

            // ---------------- Productos destacados ----------------
            Container(
              color: const Color(0xFFF5FFF5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos destacados',
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
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240, // altura fija del carrusel de tarjetas
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return GestureDetector(
                          onTap: () {
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
                          child: Container(
                            width: 160,
                            height:
                                230, // evitar overflow: misma altura que el padre
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18),
                                  ),
                                  child: producto.imagenes.isNotEmpty
                                      ? (producto.imagenes.first
                                              .startsWith('assets/')
                                          ? Image.asset(
                                              producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ))
                                      : Container(
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image,
                                              size: 48, color: Colors.grey),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${producto.precio.toStringAsFixed(2)} Bs',
                                            style: const TextStyle(
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (producto.tieneDescuento)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green[400],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '-${producto.porcentajeDescuento.toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE53935),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.shopping_cart_outlined,
                                                color: Colors.white),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              24)),
                                                ),
                                                builder: (context) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.9,
                                                    child: DetalleProducto(
                                                      producto: producto,
                                                      masProductos: productos
                                                          .where((p) =>
                                                              p.id !=
                                                              producto.id)
                                                          .take(6)
                                                          .toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ----------------- Supermercados cerca de ti -----------------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Supermercados cerca de ti',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                            onPressed: () => context.push('/stores'),
                            child: const Text('Ver Todas')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Aquí usamos la función que carga logos desde assets/supermercados/
                  _buildSupermarketsCarousel(context),
                ],
              ),
            ),

            // ---------------- Promociones del Día ----------------
            Container(
              color: const Color(0xFFF5FFF5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Promociones del Día',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                            onPressed: () {}, child: const Text('Ver Todas')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          productos.where((p) => p.tieneDescuento).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final producto = productos
                            .where((p) => p.tieneDescuento)
                            .toList()[index];
                        return GestureDetector(
                          onTap: () {
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
                          child: Container(
                            width: 160,
                            height: 230,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18)),
                                  child: producto.imagenes.isNotEmpty
                                      ? (producto.imagenes.first
                                              .startsWith('assets/')
                                          ? Image.asset(producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover)
                                          : Image.network(
                                              producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover))
                                      : Container(
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image,
                                              size: 48, color: Colors.grey)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(producto.nombre,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                              '${producto.precio.toStringAsFixed(2)} Bs',
                                              style: const TextStyle(
                                                  color: Color(0xFFE53935),
                                                  fontWeight: FontWeight.bold)),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.green[400],
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Text(
                                                '-${producto.porcentajeDescuento.toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFE53935),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.shopping_cart_outlined,
                                                color: Colors.white),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              24)),
                                                ),
                                                builder: (context) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.9,
                                                    child: DetalleProducto(
                                                      producto: producto,
                                                      masProductos: productos
                                                          .where((p) =>
                                                              p.id !=
                                                              producto.id)
                                                          .take(6)
                                                          .toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ⭐ Recomendado para ti (similar estructura)
            Container(
              color: const Color(0xFFF5FFF5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recomendado para ti',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        TextButton(
                            onPressed: () {}, child: const Text('Ver Todas')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: productos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return GestureDetector(
                          onTap: () {
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
                          child: Container(
                            width: 160,
                            height: 230,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18)),
                                  child: producto.imagenes.isNotEmpty
                                      ? (producto.imagenes.first
                                              .startsWith('assets/')
                                          ? Image.asset(producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover)
                                          : Image.network(
                                              producto.imagenes.first,
                                              height: 100,
                                              width: double.infinity,
                                              fit: BoxFit.cover))
                                      : Container(
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image,
                                              size: 48, color: Colors.grey)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(producto.nombre,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                              '${producto.precio.toStringAsFixed(2)} Bs',
                                              style: const TextStyle(
                                                  color: Color(0xFFE53935),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFE53935),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.shopping_cart_outlined,
                                                color: Colors.white),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              24)),
                                                ),
                                                builder: (context) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.9,
                                                    child: DetalleProducto(
                                                      producto: producto,
                                                      masProductos: productos
                                                          .where((p) =>
                                                              p.id !=
                                                              producto.id)
                                                          .take(6)
                                                          .toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
                height:
                    80), // espacio final para evitar solapado con bottom nav
          ],
        ),
      ),

      // Barra inferior (si ya tienes una implementación propia, reemplaza ésta)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (i) {
          switch (i) {
            case 1:
              context.push('/search');
              break;
            case 2:
              context.push('/cart');
              break;
            case 3:
              context.push('/orders');
              break;
            case 4:
              context.push('/profile');
              break;
            default:
              // ya estamos en home
              break;
          }
        },
      ),
    );
  }

  // Construye la fila de categorías con el mismo estilo que AllProducts
  Widget _buildCategoriesRow(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: _categoriesWithIcons.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = _categoriesWithIcons[index];
            final label = category['label'] as String;
            final iconData = category['icon'] as IconData;
            final isSelected = _selectedCategory == label;

            final disableAnimations = MediaQuery.of(context).disableAnimations;
            const Color selectedRed = Color(0xFFB71C1C);
            const Color unselectedBg = Color(0xFFFFEBEE);

            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 4.0 : 0),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedCategory = label;
                  });
                  // Navegar a AllProducts pasando la categoría por query param
                  await context
                      .push('/products?category=${Uri.encodeComponent(label)}');
                  // Al volver limpiar la selección para que no quede marcado
                  if (mounted) {
                    setState(() {
                      _selectedCategory = '';
                    });
                  }
                },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  scale: isSelected && !disableAnimations ? 1.06 : 1.0,
                  child: ChoiceChip(
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    avatar: Icon(
                      iconData,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[800],
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) async {
                      setState(() {
                        _selectedCategory = selected ? label : '';
                      });
                      if (selected) {
                        await context.push(
                            '/products?category=${Uri.encodeComponent(label)}');
                        if (mounted) {
                          setState(() {
                            _selectedCategory = '';
                          });
                        }
                      }
                    },
                    selectedColor: selectedRed,
                    backgroundColor: unselectedBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: isSelected ? selectedRed : Colors.transparent,
                      ),
                    ),
                    elevation: isSelected ? 4 : 0,
                    pressElevation: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- Pedidos activos (sin cambios funcionales) ----------------
  Widget _buildActiveOrdersSection(WidgetRef ref, BuildContext context) {
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
                    context.push('/orders');
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
                const Row(
                  children: [
                    Text(
                      'Seguir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
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

  // ---------------- Supermarkets carousel (alargado + estrellas + navegación) ----------------
  Widget _buildSupermarketsCarousel(BuildContext context) {
    // Filtra supermercados con logo válido
    final storesWithLogo = _supermarketStores
        .where((s) => s['logo'] != null && (s['logo'] as String).isNotEmpty)
        .toList();
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: storesWithLogo.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final store = storesWithLogo[index];
          return SizedBox(
            width: 180, // ancho reducido para evitar overflow
            child: _buildStoreCard(store, context),
          );
        },
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store, BuildContext context) {
    final logoPath = store['logo'] as String;
    final name = store['name'] as String;
    final rating = (store['rating'] as num).toDouble();
    final id = store['id'] as String;

    return GestureDetector(
      onTap: () => context.push('/store/$id'),
      child: Container(
        // width: 240, // El ancho ahora lo controla el SizedBox padre
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo más grande
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                logoPath,
                height: 60,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Icon(Icons.store, color: Colors.grey[600], size: 40),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildRatingStars(rating, size: 16),
                const SizedBox(width: 6),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => context.push('/store/$id'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                child: const Text('Ver Tienda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating, {double size = 14}) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    final stars = <Widget>[];
    for (var i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, size: size, color: Colors.amber));
    }
    if (hasHalf) {
      stars.add(Icon(Icons.star_half, size: size, color: Colors.amber));
    }
    for (var i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, size: size, color: Colors.amber));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
