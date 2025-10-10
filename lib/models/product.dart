class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String category;
  final String unit; // kg, unidad, litro, etc.
  final int stock;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? nutritionalInfo;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.category,
    required this.unit,
    required this.stock,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    this.nutritionalInfo,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      storeId: json['storeId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      images: List<String>.from(json['images']),
      category: json['category'],
      unit: json['unit'],
      stock: json['stock'],
      isAvailable: json['isAvailable'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      nutritionalInfo: json['nutritionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'category': category,
      'unit': unit,
      'stock': stock,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'nutritionalInfo': nutritionalInfo,
    };
  }
}