import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart' as app_models;

/// Firebase Authentication Service
/// Handles all authentication-related operations with Firebase
class FirebaseAuthService {
  static final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Get current Firebase user
  static firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  static Stream<firebase_auth.User?> get authStateChanges =>
      _auth.authStateChanges();

  // ============================================================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================================================

  /// Register with email and password
  static Future<app_models.User?> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create Firebase user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create user document in Firestore
      final user = app_models.User(
        id: userCredential.user!.uid,
        username: username,
        email: email,
        status: 'Hey there! I am using WeChat',
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login with email and password
  static Future<app_models.User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      // Update user status
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()},
      );

      // Get user data from Firestore
      return await getUserById(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ============================================================================
  // GOOGLE SIGN-IN
  // ============================================================================

  /// Sign in with Google
  static Future<app_models.User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign-in failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      app_models.User user;

      if (!userDoc.exists) {
        // Create new user document
        user = app_models.User(
          id: userCredential.user!.uid,
          username: googleUser.displayName ?? googleUser.email.split('@')[0],
          email: googleUser.email,
          avatar: googleUser.photoUrl,
          status: 'Hey there! I am using WeChat',
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
      } else {
        // Update existing user
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
            });

        user = app_models.User.fromJson(userDoc.data()!);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // ============================================================================
  // PHONE AUTHENTICATION
  // ============================================================================

  /// Send verification code to phone number
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(firebase_auth.PhoneAuthCredential credential)
    verificationCompleted,
    required Function(firebase_auth.FirebaseAuthException exception)
    verificationFailed,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in with phone credential
  static Future<app_models.User?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
    String? username,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Phone sign-in failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      app_models.User user;

      if (!userDoc.exists) {
        // Create new user document
        user = app_models.User(
          id: userCredential.user!.uid,
          username:
              username ?? 'user_${userCredential.user!.uid.substring(0, 8)}',
          email: '', // Phone login doesn't require email
          phoneNumber: userCredential.user!.phoneNumber,
          status: 'Hey there! I am using WeChat',
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
      } else {
        // Update existing user
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
            });

        user = app_models.User.fromJson(userDoc.data()!);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Phone sign-in failed: $e');
    }
  }

  // ============================================================================
  // APPLE SIGN-IN
  // ============================================================================

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Apple
  static Future<app_models.User?> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = FirebaseAuthService()._generateNonce();
      final nonce = FirebaseAuthService()._sha256ofString(rawNonce);

      // Request credential from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = firebase_auth.OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw Exception('Apple sign-in failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      app_models.User user;

      if (!userDoc.exists) {
        // Create new user document
        final displayName =
            appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : null;

        user = app_models.User(
          id: userCredential.user!.uid,
          username:
              displayName ??
              appleCredential.email?.split('@')[0] ??
              'user_${userCredential.user!.uid.substring(0, 8)}',
          email: appleCredential.email ?? userCredential.user!.email ?? '',
          status: 'Hey there! I am using WeChat',
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
      } else {
        // Update existing user
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
            });

        user = app_models.User.fromJson(userDoc.data()!);
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // User canceled the sign-in
        return null;
      }
      throw Exception('Apple sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Get user by ID from Firestore
  static Future<app_models.User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return app_models.User.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get current app user from Firestore
  static Future<app_models.User?> getCurrentUser() async {
    if (_auth.currentUser == null) return null;
    return await getUserById(_auth.currentUser!.uid);
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? username,
    String? status,
    String? avatar,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      final updates = <String, dynamic>{};

      if (username != null) updates['username'] = username;
      if (status != null) updates['status'] = status;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update user online status
  static Future<void> updateOnlineStatus(bool isOnline) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail for online status updates
      print('Failed to update online status: $e');
    }
  }

  /// Stream user data
  static Stream<app_models.User?> streamCurrentUser() {
    if (_auth.currentUser == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return app_models.User.fromJson(doc.data()!);
        });
  }

  // ============================================================================
  // LOGOUT & PASSWORD RESET
  // ============================================================================

  /// Sign out
  static Future<void> signOut() async {
    try {
      // Update online status before signing out
      if (_auth.currentUser != null) {
        await updateOnlineStatus(false);
      }

      // Sign out from Google if signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('No user logged in or email not available');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: currentPassword,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // Change password
      await _auth.currentUser!.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  /// Delete account
  static Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = _auth.currentUser!.uid;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete Firebase user
      await _auth.currentUser!.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Handle Firebase Auth exceptions
  static String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  // ============================================================================
  // SEARCH USERS
  // ============================================================================

  /// Search users by username or email
  static Future<List<app_models.User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => app_models.User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get all users (for contacts list)
  static Future<List<app_models.User>> getAllUsers({int limit = 50}) async {
    try {
      final snapshot = await _firestore.collection('users').limit(limit).get();

      return snapshot.docs
          .map((doc) => app_models.User.fromJson(doc.data()))
          .where((user) => user.id != currentUserId) // Exclude current user
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
}
