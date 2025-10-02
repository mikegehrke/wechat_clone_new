import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_foundations.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _settingsKey = 'app_settings';
  static const String _complianceKey = 'compliance_settings';
  
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
      // In real app, verify OTP with backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Create or get user account
      final user = await _getOrCreateUser(phoneNumber);
      
      // Update last active (can't modify final field)
      
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
      // In real app, verify credentials with backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Create or get user account
      final user = await _getOrCreateUserByEmail(email);
      
      // Update last active (can't modify final field)
      
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
      // In real app, verify social login with provider
      await Future.delayed(const Duration(seconds: 1));
      
      // Create or get user account
      final user = await _getOrCreateUserBySocial(
        provider: provider,
        providerId: providerId,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
      
      // Update last active (can't modify final field)
      
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
      // In real app, invalidate session on backend
      await Future.delayed(const Duration(milliseconds: 500));
      
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
  }) async {
    try {
      // In real app, create account on backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Create new user account
      final user = UserAccount(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        email: email,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // OTP Methods
  Future<void> sendOTP(String phoneNumber) async {
    try {
      // In real app, send OTP via SMS
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock OTP generation
      final otp = _generateOTP();
      print('OTP for $phoneNumber: $otp'); // In real app, send via SMS
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otpCode) async {
    try {
      // In real app, verify OTP with backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock verification (always true for demo)
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
  Future<UserAccount> _getOrCreateUser(String phoneNumber) async {
    // In real app, check if user exists in database
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserAccount(
      id: 'user_${phoneNumber.hashCode}',
      phoneNumber: phoneNumber,
      username: 'user_${phoneNumber.substring(phoneNumber.length - 4)}',
      displayName: 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
      createdAt: DateTime.now(),
      privacy: PrivacySettings(),
      security: SecuritySettings(),
    );
  }

  Future<UserAccount> _getOrCreateUserByEmail(String email) async {
    // In real app, check if user exists in database
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserAccount(
      id: 'user_${email.hashCode}',
      phoneNumber: '+1234567890', // Mock phone
      email: email,
      username: email.split('@')[0],
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
      privacy: PrivacySettings(),
      security: SecuritySettings(),
    );
  }

  Future<UserAccount> _getOrCreateUserBySocial({
    required String provider,
    required String providerId,
    String? email,
    String? name,
    String? avatarUrl,
  }) async {
    // In real app, check if user exists in database
    await Future.delayed(const Duration(milliseconds: 500));
    
    final socialLogin = SocialLogin(
      provider: provider,
      providerId: providerId,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      connectedAt: DateTime.now(),
    );
    
    return UserAccount(
      id: 'user_${providerId.hashCode}',
      phoneNumber: '+1234567890', // Mock phone
      email: email,
      username: name?.toLowerCase().replaceAll(' ', '_') ?? 'user_${providerId.substring(0, 4)}',
      displayName: name ?? 'User ${providerId.substring(0, 4)}',
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
      socialLogins: [socialLogin],
      privacy: PrivacySettings(),
      security: SecuritySettings(),
    );
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