class ApiConfig {
  // AI Service API Keys - In production, store in secure environment variables
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY', 
    defaultValue: 'sk-your-openai-api-key-here');
  
  static const String stabilityAIApiKey = String.fromEnvironment('STABILITY_AI_API_KEY',
    defaultValue: 'sk-your-stability-ai-api-key-here');
  
  static const String elevenLabsApiKey = String.fromEnvironment('ELEVENLABS_API_KEY',
    defaultValue: 'your-elevenlabs-api-key-here');
  
  // API Base URLs
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String stabilityAIBaseUrl = 'https://api.stability.ai/v1';
  static const String elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  
  // E-commerce API Keys
  static const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_your-stripe-publishable-key-here');
  
  static const String stripeSecretKey = String.fromEnvironment('STRIPE_SECRET_KEY',
    defaultValue: 'sk_test_your-stripe-secret-key-here');
  
  // Delivery Service API Keys
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
    defaultValue: 'your-google-maps-api-key-here');
  
  // Push Notification Keys
  static const String fcmServerKey = String.fromEnvironment('FCM_SERVER_KEY',
    defaultValue: 'your-fcm-server-key-here');
  
  // Video/Streaming API Keys
  static const String youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY',
    defaultValue: 'your-youtube-api-key-here');
  
  static const String vimeoApiKey = String.fromEnvironment('VIMEO_API_KEY',
    defaultValue: 'your-vimeo-api-key-here');
  
  // Social Media API Keys
  static const String twitterApiKey = String.fromEnvironment('TWITTER_API_KEY',
    defaultValue: 'your-twitter-api-key-here');
  
  static const String instagramApiKey = String.fromEnvironment('INSTAGRAM_API_KEY',
    defaultValue: 'your-instagram-api-key-here');
  
  // Professional Network API Keys
  static const String linkedinApiKey = String.fromEnvironment('LINKEDIN_API_KEY',
    defaultValue: 'your-linkedin-api-key-here');
  
  // Game Store API Keys
  static const String googlePlayApiKey = String.fromEnvironment('GOOGLE_PLAY_API_KEY',
    defaultValue: 'your-google-play-api-key-here');
  
  static const String appStoreApiKey = String.fromEnvironment('APP_STORE_API_KEY',
    defaultValue: 'your-app-store-api-key-here');
  
  // Check if API keys are configured
  static bool get isOpenAIConfigured => openAIApiKey.startsWith('sk-') && openAIApiKey != 'sk-your-openai-api-key-here';
  static bool get isStabilityAIConfigured => stabilityAIApiKey.startsWith('sk-') && stabilityAIApiKey != 'sk-your-stability-ai-api-key-here';
  static bool get isElevenLabsConfigured => elevenLabsApiKey.isNotEmpty && elevenLabsApiKey != 'your-elevenlabs-api-key-here';
  static bool get isStripeConfigured => stripePublishableKey.startsWith('pk_') && stripePublishableKey != 'pk_test_your-stripe-publishable-key-here';
  static bool get isGoogleMapsConfigured => googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'your-google-maps-api-key-here';
}