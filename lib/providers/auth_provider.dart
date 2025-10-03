import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  UserAccount? _userAccount;
  String? _token;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();

  User? get currentUser => _currentUser;
  UserAccount? get userAccount => _userAccount;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userAccount != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      _userAccount = _authService.currentUser;
      
      if (_userAccount != null) {
        // Convert UserAccount to User for backward compatibility
        _currentUser = User(
          id: _userAccount!.id,
          username: _userAccount!.username ?? 'user',
          email: _userAccount!.email ?? '',
          avatarUrl: _userAccount!.avatarUrl,
          status: _userAccount!.status ?? 'Online',
          lastSeen: _userAccount!.lastActiveAt ?? DateTime.now(),
          isOnline: _userAccount!.isActive,
        );
        
        print('User authenticated: ${_userAccount!.displayName}');
      }
    } catch (e) {
      _error = e.toString();
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
      _userAccount = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? 'user',
        email: _userAccount!.email ?? '',
        avatarUrl: _userAccount!.avatarUrl,
        status: _userAccount!.status ?? 'Online',
        lastSeen: _userAccount!.lastActiveAt ?? DateTime.now(),
        isOnline: _userAccount!.isActive,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign-In
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userAccount = await _authService.loginWithGoogle();
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? 'user',
        email: _userAccount!.email ?? '',
        avatarUrl: _userAccount!.avatarUrl,
        status: _userAccount!.status ?? 'Online',
        lastSeen: _userAccount!.lastActiveAt ?? DateTime.now(),
        isOnline: _userAccount!.isActive,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Apple Sign-In
  Future<bool> loginWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userAccount = await _authService.loginWithApple();
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? 'user',
        email: _userAccount!.email ?? '',
        avatarUrl: _userAccount!.avatarUrl,
        status: _userAccount!.status ?? 'Online',
        lastSeen: _userAccount!.lastActiveAt ?? DateTime.now(),
        isOnline: _userAccount!.isActive,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Anonymous Sign-In
  Future<bool> loginAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userAccount = await _authService.loginAnonymously();
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? 'guest',
        email: _userAccount!.email ?? '',
        avatarUrl: _userAccount!.avatarUrl,
        status: 'Guest',
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Phone Authentication
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendOTP(phoneNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otpCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userAccount = await _authService.loginWithPhone(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? 'user',
        email: _userAccount!.email ?? '',
        avatarUrl: _userAccount!.avatarUrl,
        status: _userAccount!.status ?? 'Online',
        lastSeen: _userAccount!.lastActiveAt ?? DateTime.now(),
        isOnline: _userAccount!.isActive,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, {String? phoneNumber}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        phoneNumber: phoneNumber ?? '+49123456789',
        email: email,
        username: username,
        displayName: username,
        password: password,
      );
      
      _userAccount = _authService.currentUser;
      
      // Convert UserAccount to User for backward compatibility
      _currentUser = User(
        id: _userAccount!.id,
        username: _userAccount!.username ?? username,
        email: _userAccount!.email ?? email,
        avatarUrl: _userAccount!.avatarUrl,
        status: 'New user',
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      _isLoading = false;
      notifyListeners();
      return true;
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
      await _authService.logout();
      
      // Clear state
      _currentUser = null;
      _userAccount = null;
      _token = null;
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