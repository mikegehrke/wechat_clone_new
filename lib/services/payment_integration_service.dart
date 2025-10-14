import '../models/payment.dart';
import '../models/delivery.dart' as delivery;
import '../models/product.dart' as product;
import '../models/game.dart';
import 'payment_service.dart';

class PaymentIntegrationService {
  // E-commerce Payment Integration
  static Future<PaymentTransaction> payForShopping({
    required List<product.CartItem> cartItems,
    required String paymentMethodId,
    required String shippingAddress,
    required String userId,
  }) async {
    try {
      final subtotal = cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final tax = subtotal * 0.08; // 8% tax
      final shipping = subtotal > 50 ? 0.0 : 9.99; // Free shipping over $50
      final total = subtotal + tax + shipping;

      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: total,
        currency: 'USD',
        description: 'Shopping Payment - ${cartItems.length} items',
        metadata: {
          'type': 'shopping',
          'cart_items': cartItems.length,
          'subtotal': subtotal,
          'tax': tax,
          'shipping': shipping,
          'shipping_address': shippingAddress,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process shopping payment: $e');
    }
  }

  // Food Delivery Payment Integration
  static Future<PaymentTransaction> payForDelivery({
    required delivery.DeliveryOrder order,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: order.total,
        currency: 'USD',
        description: 'Food Delivery - ${order.restaurantName}',
        metadata: {
          'type': 'delivery',
          'order_id': order.id,
          'restaurant_id': order.restaurantId,
          'restaurant_name': order.restaurantName,
          'items_count': order.items.length,
          'delivery_address': order.deliveryAddress.fullAddress,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process delivery payment: $e');
    }
  }

  // Game Purchase Payment Integration
  static Future<PaymentTransaction> payForGame({
    required Game game,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: game.price ?? 0.0,
        currency: 'USD',
        description: 'Game Purchase - ${game.title}',
        metadata: {
          'type': 'game_purchase',
          'game_id': game.id,
          'game_title': game.title,
          'game_category': game.category,
          'developer': game.developer,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process game payment: $e');
    }
  }

  // Streaming Subscription Payment Integration
  static Future<PaymentTransaction> payForSubscription({
    required Subscription subscription,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: subscription.price,
        currency: subscription.currency,
        description: 'Subscription - ${subscription.planName}',
        metadata: {
          'type': 'subscription',
          'subscription_id': subscription.id,
          'plan_id': subscription.planId,
          'plan_name': subscription.planName,
          'billing_cycle': subscription.billingCycle,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process subscription payment: $e');
    }
  }

  // Professional Service Payment Integration
  static Future<PaymentTransaction> payForProfessionalService({
    required String serviceType,
    required double amount,
    required String paymentMethodId,
    required String recipientId,
    required String userId,
    String? description,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: description ?? 'Professional Service - $serviceType',
        metadata: {
          'type': 'professional_service',
          'service_type': serviceType,
          'recipient_id': recipientId,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process professional service payment: $e');
    }
  }

  // Dating Premium Payment Integration
  static Future<PaymentTransaction> payForDatingPremium({
    required String planType,
    required double amount,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: 'Dating Premium - $planType',
        metadata: {
          'type': 'dating_premium',
          'plan_type': planType,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process dating premium payment: $e');
    }
  }

  // Stories Premium Payment Integration
  static Future<PaymentTransaction> payForStoriesPremium({
    required String featureType,
    required double amount,
    required String paymentMethodId,
    required String userId,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: 'Stories Premium - $featureType',
        metadata: {
          'type': 'stories_premium',
          'feature_type': featureType,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process stories premium payment: $e');
    }
  }

  // Universal P2P Payment Integration
  static Future<PaymentTransaction> sendMoneyToUser({
    required String recipientId,
    required String recipientEmail,
    required double amount,
    required String paymentMethodId,
    required String senderId,
    String? description,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: description ?? 'Money Transfer',
        metadata: {
          'type': 'p2p_transfer',
          'recipient_id': recipientId,
          'recipient_email': recipientEmail,
          'sender_id': senderId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  // QR Code Payment Integration
  static Future<PaymentTransaction> payViaQRCode({
    required String qrCodeData,
    required double amount,
    required String paymentMethodId,
    required String userId,
    String? description,
  }) async {
    try {
      // Parse QR code data
      final parts = qrCodeData.split(':');
      if (parts.length < 3 || parts[0] != 'PAYMENT_QR') {
        throw Exception('Invalid QR code format');
      }

      final recipientId = parts[1];
      final timestamp = parts[2];

      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: description ?? 'QR Code Payment',
        metadata: {
          'type': 'qr_payment',
          'qr_code_data': qrCodeData,
          'recipient_id': recipientId,
          'timestamp': timestamp,
          'user_id': userId,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process QR code payment: $e');
    }
  }

  // Cross-Platform Payment Integration
  static Future<PaymentTransaction> payForCrossPlatformService({
    required String serviceName,
    required String serviceType,
    required double amount,
    required String paymentMethodId,
    required String userId,
    Map<String, dynamic>? serviceMetadata,
  }) async {
    try {
      final transaction = await PaymentService.processStripePayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: 'USD',
        description: '$serviceName - $serviceType',
        metadata: {
          'type': 'cross_platform',
          'service_name': serviceName,
          'service_type': serviceType,
          'user_id': userId,
          ...?serviceMetadata,
        },
      );

      return transaction;
    } catch (e) {
      throw Exception('Failed to process cross-platform payment: $e');
    }
  }

  // Refund Integration
  static Future<PaymentTransaction> refundPayment({
    required String originalTransactionId,
    required double refundAmount,
    required String reason,
    required String userId,
  }) async {
    try {
      final refund = await PaymentService.refundPayment(
        transactionId: originalTransactionId,
        amount: refundAmount,
        reason: reason,
      );

      return refund;
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }

  // Payment Analytics
  static Future<Map<String, dynamic>> getPaymentAnalytics(String userId) async {
    try {
      final transactions = await PaymentService.getTransactionHistory(userId);

      final analytics = {
        'total_spent': transactions
            .where((tx) => tx.type == 'payment')
            .fold(0.0, (sum, tx) => sum + tx.amount),
        'total_received': transactions
            .where((tx) => tx.type == 'refund' || tx.type == 'transfer')
            .fold(0.0, (sum, tx) => sum + tx.amount),
        'transaction_count': transactions.length,
        'successful_payments': transactions
            .where((tx) => tx.status == 'completed')
            .length,
        'failed_payments': transactions
            .where((tx) => tx.status == 'failed')
            .length,
        'payment_methods_used': transactions
            .map((tx) => tx.paymentMethodId)
            .toSet()
            .length,
        'categories': _categorizeTransactions(transactions),
      };

      return analytics;
    } catch (e) {
      throw Exception('Failed to get payment analytics: $e');
    }
  }

  static Map<String, double> _categorizeTransactions(
    List<PaymentTransaction> transactions,
  ) {
    final categories = <String, double>{};

    for (final transaction in transactions) {
      final metadata = transaction.metadata;
      if (metadata != null && metadata['type'] != null) {
        final type = metadata['type'] as String;
        categories[type] = (categories[type] ?? 0.0) + transaction.amount;
      }
    }

    return categories;
  }

  // Payment Security
  static Future<bool> validatePayment({
    required String paymentMethodId,
    required double amount,
    required String userId,
  }) async {
    try {
      // In a real app, implement fraud detection, velocity checks, etc.
      await Future.delayed(const Duration(milliseconds: 500));

      // Basic validation rules
      if (amount <= 0) return false;
      if (amount > 10000) return false; // Max $10,000 per transaction

      return true;
    } catch (e) {
      return false;
    }
  }

  // Payment Notifications
  static Future<void> sendPaymentNotification({
    required String userId,
    required String type,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // In a real app, send push notification, email, SMS, etc.
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Handle notification error silently
    }
  }
}
