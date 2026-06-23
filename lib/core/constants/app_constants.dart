import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.opencode.ai/v1';
  static String get defaultModel => dotenv.env['DEFAULT_MODEL'] ?? 'gpt-4o-mini';
  static String get reasoningModel => dotenv.env['REASONING_MODEL'] ?? 'o4-mini';
  static const int maxToolSteps = 10;
  static const Duration requestTimeout = Duration(seconds: 60);
}

class OutlookConfig {
  static String get clientId => dotenv.env['OUTLOOK_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['OUTLOOK_CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['OUTLOOK_REDIRECT_URI'] ?? 'http://localhost';
  static String get tenantId => dotenv.env['OUTLOOK_TENANT_ID'] ?? 'common';

  static const List<String> scopes = [
    'Calendars.Read',
    'Calendars.ReadBasic',
    'offline_access',
  ];

  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';

  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

  static String get graphBaseUrl => 'https://graph.microsoft.com/v1.0';
}

class LinkedInConfig {
  static String get clientId => dotenv.env['LINKEDIN_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['LINKEDIN_CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['LINKEDIN_REDIRECT_URI'] ?? 'http://localhost';

  static const List<String> scopes = [
    'openid',
    'profile',
    'w_member_social',
  ];

  static const String authorizationEndpoint = 'https://www.linkedin.com/oauth/v2/authorization';
  static const String tokenEndpoint = 'https://www.linkedin.com/oauth/v2/accessToken';
  static const String apiBaseUrl = 'https://api.linkedin.com';
}

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}

class GoogleCalendarConfig {
  static String get clientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get webClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get webClientSecret => dotenv.env['GOOGLE_WEB_CLIENT_SECRET'] ?? '';
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
  ];
}

class AppConstants {
  static const String appName = 'Speehive Social';
  static const String appVersion = '1.0.0';
  static const String secureStorageKey = 'speehive_secure';
  static const String apiKeyStorageKey = 'openai_api_key';
  static const String baseUrlStorageKey = 'api_base_url';
  static const String modelStorageKey = 'selected_model';
  static const String outlookTokensKey = 'outlook_tokens';
  static const String linkedinTokensKey = 'linkedin_tokens';
  static const String googleTokensKey = 'google_tokens';
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
