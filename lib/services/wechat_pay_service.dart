import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/payment_service.dart';

class WeChatPayService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // WALLET BALANCE
  // ============================================================================

  /// Get user wallet balance
  static Future<double> getWalletBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      
      if (!doc.exists) {
        // Create wallet if doesn't exist
        await _firestore.collection('wallets').doc(userId).set({
          'balance': 0.0,
          'currency': 'EUR',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return 0.0;
      }

      return (doc.data()?['balance'] ?? 0.0).toDouble();
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  /// Add money to wallet (via Stripe)
  static Future<void> addMoneyToWallet({
    required String userId,
    required double amount,
  }) async {
    try {
      // Use Stripe to charge
      await PaymentService.processPayment(
        amount: amount,
        currency: 'eur',
        description: 'Add money to wallet',
      );

      // Update wallet balance
      await _firestore.collection('wallets').doc(userId).update({
        'balance': FieldValue.increment(amount),
      });

      // Record transaction
      await _recordTransaction(
        userId: userId,
        type: 'top_up',
        amount: amount,
        description: 'Added money to wallet',
      );
    } catch (e) {
      throw Exception('Failed to add money: $e');
    }
  }

  // ============================================================================
  // SEND/RECEIVE MONEY
  // ============================================================================

  /// Send money to another user
  static Future<void> sendMoney({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? message,
  }) async {
    try {
      // Check sender balance
      final balance = await getWalletBalance(fromUserId);
      if (balance < amount) {
        throw Exception('Insufficient balance');
      }

      // Deduct from sender
      await _firestore.collection('wallets').doc(fromUserId).update({
        'balance': FieldValue.increment(-amount),
      });

      // Add to receiver
      await _firestore.collection('wallets').doc(toUserId).update({
        'balance': FieldValue.increment(amount),
      });

      // Record transactions
      await _recordTransaction(
        userId: fromUserId,
        type: 'send',
        amount: -amount,
        description: message ?? 'Sent money',
        relatedUserId: toUserId,
      );

      await _recordTransaction(
        userId: toUserId,
        type: 'receive',
        amount: amount,
        description: message ?? 'Received money',
        relatedUserId: fromUserId,
      );
    } catch (e) {
      throw Exception('Failed to send money: $e');
    }
  }

  /// Request money from user
  static Future<String> requestMoney({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? message,
  }) async {
    try {
      final requestData = {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'amount': amount,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('money_requests').add(requestData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to request money: $e');
    }
  }

  // ============================================================================
  // RED PACKETS (红包 - Lucky Money)
  // ============================================================================

  /// Create red packet
  static Future<String> createRedPacket({
    required String userId,
    required double totalAmount,
    required int quantity,
    String? message,
    bool isRandom = true,
    String? chatId,
  }) async {
    try {
      // Check balance
      final balance = await getWalletBalance(userId);
      if (balance < totalAmount) {
        throw Exception('Insufficient balance');
      }

      // Deduct from sender
      await _firestore.collection('wallets').doc(userId).update({
        'balance': FieldValue.increment(-totalAmount),
      });

      // Create red packet
      final redPacketData = {
        'userId': userId,
        'totalAmount': totalAmount,
        'remainingAmount': totalAmount,
        'quantity': quantity,
        'remainingQuantity': quantity,
        'message': message ?? '恭喜发财 (Good Fortune!)',
        'isRandom': isRandom,
        'chatId': chatId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
        'claimed': [],
        'amounts': isRandom ? _generateRandomAmounts(totalAmount, quantity) : null,
      };

      final docRef = await _firestore.collection('red_packets').add(redPacketData);

      // Record transaction
      await _recordTransaction(
        userId: userId,
        type: 'red_packet_sent',
        amount: -totalAmount,
        description: 'Red Packet: ${message ?? "Lucky Money"}',
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create red packet: $e');
    }
  }

  /// Claim red packet
  static Future<Map<String, dynamic>> claimRedPacket({
    required String redPacketId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection('red_packets').doc(redPacketId);
      
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception('Red packet not found');
        }

        final data = snapshot.data()!;
        final claimed = List<Map<String, dynamic>>.from(data['claimed'] ?? []);
        
        // Check if already claimed
        if (claimed.any((c) => c['userId'] == userId)) {
          throw Exception('Already claimed');
        }

        // Check if expired
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiresAt)) {
          throw Exception('Red packet expired');
        }

        // Check if all claimed
        final remainingQty = data['remainingQuantity'] as int;
        if (remainingQty <= 0) {
          throw Exception('All claimed');
        }

        // Calculate amount
        double claimedAmount;
        if (data['isRandom'] == true) {
          final amounts = List<double>.from(data['amounts'] ?? []);
          claimedAmount = amounts[claimed.length];
        } else {
          claimedAmount = data['totalAmount'] / data['quantity'];
        }

        // Update red packet
        transaction.update(docRef, {
          'remainingAmount': FieldValue.increment(-claimedAmount),
          'remainingQuantity': FieldValue.increment(-1),
          'claimed': FieldValue.arrayUnion([
            {
              'userId': userId,
              'amount': claimedAmount,
              'timestamp': FieldValue.serverTimestamp(),
            }
          ]),
        });

        // Add to user wallet
        final walletRef = _firestore.collection('wallets').doc(userId);
        transaction.update(walletRef, {
          'balance': FieldValue.increment(claimedAmount),
        });

        return {
          'amount': claimedAmount,
          'message': data['message'],
        };
      }).then((result) async {
        // Record transaction
        await _recordTransaction(
          userId: userId,
          type: 'red_packet_received',
          amount: result['amount'],
          description: 'Red Packet: ${result['message']}',
        );
        
        return result;
      });
    } catch (e) {
      throw Exception('Failed to claim red packet: $e');
    }
  }

  /// Get red packet details
  static Future<Map<String, dynamic>> getRedPacketDetails(String redPacketId) async {
    try {
      final doc = await _firestore.collection('red_packets').doc(redPacketId).get();
      
      if (!doc.exists) {
        throw Exception('Red packet not found');
      }

      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to get red packet: $e');
    }
  }

  // ============================================================================
  // SPLIT BILL
  // ============================================================================

  /// Create split bill request
  static Future<String> createSplitBill({
    required String userId,
    required double totalAmount,
    required List<String> participants,
    String? description,
  }) async {
    try {
      final perPerson = totalAmount / participants.length;
      
      final billData = {
        'userId': userId,
        'totalAmount': totalAmount,
        'perPerson': perPerson,
        'participants': participants,
        'description': description ?? 'Split Bill',
        'paid': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('split_bills').add(billData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create split bill: $e');
    }
  }

  /// Pay split bill
  static Future<void> paySplitBill({
    required String billId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection('split_bills').doc(billId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Bill not found');
      }

      final data = doc.data()!;
      final amount = (data['perPerson'] as num).toDouble();
      final creatorId = data['userId'] as String;

      // Send money to creator
      await sendMoney(
        fromUserId: userId,
        toUserId: creatorId,
        amount: amount,
        message: 'Split Bill Payment',
      );

      // Mark as paid
      await docRef.update({
        'paid': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to pay split bill: $e');
    }
  }

  // ============================================================================
  // TRANSACTION HISTORY
  // ============================================================================

  /// Get transaction history
  static Stream<List<Map<String, dynamic>>> getTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    });
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  static Future<void> _recordTransaction({
    required String userId,
    required String type,
    required double amount,
    required String description,
    String? relatedUserId,
  }) async {
    await _firestore.collection('transactions').add({
      'userId': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'relatedUserId': relatedUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static List<double> _generateRandomAmounts(double total, int quantity) {
    final amounts = <double>[];
    var remaining = total;
    
    for (var i = 0; i < quantity - 1; i++) {
      final max = remaining / (quantity - i) * 2;
      final min = 0.01;
      final amount = (min + (max - min) * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
      amounts.add(double.parse(amount.toStringAsFixed(2)));
      remaining -= amounts.last;
    }
    
    amounts.add(double.parse(remaining.toStringAsFixed(2)));
    amounts.shuffle();
    
    return amounts;
  }
}
