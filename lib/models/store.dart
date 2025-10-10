class Store {
  final String id;
  final String name;
  final String logo;
  final String address;
  final String phone;
  final Map<String, String> openHours;
  final double rating;
  final int deliveryTime; // minutos
  final double deliveryFee;
  final bool isOpen;
  final List<String> categories;

  Store({
    required this.id,
    required this.name,
    required this.logo,
    required this.address,
    required this.phone,
    required this.openHours,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.isOpen,
    required this.categories,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      address: json['address'],
      phone: json['phone'],
      openHours: Map<String, String>.from(json['openHours']),
      rating: json['rating'].toDouble(),
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'].toDouble(),
      isOpen: json['isOpen'],
      categories: List<String>.from(json['categories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'address': address,
      'phone': phone,
      'openHours': openHours,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'isOpen': isOpen,
      'categories': categories,
    };
  }
}