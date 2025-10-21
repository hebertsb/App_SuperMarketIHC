import 'producto.dart';

class CartItem {
  final Producto producto;
  final int cantidad;
  final String? notas; // Notas especiales del usuario

  CartItem({
    required this.producto,
    required this.cantidad,
    this.notas,
  });

  double get subtotal => producto.precio * cantidad;

  CartItem copyWith({
    Producto? producto,
    int? cantidad,
    String? notas,
  }) {
    return CartItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      notas: notas ?? this.notas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto': producto.aJson(),
      'cantidad': cantidad,
      'notas': notas,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      producto: Producto.desdeJson(json['producto']),
      cantidad: json['cantidad'],
      notas: json['notas'],
    );
  }
}
