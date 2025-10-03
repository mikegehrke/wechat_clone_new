import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_foundations.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _settingsKey = 'app_settings';
  static const String _complianceKey = 'compliance_settings';
  
  // Firebase instances
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserAccount? _currentUser;
  AppSettings? _appSettings;
  ComplianceSettings? _complianceSettings;

  // Getters
  UserAccount? get currentUser => _currentUser;
  AppSettings? get appSettings => _appSettings;
  ComplianceSettings? get complianceSettings => _complianceSettings;
  bool get isLoggedIn => _currentUser != null;

  // Initialize service
  Future<void> initialize() async {
    await _loadUserFromStorage();
    await _loadSettingsFromStorage();
    await _loadComplianceFromStorage();
  }

  // Authentication Methods
  Future<UserAccount> loginWithPhone({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // Verify OTP with Firebase
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: otpCode.split(':')[0], // In real app, store verificationId separately
        smsCode: otpCode.split(':')[1],
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create or get user account
      final user = await _getOrCreateUser(phoneNumber, userCredential.user!.uid);
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
      
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserAccount> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Verify credentials with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create or get user account
      final user = await _getOrCreateUserByEmail(email, userCredential.user!.uid);
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
      
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<UserAccount> loginWithSocial({
    required String provider,
    required String providerId,
    String? email,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      // Firebase social login handled by specific providers
      // For now, create custom token or use existing Firebase methods
      
      // Create or get user account from Firestore
      final user = await _getOrCreateUserBySocial(
        provider: provider,
        providerId: providerId,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
      
      return user;
    } catch (e) {
      throw Exception('Social login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      
      _currentUser = null;
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> register({
    required String phoneNumber,
    required String email,
    required String username,
    required String displayName,
    String? password,
  }) async {
    try {
      // Create Firebase account with email/password if provided
      auth.UserCredential? userCredential;
      if (password != null && email.isNotEmpty) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      
      // Create new user account
      final userId = userCredential?.user?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserAccount(
        id: userId,
        phoneNumber: phoneNumber,
        email: email,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(user.toJson());
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // OTP Methods
  Future<String> sendOTP(String phoneNumber) async {
    try {
      // Use Firebase Phone Authentication
      String verificationId = '';
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (auth.FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          print('OTP sent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );
      
      return verificationId;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOTP(String verificationId, String otpCode) async {
    try {
      // Verify OTP with Firebase
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Device Management
  Future<List<ConnectedDevice>> getConnectedDevices() async {
    try {
      if (_currentUser == null) return [];
      
      // In real app, fetch from backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _currentUser!.devices;
    } catch (e) {
      throw Exception('Failed to get devices: $e');
    }
  }

  Future<void> addDevice({
    required String deviceName,
    required String deviceType,
    required String platform,
    String? model,
    String? osVersion,
    String? appVersion,
  }) async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      final device = ConnectedDevice(
        id: 'device_${DateTime.now().millisecondsSinceEpoch}',
        name: deviceName,
        type: deviceType,
        platform: platform,
        model: model,
        osVersion: osVersion,
        appVersion: appVersion,
        lastSeenAt: DateTime.now(),
        isPrimary: _currentUser!.devices.isEmpty,
      );
      
      // Add to user's devices
      final updatedUser = UserAccount(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        email: _currentUser!.email,
        username: _currentUser!.username,
        displayName: _currentUser!.displayName,
        avatarUrl: _currentUser!.avatarUrl,
        status: _currentUser!.status,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: _currentUser!.lastActiveAt,
        isVerified: _currentUser!.isVerified,
        isActive: _currentUser!.isActive,
        devices: [..._currentUser!.devices, device],
        socialLogins: _currentUser!.socialLogins,
        privacy: _currentUser!.privacy,
        security: _currentUser!.security,
        metadata: _currentUser!.metadata,
      );
      
      await _saveUserToStorage(updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      final updatedDevices = _currentUser!.devices.where((d) => d.id != deviceId).toList();
      
      final updatedUser = UserAccount(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        email: _currentUser!.email,
        username: _currentUser!.username,
        displayName: _currentUser!.displayName,
        avatarUrl: _currentUser!.avatarUrl,
        status: _currentUser!.status,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: _currentUser!.lastActiveAt,
        isVerified: _currentUser!.isVerified,
        isActive: _currentUser!.isActive,
        devices: updatedDevices,
        socialLogins: _currentUser!.socialLogins,
        privacy: _currentUser!.privacy,
        security: _currentUser!.security,
        metadata: _currentUser!.metadata,
      );
      
      await _saveUserToStorage(updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      throw Exception('Failed to remove device: $e');
    }
  }

  // Security Methods
  Future<void> enableTwoFactor() async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      final updatedSecurity = SecuritySettings(
        twoFactorEnabled: true,
        biometricLockEnabled: _currentUser!.security.biometricLockEnabled,
        pinLockEnabled: _currentUser!.security.pinLockEnabled,
        pinHash: _currentUser!.security.pinHash,
        autoLockEnabled: _currentUser!.security.autoLockEnabled,
        autoLockTimeoutMinutes: _currentUser!.security.autoLockTimeoutMinutes,
        endToEndEncryptionEnabled: _currentUser!.security.endToEndEncryptionEnabled,
        deviceBindingEnabled: _currentUser!.security.deviceBindingEnabled,
        activeSessions: _currentUser!.security.activeSessions,
        securityHistory: _currentUser!.security.securityHistory,
        customSettings: _currentUser!.security.customSettings,
      );
      
      final updatedUser = UserAccount(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        email: _currentUser!.email,
        username: _currentUser!.username,
        displayName: _currentUser!.displayName,
        avatarUrl: _currentUser!.avatarUrl,
        status: _currentUser!.status,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: _currentUser!.lastActiveAt,
        isVerified: _currentUser!.isVerified,
        isActive: _currentUser!.isActive,
        devices: _currentUser!.devices,
        socialLogins: _currentUser!.socialLogins,
        privacy: _currentUser!.privacy,
        security: updatedSecurity,
        metadata: _currentUser!.metadata,
      );
      
      await _saveUserToStorage(updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      throw Exception('Failed to enable two-factor: $e');
    }
  }

  Future<void> setPIN(String pin) async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      final pinHash = _hashPIN(pin);
      
      final updatedSecurity = SecuritySettings(
        twoFactorEnabled: _currentUser!.security.twoFactorEnabled,
        biometricLockEnabled: _currentUser!.security.biometricLockEnabled,
        pinLockEnabled: true,
        pinHash: pinHash,
        autoLockEnabled: _currentUser!.security.autoLockEnabled,
        autoLockTimeoutMinutes: _currentUser!.security.autoLockTimeoutMinutes,
        endToEndEncryptionEnabled: _currentUser!.security.endToEndEncryptionEnabled,
        deviceBindingEnabled: _currentUser!.security.deviceBindingEnabled,
        activeSessions: _currentUser!.security.activeSessions,
        securityHistory: _currentUser!.security.securityHistory,
        customSettings: _currentUser!.security.customSettings,
      );
      
      final updatedUser = UserAccount(
        id: _currentUser!.id,
        phoneNumber: _currentUser!.phoneNumber,
        email: _currentUser!.email,
        username: _currentUser!.username,
        displayName: _currentUser!.displayName,
        avatarUrl: _currentUser!.avatarUrl,
        status: _currentUser!.status,
        bio: _currentUser!.bio,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: _currentUser!.lastActiveAt,
        isVerified: _currentUser!.isVerified,
        isActive: _currentUser!.isActive,
        devices: _currentUser!.devices,
        socialLogins: _currentUser!.socialLogins,
        privacy: _currentUser!.privacy,
        security: updatedSecurity,
        metadata: _currentUser!.metadata,
      );
      
      await _saveUserToStorage(updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      throw Exception('Failed to set PIN: $e');
    }
  }

  Future<bool> verifyPIN(String pin) async {
    try {
      if (_currentUser == null) return false;
      
      final pinHash = _hashPIN(pin);
      return pinHash == _currentUser!.security.pinHash;
    } catch (e) {
      return false;
    }
  }

  // App Settings
  Future<void> updateAppSettings(AppSettings settings) async {
    try {
      await _saveSettingsToStorage(settings);
      _appSettings = settings;
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  Future<void> updateComplianceSettings(ComplianceSettings settings) async {
    try {
      await _saveComplianceToStorage(settings);
      _complianceSettings = settings;
    } catch (e) {
      throw Exception('Failed to update compliance settings: $e');
    }
  }

  // Data Export & Deletion
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      // In real app, generate comprehensive data export
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'user': _currentUser!.toJson(),
        'settings': _appSettings?.toJson(),
        'compliance': _complianceSettings?.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_currentUser == null) throw Exception('Not logged in');
      
      // In real app, delete all user data from backend
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_settingsKey);
      await prefs.remove(_complianceKey);
      
      _currentUser = null;
      _appSettings = null;
      _complianceSettings = null;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Private Methods
  Future<UserAccount> _getOrCreateUser(String phoneNumber, String userId) async {
    try {
      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserAccount.fromJson(doc.data()!);
      }
      
      // Create new user
      final user = UserAccount(
        id: userId,
        phoneNumber: phoneNumber,
        username: 'user_${phoneNumber.substring(phoneNumber.length - 4)}',
        displayName: 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(user.toJson());
      
      return user;
    } catch (e) {
      throw Exception('Failed to get or create user: $e');
    }
  }

  Future<UserAccount> _getOrCreateUserByEmail(String email, String userId) async {
    try {
      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserAccount.fromJson(doc.data()!);
      }
      
      // Create new user
      final user = UserAccount(
        id: userId,
        phoneNumber: '', // Will be set later if needed
        email: email,
        username: email.split('@')[0],
        displayName: email.split('@')[0],
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(user.toJson());
      
      return user;
    } catch (e) {
      throw Exception('Failed to get or create user by email: $e');
    }
  }

  Future<UserAccount> _getOrCreateUserBySocial({
    required String provider,
    required String providerId,
    String? email,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final userId = 'user_${providerId.hashCode}';
      
      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserAccount.fromJson(doc.data()!);
      }
      
      // Create new user
      final socialLogin = SocialLogin(
        provider: provider,
        providerId: providerId,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        connectedAt: DateTime.now(),
      );
      
      final user = UserAccount(
        id: userId,
        phoneNumber: '', // Will be set later if needed
        email: email,
        username: name?.toLowerCase().replaceAll(' ', '_') ?? 'user_${providerId.substring(0, 4)}',
        displayName: name ?? 'User ${providerId.substring(0, 4)}',
        avatarUrl: avatarUrl,
        createdAt: DateTime.now(),
        socialLogins: [socialLogin],
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(user.toJson());
      
      return user;
    } catch (e) {
      throw Exception('Failed to get or create user by social: $e');
    }
  }

  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  String _hashPIN(String pin) {
    // In real app, use proper hashing (bcrypt, etc.)
    return pin.hashCode.toString();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = UserAccount.fromJson(userMap);
      }
    } catch (e) {
      print('Failed to load user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage(UserAccount user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Failed to save user to storage: $e');
    }
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        _appSettings = AppSettings.fromJson(settingsMap);
      } else {
        _appSettings = AppSettings(
          notifications: NotificationSettings(),
          cache: CacheSettings(),
        );
      }
    } catch (e) {
      print('Failed to load settings from storage: $e');
      _appSettings = AppSettings(
        notifications: NotificationSettings(),
        cache: CacheSettings(),
      );
    }
  }

  Future<void> _saveSettingsToStorage(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Failed to save settings to storage: $e');
    }
  }

  Future<void> _loadComplianceFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complianceJson = prefs.getString(_complianceKey);
      
      if (complianceJson != null) {
        final complianceMap = jsonDecode(complianceJson);
        _complianceSettings = ComplianceSettings.fromJson(complianceMap);
      } else {
        _complianceSettings = ComplianceSettings();
      }
    } catch (e) {
      print('Failed to load compliance from storage: $e');
      _complianceSettings = ComplianceSettings();
    }
  }

  Future<void> _saveComplianceToStorage(ComplianceSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final complianceJson = jsonEncode(settings.toJson());
      await prefs.setString(_complianceKey, complianceJson);
    } catch (e) {
      print('Failed to save compliance to storage: $e');
    }
  }
}