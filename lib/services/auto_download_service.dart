import 'package:shared_preferences/shared_preferences.dart';

class AutoDownloadService {
  // ============================================================================
  // AUTO-DOWNLOAD SETTINGS
  // ============================================================================

  static const String _keyPhotos = 'auto_download_photos';
  static const String _keyVideos = 'auto_download_videos';
  static const String _keyAudios = 'auto_download_audios';
  static const String _keyDocuments = 'auto_download_documents';
  static const String _keyWifiOnly = 'auto_download_wifi_only';

  /// Get auto-download settings
  static Future<Map<String, bool>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'photos': prefs.getBool(_keyPhotos) ?? true,
      'videos': prefs.getBool(_keyVideos) ?? false,
      'audios': prefs.getBool(_keyAudios) ?? true,
      'documents': prefs.getBool(_keyDocuments) ?? false,
      'wifiOnly': prefs.getBool(_keyWifiOnly) ?? true,
    };
  }

  /// Update auto-download setting
  static Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (key) {
      case 'photos':
        await prefs.setBool(_keyPhotos, value);
        break;
      case 'videos':
        await prefs.setBool(_keyVideos, value);
        break;
      case 'audios':
        await prefs.setBool(_keyAudios, value);
        break;
      case 'documents':
        await prefs.setBool(_keyDocuments, value);
        break;
      case 'wifiOnly':
        await prefs.setBool(_keyWifiOnly, value);
        break;
    }
  }

  /// Check if media should auto-download
  static Future<bool> shouldAutoDownload(String mediaType) async {
    final settings = await getSettings();
    
    switch (mediaType) {
      case 'image':
        return settings['photos'] ?? true;
      case 'video':
        return settings['videos'] ?? false;
      case 'audio':
        return settings['audios'] ?? true;
      case 'document':
        return settings['documents'] ?? false;
      default:
        return false;
    }
  }
}
