import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/ai/ai_provider.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';
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
