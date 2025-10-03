import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _paymentMethodsSub = 'paymentMethods';
  static const String _transactionsCollection = 'paymentTransactions';
  static const String _walletsCollection = 'wallets';
  static const String _paymentRequestsCollection = 'paymentRequests';
  static const String _subscriptionsCollection = 'subscriptions';
  // Add payment method
  static Future<void> addPaymentMethod(String userId, PaymentMethod paymentMethod) async {
    try {
      final pmRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_paymentMethodsSub)
          .doc(paymentMethod.id);
      await pmRef.set(paymentMethod.toJson());
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
      final reqRef = _firestore.collection(_paymentRequestsCollection).doc();
      final pr = PaymentRequest(
        id: reqRef.id,
        fromUserId: fromUserId,
        fromUserName: '',
        toUserEmail: toUserIds.isNotEmpty ? toUserIds.first : '',
        amount: amount,
        description: reason,
        createdAt: DateTime.now(),
      );
      await reqRef.set(pr.toJson());
    } catch (e) {
      throw Exception('Failed to request money: $e');
    }
  }

  // Get payment methods for user
  static Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_paymentMethodsSub)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return PaymentMethod.fromJson(data);
      }).toList();
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
      final txRef = _firestore.collection(_transactionsCollection).doc();
      final tx = PaymentTransaction(
        id: txRef.id,
        userId: fromUserId,
        type: 'transfer',
        amount: amount,
        status: 'completed',
        description: note ?? 'P2P Transfer',
        paymentMethodId: paymentMethodId,
        recipientId: toUserId,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      await txRef.set(tx.toJson());
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
      final transaction = PaymentTransaction(
        id: 'pi_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
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
      await _firestore.collection(_transactionsCollection).doc(transaction.id).set(transaction.toJson());
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
      final paymentMethod = PaymentMethod(
        id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        type: 'paypal',
        paypalEmail: email,
        isVerified: true,
        createdAt: DateTime.now(),
      );
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
      final transaction = PaymentTransaction(
        id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
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
      await _firestore.collection(_transactionsCollection).doc(transaction.id).set(transaction.toJson());
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
      await _firestore.collection(_transactionsCollection).doc(transaction.id).set(transaction.toJson());
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
      await _firestore.collection(_transactionsCollection).doc(transaction.id).set(transaction.toJson());
      return transaction;
    } catch (e) {
      throw Exception('Failed to process Google Pay payment: $e');
    }
  }

  // Wallet Operations
  static Future<Wallet> getUserWallet(String userId) async {
    try {
      final doc = await _firestore.collection(_walletsCollection).doc(userId).get();
      if (!doc.exists) {
        final wallet = Wallet(
          id: 'wallet_$userId',
          userId: userId,
          balance: 0.0,
          pendingBalance: 0.0,
          totalEarned: 0.0,
          totalSpent: 0.0,
          lastUpdated: DateTime.now(),
          transactions: const [],
        );
        await _firestore.collection(_walletsCollection).doc(userId).set(wallet.toJson());
        return wallet;
      }
      final data = Map<String, dynamic>.from(doc.data()!);
      return Wallet.fromJson(data);
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
      final walletRef = _firestore.collection(_walletsCollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(walletRef);
        double balance = 0.0;
        Map<String, dynamic> wdata = {};
        if (snap.exists) {
          wdata = Map<String, dynamic>.from(snap.data()!);
          balance = (wdata['balance'] as num?)?.toDouble() ?? 0.0;
        }
        balance += amount;
        wdata['id'] = 'wallet_$userId';
        wdata['userId'] = userId;
        wdata['balance'] = balance;
        wdata['lastUpdated'] = DateTime.now().toIso8601String();
        tx.set(walletRef, wdata, SetOptions(merge: true));
        final txRef = _firestore.collection(_transactionsCollection).doc(transaction.id);
        tx.set(txRef, transaction.toJson());
      });
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
      final transaction = WalletTransaction(
        id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
        walletId: 'wallet_$userId',
        type: 'debit',
        amount: amount,
        currency: currency,
        description: description ?? 'Wallet Withdrawal',
        createdAt: DateTime.now(),
      );
      final walletRef = _firestore.collection(_walletsCollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(walletRef);
        if (!snap.exists) throw Exception('Wallet not found');
        final wdata = Map<String, dynamic>.from(snap.data()!);
        double balance = (wdata['balance'] as num?)?.toDouble() ?? 0.0;
        if (balance < amount) throw Exception('Insufficient balance');
        balance -= amount;
        wdata['balance'] = balance;
        wdata['lastUpdated'] = DateTime.now().toIso8601String();
        tx.update(walletRef, wdata);
        final txRef = _firestore.collection(_transactionsCollection).doc(transaction.id);
        tx.set(txRef, transaction.toJson());
      });
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
      await _firestore.collection(_paymentRequestsCollection).doc(request.id).set(request.toJson());
      return request;
    } catch (e) {
      throw Exception('Failed to create payment request: $e');
    }
  }

  static Future<List<PaymentRequest>> getPaymentRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_paymentRequestsCollection)
          .where('fromUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return PaymentRequest.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get payment requests: $e');
    }
  }

  static Future<void> payPaymentRequest(String requestId, String paymentMethodId) async {
    try {
      final reqRef = _firestore.collection(_paymentRequestsCollection).doc(requestId);
      await reqRef.update({'status': 'paid', 'paidAt': DateTime.now().toIso8601String(), 'paymentMethodId': paymentMethodId});
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
      await _firestore.collection(_subscriptionsCollection).doc(subscription.id).set(subscription.toJson());
      return subscription;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  static Future<List<Subscription>> getUserSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Subscription.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
    }
  }

  static Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _firestore.collection(_subscriptionsCollection).doc(subscriptionId).update({'status': 'cancelled', 'endDate': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Payment Methods Management
  static Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      return await getPaymentMethods(userId);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  static Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      // Requires user context; provide userId in real app or store reverse index
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  static Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // Requires user context to unset others; implement in app layer
    } catch (e) {
      throw Exception('Failed to set default payment method: $e');
    }
  }

  // Transaction History
  static Future<List<PaymentTransaction>> getTransactionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return PaymentTransaction.fromJson(data);
      }).toList();
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
      await _firestore.collection(_transactionsCollection).doc(refund.id).set(refund.toJson());
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