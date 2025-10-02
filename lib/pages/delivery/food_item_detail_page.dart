import 'package:flutter/material.dart';
import '../../models/delivery.dart';

class FoodItemDetailPage extends StatefulWidget {
  final FoodItem item;
  final Restaurant restaurant;

  const FoodItemDetailPage({
    super.key,
    required this.item,
    required this.restaurant,
  });

  @override
  State<FoodItemDetailPage> createState() => _FoodItemDetailPageState();
}

class _FoodItemDetailPageState extends State<FoodItemDetailPage> {
  int _quantity = 1;
  String? _selectedSize;
  final List<String> _selectedAddons = [];
  String _specialInstructions = '';

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Food image
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 64),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '\$${widget.item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07C160),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Description
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Badges
                      Wrap(
                        spacing: 8,
                        children: [
                          if (widget.item.isVegetarian)
                            _buildBadge('Vegetarian', Colors.green, Icons.eco),
                          if (widget.item.isSpicy)
                            _buildBadge('Spicy', Colors.red, Icons.local_fire_department),
                          if (widget.item.isPopular)
                            _buildBadge('Popular', Colors.orange, Icons.star),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Quantity selector
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          _buildQuantityButton(
                            Icons.remove,
                            () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            Icons.add,
                            () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Special instructions
                      const Text(
                        'Special Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add any special requests...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) => _specialInstructions = value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Add to cart button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart),
                      const SizedBox(width: 12),
                      Text(
                        'Add to Cart - \$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: const Color(0xFF07C160),
      ),
    );
  }

  double _calculateTotalPrice() {
    return widget.item.price * _quantity;
  }

  void _addToCart() {
    Navigator.pop(context, {
      'item': widget.item,
      'quantity': _quantity,
      'specialInstructions': _specialInstructions,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} added to cart'),
        backgroundColor: const Color(0xFF07C160),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
