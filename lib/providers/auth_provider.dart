import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already logged in with Firebase
      if (FirebaseAuthService.isLoggedIn) {
        _currentUser = await FirebaseAuthService.getCurrentUser();
        
        if (_currentUser != null) {
          // Update online status
          await FirebaseAuthService.updateOnlineStatus(true);
          print('User authenticated: ${_currentUser!.username}');
        }
      }

      // Listen to auth state changes
      FirebaseAuthService.authStateChanges.listen((firebaseUser) async {
        if (firebaseUser == null) {
          _currentUser = null;
          notifyListeners();
        } else {
          _currentUser = await FirebaseAuthService.getCurrentUser();
          notifyListeners();
        }
      });
    } catch (e) {
      _error = e.toString();
      print('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await FirebaseAuthService.loginWithEmail(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await FirebaseAuthService.registerWithEmail(
        email: email,
        password: password,
        username: username,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await FirebaseAuthService.signInWithGoogle();

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send phone verification code
  Future<String?> sendPhoneVerificationCode(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String? verificationId;

    try {
      await FirebaseAuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          _isLoading = false;
          notifyListeners();
        },
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          _isLoading = false;
          notifyListeners();
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          _error = e.message ?? 'Verification failed';
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );

      return verificationId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Verify phone code and sign in
  Future<bool> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
    String? username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await FirebaseAuthService.signInWithPhoneCredential(
        verificationId: verificationId,
        smsCode: smsCode,
        username: username,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuthService.signOut();

      // Clear state
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}