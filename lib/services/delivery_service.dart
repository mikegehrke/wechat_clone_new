import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery.dart';

class DeliveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _restaurantsCollection = 'restaurants';
  static const String _menuItemsCollection = 'menuItems';
  static const String _ordersCollection = 'deliveryOrders';
  static const String _usersCollection = 'users';
  // Get nearby restaurants
  static Future<List<Restaurant>> getNearbyRestaurants({
    required Map<String, double> userLocation,
    double radius = 10.0, // km
  }) async {
    try {
      // Basic implementation: fetch all and filter by approximate distance
      final snapshot = await _firestore
          .collection(_restaurantsCollection)
          .orderBy('rating', descending: true)
          .limit(100)
          .get();
      final lat = userLocation['lat'];
      final lng = userLocation['lng'];
      final List<Restaurant> restaurants = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Restaurant.fromJson(data);
      }).where((r) {
        if (lat == null || lng == null) return true;
        final rlat = (r.location['lat'] as num?)?.toDouble();
        final rlng = (r.location['lng'] as num?)?.toDouble();
        if (rlat == null || rlng == null) return false;
        final dLat = (rlat - lat).abs();
        final dLng = (rlng - lng).abs();
        // Very rough filter (~111km per degree)
        final approxKm = (dLat + dLng) * 111.0;
        return approxKm <= radius;
      }).toList();
      return restaurants;
    } catch (e) {
      throw Exception('Failed to get nearby restaurants: $e');
    }
  }

  // Search restaurants
  static Future<List<Restaurant>> searchRestaurants({
    required String query,
    String? cuisine,
    double? minRating,
    double? maxDeliveryFee,
    int? maxDeliveryTime,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore.collection(_restaurantsCollection).limit(100);
      if (cuisine != null && cuisine.isNotEmpty) {
        q = q.where('cuisine', isEqualTo: cuisine);
      }
      if (minRating != null) {
        q = q.where('rating', isGreaterThanOrEqualTo: minRating);
      }
      final snapshot = await q.get();
      var restaurants = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Restaurant.fromJson(data);
      }).toList();
      final normalized = query.toLowerCase();
      restaurants = restaurants.where((r) =>
          r.name.toLowerCase().contains(normalized) ||
          r.description.toLowerCase().contains(normalized) ||
          r.cuisine.toLowerCase().contains(normalized)).toList();
      if (maxDeliveryFee != null) {
        restaurants = restaurants.where((r) => r.deliveryFee <= maxDeliveryFee).toList();
      }
      if (maxDeliveryTime != null) {
        restaurants = restaurants.where((r) => r.deliveryTime <= maxDeliveryTime).toList();
      }
      return restaurants;
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  // Get restaurant menu
  static Future<List<FoodItem>> getRestaurantMenu(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_menuItemsCollection)
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('category')
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return FoodItem.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get restaurant menu: $e');
    }
  }

  // Get food item details
  static Future<FoodItem?> getFoodItem(String itemId) async {
    try {
      final doc = await _firestore.collection(_menuItemsCollection).doc(itemId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return FoodItem.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get food item: $e');
    }
  }

  // Create delivery order
  static Future<DeliveryOrder> createOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required DeliveryAddress deliveryAddress,
    required PaymentMethod paymentMethod,
    double tip = 0.0,
  }) async {
    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final deliveryFee = subtotal > 25 ? 0.0 : 2.99; // Free delivery over $25
      final tax = subtotal * 0.08; // 8% tax
      final total = subtotal + deliveryFee + tax + tip;

      final orderRef = _firestore.collection(_ordersCollection).doc();
      final order = DeliveryOrder(
        id: orderRef.id,
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        tip: tip,
        total: total,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(minutes: 45)),
      );
      await orderRef.set(order.toJson());
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('deliveryOrders')
          .doc(order.id)
          .set({'orderId': order.id, 'createdAt': order.createdAt.toIso8601String()});
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<DeliveryOrder>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return DeliveryOrder.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  // Get order by ID
  static Future<DeliveryOrder?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return DeliveryOrder.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Track order
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('deliveryTracking').doc(orderId).get();
      if (!doc.exists) {
        return {
          'orderId': orderId,
          'status': 'preparing',
          'estimatedDelivery': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
          'trackingHistory': [],
        };
      }
      final data = Map<String, dynamic>.from(doc.data()!);
      data['orderId'] = orderId;
      return data;
    } catch (e) {
      throw Exception('Failed to track order: $e');
    }
  }

  // Cancel order
  static Future<void> cancelOrder(String orderId) async {
    try {
      final orderRef = _firestore.collection(_ordersCollection).doc(orderId);
      await orderRef.update({'status': 'cancelled'});
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Rate order
  static Future<void> rateOrder(String orderId, double rating, String? review) async {
    try {
      final orderRef = _firestore.collection(_ordersCollection).doc(orderId);
      await orderRef.set({
        'rating': rating,
        'review': review,
        'ratedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to rate order: $e');
    }
  }

  // Get cuisines
  static Future<List<String>> getCuisines() async {
    try {
      return [
        'American',
        'Italian',
        'Chinese',
        'Mexican',
        'Indian',
        'Thai',
        'Japanese',
        'Mediterranean',
        'Korean',
        'Vietnamese',
        'French',
        'Greek',
        'Turkish',
        'Lebanese',
        'Brazilian',
        'Ethiopian',
        'Caribbean',
        'German',
        'Spanish',
        'British',
      ];
    } catch (e) {
      throw Exception('Failed to get cuisines: $e');
    }
  }

  // Mock data generators (kept for reference)
  static List<Restaurant> _createMockRestaurants() {
    final cuisines = ['American', 'Italian', 'Chinese', 'Mexican', 'Indian', 'Thai', 'Japanese'];
    final names = [
      'Mario\'s Pizza', 'Golden Dragon', 'Taco Fiesta', 'Spice Palace', 'Sushi Zen',
      'Burger Junction', 'Pasta House', 'Curry Corner', 'Noodle Bar', 'BBQ Pit',
      'Seafood Shack', 'Veggie Garden', 'Steak House', 'Cafe Central', 'Deli Express',
    ];
    
    return List.generate(20, (index) {
      final cuisine = cuisines[index % cuisines.length];
      final name = names[index % names.length];
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      final deliveryFee = index % 4 == 0 ? 0.0 : 2.99;
      final deliveryTime = 25 + (index % 20);
      final distance = 0.5 + (index * 0.3);
      
      return Restaurant(
        id: 'restaurant_$index',
        name: name,
        description: _generateRestaurantDescription(cuisine),
        imageUrl: 'https://via.placeholder.com/400x300/${_getRandomColor()}/FFFFFF?text=$name',
        address: _generateAddress(),
        rating: rating,
        reviewCount: 50 + (index * 10),
        cuisine: cuisine,
        deliveryFee: deliveryFee,
        deliveryTime: deliveryTime,
        distance: distance,
        isOpen: index % 10 != 0,
        tags: _getRestaurantTags(cuisine),
        location: {
          'lat': 40.7128 + (index * 0.001),
          'lng': -74.0060 + (index * 0.001),
        },
      );
    });
  }

  static List<FoodItem> _createMockFoodItems(String restaurantId) {
    final categories = ['Appetizers', 'Main Course', 'Desserts', 'Beverages', 'Salads'];
    final items = [
      'Margherita Pizza', 'Chicken Burger', 'Caesar Salad', 'Chocolate Cake', 'Coca Cola',
      'Pasta Carbonara', 'Fish Tacos', 'Greek Salad', 'Tiramisu', 'Orange Juice',
      'Spring Rolls', 'Beef Stir Fry', 'Fruit Salad', 'Ice Cream', 'Coffee',
      'Garlic Bread', 'BBQ Ribs', 'Caprese Salad', 'Cheesecake', 'Tea',
    ];
    
    return List.generate(15, (index) {
      final category = categories[index % categories.length];
      final item = items[index % items.length];
      final price = 8.0 + (index * 2.0);
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      
      return FoodItem(
        id: 'item_$index',
        restaurantId: restaurantId,
        name: item,
        description: _generateFoodDescription(item),
        price: price,
        imageUrl: 'https://via.placeholder.com/300x200/${_getRandomColor()}/FFFFFF?text=$item',
        category: category,
        ingredients: _getIngredients(item),
        allergens: _getAllergens(item),
        isVegetarian: index % 3 == 0,
        isVegan: index % 5 == 0,
        isSpicy: index % 4 == 0,
        calories: 200 + (index * 50),
        rating: rating,
        reviewCount: 10 + (index * 3),
        isAvailable: index % 10 != 0,
      );
    });
  }

  static List<DeliveryOrder> _createMockOrders() {
    final restaurants = _createMockRestaurants().take(5).toList();
    final foodItems = _createMockFoodItems('restaurant_1').take(3).toList();
    
    return List.generate(5, (index) {
      final restaurant = restaurants[index];
      final items = foodItems.map((item) => CartItem(
        id: 'cart_${item.id}',
        foodItem: item,
        quantity: 1 + (index % 3),
      )).toList();
      
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final deliveryFee = subtotal > 25 ? 0.0 : 2.99;
      final tax = subtotal * 0.08;
      final tip = subtotal * 0.15;
      final total = subtotal + deliveryFee + tax + tip;
      
      return DeliveryOrder(
        id: 'order_$index',
        userId: 'user_1',
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        tip: tip,
        total: total,
        status: OrderStatus.values[index % OrderStatus.values.length],
        deliveryAddress: DeliveryAddress(
          id: 'address_1',
          fullName: 'John Doe',
          address: '123 Main St',
          apartment: 'Apt 4B',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          phoneNumber: '+1-555-0123',
          location: {'lat': 40.7128, 'lng': -74.0060},
        ),
        paymentMethod: PaymentMethod(
          id: 'payment_1',
          type: 'card',
          lastFourDigits: '1234',
          brand: 'visa',
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ),
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        estimatedDelivery: DateTime.now().subtract(Duration(days: index * 2)).add(const Duration(minutes: 45)),
        actualDelivery: index > 2 ? DateTime.now().subtract(Duration(days: index * 2)).add(const Duration(minutes: 50)) : null,
        driverId: 'driver_$index',
        driverName: 'Driver ${index + 1}',
        driverPhone: '+1-555-000$index',
        trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );
    });
  }

  static String _generateRestaurantDescription(String cuisine) {
    final descriptions = {
      'American': 'Classic American comfort food with a modern twist',
      'Italian': 'Authentic Italian cuisine made with fresh ingredients',
      'Chinese': 'Traditional Chinese dishes with bold flavors',
      'Mexican': 'Spicy and flavorful Mexican street food',
      'Indian': 'Rich and aromatic Indian spices and curries',
      'Thai': 'Fresh Thai ingredients with perfect balance of flavors',
      'Japanese': 'Fresh sushi and traditional Japanese dishes',
    };
    return descriptions[cuisine] ?? 'Delicious food made with love';
  }

  static String _generateFoodDescription(String item) {
    return 'Delicious $item made with fresh ingredients and authentic flavors. Perfect for any occasion.';
  }

  static String _generateAddress() {
    final streets = ['Main St', 'Oak Ave', 'Pine Rd', 'Elm St', 'Cedar Blvd'];
    final street = streets[Random().nextInt(streets.length)];
    final number = 100 + Random().nextInt(900);
    return '$number $street, New York, NY 10001';
  }

  static List<String> _getRestaurantTags(String cuisine) {
    final tags = {
      'American': ['Fast Food', 'Casual', 'Family Friendly'],
      'Italian': ['Authentic', 'Romantic', 'Fine Dining'],
      'Chinese': ['Traditional', 'Spicy', 'Takeout'],
      'Mexican': ['Spicy', 'Street Food', 'Casual'],
      'Indian': ['Spicy', 'Vegetarian Options', 'Traditional'],
      'Thai': ['Spicy', 'Fresh', 'Healthy'],
      'Japanese': ['Fresh', 'Healthy', 'Traditional'],
    };
    return tags[cuisine] ?? ['Popular', 'Local'];
  }

  static List<String> _getIngredients(String item) {
    final ingredients = {
      'Margherita Pizza': ['Tomato sauce', 'Mozzarella', 'Basil', 'Olive oil'],
      'Chicken Burger': ['Chicken patty', 'Lettuce', 'Tomato', 'Onion', 'Mayo'],
      'Caesar Salad': ['Romaine lettuce', 'Parmesan', 'Croutons', 'Caesar dressing'],
      'Chocolate Cake': ['Chocolate', 'Flour', 'Eggs', 'Sugar', 'Butter'],
      'Coca Cola': ['Carbonated water', 'Sugar', 'Caffeine'],
    };
    return ingredients[item] ?? ['Fresh ingredients', 'Natural flavors'];
  }

  static List<String> _getAllergens(String item) {
    final allergens = <String, List<String>>{
      'Margherita Pizza': ['Gluten', 'Dairy'],
      'Chicken Burger': ['Gluten', 'Eggs'],
      'Caesar Salad': ['Dairy', 'Gluten'],
      'Chocolate Cake': ['Gluten', 'Eggs', 'Dairy'],
      'Coca Cola': [],
    };
    return allergens[item] ?? [];
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[Random().nextInt(colors.length)];
  }

  // Place order (legacy path) — prefer createOrder
  static Future<DeliveryOrder> placeOrder({
    required String userId,
    required String restaurantId,
    required List<CartItem> items,
    required String deliveryAddress,
    String? deliveryInstructions,
    required String paymentMethod,
    double tip = 0.0,
  }) async {
    try {
      // Delegate to createOrder with minimal mapping
      final address = DeliveryAddress(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: '',
        address: deliveryAddress,
        city: '',
        state: '',
        zipCode: '',
        country: '',
        phoneNumber: '',
      );
      final pm = PaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        type: paymentMethod,
        lastFourDigits: '',
        brand: '',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      );
      return await createOrder(
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: 'Restaurant',
        items: items,
        deliveryAddress: address,
        paymentMethod: pm,
        tip: tip,
      );
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}