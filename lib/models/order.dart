import 'cart_item.dart';

enum OrderStatus {
  pendiente, // Pedido creado pero no confirmado
  confirmado, // Pedido confirmado, esperando preparación
  preparando, // Supermercado preparando el pedido
  enCamino, // En ruta de entrega
  entregado, // Entregado exitosamente
  cancelado, // Pedido cancelado
}

enum PaymentMethod {
  tarjetaCredito,
  tarjetaDebito,
  efectivo,
  transferencia,
}

class DeliveryInfo {
  final String direccion;
  final String? referencia;
  final double latitud;
  final double longitud;
  final String telefono;

  DeliveryInfo({
    required this.direccion,
    this.referencia,
    required this.latitud,
    required this.longitud,
    required this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'direccion': direccion,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'telefono': telefono,
    };
  }

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      direccion: json['direccion'],
      referencia: json['referencia'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      telefono: json['telefono'],
    );
  }
}

class DriverInfo {
  final String nombre;
  final String telefono;
  final String vehiculo;
  final String placa;
  final double? latitudActual;
  final double? longitudActual;

  DriverInfo({
    required this.nombre,
    required this.telefono,
    required this.vehiculo,
    required this.placa,
    this.latitudActual,
    this.longitudActual,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'vehiculo': vehiculo,
      'placa': placa,
      'latitudActual': latitudActual,
      'longitudActual': longitudActual,
    };
  }

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      nombre: json['nombre'],
      telefono: json['telefono'],
      vehiculo: json['vehiculo'],
      placa: json['placa'],
      latitudActual: json['latitudActual'],
      longitudActual: json['longitudActual'],
    );
  }
}

class Order {
  final String id;
  final String idTienda;
  final String nombreTienda;
  final List<CartItem> items;
  final double subtotal;
  final double costoEnvio;
  final double total;
  final OrderStatus estado;
  final PaymentMethod metodoPago;
  final DeliveryInfo infoEntrega;
  final DriverInfo? conductor;
  final DateTime fechaCreacion;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaEntrega;
  final int tiempoEstimadoMin; // en minutos

  Order({
    required this.id,
    required this.idTienda,
    required this.nombreTienda,
    required this.items,
    required this.subtotal,
    required this.costoEnvio,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.infoEntrega,
    this.conductor,
    required this.fechaCreacion,
    this.fechaConfirmacion,
    this.fechaEntrega,
    required this.tiempoEstimadoMin,
  });

  Order copyWith({
    String? id,
    String? idTienda,
    String? nombreTienda,
    List<CartItem>? items,
    double? subtotal,
    double? costoEnvio,
    double? total,
    OrderStatus? estado,
    PaymentMethod? metodoPago,
    DeliveryInfo? infoEntrega,
    DriverInfo? conductor,
    DateTime? fechaCreacion,
    DateTime? fechaConfirmacion,
    DateTime? fechaEntrega,
    int? tiempoEstimadoMin,
  }) {
    return Order(
      id: id ?? this.id,
      idTienda: idTienda ?? this.idTienda,
      nombreTienda: nombreTienda ?? this.nombreTienda,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      costoEnvio: costoEnvio ?? this.costoEnvio,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      infoEntrega: infoEntrega ?? this.infoEntrega,
      conductor: conductor ?? this.conductor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      tiempoEstimadoMin: tiempoEstimadoMin ?? this.tiempoEstimadoMin,
    );
  }

  String get estadoTexto {
    switch (estado) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.confirmado:
        return 'Confirmado';
      case OrderStatus.preparando:
        return 'Preparando';
      case OrderStatus.enCamino:
        return 'En camino';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idTienda': idTienda,
      'nombreTienda': nombreTienda,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'costoEnvio': costoEnvio,
      'total': total,
      'estado': estado.toString(),
      'metodoPago': metodoPago.toString(),
      'infoEntrega': infoEntrega.toJson(),
      'conductor': conductor?.toJson(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaConfirmacion': fechaConfirmacion?.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
      'tiempoEstimadoMin': tiempoEstimadoMin,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      idTienda: json['idTienda'],
      nombreTienda: json['nombreTienda'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'],
      costoEnvio: json['costoEnvio'],
      total: json['total'],
      estado: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['estado'],
      ),
      metodoPago: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['metodoPago'],
      ),
      infoEntrega: DeliveryInfo.fromJson(json['infoEntrega']),
      conductor:
          json['conductor'] != null ? DriverInfo.fromJson(json['conductor']) : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaConfirmacion: json['fechaConfirmacion'] != null
          ? DateTime.parse(json['fechaConfirmacion'])
          : null,
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : null,
      tiempoEstimadoMin: json['tiempoEstimadoMin'],
    );
  }
}
