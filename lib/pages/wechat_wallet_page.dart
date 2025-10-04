import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wechat_pay_service.dart';

class WeChatWalletPage extends StatefulWidget {
  const WeChatWalletPage({super.key});

  @override
  State<WeChatWalletPage> createState() => _WeChatWalletPageState();
}

class _WeChatWalletPageState extends State<WeChatWalletPage> {
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  double _balance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final balance = await WeChatPayService.getWalletBalance(_currentUserId);
      setState(() {
        _balance = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMoney() async {
    final amountController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (€)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) return;

    try {
      await WeChatPayService.addMoneyToWallet(
        userId: _currentUserId,
        amount: amount,
      );
      
      await _loadBalance();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added €${amount.toStringAsFixed(2)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _sendMoney() async {
    // Navigate to send money page
    Navigator.pushNamed(context, '/send-money');
  }

  Future<void> _createRedPacket() async {
    Navigator.pushNamed(context, '/create-red-packet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/transaction-history');
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addMoney,
                          icon: const Icon(Icons.add, color: Colors.blue),
                          label: const Text('Add Money', style: TextStyle(color: Colors.blue)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildQuickAction(
                          icon: Icons.send,
                          label: 'Send Money',
                          onTap: _sendMoney,
                        ),
                        _buildQuickAction(
                          icon: Icons.card_giftcard,
                          label: 'Red Packet',
                          onTap: _createRedPacket,
                        ),
                        _buildQuickAction(
                          icon: Icons.receipt_long,
                          label: 'Request',
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.qr_code_scanner,
                          label: 'Scan QR',
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.people,
                          label: 'Split Bill',
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.account_balance_wallet,
                          label: 'Bank',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Recent Transactions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: WeChatPayService.getTransactionHistory(_currentUserId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final transactions = snapshot.data!;

                            if (transactions.isEmpty) {
                              return const Center(
                                child: Text('No transactions yet'),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length > 5 ? 5 : transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isPositive = tx['amount'] > 0;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isPositive ? Colors.green : Colors.red,
                                    child: Icon(
                                      isPositive ? Icons.add : Icons.remove,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(tx['description']),
                                  subtitle: Text(tx['type']),
                                  trailing: Text(
                                    '${isPositive ? '+' : ''}€${tx['amount'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isPositive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
