import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import '../models/app_foundations.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      // Verify OTP with Firebase
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId ?? '',
        smsCode: otpCode,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Authentication failed');
      }
      
      // Create or get user account
      final user = await _getOrCreateUser(phoneNumber, firebaseUser.uid);
      
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
      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Authentication failed');
      }
      
      // Create or get user account
      final user = await _getOrCreateUserByEmail(email, firebaseUser.uid);
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
      
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Google Sign-In
  Future<UserAccount> loginWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google authentication failed');
      }

      // Create or get user account
      final user = await _getOrCreateUserBySocial(
        provider: 'google',
        providerId: firebaseUser.uid,
        email: firebaseUser.email,
        name: firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
        firebaseUid: firebaseUser.uid,
      );

      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  // Apple Sign-In
  Future<UserAccount> loginWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Apple authentication failed');
      }

      // Create display name from Apple credential
      String? displayName;
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
      }

      // Create or get user account
      final user = await _getOrCreateUserBySocial(
        provider: 'apple',
        providerId: firebaseUser.uid,
        email: firebaseUser.email ?? appleCredential.email,
        name: displayName ?? firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
        firebaseUid: firebaseUser.uid,
      );

      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw Exception('Apple login failed: $e');
    }
  }

  // Anonymous Sign-In
  Future<UserAccount> loginAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Anonymous authentication failed');
      }

      // Create anonymous user account
      final user = UserAccount(
        id: firebaseUser.uid,
        phoneNumber: '',
        email: '',
        username: 'guest_${firebaseUser.uid.substring(0, 8)}',
        displayName: 'Guest User',
        isAnonymous: true,
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );

      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;

      return user;
    } catch (e) {
      throw Exception('Anonymous login failed: $e');
    }
  }

  // Convert Anonymous to Permanent Account
  Future<UserAccount> linkAnonymousAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || !user.isAnonymous) {
        throw Exception('No anonymous user to link');
      }

      // Create email credential
      final credential = EmailAuthProvider.credential(email: email, password: password);

      // Link the anonymous account with email/password
      final userCredential = await user.linkWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Account linking failed');
      }

      // Update user account
      final updatedUser = UserAccount(
        id: firebaseUser.uid,
        phoneNumber: _currentUser?.phoneNumber ?? '',
        email: email,
        username: email.split('@')[0],
        displayName: _currentUser?.displayName ?? email.split('@')[0],
        isAnonymous: false,
        createdAt: _currentUser?.createdAt ?? DateTime.now(),
        privacy: _currentUser?.privacy ?? PrivacySettings(),
        security: _currentUser?.security ?? SecuritySettings(),
      );

      // Save to Firestore and storage
      await _firestore.collection('users').doc(firebaseUser.uid).set(updatedUser.toJson());
      await _saveUserToStorage(updatedUser);
      _currentUser = updatedUser;

      return updatedUser;
    } catch (e) {
      throw Exception('Account linking failed: $e');
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
      // This method is now deprecated in favor of specific social login methods
      // Redirect to appropriate method based on provider
      switch (provider.toLowerCase()) {
        case 'google':
          return await loginWithGoogle();
        case 'apple':
          return await loginWithApple();
        default:
          throw Exception('Unsupported social provider: $provider');
      }
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
      UserCredential? userCredential;
      
      if (password != null && email.isNotEmpty) {
        // Register with email and password
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      
      final firebaseUser = userCredential?.user ?? _auth.currentUser;
      
      if (firebaseUser == null) {
        throw Exception('Registration failed');
      }
      
      // Create new user account
      final user = UserAccount(
        id: firebaseUser.uid,
        phoneNumber: phoneNumber,
        email: email,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
        privacy: PrivacySettings(),
        security: SecuritySettings(),
      );
      
      // Save user data to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());
      
      // Save to storage
      await _saveUserToStorage(user);
      _currentUser = user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // OTP Methods
  String? _verificationId;
  
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otpCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification ID available');
      }
      
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
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
  Future<UserAccount> _getOrCreateUser(String phoneNumber, String firebaseUid) async {
    try {
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return UserAccount.fromJson(userData);
      } else {
        // Create new user
        final user = UserAccount(
          id: firebaseUid,
          phoneNumber: phoneNumber,
          username: 'user_${phoneNumber.substring(phoneNumber.length - 4)}',
          displayName: 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
          createdAt: DateTime.now(),
          privacy: PrivacySettings(),
          security: SecuritySettings(),
        );
        
        // Save to Firestore
        await _firestore.collection('users').doc(firebaseUid).set(user.toJson());
        
        return user;
      }
    } catch (e) {
      throw Exception('Failed to get or create user: $e');
    }
  }

  Future<UserAccount> _getOrCreateUserByEmail(String email, String firebaseUid) async {
    try {
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return UserAccount.fromJson(userData);
      } else {
        // Create new user
        final user = UserAccount(
          id: firebaseUid,
          phoneNumber: '+1234567890', // Mock phone
          email: email,
          username: email.split('@')[0],
          displayName: email.split('@')[0],
          createdAt: DateTime.now(),
          privacy: PrivacySettings(),
          security: SecuritySettings(),
        );
        
        // Save to Firestore
        await _firestore.collection('users').doc(firebaseUid).set(user.toJson());
        
        return user;
      }
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
    required String firebaseUid,
  }) async {
    try {
      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return UserAccount.fromJson(userData);
      } else {
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
          id: firebaseUid,
          phoneNumber: '+1234567890', // Mock phone - can be updated later
          email: email ?? '',
          username: name?.toLowerCase().replaceAll(' ', '_') ?? 'user_${firebaseUid.substring(0, 8)}',
          displayName: name ?? 'User ${firebaseUid.substring(0, 8)}',
          avatarUrl: avatarUrl,
          createdAt: DateTime.now(),
          socialLogins: [socialLogin],
          privacy: PrivacySettings(),
          security: SecuritySettings(),
        );
        
        // Save to Firestore
        await _firestore.collection('users').doc(firebaseUid).set(user.toJson());
        
        return user;
      }
    } catch (e) {
      throw Exception('Failed to get or create social user: $e');
    }
  }

  // Helper methods for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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