class ApiConfig {
  // Backend server configuration
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000',
  );
  
  static const String apiUrl = '$baseUrl/api';
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:5000',
  );
  
  // API Endpoints
  static const String authEndpoint = '$apiUrl/auth';
  static const String usersEndpoint = '$apiUrl/users';
  static const String chatEndpoint = '$apiUrl/chat';
  static const String paymentsEndpoint = '$apiUrl/payments';
  static const String ecommerceEndpoint = '$apiUrl/ecommerce';
  static const String deliveryEndpoint = '$apiUrl/delivery';
  static const String socialEndpoint = '$apiUrl/social';
  static const String streamingEndpoint = '$apiUrl/streaming';
  static const String gamesEndpoint = '$apiUrl/games';
  static const String professionalEndpoint = '$apiUrl/professional';
  static const String datingEndpoint = '$apiUrl/dating';
  static const String filesEndpoint = '$apiUrl/files';
  static const String notificationsEndpoint = '$apiUrl/notifications';
  
  // Timeout configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}