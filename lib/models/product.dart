class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String currency;
  final List<String> images;
  final String category;
  final List<String> subcategories;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final int stockQuantity;
  final Map<String, dynamic> specifications;
  final List<String> features;
  final String sellerId;
  final String sellerName;
  final double sellerRating;
  final bool isPrimeEligible;
  final bool isFreeShipping;
  final String shippingTime;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    this.images = const [],
    required this.category,
    this.subcategories = const [],
    this.brand = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isInStock = true,
    this.stockQuantity = 0,
    this.specifications = const {},
    this.features = const [],
    required this.sellerId,
    required this.sellerName,
    this.sellerRating = 0.0,
    this.isPrimeEligible = false,
    this.isFreeShipping = false,
    this.shippingTime = '',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      originalPrice: json['originalPrice']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      subcategories: List<String>.from(json['subcategories'] ?? []),
      brand: json['brand'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isInStock: json['isInStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      sellerRating: json['sellerRating']?.toDouble() ?? 0.0,
      isPrimeEligible: json['isPrimeEligible'] ?? false,
      isFreeShipping: json['isFreeShipping'] ?? false,
      shippingTime: json['shippingTime'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'images': images,
      'category': category,
      'subcategories': subcategories,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'isInStock': isInStock,
      'stockQuantity': stockQuantity,
      'specifications': specifications,
      'features': features,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerRating': sellerRating,
      'isPrimeEligible': isPrimeEligible,
      'isFreeShipping': isFreeShipping,
      'shippingTime': shippingTime,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? currency,
    List<String>? images,
    String? category,
    List<String>? subcategories,
    String? brand,
    double? rating,
    int? reviewCount,
    bool? isInStock,
    int? stockQuantity,
    Map<String, dynamic>? specifications,
    List<String>? features,
    String? sellerId,
    String? sellerName,
    double? sellerRating,
    bool? isPrimeEligible,
    bool? isFreeShipping,
    String? shippingTime,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      images: images ?? this.images,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      brand: brand ?? this.brand,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isInStock: isInStock ?? this.isInStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      specifications: specifications ?? this.specifications,
      features: features ?? this.features,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerRating: sellerRating ?? this.sellerRating,
      isPrimeEligible: isPrimeEligible ?? this.isPrimeEligible,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      shippingTime: shippingTime ?? this.shippingTime,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  String get formattedOriginalPrice {
    if (originalPrice == null) return '';
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedReviewCount {
    if (reviewCount >= 1000) {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    return reviewCount.toString();
  }

  bool get hasDiscount {
    return originalPrice != null && originalPrice! > price;
  }

  String get stockStatus {
    if (!isInStock) return 'Out of Stock';
    if (stockQuantity <= 5) return 'Only $stockQuantity left';
    return 'In Stock';
  }
}

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice {
    return product.price * quantity;
  }

  String get formattedTotalPrice {
    return '\$${totalPrice.toStringAsFixed(2)}';
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String currency;
  final OrderStatus status;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.currency = 'USD',
    this.status = OrderStatus.pending,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.trackingNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      tax: json['tax']?.toDouble() ?? 0.0,
      shipping: json['shipping']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
      createdAt: DateTime.parse(json['createdAt']),
      shippedAt: json['shippedAt'] != null ? DateTime.parse(json['shippedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'currency': currency,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingNumber': trackingNumber,
    };
  }

  String get formattedTotal {
    return '\$${total.toStringAsFixed(2)}';
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
  returned,
}

class ShippingAddress {
  final String id;
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final bool isDefault;

  ShippingAddress({
    required this.id,
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    this.isDefault = false,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      fullName: json['fullName'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    return '$address, $city, $state $zipCode, $country';
  }
}

class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'apple_pay', etc.
  final String lastFourDigits;
  final String brand; // 'visa', 'mastercard', etc.
  final DateTime expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.brand,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      lastFourDigits: json['lastFourDigits'],
      brand: json['brand'],
      expiryDate: DateTime.parse(json['expiryDate']),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'expiryDate': expiryDate.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  String get displayName {
    switch (type) {
      case 'card':
        return '$brand •••• $lastFourDigits';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      default:
        return type;
    }
  }
}