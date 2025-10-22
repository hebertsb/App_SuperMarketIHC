// lib/screens/products/all_products_screen.dart
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
  String _sortBy =
      'Relevancia'; // Relevancia, Precio menor, Precio mayor, Descuento, Nombre

  bool _initialized = false;

  // Filtros adicionales
  late double _minAvailablePrice;
  late double _maxAvailablePrice;
  late RangeValues _priceRange; // actual
  bool _onlyDiscount = false;

  // Copia exacta (orden + labels + iconos) del Home para que sean idénticos
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Establecer categoría entrante desde query param o constructor
      String? incomingCategory = Uri.base.queryParameters['category'];
      incomingCategory ??= widget.initialCategory;

      if (incomingCategory != null && incomingCategory.isNotEmpty) {
        final match = _findBestMatch(incomingCategory);
        if (match != null) {
          _selectedCategory = match;
        } else {
          _selectedCategory = incomingCategory;
        }
      } else {
        _selectedCategory = 'Todos';
      }

      // Inicializar rango de precios según productos disponibles
      if (productos.isNotEmpty) {
        final prices = productos.map((p) => p.precio).toList();
        _minAvailablePrice = prices.reduce((a, b) => a < b ? a : b);
        _maxAvailablePrice = prices.reduce((a, b) => a > b ? a : b);
        if (_minAvailablePrice.isNaN || _maxAvailablePrice.isNaN) {
          _minAvailablePrice = 0;
          _maxAvailablePrice = 1000;
        }
      } else {
        _minAvailablePrice = 0;
        _maxAvailablePrice = 1000;
      }

      // Margen para que el RangeSlider no quede exacto y se vea bien
      if (_minAvailablePrice == _maxAvailablePrice) {
        _maxAvailablePrice = _minAvailablePrice + 1;
      }

      _priceRange = RangeValues(_minAvailablePrice, _maxAvailablePrice);
      _initialized = true;
    }
  }

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

          // Banner indicativo de filtro de categoría (si aplica)
          if (_selectedCategory.isNotEmpty &&
              _selectedCategory.toLowerCase() != 'todos')
            Container(
              width: double.infinity,
              color: Colors.yellow[100],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtrando por: $_selectedCategory',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Reset completo de filtros cuando el usuario quita la categoría
                      setState(() {
                        _selectedCategory = 'Todos';
                        _priceRange =
                            RangeValues(_minAvailablePrice, _maxAvailablePrice);
                        _onlyDiscount = false;
                        _searchQuery = '';
                        _sortBy = 'Relevancia';
                      });
                    },
                    child: const Text('Quitar filtro'),
                  )
                ],
              ),
            ),

          // Fila de categorías (mismo estilo que Home)
          Container(
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

                  final disableAnimations =
                      MediaQuery.of(context).disableAnimations;
                  const Color selectedRed = Color(0xFFB71C1C);
                  const Color unselectedBg = Color(0xFFFFEBEE);

                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 4.0 : 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = label;
                        });
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        scale: isSelected && !disableAnimations ? 1.06 : 1.0,
                        child: ChoiceChip(
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          avatar: Icon(
                            iconData,
                            size: 18,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                          label: Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? label : 'Todos';
                            });
                          },
                          selectedColor: selectedRed,
                          backgroundColor: unselectedBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color:
                                  isSelected ? selectedRed : Colors.transparent,
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
          ),

          // Contador de productos, orden y botón Filtros
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
                Row(
                  children: [
                    // Botón filtros
                    ElevatedButton.icon(
                      onPressed: () => _openFilterSheet(context),
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filtros'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[800],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ordenamiento popup
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
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'Relevancia', child: Text('Relevancia')),
                        PopupMenuItem(
                            value: 'Precio menor',
                            child: Text('Precio: menor a mayor')),
                        PopupMenuItem(
                            value: 'Precio mayor',
                            child: Text('Precio: mayor a menor')),
                        PopupMenuItem(
                            value: 'Descuento', child: Text('Mayor descuento')),
                        PopupMenuItem(
                            value: 'Nombre', child: Text('Nombre: A-Z')),
                      ],
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
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text('Intenta con otra búsqueda o ajuste de filtros',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  top: Radius.circular(24)),
                            ),
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
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

    // Filtrar por categoría (si no es 'Todos')
    if (_selectedCategory.toLowerCase() != 'todos') {
      filtered = filtered.where((producto) {
        final prodCat = producto.categoria.toLowerCase();
        final selCat = _selectedCategory.toLowerCase();
        // coincidencia flexible (p. ej. 'Carnes' vs 'Carnes y Pescados')
        return prodCat.contains(selCat) || selCat.contains(prodCat);
      }).toList();
    }

    // Filtrar por descuento
    if (_onlyDiscount) {
      filtered = filtered.where((p) => p.tieneDescuento).toList();
    }

    // Filtrar por rango de precio
    filtered = filtered.where((p) {
      return p.precio >= _priceRange.start && p.precio <= _priceRange.end;
    }).toList();

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
        filtered.sort((a, b) {
          if (a.tieneDescuento && !b.tieneDescuento) return -1;
          if (!a.tieneDescuento && b.tieneDescuento) return 1;
          return 0;
        });
        break;
    }

    return filtered;
  }

  // Normaliza y busca la mejor coincidencia dentro de las etiquetas (maneja acentos y plurales simples)
  String _normalize(String s) {
    var out = s.toLowerCase().trim();
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
      'ü': 'u',
    };
    accents.forEach((k, v) {
      out = out.replaceAll(k, v);
    });
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    if (out.endsWith('s') && out.length > 3) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  String? _findBestMatch(String incoming) {
    final inc = _normalize(incoming);

    // buscar exacta normalizada
    for (final m in _categoriesWithIcons) {
      final label = (m['label'] as String);
      if (_normalize(label) == inc) return label;
    }

    // búsqueda por contención
    for (final m in _categoriesWithIcons) {
      final label = (m['label'] as String);
      final low = _normalize(label);
      if (low.contains(inc) || inc.contains(low)) return label;
    }

    return null;
  }

  // Abre el modal de filtros con StatefulBuilder para manejar cambios temporales
  void _openFilterSheet(BuildContext context) {
    final tempRange = RangeValues(_priceRange.start, _priceRange.end);
    bool tempOnlyDiscount = _onlyDiscount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        RangeValues currentRange = RangeValues(tempRange.start, tempRange.end);
        bool currentOnly = tempOnlyDiscount;

        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Filtros',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rango de precio',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        RangeSlider(
                          min: _minAvailablePrice,
                          max: _maxAvailablePrice,
                          values: currentRange,
                          labels: RangeLabels(
                            currentRange.start.toStringAsFixed(0),
                            currentRange.end.toStringAsFixed(0),
                          ),
                          onChanged: (r) {
                            setModalState(() {
                              currentRange = r;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_minAvailablePrice.toStringAsFixed(0)} Bs'),
                            Text('${_maxAvailablePrice.toStringAsFixed(0)} Bs'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: currentOnly,
                          onChanged: (v) =>
                              setModalState(() => currentOnly = v),
                          title: const Text('Solo con descuento'),
                          secondary: const Icon(Icons.percent),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset filtros a valores iniciales
                              setState(() {
                                _priceRange = RangeValues(
                                    _minAvailablePrice, _maxAvailablePrice);
                                _onlyDiscount = false;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Resetear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Aplicar filtros
                              setState(() {
                                _priceRange = currentRange;
                                _onlyDiscount = currentOnly;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
