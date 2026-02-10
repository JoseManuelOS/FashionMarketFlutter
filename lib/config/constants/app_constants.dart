/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Fashion Market';
  static const String appVersion = '1.0.0';

  // API & Backend - Supabase credentials from FashionStore
  static const String supabaseUrl = 'https://sjalsswfvoshyppbbhtv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqYWxzc3dmdm9zaHlwcGJiaHR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NTQ3MzMsImV4cCI6MjA4MzQzMDczM30.5HLqcZmKTkoDbwbVnBPxTkdt95QD7nly2m7NscjaCjU';

  // FashionStore API (backend desplegado)
  static const String fashionStoreBaseUrl = 'http://j4o0084kg0ssoo0wc0ocw0g8.victoriafp.online';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;

  // Image Placeholders
  static const String productPlaceholder = 'assets/images/product_placeholder.png';
  static const String userPlaceholder = 'assets/images/user_placeholder.png';
}
