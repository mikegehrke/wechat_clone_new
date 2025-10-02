import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';
import '../widgets/rating_stars.dart';
import '../widgets/food_item_card.dart';
import 'delivery/food_item_detail_page.dart';
import 'delivery/delivery_cart_page.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  List<FoodItem> _menuItems = [];
  Map<String, List<FoodItem>> _menuByCategory = {};
  bool _isLoading = false;
  String? _error;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final menuItems = await DeliveryService.getRestaurantMenu(widget.restaurant.id);
      
      // Group items by category
      final menuByCategory = <String, List<FoodItem>>{};
      for (final item in menuItems) {
        if (!menuByCategory.containsKey(item.category)) {
          menuByCategory[item.category] = [];
        }
        menuByCategory[item.category]!.add(item);
      }

      setState(() {
        _menuItems = menuItems;
        _menuByCategory = menuByCategory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Restaurant header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.restaurant, size: 100, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.restaurant.cuisine,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingStars(rating: widget.restaurant.rating),
                            const SizedBox(width: 8),
                            Text(
                              widget.restaurant.formattedRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.restaurant.formattedReviewCount})',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
            ],
          ),
          
          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    widget.restaurant.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.access_time,
                          title: 'Delivery Time',
                          subtitle: widget.restaurant.formattedDeliveryTime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.local_shipping,
                          title: 'Delivery Fee',
                          subtitle: widget.restaurant.formattedDeliveryFee,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Distance',
                          subtitle: widget.restaurant.formattedDistance,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.star,
                          title: 'Rating',
                          subtitle: widget.restaurant.formattedRating,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Menu section
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Menu items
          _buildMenuItems(),
        ],
      ),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMenu,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_menuByCategory.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No menu items available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = _menuByCategory.keys.elementAt(index);
          final items = _menuByCategory[category]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Category items
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: FoodItemCard(
                  item: item,
                  onTap: () => _navigateToFoodItem(item),
                  onAdd: () => _addToCart(item),
                ),
              )),
            ],
          );
        },
        childCount: _menuByCategory.length,
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Cart info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItems items',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          // View cart button
          ElevatedButton(
            onPressed: _viewCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View Cart'),
          ),
        ],
      ),
    );
  }

  void _navigateToFoodItem(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodItemDetailPage(
          item: foodItem,
          restaurant: widget.restaurant,
        ),
      ),
    );
  }

  void _addToCart(FoodItem foodItem) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
        );
      });
    } else {
      setState(() {
        _cartItems.add(CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          foodItem: foodItem,
          quantity: 1,
        ));
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${foodItem.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: _viewCart,
        ),
      ),
    );
  }

  void _viewCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryCartPage(
          restaurant: widget.restaurant,
          cartItems: _cartItems,
        ),
      ),
    );
  }
}