import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/cuisine_filter.dart';
import '../widgets/delivery_search_bar.dart';
import 'restaurant_detail_page.dart';
import 'delivery_orders_page.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Restaurant> _restaurants = [];
  List<String> _cuisines = [];
  String? _selectedCuisine;
  bool _isLoading = false;
  String? _error;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        DeliveryService.getNearbyRestaurants(
          userLocation: {'lat': 40.7128, 'lng': -74.0060},
        ),
        DeliveryService.getCuisines(),
      ]);

      setState(() {
        _restaurants = futures[0] as List<Restaurant>;
        _cuisines = futures[1] as List<String>;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Food Delivery',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryOrdersPage(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Nearby'),
            Tab(text: 'Cuisines'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNearbyTab(),
          _buildCuisinesTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildNearbyTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: DeliverySearchBar(
            onSearch: (query) {
              _tabController.animateTo(2);
              // In real app, pass query to search tab
            },
          ),
        ),
        
        // Cuisine filter
        if (_cuisines.isNotEmpty)
          SizedBox(
            height: 50,
            child: CuisineFilter(
              cuisines: _cuisines,
              selectedCuisine: _selectedCuisine,
              onCuisineSelected: (cuisine) {
                setState(() {
                  _selectedCuisine = cuisine;
                });
                _filterRestaurants();
              },
            ),
          ),
        
        // Restaurants list
        Expanded(
          child: _buildRestaurantsList(),
        ),
      ],
    );
  }

  Widget _buildCuisinesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _cuisines.length,
      itemBuilder: (context, index) {
        final cuisine = _cuisines[index];
        return _buildCuisineCard(cuisine);
      },
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DeliverySearchBar(
            onSearch: (query) {
              _performSearch(query);
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsList() {
    final filteredRestaurants = _selectedCuisine != null
        ? _restaurants.where((r) => r.cuisine == _selectedCuisine).toList()
        : _restaurants;

    if (filteredRestaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = filteredRestaurants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RestaurantCard(
            restaurant: restaurant,
            onTap: () => _navigateToRestaurant(restaurant),
          ),
        );
      },
    );
  }

  Widget _buildCuisineCard(String cuisine) {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(0);
        setState(() {
          _selectedCuisine = cuisine;
        });
        _filterRestaurants();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCuisineIcon(cuisine),
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              cuisine,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // In real app, show search results
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for restaurants',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter a restaurant name or cuisine',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCuisineIcon(String cuisine) {
    final icons = {
      'American': Icons.restaurant,
      'Italian': Icons.local_pizza,
      'Chinese': Icons.ramen_dining,
      'Mexican': Icons.local_dining,
      'Indian': Icons.spa,
      'Thai': Icons.local_fire_department,
      'Japanese': Icons.set_meal,
      'Mediterranean': Icons.water_drop,
      'Korean': Icons.local_florist,
      'Vietnamese': Icons.local_pharmacy,
      'French': Icons.cake,
      'Greek': Icons.local_drink,
      'Turkish': Icons.local_cafe,
      'Lebanese': Icons.local_bar,
      'Brazilian': Icons.local_activity,
      'Ethiopian': Icons.local_grocery_store,
      'Caribbean': Icons.local_beach_access,
      'German': Icons.local_gas_station,
      'Spanish': Icons.local_hotel,
      'British': Icons.local_library,
    };
    return icons[cuisine] ?? Icons.restaurant;
  }

  void _filterRestaurants() {
    setState(() {
      // Filtering is handled in _buildRestaurantsList()
    });
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailPage(restaurant: restaurant),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$query"...')),
    );
  }
}