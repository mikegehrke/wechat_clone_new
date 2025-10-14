import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart' hide Order;
import '../models/product.dart' as product;

class EcommerceService {
  static const String _baseUrl =
      'https://api.example.com'; // In real app, use real API
  static const String _apiKey = 'your_api_key_here';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search products
  static Future<List<Product>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query firestoreQuery = _firestore.collection('products');

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category);
      }

      if (minPrice != null) {
        firestoreQuery = firestoreQuery.where(
          'price',
          isGreaterThanOrEqualTo: minPrice,
        );
      }

      if (maxPrice != null) {
        firestoreQuery = firestoreQuery.where(
          'price',
          isLessThanOrEqualTo: maxPrice,
        );
      }

      final snapshot = await firestoreQuery.limit(limit).get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();

      // Filter by query if provided
      if (query.isNotEmpty) {
        return products
            .where(
              (p) =>
                  p.title.toLowerCase().contains(query.toLowerCase()) ||
                  p.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      return products;
    } catch (e) {
      print('Firestore error, falling back to mock: $e');
      return _createMockProducts();
    }
  }

  // Get product by ID
  static Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Product.fromJson(data);
    } catch (e) {
      print('Firestore error, falling back to mock: $e');
      final products = _createMockProducts();
      return products.isNotEmpty ? products.first : null;
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory({
    required String category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Firestore error, falling back to mock: $e');
      return _createMockProducts();
    }
  }

  // Get featured products
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      return _createMockProducts().take(10).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: $e');
    }
  }

  // Get trending products
  static Future<List<Product>> getTrendingProducts() async {
    try {
      return _createMockProducts().take(15).toList();
    } catch (e) {
      throw Exception('Failed to get trending products: $e');
    }
  }

  // Get product reviews
  static Future<List<Map<String, dynamic>>> getProductReviews(
    String productId,
  ) async {
    try {
      // Mock reviews
      return [
        {
          'id': '1',
          'userId': 'user1',
          'username': 'John Doe',
          'rating': 5,
          'title': 'Great product!',
          'comment': 'Really happy with this purchase. Quality is excellent.',
          'date': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'verified': true,
        },
        {
          'id': '2',
          'userId': 'user2',
          'username': 'Jane Smith',
          'rating': 4,
          'title': 'Good value',
          'comment': 'Good quality for the price. Would recommend.',
          'date': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
          'verified': true,
        },
        {
          'id': '3',
          'userId': 'user3',
          'username': 'Mike Johnson',
          'rating': 3,
          'title': 'Average',
          'comment': 'It\'s okay, nothing special but does the job.',
          'date': DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
          'verified': false,
        },
      ];
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  // Add product to cart
  static Future<void> addToCart(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .set({
            'productId': productId,
            'quantity': quantity,
            'addedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // Get user's cart
  static Future<List<CartItem>> getCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final cartItems = <CartItem>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productId = data['productId'];
        final quantity = data['quantity'];

        // Get product details
        final product = await getProduct(productId);
        if (product != null) {
          cartItems.add(
            CartItem(
              id: doc.id,
              product: product,
              quantity: quantity,
              addedAt:
                  (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            ),
          );
        }
      }

      return cartItems;
    } catch (e) {
      print('Firestore error, falling back to mock: $e');
      return _createMockCartItems();
    }
  }

  // Update cart item quantity
  static Future<void> updateCartItem(
    String userId,
    String itemId,
    int quantity,
  ) async {
    try {
      // In real app, make HTTP request to update cart
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String userId, String itemId) async {
    try {
      // In real app, make HTTP request to remove from cart
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  // Clear cart
  static Future<void> clearCart(String userId) async {
    try {
      // In real app, make HTTP request to clear cart
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Create order
  static Future<product.Order> createOrder({
    required String userId,
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.08; // 8% tax
      final shipping = subtotal > 50 ? 0.0 : 9.99; // Free shipping over $50
      final total = subtotal + tax + shipping;

      final order = product.Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      // In real app, save order to database
      await Future.delayed(const Duration(seconds: 1));

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<product.Order>> getUserOrders(String userId) async {
    try {
      // In real app, make HTTP request to get orders
      return _createMockOrders();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  // Get order by ID
  static Future<product.Order?> getOrder(String orderId) async {
    try {
      // In real app, make HTTP request to get order
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
        'status': 'shipped',
        'trackingNumber': '1Z999AA1234567890',
        'carrier': 'UPS',
        'estimatedDelivery': DateTime.now()
            .add(const Duration(days: 3))
            .toIso8601String(),
        'trackingHistory': [
          {
            'status': 'Order placed',
            'date': DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String(),
            'location': 'Warehouse',
          },
          {
            'status': 'Shipped',
            'date': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'location': 'Distribution Center',
          },
          {
            'status': 'In transit',
            'date': DateTime.now().toIso8601String(),
            'location': 'On the way',
          },
        ],
      };
    } catch (e) {
      throw Exception('Failed to track order: $e');
    }
  }

  // Get categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      return [
        {'id': 'electronics', 'name': 'Electronics', 'icon': '📱'},
        {'id': 'clothing', 'name': 'Clothing', 'icon': '👕'},
        {'id': 'home', 'name': 'Home & Garden', 'icon': '🏠'},
        {'id': 'sports', 'name': 'Sports & Outdoors', 'icon': '⚽'},
        {'id': 'books', 'name': 'Books', 'icon': '📚'},
        {'id': 'beauty', 'name': 'Beauty & Health', 'icon': '💄'},
        {'id': 'toys', 'name': 'Toys & Games', 'icon': '🧸'},
        {'id': 'automotive', 'name': 'Automotive', 'icon': '🚗'},
        {'id': 'food', 'name': 'Food & Grocery', 'icon': '🍎'},
        {'id': 'jewelry', 'name': 'Jewelry', 'icon': '💍'},
      ];
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Mock data generators
  static List<Product> _createMockProducts() {
    final categories = ['Electronics', 'Clothing', 'Home', 'Sports', 'Books'];
    final brands = [
      'Apple',
      'Samsung',
      'Nike',
      'Adidas',
      'Sony',
      'LG',
      'Dell',
      'HP',
    ];

    return List.generate(50, (index) {
      final category = categories[index % categories.length];
      final brand = brands[index % brands.length];
      final price = 10.0 + (index * 5.0);
      final originalPrice = price + (index % 3 == 0 ? 20.0 : 0.0);

      return Product(
        id: 'product_$index',
        title: _generateProductTitle(category, brand, index),
        description: _generateProductDescription(category),
        price: price,
        originalPrice: originalPrice > price ? originalPrice : null,
        images: List.generate(
          3,
          (i) =>
              'https://via.placeholder.com/400x400/${_getRandomColor()}/FFFFFF?text=$brand+${i + 1}',
        ),
        category: category,
        subcategories: _getSubcategories(category),
        brand: brand,
        rating: 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0),
        reviewCount: 10 + (index * 5),
        isInStock: index % 10 != 0,
        stockQuantity: 50 + (index * 2),
        specifications: _getSpecifications(category),
        features: _getFeatures(category),
        sellerId: 'seller_${index % 5}',
        sellerName: '$brand Store',
        sellerRating: 4.0 + (index % 2 == 0 ? 0.5 : 0.0),
        isPrimeEligible: index % 3 == 0,
        isFreeShipping: price > 25.0,
        shippingTime: price > 50.0 ? '1-2 days' : '3-5 days',
        tags: _getTags(category),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }

  static List<CartItem> _createMockCartItems() {
    final products = _createMockProducts().take(3).toList();
    return products.map((product) {
      return CartItem(
        id: 'cart_${product.id}',
        product: product,
        quantity: 1 + (products.indexOf(product) % 3),
        addedAt: DateTime.now().subtract(
          Duration(days: products.indexOf(product)),
        ),
      );
    }).toList();
  }

  static List<product.Order> _createMockOrders() {
    final cartItems = _createMockCartItems();
    final orders = <product.Order>[];

    for (var index = 0; index < 5; index++) {
      final subtotal = cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final tax = subtotal * 0.08;
      final shipping = subtotal > 50 ? 0.0 : 9.99;
      final total = subtotal + tax + shipping;

      orders.add(
        product.Order(
          id: 'order_$index',
          userId: 'user_1',
          items: cartItems,
          subtotal: subtotal,
          tax: tax,
          shipping: shipping,
          total: total,
          status: OrderStatus.values[index % OrderStatus.values.length],
          shippingAddress: ShippingAddress(
            id: 'address_1',
            fullName: 'John Doe',
            address: '123 Main St',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            country: 'USA',
            phoneNumber: '+1-555-0123',
          ),
          paymentMethod: PaymentMethod(
            id: 'payment_1',
            type: 'card',
            lastFourDigits: '1234',
            brand: 'visa',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
          ),
          createdAt: DateTime.now().subtract(Duration(days: index * 7)),
          shippedAt: index > 0
              ? DateTime.now().subtract(Duration(days: index * 7 - 2))
              : null,
          deliveredAt: index > 2
              ? DateTime.now().subtract(Duration(days: index * 7 - 5))
              : null,
          trackingNumber: index > 0 ? '1Z999AA123456789$index' : null,
        ),
      );
    }

    return orders;
  }

  static String _generateProductTitle(
    String category,
    String brand,
    int index,
  ) {
    final titles = {
      'Electronics': [
        'Smartphone',
        'Laptop',
        'Headphones',
        'Tablet',
        'Smart Watch',
      ],
      'Clothing': ['T-Shirt', 'Jeans', 'Sneakers', 'Jacket', 'Dress'],
      'Home': [
        'Coffee Maker',
        'Vacuum Cleaner',
        'Air Purifier',
        'Blender',
        'Toaster',
      ],
      'Sports': [
        'Running Shoes',
        'Yoga Mat',
        'Dumbbells',
        'Basketball',
        'Tennis Racket',
      ],
      'Books': ['Novel', 'Cookbook', 'Biography', 'Textbook', 'Comic Book'],
    };

    final categoryTitles = titles[category] ?? ['Product'];
    final title = categoryTitles[index % categoryTitles.length];
    return '$brand $title ${index + 1}';
  }

  static String _generateProductDescription(String category) {
    final descriptions = {
      'Electronics':
          'High-quality electronic device with advanced features and modern design.',
      'Clothing':
          'Comfortable and stylish clothing made from premium materials.',
      'Home':
          'Essential home appliance that makes your daily life easier and more convenient.',
      'Sports':
          'Professional-grade sports equipment for athletes and fitness enthusiasts.',
      'Books':
          'Engaging and informative book that provides valuable knowledge and entertainment.',
    };

    return descriptions[category] ?? 'Quality product with excellent features.';
  }

  static List<String> _getSubcategories(String category) {
    final subcategories = {
      'Electronics': ['Smartphones', 'Computers', 'Audio', 'Cameras'],
      'Clothing': ['Men', 'Women', 'Kids', 'Accessories'],
      'Home': ['Kitchen', 'Living Room', 'Bedroom', 'Bathroom'],
      'Sports': ['Fitness', 'Outdoor', 'Team Sports', 'Water Sports'],
      'Books': ['Fiction', 'Non-Fiction', 'Educational', 'Children'],
    };

    return subcategories[category] ?? ['General'];
  }

  static Map<String, dynamic> _getSpecifications(String category) {
    final specifications = {
      'Electronics': {
        'Weight': '150g',
        'Dimensions': '6.1" x 2.8" x 0.3"',
        'Battery': '3000mAh',
        'Storage': '128GB',
      },
      'Clothing': {
        'Material': '100% Cotton',
        'Size': 'Medium',
        'Color': 'Black',
        'Care': 'Machine Washable',
      },
      'Home': {
        'Power': '120V',
        'Capacity': '2L',
        'Material': 'Stainless Steel',
        'Warranty': '2 Years',
      },
      'Sports': {
        'Weight': '500g',
        'Size': 'Standard',
        'Material': 'Rubber',
        'Color': 'Black',
      },
      'Books': {
        'Pages': '300',
        'Language': 'English',
        'Format': 'Paperback',
        'Publisher': 'Example Publishing',
      },
    };

    return specifications[category] ?? {'Type': 'General'};
  }

  static List<String> _getFeatures(String category) {
    final features = {
      'Electronics': [
        'Wireless',
        'Bluetooth',
        'Water Resistant',
        'Fast Charging',
      ],
      'Clothing': ['Comfortable', 'Durable', 'Easy Care', 'Stylish'],
      'Home': ['Energy Efficient', 'Easy to Use', 'Compact', 'Reliable'],
      'Sports': ['Professional Grade', 'Durable', 'Lightweight', 'Ergonomic'],
      'Books': ['Well Written', 'Informative', 'Engaging', 'Educational'],
    };

    return features[category] ?? ['Quality', 'Reliable'];
  }

  static List<String> _getTags(String category) {
    final tags = {
      'Electronics': ['tech', 'gadget', 'modern', 'smart'],
      'Clothing': ['fashion', 'style', 'comfort', 'trendy'],
      'Home': ['appliance', 'convenient', 'practical', 'essential'],
      'Sports': ['fitness', 'athletic', 'performance', 'active'],
      'Books': ['reading', 'knowledge', 'education', 'entertainment'],
    };

    return tags[category] ?? ['quality', 'popular'];
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B',
      '4ECDC4',
      '45B7D1',
      '96CEB4',
      'FFEAA7',
      'DDA0DD',
      '98D8C8',
      'F7DC6F',
      'BB8FCE',
      '85C1E9',
      'F8C471',
      '82E0AA',
    ];
    return colors[DateTime.now().microsecondsSinceEpoch % colors.length];
  }
}
