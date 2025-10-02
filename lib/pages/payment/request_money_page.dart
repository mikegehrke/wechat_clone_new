import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../../services/payment_service.dart';

class RequestMoneyPage extends StatefulWidget {
  const RequestMoneyPage({super.key});

  @override
  State<RequestMoneyPage> createState() => _RequestMoneyPageState();
}

class _RequestMoneyPageState extends State<RequestMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _searchController = TextEditingController();
  
  final List<User> _selectedUsers = [];
  List<User> _contacts = [];
  List<User> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    
    try {
      // In real app, fetch from backend
      final contacts = [
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
        User(
          id: 'user_4',
          username: 'James Brown',
          email: 'james@example.com',
          phoneNumber: '+1234567893',
          avatar: '',
          lastSeen: DateTime.now(),
        ),
      ];
      
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final results = _contacts.where((user) =>
      user.username.toLowerCase().contains(query.toLowerCase()) ||
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
        title: const Text('Request Money'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
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
                        
                        // Reason
                        const Text(
                          'What\'s this for?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Dinner, rent, tickets, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reason';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Request from
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Request From',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedUsers.isNotEmpty)
                              Text(
                                '${_selectedUsers.length} selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Selected users
                        if (_selectedUsers.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedUsers.map((user) => Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  user.username[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              label: Text(user.username),
                              onDeleted: () {
                                setState(() => _selectedUsers.remove(user));
                              },
                              deleteIcon: const Icon(Icons.close, size: 18),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Search
                        TextField(
                          controller: _searchController,
                          onChanged: _searchContacts,
                          decoration: InputDecoration(
                            hintText: 'Search contacts...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Contacts list
                        if (_isSearching)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_searchResults.isNotEmpty)
                          _buildContactsList(_searchResults)
                        else if (_searchController.text.isEmpty)
                          _buildContactsList(_contacts.where((user) => 
                            !_selectedUsers.contains(user)
                          ).toList())
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No contacts found'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Request button
                  Container(
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
                        onPressed: _selectedUsers.isEmpty ? null : _requestMoney,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07C160),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedUsers.isEmpty
                              ? 'Select at least one person'
                              : 'Request from ${_selectedUsers.length} ${_selectedUsers.length == 1 ? 'person' : 'people'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContactsList(List<User> contacts) {
    return Column(
      children: contacts.map((user) {
        final isSelected = _selectedUsers.contains(user);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.green[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.green : Colors.blue[100],
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(user.email),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedUsers.remove(user);
                } else {
                  _selectedUsers.add(user);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _requestMoney() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUsers.isEmpty) return;

    final amount = double.parse(_amountController.text);
    final reason = _reasonController.text;

    // Show confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request \$${amount.toStringAsFixed(2)} from:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._selectedUsers.map((user) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${user.username}'),
            )),
            const SizedBox(height: 12),
            Text('For: $reason'),
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
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PaymentService.requestMoney(
        fromUserId: 'demo_user_1',
        toUserIds: _selectedUsers.map((u) => u.id).toList(),
        amount: amount,
        reason: reason,
      );
      
      for (final user in _selectedUsers) {
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request sent to ${_selectedUsers.length} ${_selectedUsers.length == 1 ? 'person' : 'people'}',
            ),
            backgroundColor: const Color(0xFF07C160),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }
}
