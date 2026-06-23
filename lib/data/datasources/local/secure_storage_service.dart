import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speehive_social/core/constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: AppConstants.apiKeyStorageKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: AppConstants.apiKeyStorageKey);
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    await _storage.write(key: AppConstants.baseUrlStorageKey, value: baseUrl);
  }

  Future<String?> getBaseUrl() async {
    return await _storage.read(key: AppConstants.baseUrlStorageKey);
  }

  Future<void> saveModel(String model) async {
    await _storage.write(key: AppConstants.modelStorageKey, value: model);
  }

  Future<String?> getModel() async {
    return await _storage.read(key: AppConstants.modelStorageKey);
  }

  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
