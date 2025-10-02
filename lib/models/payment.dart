class PaymentMethod {
  final String id;
  final String type; // 'card', 'paypal', 'apple_pay', 'google_pay', 'bank_transfer'
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvv;
  final String? cardBrand; // 'visa', 'mastercard', 'amex', 'discover'
  final String? paypalEmail;
  final String? bankAccountNumber;
  final String? bankRoutingNumber;
  final String? bankName;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastUsed;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.cardBrand,
    this.paypalEmail,
    this.bankAccountNumber,
    this.bankRoutingNumber,
    this.bankName,
    this.isDefault = false,
    this.isVerified = false,
    required this.createdAt,
    this.lastUsed,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cvv: json['cvv'],
      cardBrand: json['cardBrand'],
      paypalEmail: json['paypalEmail'],
      bankAccountNumber: json['bankAccountNumber'],
      bankRoutingNumber: json['bankRoutingNumber'],
      bankName: json['bankName'],
      isDefault: json['isDefault'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardBrand': cardBrand,
      'paypalEmail': paypalEmail,
      'bankAccountNumber': bankAccountNumber,
      'bankRoutingNumber': bankRoutingNumber,
      'bankName': bankName,
      'isDefault': isDefault,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  String get displayName {
    switch (type) {
      case 'card':
        if (cardNumber != null && cardNumber!.length >= 4) {
          return '${cardBrand?.toUpperCase() ?? 'CARD'} •••• ${cardNumber!.substring(cardNumber!.length - 4)}';
        }
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal (${paypalEmail ?? 'Account'})';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      case 'bank_transfer':
        return 'Bank Transfer (${bankName ?? 'Account'})';
      default:
        return type.toUpperCase();
    }
  }

  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.length < 4) return '•••• •••• •••• ••••';
    final lastFour = cardNumber!.substring(cardNumber!.length - 4);
    return '•••• •••• •••• $lastFour';
  }

  String get expiryDate {
    if (expiryMonth == null || expiryYear == null) return '';
    return '$expiryMonth/$expiryYear';
  }
}

class PaymentTransaction {
  final String id;
  final String userId;
  final String type; // 'payment', 'refund', 'transfer', 'withdrawal'
  final double amount;
  final String currency;
  final String status; // 'pending', 'completed', 'failed', 'cancelled', 'refunded'
  final String? description;
  final String? reference;
  final String? paymentMethodId;
  final String? recipientId;
  final String? recipientEmail;
  final String? recipientName;
  final Map<String, dynamic>? metadata;
  final double? fee;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? stripePaymentIntentId;
  final String? paypalTransactionId;

  PaymentTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    this.description,
    this.reference,
    this.paymentMethodId,
    this.recipientId,
    this.recipientEmail,
    this.recipientName,
    this.metadata,
    this.fee,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
    this.stripePaymentIntentId,
    this.paypalTransactionId,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'],
      description: json['description'],
      reference: json['reference'],
      paymentMethodId: json['paymentMethodId'],
      recipientId: json['recipientId'],
      recipientEmail: json['recipientEmail'],
      recipientName: json['recipientName'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      fee: json['fee']?.toDouble(),
      failureReason: json['failureReason'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      stripePaymentIntentId: json['stripePaymentIntentId'],
      paypalTransactionId: json['paypalTransactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      'reference': reference,
      'paymentMethodId': paymentMethodId,
      'recipientId': recipientId,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'metadata': metadata,
      'fee': fee,
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'stripePaymentIntentId': stripePaymentIntentId,
      'paypalTransactionId': paypalTransactionId,
    };
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)} $currency';
  }

  String get formattedFee {
    if (fee == null) return '';
    return '\$${fee!.toStringAsFixed(2)} $currency';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class Wallet {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final double pendingBalance;
  final double totalEarned;
  final double totalSpent;
  final DateTime lastUpdated;
  final List<WalletTransaction> transactions;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'USD',
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalSpent = 0.0,
    required this.lastUpdated,
    this.transactions = const [],
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      balance: json['balance']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      pendingBalance: json['pendingBalance']?.toDouble() ?? 0.0,
      totalEarned: json['totalEarned']?.toDouble() ?? 0.0,
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      transactions: (json['transactions'] as List?)
          ?.map((tx) => WalletTransaction.fromJson(tx))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'pendingBalance': pendingBalance,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
    };
  }

  String get formattedBalance {
    return '\$${balance.toStringAsFixed(2)} $currency';
  }

  String get formattedPendingBalance {
    return '\$${pendingBalance.toStringAsFixed(2)} $currency';
  }

  String get formattedTotalEarned {
    return '\$${totalEarned.toStringAsFixed(2)} $currency';
  }

  String get formattedTotalSpent {
    return '\$${totalSpent.toStringAsFixed(2)} $currency';
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String type; // 'credit', 'debit', 'transfer_in', 'transfer_out', 'refund'
  final double amount;
  final String currency;
  final String description;
  final String? reference;
  final String? relatedTransactionId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    this.reference,
    this.relatedTransactionId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      walletId: json['walletId'],
      type: json['type'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      reference: json['reference'],
      relatedTransactionId: json['relatedTransactionId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'relatedTransactionId': relatedTransactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedAmount {
    final sign = type == 'credit' || type == 'transfer_in' || type == 'refund' ? '+' : '-';
    return '$sign\$${amount.toStringAsFixed(2)} $currency';
  }

  Color get amountColor {
    return type == 'credit' || type == 'transfer_in' || type == 'refund' 
        ? Colors.green 
        : Colors.red;
  }
}

class PaymentRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? toUserId;
  final String? toUserEmail;
  final String? toUserName;
  final double amount;
  final String currency;
  final String description;
  final String status; // 'pending', 'paid', 'cancelled', 'expired'
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final String? paymentMethodId;
  final String? paymentTransactionId;

  PaymentRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.toUserId,
    this.toUserEmail,
    this.toUserName,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    this.status = 'pending',
    required this.createdAt,
    this.expiresAt,
    this.paidAt,
    this.paymentMethodId,
    this.paymentTransactionId,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      toUserId: json['toUserId'],
      toUserEmail: json['toUserEmail'],
      toUserName: json['toUserName'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      paymentMethodId: json['paymentMethodId'],
      paymentTransactionId: json['paymentTransactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserEmail': toUserEmail,
      'toUserName': toUserName,
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'paymentTransactionId': paymentTransactionId,
    };
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)} $currency';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

class Subscription {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final double price;
  final String currency;
  final String billingCycle; // 'monthly', 'yearly', 'weekly', 'daily'
  final String status; // 'active', 'cancelled', 'expired', 'past_due'
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final String? paymentMethodId;
  final bool autoRenew;
  final Map<String, dynamic> features;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.price,
    this.currency = 'USD',
    required this.billingCycle,
    this.status = 'active',
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.paymentMethodId,
    this.autoRenew = true,
    this.features = const {},
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      planId: json['planId'],
      planName: json['planName'],
      price: json['price']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      billingCycle: json['billingCycle'],
      status: json['status'] ?? 'active',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.parse(json['nextBillingDate']) : null,
      paymentMethodId: json['paymentMethodId'],
      autoRenew: json['autoRenew'] ?? true,
      features: Map<String, dynamic>.from(json['features'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'price': price,
      'currency': currency,
      'billingCycle': billingCycle,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'autoRenew': autoRenew,
      'features': features,
    };
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)} $currency';
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'Active';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'past_due':
        return 'Past Due';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      case 'past_due':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}