import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.opencode.ai/v1';
  static String get defaultModel => dotenv.env['DEFAULT_MODEL'] ?? 'gpt-4o-mini';
  static String get reasoningModel => dotenv.env['REASONING_MODEL'] ?? 'o4-mini';
  static const int maxToolSteps = 10;
  static const Duration requestTimeout = Duration(seconds: 60);
}

class AppConstants {
  static const String appName = 'Speehive Social';
  static const String appVersion = '1.0.0';
  static const String secureStorageKey = 'speehive_secure';
  static const String apiKeyStorageKey = 'openai_api_key';
  static const String baseUrlStorageKey = 'api_base_url';
  static const String modelStorageKey = 'selected_model';
}

class PlatformConstants {
  static const List<String> supportedPlatforms = [
    'twitter',
    'linkedin',
    'instagram',
    'facebook',
  ];
  static const Map<String, String> platformIcons = {
    'twitter': 'assets/icons/twitter.svg',
    'linkedin': 'assets/icons/linkedin.svg',
    'instagram': 'assets/icons/instagram.svg',
    'facebook': 'assets/icons/facebook.svg',
  };
}
