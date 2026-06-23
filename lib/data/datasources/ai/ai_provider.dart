import 'package:ai_sdk_provider/ai_sdk_provider.dart';
import 'package:ai_sdk_openai/ai_sdk_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:speehive_social/core/constants/app_constants.dart';

class AppAIProvider {
  late OpenAIProvider _provider;
  String _currentModel;

  AppAIProvider({
    String? apiKey,
    String? baseUrl,
    String? model,
  }) : _currentModel = model ?? ApiConfig.defaultModel {
    debugPrint('[CHAT] AppAIProvider: constructor - apiKey=${apiKey != null ? "SET (${apiKey.substring(0, apiKey.length > 8 ? 8 : apiKey.length)}...)" : "NULL"}, baseUrl=$baseUrl, model=$_currentModel');
    _provider = OpenAIProvider(
      apiKey: apiKey,
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
    );
  }

  LanguageModelV3 get languageModel {
    debugPrint('[CHAT] AppAIProvider.languageModel: model=$_currentModel, baseUrl=${_provider.baseUrl}');
    return _provider.call(_currentModel);
  }

  LanguageModelV3 get reasoningModel => _provider.call(ApiConfig.reasoningModel);

  void updateConfig({
    String? apiKey,
    String? baseUrl,
    String? model,
  }) {
    debugPrint('[CHAT] AppAIProvider.updateConfig: apiKey=${apiKey != null ? "SET" : "NULL"}, baseUrl=$baseUrl, model=$model');
    _provider = OpenAIProvider(
      apiKey: apiKey ?? _provider.apiKey,
      baseUrl: baseUrl ?? _provider.baseUrl,
    );
    if (model != null) {
      _currentModel = model;
    }
  }

  String? get apiKey => _provider.apiKey;
  String? get baseUrl => _provider.baseUrl;
  String get currentModel => _currentModel;
}
