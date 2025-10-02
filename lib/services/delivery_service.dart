import 'dart:math';
import '../models/delivery.dart';

class DeliveryService {
  // Get nearby restaurants
  static Future<List<Restaurant>> getNearbyRestaurants({
    required Map<String, double> userLocation,
    double radius = 10.0, // km
  }) async {
    try {
      // In real app, make API call to get nearby restaurants
      // For demo, return mock data
      return _createMockRestaurants();
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
      // In real app, make API call to search restaurants
      return _createMockRestaurants();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  // Get restaurant menu
  static Future<List<FoodItem>> getRestaurantMenu(String restaurantId) async {
    try {
      // In real app, make API call to get restaurant menu
      return _createMockFoodItems(restaurantId);
    } catch (e) {
      throw Exception('Failed to get restaurant menu: $e');
    }
  }

  // Get food item details
  static Future<FoodItem?> getFoodItem(String itemId) async {
    try {
      // In real app, make API call to get food item details
      final items = _createMockFoodItems('restaurant_1');
      return items.isNotEmpty ? items.first : null;
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

      final order = DeliveryOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      // In real app, save order to database
      await Future.delayed(const Duration(seconds: 1));

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<DeliveryOrder>> getUserOrders(String userId) async {
    try {
      // In real app, make API call to get user orders
      return _createMockOrders();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  // Get order by ID
  static Future<DeliveryOrder?> getOrder(String orderId) async {
    try {
      // In real app, make API call to get order
      final orders = _createMockOrders();
      return orders.isNotEmpty ? orders.first : null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Track order
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      // Mock tracking data
      return {
        'orderId': orderId,
        'status': 'delivering',
        'driverName': 'John Smith',
        'driverPhone': '+1-555-0123',
        'estimatedDelivery': DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
        'location': {
          'lat': 40.7128,
          'lng': -74.0060,
        },
        'trackingHistory': [
          {
            'status': 'Order placed',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
            'description': 'Your order has been placed',
          },
          {
            'status': 'Confirmed',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
            'description': 'Restaurant confirmed your order',
          },
          {
            'status': 'Preparing',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
            'description': 'Restaurant is preparing your food',
          },
          {
            'status': 'Ready',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
            'description': 'Your order is ready for pickup',
          },
          {
            'status': 'Picked up',
            'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
            'description': 'Driver picked up your order',
          },
          {
            'status': 'On the way',
            'timestamp': DateTime.now().toIso8601String(),
            'description': 'Driver is on the way to you',
          },
        ],
      };
    } catch (e) {
      throw Exception('Failed to track order: $e');
    }
  }

  // Cancel order
  static Future<void> cancelOrder(String orderId) async {
    try {
      // In real app, make API call to cancel order
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Rate order
  static Future<void> rateOrder(String orderId, double rating, String? review) async {
    try {
      // In real app, make API call to rate order
      await Future.delayed(const Duration(milliseconds: 500));
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

  // Mock data generators
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

  // Place order
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
      // In real app, send order to backend API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      final subtotal = items.fold(0.0, (sum, item) => sum + (item.foodItem.price * item.quantity));
      final deliveryFee = 2.99;
      final tax = subtotal * 0.08;
      final total = subtotal + deliveryFee + tax + tip;
      
      return DeliveryOrder(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: 'Restaurant Name', // In real app, fetch from restaurant
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        tip: tip,
        total: total,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 30)),
        deliveryAddress: deliveryAddress,
        deliveryInstructions: deliveryInstructions,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}