import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static String? _accessToken;
  static String? _refreshToken;
  
  // Get access token
  static Future<String?> getAccessToken() async {
    if (_accessToken == null) {
      await init();
    }
    return _accessToken;
  }
  
  // Initialize tokens from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }
  
  // Save tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }
  
  // Clear tokens
  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
  
  // Get headers with authentication
  static Map<String, String> get _headers {
    if (_accessToken != null) {
      return ApiConfig.getAuthHeaders(_accessToken!);
    }
    return ApiConfig.headers;
  }
  
  // HTTP GET request
  static Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // HTTP POST request
  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // HTTP PUT request
  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(
            Uri.parse(endpoint),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // HTTP DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse(endpoint), headers: _headers)
          .timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Upload file
  static Future<dynamic> uploadFile(String endpoint, String filePath, {String fieldName = 'file'}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      final streamResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Handle response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      _refreshAccessToken();
      throw ApiException('Unauthorized', response.statusCode);
    } else {
      final error = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      throw ApiException(
        error?['error']?['message'] ?? 'Request failed',
        response.statusCode,
      );
    }
  }
  
  // Handle errors
  static Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error.toString().contains('TimeoutException')) {
      return ApiException('Request timeout', 0);
    } else if (error.toString().contains('SocketException')) {
      return ApiException('No internet connection', 0);
    } else {
      return ApiException(error.toString(), 0);
    }
  }
  
  // Refresh access token
  static Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) return;
    
    try {
      final response = await post(
        '${ApiConfig.authEndpoint}/refresh',
        body: {'refreshToken': _refreshToken},
      );
      
      if (response['tokens'] != null) {
        await saveTokens(
          response['tokens']['accessToken'],
          response['tokens']['refreshToken'],
        );
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await clearTokens();
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}