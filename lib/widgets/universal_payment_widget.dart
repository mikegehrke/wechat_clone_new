import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class UniversalPaymentWidget extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final String? recipientId;
  final String? recipientEmail;
  final String? recipientName;
  final Map<String, dynamic>? metadata;
  final Function(PaymentTransaction)? onSuccess;
  final Function(String)? onError;
  final VoidCallback? onCancel;

  const UniversalPaymentWidget({
    super.key,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    this.recipientId,
    this.recipientEmail,
    this.recipientName,
    this.metadata,
    this.onSuccess,
    this.onError,
    this.onCancel,
  });

  @override
  State<UniversalPaymentWidget> createState() => _UniversalPaymentWidgetState();
}

class _UniversalPaymentWidgetState extends State<UniversalPaymentWidget> {
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final methods = await PaymentService.getUserPaymentMethods('demo_user_1');
      setState(() {
        _paymentMethods = methods;
        _selectedPaymentMethod = methods.firstWhere(
          (method) => method.isDefault,
          orElse: () => methods.isNotEmpty ? methods.first : null,
        );
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Universal Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          
          // Payment methods
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_paymentMethods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'No payment methods found. Please add a payment method first.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._paymentMethods.map((method) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildPaymentMethodOption(method),
                  )),
                
                const SizedBox(height: 20),
                
                // Payment options
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentOption(
                        icon: Icons.credit_card,
                        title: 'Card',
                        subtitle: 'Visa, Mastercard',
                        color: Colors.blue,
                        onTap: () => _processPayment('card'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentOption(
                        icon: Icons.account_balance_wallet,
                        title: 'PayPal',
                        subtitle: 'Pay with PayPal',
                        color: Colors.indigo,
                        onTap: () => _processPayment('paypal'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentOption(
                        icon: Icons.apple,
                        title: 'Apple Pay',
                        subtitle: 'Touch ID / Face ID',
                        color: Colors.black,
                        onTap: () => _processPayment('apple_pay'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentOption(
                        icon: Icons.android,
                        title: 'Google Pay',
                        subtitle: 'Fingerprint / PIN',
                        color: Colors.green,
                        onTap: () => _processPayment('google_pay'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedPaymentMethod != null && !_isProcessing
                            ? () => _processPayment(_selectedPaymentMethod!.type)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Pay Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method.type),
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'apple_pay':
        return Icons.apple;
      case 'google_pay':
        return Icons.android;
      case 'bank_transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Future<void> _processPayment(String paymentType) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      PaymentTransaction transaction;
      
      switch (paymentType) {
        case 'card':
          if (_selectedPaymentMethod == null) {
            throw Exception('No payment method selected');
          }
          transaction = await PaymentService.processStripePayment(
            paymentMethodId: _selectedPaymentMethod!.id,
            amount: widget.amount,
            currency: widget.currency,
            description: widget.description,
            metadata: widget.metadata,
          );
          break;
        case 'paypal':
          if (_selectedPaymentMethod == null) {
            throw Exception('No PayPal account found');
          }
          transaction = await PaymentService.processPayPalPayment(
            paymentMethodId: _selectedPaymentMethod!.id,
            amount: widget.amount,
            currency: widget.currency,
            description: widget.description,
            metadata: widget.metadata,
          );
          break;
        case 'apple_pay':
          transaction = await PaymentService.processApplePayPayment(
            amount: widget.amount,
            currency: widget.currency,
            description: widget.description,
            metadata: widget.metadata,
          );
          break;
        case 'google_pay':
          transaction = await PaymentService.processGooglePayPayment(
            amount: widget.amount,
            currency: widget.currency,
            description: widget.description,
            metadata: widget.metadata,
          );
          break;
        default:
          throw Exception('Unsupported payment type');
      }

      setState(() {
        _isProcessing = false;
      });

      if (widget.onSuccess != null) {
        widget.onSuccess!(transaction);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Transaction ID: ${transaction.id}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString();
      });

      if (widget.onError != null) {
        widget.onError!(e.toString());
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}