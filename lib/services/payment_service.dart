import 'dart:math';
import '../models/payment.dart';

class PaymentService {
  // Add payment method
  static Future<void> addPaymentMethod(String userId, PaymentMethod paymentMethod) async {
    try {
      // In real app, save to backend/database
      await Future.delayed(const Duration(seconds: 1));
      // Success
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  // Request money from users
  static Future<void> requestMoney({
    required String fromUserId,
    required List<String> toUserIds,
    required double amount,
    required String reason,
  }) async {
    try {
      // In real app, create payment request in backend
      await Future.delayed(const Duration(seconds: 1));
      // Success
    } catch (e) {
      throw Exception('Failed to request money: $e');
    }
  }

  // Get payment methods for user
  static Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      // In real app, fetch from backend
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        PaymentMethod(
          id: 'pm_1',
          type: 'card',
          cardNumber: '•••• 4242',
          cardBrand: 'Visa',
          isDefault: true,
          createdAt: DateTime.now(),
        ),
        PaymentMethod(
          id: 'pm_2',
          type: 'paypal',
          paypalEmail: 'user@example.com',
          isDefault: false,
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  // Send money to user
  static Future<void> sendMoney({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String paymentMethodId,
    String? note,
  }) async {
    try {
      // In real app, process payment via backend
      await Future.delayed(const Duration(seconds: 1));
      // Success
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  // Stripe Payment Methods
  static Future<PaymentMethod> createStripePaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    try {
      // In real app, integrate with Stripe API
      final cardBrand = _getCardBrand(cardNumber);
      
      final paymentMethod = PaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        type: 'card',
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardBrand: cardBrand,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return paymentMethod;
    } catch (e) {
      throw Exception('Failed to create payment method: $e');
    }
  }

  static Future<PaymentTransaction> processStripePayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In real app, integrate with Stripe Payment Intents API
      final transaction = PaymentTransaction(
        id: 'pi_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1', // In real app, get from auth
        type: 'payment',
        amount: amount,
        currency: currency,
        status: 'completed',
        description: description ?? 'Payment',
        paymentMethodId: paymentMethodId,
        stripePaymentIntentId: 'pi_${DateTime.now().millisecondsSinceEpoch}',
        fee: amount * 0.029 + 0.30, // Stripe fee: 2.9% + $0.30
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: metadata,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 3));

      return transaction;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // PayPal Payment Methods
  static Future<PaymentMethod> createPayPalPaymentMethod({
    required String email,
  }) async {
    try {
      // In real app, integrate with PayPal API
      final paymentMethod = PaymentMethod(
        id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        type: 'paypal',
        paypalEmail: email,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return paymentMethod;
    } catch (e) {
      throw Exception('Failed to create PayPal payment method: $e');
    }
  }

  static Future<PaymentTransaction> processPayPalPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In real app, integrate with PayPal Orders API
      final transaction = PaymentTransaction(
        id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1', // In real app, get from auth
        type: 'payment',
        amount: amount,
        currency: currency,
        status: 'completed',
        description: description ?? 'PayPal Payment',
        paymentMethodId: paymentMethodId,
        paypalTransactionId: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        fee: amount * 0.034 + 0.30, // PayPal fee: 3.4% + $0.30
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: metadata,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 3));

      return transaction;
    } catch (e) {
      throw Exception('Failed to process PayPal payment: $e');
    }
  }

  // Apple Pay
  static Future<PaymentTransaction> processApplePayPayment({
    required double amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In real app, integrate with Apple Pay API
      final transaction = PaymentTransaction(
        id: 'ap_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
        type: 'payment',
        amount: amount,
        currency: currency,
        status: 'completed',
        description: description ?? 'Apple Pay Payment',
        fee: amount * 0.029 + 0.30, // Apple Pay fee
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: metadata,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return transaction;
    } catch (e) {
      throw Exception('Failed to process Apple Pay payment: $e');
    }
  }

  // Google Pay
  static Future<PaymentTransaction> processGooglePayPayment({
    required double amount,
    required String currency,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In real app, integrate with Google Pay API
      final transaction = PaymentTransaction(
        id: 'gp_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
        type: 'payment',
        amount: amount,
        currency: currency,
        status: 'completed',
        description: description ?? 'Google Pay Payment',
        fee: amount * 0.029 + 0.30, // Google Pay fee
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: metadata,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return transaction;
    } catch (e) {
      throw Exception('Failed to process Google Pay payment: $e');
    }
  }

  // Wallet Operations
  static Future<Wallet> getUserWallet(String userId) async {
    try {
      // In real app, make API call to get wallet
      return _createMockWallet(userId);
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  static Future<WalletTransaction> addToWallet({
    required String userId,
    required double amount,
    required String currency,
    String? description,
    String? reference,
  }) async {
    try {
      // In real app, make API call to add to wallet
      final transaction = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        walletId: 'wallet_$userId',
        type: 'credit',
        amount: amount,
        currency: currency,
        description: description ?? 'Wallet Top-up',
        reference: reference,
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return transaction;
    } catch (e) {
      throw Exception('Failed to add to wallet: $e');
    }
  }

  static Future<WalletTransaction> withdrawFromWallet({
    required String userId,
    required double amount,
    required String currency,
    String? description,
    String? bankAccountId,
  }) async {
    try {
      // In real app, make API call to withdraw from wallet
      final transaction = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        walletId: 'wallet_$userId',
        type: 'debit',
        amount: amount,
        currency: currency,
        description: description ?? 'Wallet Withdrawal',
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return transaction;
    } catch (e) {
      throw Exception('Failed to withdraw from wallet: $e');
    }
  }

  // Payment Requests
  static Future<PaymentRequest> createPaymentRequest({
    required String fromUserId,
    required String fromUserName,
    required String toUserEmail,
    required double amount,
    required String currency,
    required String description,
    Duration? expiresIn,
  }) async {
    try {
      final expiresAt = expiresIn != null 
          ? DateTime.now().add(expiresIn) 
          : DateTime.now().add(const Duration(days: 7));

      final request = PaymentRequest(
        id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        toUserEmail: toUserEmail,
        amount: amount,
        currency: currency,
        description: description,
        expiresAt: expiresAt,
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      return request;
    } catch (e) {
      throw Exception('Failed to create payment request: $e');
    }
  }

  static Future<List<PaymentRequest>> getPaymentRequests(String userId) async {
    try {
      // In real app, make API call to get payment requests
      return _createMockPaymentRequests();
    } catch (e) {
      throw Exception('Failed to get payment requests: $e');
    }
  }

  static Future<void> payPaymentRequest(String requestId, String paymentMethodId) async {
    try {
      // In real app, make API call to pay payment request
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to pay payment request: $e');
    }
  }

  // Subscriptions
  static Future<Subscription> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String billingCycle,
    required String paymentMethodId,
  }) async {
    try {
      final subscription = Subscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        planId: planId,
        planName: planName,
        price: price,
        billingCycle: billingCycle,
        paymentMethodId: paymentMethodId,
        startDate: DateTime.now(),
        nextBillingDate: _getNextBillingDate(billingCycle),
        features: _getPlanFeatures(planId),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return subscription;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  static Future<List<Subscription>> getUserSubscriptions(String userId) async {
    try {
      // In real app, make API call to get subscriptions
      return _createMockSubscriptions();
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
    }
  }

  static Future<void> cancelSubscription(String subscriptionId) async {
    try {
      // In real app, make API call to cancel subscription
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Payment Methods Management
  static Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      // In real app, make API call to get payment methods
      return _createMockPaymentMethods();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  static Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      // In real app, make API call to delete payment method
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  static Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // In real app, make API call to set default payment method
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Transaction History
  static Future<List<PaymentTransaction>> getTransactionHistory(String userId) async {
    try {
      // In real app, make API call to get transaction history
      return _createMockTransactions();
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // Refunds
  static Future<PaymentTransaction> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    try {
      // In real app, make API call to refund payment
      final refund = PaymentTransaction(
        id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
        type: 'refund',
        amount: amount,
        status: 'completed',
        description: reason ?? 'Refund',
        reference: transactionId,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      return refund;
    } catch (e) {
      throw Exception('Failed to refund payment: $e');
    }
  }

  // Helper methods
  static String _getCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.startsWith('4')) return 'visa';
    if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) return 'mastercard';
    if (cleanNumber.startsWith('3')) return 'amex';
    if (cleanNumber.startsWith('6')) return 'discover';
    
    return 'unknown';
  }

  static DateTime _getNextBillingDate(String billingCycle) {
    final now = DateTime.now();
    switch (billingCycle) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now.add(const Duration(days: 30));
    }
  }

  static Map<String, dynamic> _getPlanFeatures(String planId) {
    final features = {
      'basic': {
        'max_storage': '1GB',
        'max_users': 1,
        'support': 'email',
        'analytics': false,
      },
      'pro': {
        'max_storage': '10GB',
        'max_users': 5,
        'support': 'priority',
        'analytics': true,
      },
      'enterprise': {
        'max_storage': 'unlimited',
        'max_users': -1,
        'support': 'dedicated',
        'analytics': true,
      },
    };
    return features[planId] ?? {};
  }

  // Mock data generators
  static Wallet _createMockWallet(String userId) {
    return Wallet(
      id: 'wallet_$userId',
      userId: userId,
      balance: 150.75,
      pendingBalance: 25.50,
      totalEarned: 500.00,
      totalSpent: 349.25,
      lastUpdated: DateTime.now(),
      transactions: _createMockWalletTransactions(),
    );
  }

  static List<WalletTransaction> _createMockWalletTransactions() {
    return List.generate(10, (index) {
      final types = ['credit', 'debit', 'transfer_in', 'transfer_out', 'refund'];
      final type = types[index % types.length];
      final amount = 10.0 + (index * 15.0);
      
      return WalletTransaction(
        id: 'wt_$index',
        walletId: 'wallet_demo_user_1',
        type: type,
        amount: amount,
        description: _getTransactionDescription(type, index),
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static List<PaymentRequest> _createMockPaymentRequests() {
    return List.generate(5, (index) {
      final statuses = ['pending', 'paid', 'cancelled', 'expired'];
      final status = statuses[index % statuses.length];
      final amount = 25.0 + (index * 10.0);
      
      return PaymentRequest(
        id: 'pr_$index',
        fromUserId: 'user_$index',
        fromUserName: 'User ${index + 1}',
        toUserEmail: 'recipient$index@email.com',
        amount: amount,
        description: 'Payment request ${index + 1}',
        status: status,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        expiresAt: DateTime.now().add(Duration(days: 7 - index)),
        paidAt: status == 'paid' ? DateTime.now().subtract(Duration(days: index)) : null,
      );
    });
  }

  static List<Subscription> _createMockSubscriptions() {
    final plans = [
      {'id': 'basic', 'name': 'Basic Plan', 'price': 9.99, 'cycle': 'monthly'},
      {'id': 'pro', 'name': 'Pro Plan', 'price': 19.99, 'cycle': 'monthly'},
      {'id': 'enterprise', 'name': 'Enterprise Plan', 'price': 99.99, 'cycle': 'yearly'},
    ];
    
    return List.generate(2, (index) {
      final plan = plans[index % plans.length];
      final statuses = ['active', 'cancelled'];
      final status = statuses[index % statuses.length];
      
      return Subscription(
        id: 'sub_$index',
        userId: 'demo_user_1',
        planId: plan['id'] as String,
        planName: plan['name'] as String,
        price: plan['price'] as double,
        billingCycle: plan['cycle'] as String,
        status: status,
        startDate: DateTime.now().subtract(Duration(days: index * 30)),
        nextBillingDate: status == 'active' ? DateTime.now().add(Duration(days: 30 - index)) : null,
        features: _getPlanFeatures(plan['id'] as String),
      );
    });
  }

  static List<PaymentMethod> _createMockPaymentMethods() {
    return [
      PaymentMethod(
        id: 'pm_1',
        type: 'card',
        cardNumber: '4242424242424242',
        cardHolderName: 'John Doe',
        expiryMonth: '12',
        expiryYear: '2025',
        cardBrand: 'visa',
        isDefault: true,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PaymentMethod(
        id: 'pm_2',
        type: 'paypal',
        paypalEmail: 'john.doe@email.com',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      PaymentMethod(
        id: 'pm_3',
        type: 'apple_pay',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  static List<PaymentTransaction> _createMockTransactions() {
    return List.generate(15, (index) {
      final types = ['payment', 'refund', 'transfer', 'withdrawal'];
      final statuses = ['completed', 'pending', 'failed'];
      final type = types[index % types.length];
      final status = statuses[index % statuses.length];
      final amount = 20.0 + (index * 5.0);
      
      return PaymentTransaction(
        id: 'tx_$index',
        userId: 'demo_user_1',
        type: type,
        amount: amount,
        status: status,
        description: _getTransactionDescription(type, index),
        paymentMethodId: 'pm_${index % 3 + 1}',
        fee: amount * 0.029 + 0.30,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        completedAt: status == 'completed' ? DateTime.now().subtract(Duration(days: index)) : null,
        failureReason: status == 'failed' ? 'Insufficient funds' : null,
      );
    });
  }

  static String _getTransactionDescription(String type, int index) {
    final descriptions = {
      'payment': ['Shopping payment', 'Service payment', 'Subscription payment'],
      'refund': ['Order refund', 'Service refund', 'Subscription refund'],
      'transfer': ['Money transfer', 'P2P transfer', 'Business transfer'],
      'withdrawal': ['Bank withdrawal', 'ATM withdrawal', 'Cash withdrawal'],
      'credit': ['Wallet top-up', 'Cashback reward', 'Referral bonus'],
      'debit': ['Wallet purchase', 'Service fee', 'Subscription fee'],
      'transfer_in': ['Transfer received', 'Payment received', 'Refund received'],
      'transfer_out': ['Transfer sent', 'Payment sent', 'Refund sent'],
    };
    
    final typeDescriptions = descriptions[type] ?? ['Transaction'];
    return typeDescriptions[index % typeDescriptions.length];
  }
}