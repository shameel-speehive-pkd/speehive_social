import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/core/services/event_check_service.dart';
import 'package:speehive_social/data/datasources/ai/ai_provider.dart';
import 'package:speehive_social/data/datasources/auth/google_calendar_oauth_service.dart';
import 'package:speehive_social/data/datasources/auth/linkedin_oauth_service.dart';
import 'package:speehive_social/data/datasources/auth/outlook_oauth_service.dart';
import 'package:speehive_social/data/datasources/google/google_calendar_datasource.dart';
import 'package:speehive_social/data/datasources/local/draft_storage_service.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';
import 'package:speehive_social/data/datasources/linkedin/linkedin_post_datasource.dart';
import 'package:speehive_social/data/datasources/outlook/outlook_calendar_datasource.dart';
import 'package:speehive_social/data/repositories/chat_repository_impl.dart';
import 'package:speehive_social/domain/repositories/chat_repository.dart';
import 'package:speehive_social/domain/usecases/generate_text.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final aiProvider = Provider<AppAIProvider>((ref) {
  throw UnimplementedError('Must be overridden in main()');
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(aiProvider));
});

final generateTextUseCaseProvider = Provider<GenerateTextUseCase>((ref) {
  return GenerateTextUseCase(ref.watch(chatRepositoryProvider));
});

// Outlook providers
final outlookOAuthServiceProvider = Provider<OutlookOAuthService>((ref) {
  return OutlookOAuthService(ref.watch(secureStorageProvider));
});

final outlookCalendarDatasourceProvider = Provider<OutlookCalendarDatasource>((ref) {
  return OutlookCalendarDatasource(ref.watch(outlookOAuthServiceProvider));
});

// LinkedIn providers
final linkedinOAuthServiceProvider = Provider<LinkedInOAuthService>((ref) {
  return LinkedInOAuthService(ref.watch(secureStorageProvider));
});

final linkedinPostDatasourceProvider = Provider<LinkedInPostDatasource>((ref) {
  return LinkedInPostDatasource(ref.watch(linkedinOAuthServiceProvider));
});

// Google Calendar providers
final googleCalendarOAuthServiceProvider = Provider<GoogleCalendarOAuthService>((ref) {
  return GoogleCalendarOAuthService(ref.watch(secureStorageProvider));
});

final googleCalendarDatasourceProvider = Provider<GoogleCalendarDatasource>((ref) {
  return GoogleCalendarDatasource(ref.watch(googleCalendarOAuthServiceProvider));
});

// Draft storage provider
final draftStorageServiceProvider = Provider<DraftStorageService>((ref) {
  return DraftStorageService(ref.watch(secureStorageProvider));
});

// Event check service provider
final eventCheckServiceProvider = Provider<EventCheckService>((ref) {
  return EventCheckService(
    googleCalendarDatasource: ref.watch(googleCalendarDatasourceProvider),
    outlookDatasource: ref.watch(outlookCalendarDatasourceProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

Future<ProviderContainer> initProviders() async {
  final storage = SecureStorageService();

  final savedApiKey = await storage.getApiKey();
  final savedBaseUrl = await storage.getBaseUrl();
  final savedModel = await storage.getModel();

  final effectiveApiKey = savedApiKey ?? ApiConfig.apiKey;

  final aiProviderInstance = AppAIProvider(
    apiKey: effectiveApiKey,
    baseUrl: savedBaseUrl ?? ApiConfig.baseUrl,
    model: savedModel ?? ApiConfig.defaultModel,
  );

  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      aiProvider.overrideWithValue(aiProviderInstance),
    ],
  );

  return container;
}
