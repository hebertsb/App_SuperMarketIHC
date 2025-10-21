class Producto {
  final String id;
  final String idTienda; // ID del supermercado
  final String nombre;
  final String descripcion;
  final double precio;
  final double? precioOriginal;
  final List<String> imagenes;
  final String categoria;
  final String unidad; // kg, unidad, litro, etc.
  final int stock;
  final bool disponible;
  final double calificacion;
  final int cantidadResenas;
  final Map<String, dynamic>? informacionNutricional;

  Producto({
    required this.id,
    required this.idTienda,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.precioOriginal,
    required this.imagenes,
    required this.categoria,
    required this.unidad,
    required this.stock,
    required this.disponible,
    required this.calificacion,
    required this.cantidadResenas,
    this.informacionNutricional,
  });

  bool get tieneDescuento => precioOriginal != null && precioOriginal! > precio;

  double get porcentajeDescuento {
    if (!tieneDescuento) return 0;
    return ((precioOriginal! - precio) / precioOriginal!) * 100;
  }

  factory Producto.desdeJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      idTienda: json['idTienda'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio'].toDouble(),
      precioOriginal: json['precioOriginal']?.toDouble(),
      imagenes: List<String>.from(json['imagenes']),
      categoria: json['categoria'],
      unidad: json['unidad'],
      stock: json['stock'],
      disponible: json['disponible'],
      calificacion: json['calificacion'].toDouble(),
      cantidadResenas: json['cantidadResenas'],
      informacionNutricional: json['informacionNutricional'],
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'idTienda': idTienda,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'precioOriginal': precioOriginal,
      'imagenes': imagenes,
      'categoria': categoria,
      'unidad': unidad,
      'stock': stock,
      'disponible': disponible,
      'calificacion': calificacion,
      'cantidadResenas': cantidadResenas,
      'informacionNutricional': informacionNutricional,
    };
  }
}
