import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_foundations.dart';

class AppSettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _complianceKey = 'compliance_settings';
  static const String _permissionsKey = 'app_permissions';
  static const String _onboardingKey = 'onboarding_completed';

  // Singleton
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  AppSettings? _appSettings;
  ComplianceSettings? _complianceSettings;
  Map<String, bool> _permissions = {};
  bool _onboardingCompleted = false;

  // Getters
  AppSettings? get appSettings => _appSettings;
  ComplianceSettings? get complianceSettings => _complianceSettings;
  Map<String, bool> get permissions => _permissions;
  bool get onboardingCompleted => _onboardingCompleted;

  // Initialize service
  Future<void> initialize() async {
    await _loadSettingsFromStorage();
    await _loadComplianceFromStorage();
    await _loadPermissionsFromStorage();
    await _loadOnboardingFromStorage();
  }

  // Language & Localization
  Future<void> setLanguage(String languageCode) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: languageCode,
        region: _appSettings!.region,
        isRTL: _isRTLLanguage(languageCode),
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to set language: $e');
    }
  }

  Future<void> setRegion(String regionCode) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: regionCode,
        isRTL: _appSettings!.isRTL,
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to set region: $e');
    }
  }

  // Theme & Accessibility
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: _appSettings!.region,
        isRTL: _appSettings!.isRTL,
        themeMode: themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: themeMode == ThemeMode.system,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to set theme: $e');
    }
  }

  Future<void> setFontSize(double fontSize) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: _appSettings!.region,
        isRTL: _appSettings!.isRTL,
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: fontSize,
        isLargeText: fontSize > 18.0,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to set font size: $e');
    }
  }

  Future<void> setAccessibilitySettings({
    bool? isScreenReaderEnabled,
    bool? isHighContrast,
    bool? isReduceMotion,
  }) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: _appSettings!.region,
        isRTL: _appSettings!.isRTL,
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled:
            isScreenReaderEnabled ?? _appSettings!.isScreenReaderEnabled,
        isHighContrast: isHighContrast ?? _appSettings!.isHighContrast,
        isReduceMotion: isReduceMotion ?? _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to set accessibility settings: $e');
    }
  }

  // Permissions
  Future<void> requestPermission(String permission) async {
    try {
      // In real app, request actual permission
      await Future.delayed(const Duration(milliseconds: 500));

      _permissions[permission] = true;
      await _savePermissionsToStorage();
    } catch (e) {
      throw Exception('Failed to request permission: $e');
    }
  }

  Future<bool> checkPermission(String permission) async {
    try {
      // In real app, check actual permission status
      await Future.delayed(const Duration(milliseconds: 100));

      return _permissions[permission] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> revokePermission(String permission) async {
    try {
      _permissions[permission] = false;
      await _savePermissionsToStorage();
    } catch (e) {
      throw Exception('Failed to revoke permission: $e');
    }
  }

  // Onboarding
  Future<void> completeOnboarding() async {
    try {
      _onboardingCompleted = true;
      await _saveOnboardingToStorage();
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  Future<void> resetOnboarding() async {
    try {
      _onboardingCompleted = false;
      await _saveOnboardingToStorage();
    } catch (e) {
      throw Exception('Failed to reset onboarding: $e');
    }
  }

  // Notifications
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: _appSettings!.region,
        isRTL: _appSettings!.isRTL,
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: settings,
        cache: _appSettings!.cache,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  // Cache Management
  Future<void> updateCacheSettings(CacheSettings settings) async {
    try {
      _appSettings ??= _getDefaultSettings();

      final updatedSettings = AppSettings(
        language: _appSettings!.language,
        region: _appSettings!.region,
        isRTL: _appSettings!.isRTL,
        themeMode: _appSettings!.themeMode,
        isDarkMode: _appSettings!.isDarkMode,
        isSystemTheme: _appSettings!.isSystemTheme,
        fontSize: _appSettings!.fontSize,
        isLargeText: _appSettings!.isLargeText,
        isScreenReaderEnabled: _appSettings!.isScreenReaderEnabled,
        isHighContrast: _appSettings!.isHighContrast,
        isReduceMotion: _appSettings!.isReduceMotion,
        notifications: _appSettings!.notifications,
        cache: settings,
        customSettings: _appSettings!.customSettings,
      );

      await _saveSettingsToStorage(updatedSettings);
      _appSettings = updatedSettings;
    } catch (e) {
      throw Exception('Failed to update cache settings: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      // In real app, clear actual cache
      await Future.delayed(const Duration(seconds: 1));

      // Can't use context here (no BuildContext available in service)
      // Return success instead
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  // Compliance
  Future<void> updateComplianceSettings(ComplianceSettings settings) async {
    try {
      await _saveComplianceToStorage(settings);
      _complianceSettings = settings;
    } catch (e) {
      throw Exception('Failed to update compliance settings: $e');
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      // In real app, generate comprehensive data export
      await Future.delayed(const Duration(seconds: 2));

      return {
        'settings': _appSettings?.toJson(),
        'compliance': _complianceSettings?.toJson(),
        'permissions': _permissions,
        'onboardingCompleted': _onboardingCompleted,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Private Methods
  AppSettings _getDefaultSettings() {
    return AppSettings(
      notifications: NotificationSettings(),
      cache: CacheSettings(),
    );
  }

  bool _isRTLLanguage(String languageCode) {
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(languageCode);
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        _appSettings = AppSettings.fromJson(settingsMap);
      } else {
        _appSettings = _getDefaultSettings();
      }
    } catch (e) {
      print('Failed to load settings from storage: $e');
      _appSettings = _getDefaultSettings();
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

  Future<void> _loadPermissionsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString(_permissionsKey);

      if (permissionsJson != null) {
        final permissionsMap = jsonDecode(permissionsJson);
        _permissions = Map<String, bool>.from(permissionsMap);
      } else {
        _permissions = {};
      }
    } catch (e) {
      print('Failed to load permissions from storage: $e');
      _permissions = {};
    }
  }

  Future<void> _savePermissionsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = jsonEncode(_permissions);
      await prefs.setString(_permissionsKey, permissionsJson);
    } catch (e) {
      print('Failed to save permissions to storage: $e');
    }
  }

  Future<void> _loadOnboardingFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      print('Failed to load onboarding from storage: $e');
      _onboardingCompleted = false;
    }
  }

  Future<void> _saveOnboardingToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, _onboardingCompleted);
    } catch (e) {
      print('Failed to save onboarding to storage: $e');
    }
  }
}
