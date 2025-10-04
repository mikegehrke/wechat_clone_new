import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // QR CODE SHARING (Add contact via QR)
  // ============================================================================

  /// Generate QR data for user
  static String generateUserQRData(String userId) {
    return 'wechat_user:$userId';
  }

  /// Generate QR data for group
  static String generateGroupQRData(String groupId) {
    return 'wechat_group:$groupId';
  }

  /// Generate QR data for payment
  static String generatePaymentQRData({
    required String userId,
    double? amount,
  }) {
    if (amount != null) {
      return 'wechat_pay:$userId:$amount';
    }
    return 'wechat_pay:$userId';
  }

  /// Parse QR data
  static Map<String, dynamic>? parseQRData(String data) {
    if (data.startsWith('wechat_user:')) {
      final userId = data.replaceFirst('wechat_user:', '');
      return {'type': 'user', 'userId': userId};
    }
    
    if (data.startsWith('wechat_group:')) {
      final groupId = data.replaceFirst('wechat_group:', '');
      return {'type': 'group', 'groupId': groupId};
    }
    
    if (data.startsWith('wechat_pay:')) {
      final parts = data.replaceFirst('wechat_pay:', '').split(':');
      return {
        'type': 'payment',
        'userId': parts[0],
        'amount': parts.length > 1 ? double.tryParse(parts[1]) : null,
      };
    }

    return null;
  }

  /// Handle scanned QR code
  static Future<String> handleScannedQR({
    required String data,
    required String currentUserId,
  }) async {
    try {
      final parsed = parseQRData(data);
      
      if (parsed == null) {
        throw Exception('Invalid QR code');
      }

      switch (parsed['type']) {
        case 'user':
          // Add contact
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('contacts')
              .doc(parsed['userId'])
              .set({
            'contactId': parsed['userId'],
            'addedAt': FieldValue.serverTimestamp(),
          });
          return 'Contact added!';

        case 'group':
          // Join group
          await _firestore.collection('chats').doc(parsed['groupId']).update({
            'participants': FieldValue.arrayUnion([currentUserId]),
          });
          return 'Joined group!';

        case 'payment':
          return 'payment:${parsed['userId']}:${parsed['amount']}';

        default:
          throw Exception('Unknown QR type');
      }
    } catch (e) {
      throw Exception('Failed to handle QR: $e');
    }
  }
}
