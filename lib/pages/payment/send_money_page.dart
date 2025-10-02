import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/payment.dart';
import '../../models/user.dart';
import '../../services/payment_service.dart';

class SendMoneyPage extends StatefulWidget {
  final User? recipient;
  
  const SendMoneyPage({super.key, this.recipient});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  
  User? _selectedRecipient;
  List<User> _recentContacts = [];
  List<User> _searchResults = [];
  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedPaymentMethod;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedRecipient = widget.recipient;
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final methods = await PaymentService.getPaymentMethods('demo_user_1');
      final contacts = await _getRecentContacts();
      
      setState(() {
        _paymentMethods = methods;
        _selectedPaymentMethod = methods.firstWhere(
          (m) => m.isDefault,
          orElse: () => methods.first,
        );
        _recentContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<User>> _getRecentContacts() async {
    // In real app, fetch from backend
    return [
      User(
        id: 'user_1',
        username: 'Sarah Johnson',
        email: 'sarah@example.com',
        phoneNumber: '+1234567890',
        avatar: '',
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'user_2',
        username: 'Michael Chen',
        email: 'michael@example.com',
        phoneNumber: '+1234567891',
        avatar: '',
        lastSeen: DateTime.now(),
      ),
      User(
        id: 'user_3',
        username: 'Emma Wilson',
        email: 'emma@example.com',
        phoneNumber: '+1234567892',
        avatar: '',
        lastSeen: DateTime.now(),
      ),
    ];
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _recentContacts.where((user) =>
      user.name.toLowerCase().contains(query.toLowerCase()) ||
      user.email.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Recipient selection
                  const Text(
                    'Send To',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_selectedRecipient == null) ...[
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: _searchUsers,
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search results or recent contacts
                    if (_isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (_searchResults.isNotEmpty)
                      _buildContactsList(_searchResults)
                    else if (_searchController.text.isEmpty)
                      _buildRecentContacts()
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No contacts found'),
                        ),
                      ),
                  ] else
                    _buildSelectedRecipient(),
                  
                  if (_selectedRecipient != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Amount
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter valid amount';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<PaymentMethod>(
                      value: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Row(
                            children: [
                              Icon(_getPaymentIcon(method.type)),
                              const SizedBox(width: 12),
                              Text(_getPaymentLabel(method)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPaymentMethod = value);
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Note
                    const Text(
                      'Note (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'What\'s this for?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Send button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _sendMoney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07C160),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Send Money',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRecentContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildContactsList(_recentContacts),
      ],
    );
  }

  Widget _buildContactsList(List<User> contacts) {
    return Column(
      children: contacts.map((user) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(user.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            setState(() {
              _selectedRecipient = user;
              _searchController.clear();
              _searchResults = [];
            });
          },
        ),
      )).toList(),
    );
  }

  Widget _buildSelectedRecipient() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                _selectedRecipient!.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRecipient!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedRecipient!.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _selectedRecipient = null);
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'apple_pay':
        return Icons.apple;
      case 'google_pay':
        return Icons.g_mobiledata;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentLabel(PaymentMethod method) {
    switch (method.type) {
      case 'card':
        return '${method.cardBrand?.toUpperCase() ?? 'Card'} •••• ${method.cardNumber?.substring(method.cardNumber!.length - 4)}';
      case 'paypal':
        return 'PayPal (${method.paypalEmail})';
      case 'bank_transfer':
        return 'Bank •••• ${method.bankAccountNumber?.substring(method.bankAccountNumber!.length - 4)}';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return method.type;
    }
  }

  Future<void> _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipient == null || _selectedPaymentMethod == null) return;

    final amount = double.parse(_amountController.text);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send \$${amount.toStringAsFixed(2)} to:'),
            const SizedBox(height: 8),
            Text(
              _selectedRecipient!.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_selectedRecipient!.email),
            const SizedBox(height: 16),
            Text('From: ${_getPaymentLabel(_selectedPaymentMethod!)}'),
            if (_noteController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: ${_noteController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PaymentService.sendMoney(
        fromUserId: 'demo_user_1',
        toUserId: _selectedRecipient!.id,
        amount: amount,
        paymentMethodId: _selectedPaymentMethod!.id,
        note: _noteController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully sent \$${amount.toStringAsFixed(2)} to ${_selectedRecipient!.name}'),
            backgroundColor: const Color(0xFF07C160),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send money: $e')),
        );
      }
    }
  }
}
