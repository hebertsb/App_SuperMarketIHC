import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/producto.dart';
import '../../providers/cart_provider.dart';

class DetalleProducto extends ConsumerStatefulWidget {
  final Producto producto;
  final List<Producto> masProductos;

  const DetalleProducto({
    super.key,
    required this.producto,
    required this.masProductos,
  });

  @override
  ConsumerState<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends ConsumerState<DetalleProducto> {
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador superior
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Imagen principal
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: p.imagenes.first.startsWith('assets/')
                    ? Image.asset(
                        p.imagenes.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        p.imagenes.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 12),

              // Nombre y descripción
              Text(
                p.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.descripcion,
                style: TextStyle(color: Colors.grey[700]),
              ),

              const SizedBox(height: 16),
              const Text(
                "Más productos:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Productos relacionados
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.masProductos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final prod = widget.masProductos[i];
                    final descuento = ((1 -
                                (prod.precio /
                                    (prod.precioOriginal ?? prod.precio))) *
                            100)
                        .round();

                    return Container(
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: prod.imagenes.first.startsWith('assets/')
                                ? Image.asset(
                                    prod.imagenes.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.network(
                                    prod.imagenes.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          if (prod.precioOriginal != null &&
                              prod.precioOriginal! > prod.precio)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[400],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "-$descuento%",
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Precio y control de cantidad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${p.precio.toStringAsFixed(2)} Bs.\n x ${p.unidad}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (cantidad > 0) {
                            setState(() => cantidad--);
                          }
                        },
                      ),
                      Text(
                        "$cantidad",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => cantidad++);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: cantidad > 0
                            ? () {
                                // Añadir al carrito la cantidad seleccionada
                                for (var i = 0; i < cantidad; i++) {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addProduct(widget.producto);
                                }

                                // Mostrar mensaje de confirmación
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.producto.nombre} (x$cantidad) agregado al carrito'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFFE53935),
                                    action: SnackBarAction(
                                      label: 'Ver Carrito',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Cerrar el modal
                                        context.push('/cart');
                                      },
                                    ),
                                  ),
                                );

                                // Cerrar el modal después de un breve delay
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.pop(context);
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF865E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          cantidad > 0 ? "Añadir" : "Selecciona cantidad",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
