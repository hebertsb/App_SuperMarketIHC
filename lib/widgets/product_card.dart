import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/producto.dart';
import '../providers/cart_provider.dart';

class ProductoCard extends ConsumerWidget {
  final Producto producto;
  final VoidCallback onVerDetalle;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onVerDetalle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: producto.imagenes.isNotEmpty
                          ? (producto.imagenes.first.startsWith('assets/')
                              ? Image.asset(
                                  producto.imagenes.first,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  producto.imagenes.first,
                                  fit: BoxFit.cover,
                                ))
                          : const Center(
                              child: Icon(Icons.image,
                                  size: 40, color: Colors.grey),
                            ),
                    ),
                  ),

                  // Etiqueta de descuento
                  if (producto.tieneDescuento)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${producto.porcentajeDescuento.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Información del producto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Unidad
                    Text(
                      'Por ${producto.unidad}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),

                    // Precio y botón agregar
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (producto.tieneDescuento)
                              Text(
                                'Bs ${producto.precioOriginal!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text(
                              'Bs ${producto.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Botón agregar
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(cartProvider.notifier)
                                .addProduct(producto);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${producto.nombre} agregado al carrito'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: const Color(0xFFE53935),
                              ),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
