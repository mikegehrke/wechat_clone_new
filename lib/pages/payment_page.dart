import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/subscription_card.dart';
import 'payment/add_payment_method_page.dart';
import 'payment/send_money_page.dart';
import 'payment/request_money_page.dart';
import 'payment/transaction_detail_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Wallet? _wallet;
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentTransaction> _transactions = [];
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        PaymentService.getUserWallet(_currentUserId),
        PaymentService.getUserPaymentMethods(_currentUserId),
        PaymentService.getTransactionHistory(_currentUserId),
        PaymentService.getUserSubscriptions(_currentUserId),
      ]);

      setState(() {
        _wallet = futures[0] as Wallet;
        _paymentMethods = futures[1] as List<PaymentMethod>;
        _transactions = futures[2] as List<PaymentTransaction>;
        _subscriptions = futures[3] as List<Subscription>;
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
          'Payments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPaymentMethodPage(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Wallet'),
            Tab(text: 'Cards'),
            Tab(text: 'History'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWalletTab(),
          _buildCardsTab(),
          _buildHistoryTab(),
          _buildSubscriptionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Quick Pay', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildWalletTab() {
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_wallet == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No wallet found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet balance card
          WalletBalanceCard(
            wallet: _wallet!,
            onAddMoney: _addMoney,
            onWithdrawMoney: _withdrawMoney,
          ),

          const SizedBox(height: 24),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.send,
                  title: 'Send Money',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SendMoneyPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.request_page,
                  title: 'Request Money',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestMoneyPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ..._wallet!.transactions
              .take(5)
              .map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionItem(
                    transaction: transaction,
                    onTap: () => _navigateToTransactionDetail(transaction),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCardsTab() {
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_paymentMethods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No payment methods',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a payment method to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPaymentMethodPage(),
                  ),
                );
              },
              child: const Text('Add Payment Method'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = _paymentMethods[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PaymentMethodCard(
            paymentMethod: paymentMethod,
            onTap: () => _showPaymentMethodOptions(paymentMethod),
            onSetDefault: () => _setDefaultPaymentMethod(paymentMethod),
            onDelete: () => _deletePaymentMethod(paymentMethod),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TransactionItem(
            transaction: transaction,
            onTap: () => _navigateToTransactionDetail(transaction),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionsTab() {
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
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_subscriptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subscriptions, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No subscriptions',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SubscriptionCard(
            subscription: subscription,
            onTap: () => _showSubscriptionOptions(subscription),
            onCancel: () => _cancelSubscription(subscription),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _addMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add money feature coming soon!')),
    );
  }

  void _withdrawMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdraw money feature coming soon!')),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.send,
                    title: 'Send Money',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SendMoneyPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.request_page,
                    title: 'Request Money',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestMoneyPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.add_card,
                    title: 'Add Card',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPaymentMethodPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.qr_code,
                    title: 'Scan QR',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR scanner coming soon!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodOptions(PaymentMethod paymentMethod) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              paymentMethod.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Set as Default'),
              onTap: () {
                Navigator.pop(context);
                _setDefaultPaymentMethod(paymentMethod);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePaymentMethod(paymentMethod);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setDefaultPaymentMethod(PaymentMethod paymentMethod) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${paymentMethod.displayName} set as default')),
    );
  }

  void _deletePaymentMethod(PaymentMethod paymentMethod) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${paymentMethod.displayName} deleted')),
    );
  }

  void _showSubscriptionOptions(Subscription subscription) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${subscription.planName} options')));
  }

  void _cancelSubscription(Subscription subscription) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${subscription.planName} cancelled')),
    );
  }

  void _navigateToTransactionDetail(dynamic transaction) {
    // Convert WalletTransaction to PaymentTransaction if needed
    PaymentTransaction paymentTx;

    if (transaction is WalletTransaction) {
      paymentTx = PaymentTransaction(
        id: transaction.id,
        userId: 'demo_user_1',
        amount: transaction.amount,
        type: transaction.type == 'credit' ? 'received' : 'sent',
        status: 'completed', // Default for wallet transactions
        createdAt: transaction.createdAt,
        description: transaction.description,
        fee: 0,
      );
    } else {
      paymentTx = transaction as PaymentTransaction;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(transaction: paymentTx),
      ),
    );
  }
}
