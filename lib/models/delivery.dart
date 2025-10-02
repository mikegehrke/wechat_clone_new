class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final double rating;
  final int reviewCount;
  final String cuisine;
  final double deliveryFee;
  final int deliveryTime; // in minutes
  final double distance; // in km
  final bool isOpen;
  final List<String> tags;
  final Map<String, dynamic> location; // lat, lng

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.cuisine,
    this.deliveryFee = 0.0,
    this.deliveryTime = 30,
    this.distance = 0.0,
    this.isOpen = true,
    this.tags = const [],
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      address: json['address'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      cuisine: json['cuisine'],
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0.0,
      deliveryTime: json['deliveryTime'] ?? 30,
      distance: json['distance']?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      location: Map<String, dynamic>.from(json['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'cuisine': cuisine,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'distance': distance,
      'isOpen': isOpen,
      'tags': tags,
      'location': location,
    };
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

  String get formattedDeliveryFee {
    return deliveryFee == 0 ? 'Free' : '\$${deliveryFee.toStringAsFixed(2)}';
  }

  String get formattedDistance {
    return '${distance.toStringAsFixed(1)} km';
  }

  String get formattedDeliveryTime {
    return '$deliveryTime-${deliveryTime + 10} min';
  }
}

class FoodItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final List<String> allergens;
  final bool isVegetarian;
  final bool isVegan;
  final bool isSpicy;
  final int calories;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  FoodItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.ingredients = const [],
    this.allergens = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isSpicy = false,
    this.calories = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      restaurantId: json['restaurantId'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      category: json['category'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isSpicy: json['isSpicy'] ?? false,
      calories: json['calories'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'ingredients': ingredients,
      'allergens': allergens,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isSpicy': isSpicy,
      'calories': calories,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
    };
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
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
}

class CartItem {
  final String id;
  final FoodItem foodItem;
  final int quantity;
  final List<String> customizations;
  final String? specialInstructions;

  CartItem({
    required this.id,
    required this.foodItem,
    required this.quantity,
    this.customizations = const [],
    this.specialInstructions,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      foodItem: FoodItem.fromJson(json['foodItem']),
      quantity: json['quantity'],
      customizations: List<String>.from(json['customizations'] ?? []),
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'customizations': customizations,
      'specialInstructions': specialInstructions,
    };
  }

  double get totalPrice {
    return foodItem.price * quantity;
  }

  String get formattedTotalPrice {
    return '\$${totalPrice.toStringAsFixed(2)}';
  }
}

class DeliveryOrder {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double tip;
  final double total;
  final DeliveryAddress deliveryAddress;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? trackingNumber;

  DeliveryOrder({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.tip,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.estimatedDelivery,
    this.actualDelivery,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.trackingNumber,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'],
      userId: json['userId'],
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0.0,
      tax: json['tax']?.toDouble() ?? 0.0,
      tip: json['tip']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedDelivery: json['estimatedDelivery'] != null 
          ? DateTime.parse(json['estimatedDelivery']) 
          : null,
      actualDelivery: json['actualDelivery'] != null 
          ? DateTime.parse(json['actualDelivery']) 
          : null,
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'tip': tip,
      'total': total,
      'deliveryAddress': deliveryAddress.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'actualDelivery': actualDelivery?.toIso8601String(),
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'trackingNumber': trackingNumber,
    };
  }

  String get formattedTotal {
    return '\$${total.toStringAsFixed(2)}';
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.delivering:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Duration? get estimatedTimeRemaining {
    if (estimatedDelivery == null) return null;
    final now = DateTime.now();
    if (estimatedDelivery!.isBefore(now)) return Duration.zero;
    return estimatedDelivery!.difference(now);
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickedUp,
  delivering,
  delivered,
  cancelled,
}

class DeliveryAddress {
  final String id;
  final String fullName;
  final String address;
  final String apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final Map<String, dynamic> location; // lat, lng
  final String? instructions;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.fullName,
    required this.address,
    this.apartment = '',
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    required this.location,
    this.instructions,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      fullName: json['fullName'],
      address: json['address'],
      apartment: json['apartment'] ?? '',
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
      location: Map<String, dynamic>.from(json['location'] ?? {}),
      instructions: json['instructions'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address': address,
      'apartment': apartment,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'location': location,
      'instructions': instructions,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    final parts = [address];
    if (apartment.isNotEmpty) parts.add('Apt $apartment');
    parts.addAll([city, '$state $zipCode', country]);
    return parts.join(', ');
  }
}

class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'apple_pay', 'cash'
  final String lastFourDigits;
  final String brand; // 'visa', 'mastercard', etc.
  final DateTime? expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.brand,
    this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      lastFourDigits: json['lastFourDigits'],
      brand: json['brand'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'expiryDate': expiryDate?.toIso8601String(),
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
      case 'cash':
        return 'Cash on Delivery';
      default:
        return type;
    }
  }
}