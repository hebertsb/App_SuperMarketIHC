import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/producto.dart';
import '../../models/producto.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar.dart';
import '../products/detalle_producto.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  
  const AllProductsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  String _sortBy = 'Relevancia'; // Relevancia, Precio menor, Precio mayor, Descuento

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  final List<String> _categories = [
    'Todos',
    'Frutas y Verduras',
    'Lácteos',
    'Cereales y Granos',
    'Snacks',
    'Limpieza',
    'Bebidas',
    'Carnes y Pescados',
    'Panadería',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Productos'),
        backgroundColor: const Color(0xFFE53935),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Filtros de categoría
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFFE53935).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFE53935),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFE53935) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE53935) : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Contador de productos y ordenamiento
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} productos encontrados',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _sortBy,
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.sort, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Relevancia',
                      child: Text('Relevancia'),
                    ),
                    const PopupMenuItem(
                      value: 'Precio menor',
                      child: Text('Precio: menor a mayor'),
                    ),
                    const PopupMenuItem(
                      value: 'Precio mayor',
                      child: Text('Precio: mayor a menor'),
                    ),
                    const PopupMenuItem(
                      value: 'Descuento',
                      child: Text('Mayor descuento'),
                    ),
                    const PopupMenuItem(
                      value: 'Nombre',
                      child: Text('Nombre: A-Z'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Grilla de productos
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otra búsqueda o categoría',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final producto = filteredProducts[index];
                      return ProductoCard(
                        producto: producto,
                        onVerDetalle: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.9,
                                child: DetalleProducto(
                                  producto: producto,
                                  masProductos: filteredProducts
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
          ),
        ],
      ),
    );
  }

  List<Producto> _getFilteredProducts() {
    List<Producto> filtered = List.from(productos);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((producto) {
        return producto.nombre.toLowerCase().contains(_searchQuery) ||
            producto.descripcion.toLowerCase().contains(_searchQuery) ||
            producto.categoria.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filtrar por categoría
    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((producto) {
        return producto.categoria.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
            _selectedCategory.toLowerCase().contains(producto.categoria.toLowerCase());
      }).toList();
    }

    // Ordenar
    switch (_sortBy) {
      case 'Precio menor':
        filtered.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 'Precio mayor':
        filtered.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case 'Descuento':
        filtered.sort((a, b) {
          final descA = a.tieneDescuento ? a.porcentajeDescuento : 0.0;
          final descB = b.tieneDescuento ? b.porcentajeDescuento : 0.0;
          return descB.compareTo(descA);
        });
        break;
      case 'Nombre':
        filtered.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'Relevancia':
      default:
        // Mantener orden original o por relevancia
        // Priorizar productos con descuento
        filtered.sort((a, b) {
          if (a.tieneDescuento && !b.tieneDescuento) return -1;
          if (!a.tieneDescuento && b.tieneDescuento) return 1;
          return 0;
        });
        break;
    }

    return filtered;
  }
}
