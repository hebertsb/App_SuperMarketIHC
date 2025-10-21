import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_delivery_app/data/producto.dart';
import 'package:supermarket_delivery_app/screens/products/detalle_producto.dart';
import 'package:supermarket_delivery_app/widgets/product_card.dart';
import '../../widgets/search_bar.dart';

class ListaProductosScreen extends ConsumerWidget {
  const ListaProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: const Color(0xFFE53935),
        actions: [
          IconButton(
            onPressed: () => context.push('/carrito'),
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: const Color(0xFFE53935),
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              hintText: 'Buscar productos...',
              onChanged: (valor) {
                // Implementar lógica de búsqueda
              },
            ),
          ),

          // Filtro de categorías
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                _construirFiltroCategoria('Todos', true),
                _construirFiltroCategoria('Frutas', false),
                _construirFiltroCategoria('Lácteos', false),
                _construirFiltroCategoria('Cereales', false),
                _construirFiltroCategoria('Snacks', false),
                _construirFiltroCategoria('Limpieza', false),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Grilla de productos
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return ProductoCard(
                  producto: producto,
                  onVerDetalle: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: DetalleProducto(
                              producto: producto,
                              masProductos: productos
                                  .where((p) => p.id != producto.id)
                                  .take(6)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  onAgregarAlCarrito: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${producto.nombre} agregado al carrito'),
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

  Widget _construirFiltroCategoria(String etiqueta, bool seleccionado) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(etiqueta),
        selected: seleccionado,
        onSelected: (selected) {
          // Implementar filtrado aquí
        },
        selectedColor: const Color(0xFFE53935).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFFE53935),
      ),
    );
  }
}
