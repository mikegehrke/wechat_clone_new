import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class EcommerceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _productsCollection = 'products';
  static const String _categoriesCollection = 'categories';
  static const String _usersCollection = 'users';
  static const String _ordersCollection = 'orders';
  static const String _reviewsCollection = 'productReviews';

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
      // Firestore has limited full-text search; we fetch and filter client-side
      Query<Map<String, dynamic>> q = _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (category != null && category.isNotEmpty) {
        q = _firestore
            .collection(_productsCollection)
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true)
            .limit(limit);
      }
      final snapshot = await q.get();
      var products = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
      final normalized = query.toLowerCase();
      products = products.where((p) {
        final hay = [
          p.title,
          p.description,
          p.brand,
          p.category,
          ...p.tags,
        ].join(' ').toLowerCase();
        return hay.contains(normalized);
      }).toList();
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_asc':
            products.sort((a, b) => a.price.compareTo(b.price));
            break;
          case 'price_desc':
            products.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'rating':
            products.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case 'newest':
          default:
            products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
      return products;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection(_productsCollection).doc(productId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return Product.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get product: $e');
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
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Get featured products
  static Future<List<Product>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: $e');
    }
  }

  // Get trending products
  static Future<List<Product>> getTrendingProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('isTrending', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(15)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending products: $e');
    }
  }

  // Get product reviews
  static Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productId)
          .orderBy('date', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  // Add product to cart
  static Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      final productDoc = await _firestore.collection(_productsCollection).doc(productId).get();
      if (!productDoc.exists) throw Exception('Product not found');
      final productData = Map<String, dynamic>.from(productDoc.data()!);
      productData['id'] = productDoc.id;
      final product = Product.fromJson(productData);
      final cartRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(productId);
      await cartRef.set({
        'id': 'cart_$productId',
        'product': product.toJson(),
        'quantity': quantity,
        'addedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // Get user's cart
  static Future<List<CartItem>> getCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('cart')
          .orderBy('addedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return CartItem.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  // Update cart item quantity
  static Future<void> updateCartItem(String userId, String itemId, int quantity) async {
    try {
      final itemRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(itemId);
      await itemRef.update({'quantity': quantity});
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String userId, String itemId) async {
    try {
      final itemRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('cart')
          .doc(itemId);
      await itemRef.delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  // Clear cart
  static Future<void> clearCart(String userId) async {
    try {
      final cartCol = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('cart');
      final snapshot = await cartCol.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Create order
  static Future<Order> createOrder({
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

      final orderRef = _firestore.collection(_ordersCollection).doc();
      final order = Order(
        id: orderRef.id,
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
      await orderRef.set(order.toJson());
      // Optionally write a user-scoped reference
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('orders')
          .doc(order.id)
          .set({'orderId': order.id, 'createdAt': order.createdAt.toIso8601String()});
      // Clear cart after placing order
      await clearCart(userId);
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  // Get order by ID
  static Future<Order?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Track order
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orderTracking').doc(orderId).get();
      if (!doc.exists) {
        return {
          'orderId': orderId,
          'status': 'processing',
          'estimatedDelivery': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
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

  // Get categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_categoriesCollection)
          .orderBy('name')
          .get();
      if (snapshot.docs.isEmpty) {
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
      }
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Mock data generators (unused with real backend, kept for reference only)
  static List<Product> _createMockProducts() {
    final categories = ['Electronics', 'Clothing', 'Home', 'Sports', 'Books'];
    final brands = ['Apple', 'Samsung', 'Nike', 'Adidas', 'Sony', 'LG', 'Dell', 'HP'];
    
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
        images: List.generate(3, (i) => 
          'https://via.placeholder.com/400x400/${_getRandomColor()}/FFFFFF?text=${brand}+${i + 1}'),
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
        sellerName: '${brand} Store',
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
        addedAt: DateTime.now().subtract(Duration(days: products.indexOf(product))),
      );
    }).toList();
  }

  static List<Order> _createMockOrders() {
    final cartItems = _createMockCartItems();
    return List.generate(5, (index) {
      final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.08;
      final shipping = subtotal > 50 ? 0.0 : 9.99;
      final total = subtotal + tax + shipping;

      return Order(
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
        shippedAt: index > 0 ? DateTime.now().subtract(Duration(days: index * 7 - 2)) : null,
        deliveredAt: index > 2 ? DateTime.now().subtract(Duration(days: index * 7 - 5)) : null,
        trackingNumber: index > 0 ? '1Z999AA123456789$index' : null,
      );
    });
  }

  static String _generateProductTitle(String category, String brand, int index) {
    final titles = {
      'Electronics': ['Smartphone', 'Laptop', 'Headphones', 'Tablet', 'Smart Watch'],
      'Clothing': ['T-Shirt', 'Jeans', 'Sneakers', 'Jacket', 'Dress'],
      'Home': ['Coffee Maker', 'Vacuum Cleaner', 'Air Purifier', 'Blender', 'Toaster'],
      'Sports': ['Running Shoes', 'Yoga Mat', 'Dumbbells', 'Basketball', 'Tennis Racket'],
      'Books': ['Novel', 'Cookbook', 'Biography', 'Textbook', 'Comic Book'],
    };
    
    final categoryTitles = titles[category] ?? ['Product'];
    final title = categoryTitles[index % categoryTitles.length];
    return '$brand $title ${index + 1}';
  }

  static String _generateProductDescription(String category) {
    final descriptions = {
      'Electronics': 'High-quality electronic device with advanced features and modern design.',
      'Clothing': 'Comfortable and stylish clothing made from premium materials.',
      'Home': 'Essential home appliance that makes your daily life easier and more convenient.',
      'Sports': 'Professional-grade sports equipment for athletes and fitness enthusiasts.',
      'Books': 'Engaging and informative book that provides valuable knowledge and entertainment.',
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
      'Electronics': ['Wireless', 'Bluetooth', 'Water Resistant', 'Fast Charging'],
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
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[DateTime.now().microsecondsSinceEpoch % colors.length];
  }
}