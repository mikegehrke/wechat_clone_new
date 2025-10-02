import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _token != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await StorageService.getToken();
      _currentUser = await StorageService.getUser();

      if (_token != null && _currentUser != null) {
        // For demo purposes, we'll simulate a valid session
        // In a real app, you would verify the token with your backend
        print('User authenticated: ${_currentUser!.username}');
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
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any email/password combination
      if (email.isNotEmpty && password.isNotEmpty) {
        _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = User(
          id: 'demo_user_1',
          username: email.split('@')[0],
          email: email,
          status: 'Online',
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_currentUser!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Please enter email and password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, accept any registration
      if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
        _currentUser = User(
          id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
          username: username,
          email: email,
          status: 'New user',
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_currentUser!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Please fill in all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      // Clear storage
      await StorageService.clearAll();

      // Clear state
      _currentUser = null;
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