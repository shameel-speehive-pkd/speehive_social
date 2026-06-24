import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/auth/linkedin_oauth_callback_handler.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';

class LinkedInTokens {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  const LinkedInTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory LinkedInTokens.fromJson(Map<String, dynamic> json) {
    return LinkedInTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class LinkedInOAuthService {
  final SecureStorageService _storage;
  LinkedInTokens? _tokens;
  LinkedInOAuthCallbackHandler? _callbackHandler;

  LinkedInOAuthService(this._storage);

  Uri getAuthorizationUrl({String? redirectUri}) {
    final params = {
      'response_type': 'code',
      'client_id': LinkedInConfig.clientId,
      'redirect_uri': redirectUri ?? LinkedInConfig.redirectUri,
      'scope': LinkedInConfig.scopes.join(' '),
      'state': 'speehive_linkedin',
    };

    return Uri.parse(LinkedInConfig.authorizationEndpoint)
        .replace(queryParameters: params);
  }

  Future<String?> startCallbackServer({int port = 34217}) async {
    _callbackHandler = LinkedInOAuthCallbackHandler();
    return await _callbackHandler!.startServerAndGetCode(port: port);
  }

  Future<String?> waitForAuthorizationCode() async {
    if (_callbackHandler == null) return null;
    return await _callbackHandler!.authorizationCode;
  }

  Future<void> stopCallbackServer() async {
    await _callbackHandler?.stopServer();
    _callbackHandler = null;
  }

  Future<LinkedInTokens?> exchangeCodeForTokens(String code) async {
    try {
      final response = await http.post(
        Uri.parse(LinkedInConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': LinkedInConfig.redirectUri,
          'client_id': LinkedInConfig.clientId,
          'client_secret': LinkedInConfig.clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tokens = LinkedInTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        await _saveTokens(_tokens!);
        debugPrint('[LINKEDIN] OAuth tokens obtained successfully');
        return _tokens;
      } else {
        debugPrint('[LINKEDIN] Token exchange failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[LINKEDIN] Token exchange error: $e');
      return null;
    }
  }

  Future<LinkedInTokens?> refreshAccessToken() async {
    if (_tokens == null) {
      _tokens = await _loadTokens();
    }
    if (_tokens == null || _tokens!.refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse(LinkedInConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _tokens!.refreshToken,
          'client_id': LinkedInConfig.clientId,
          'client_secret': LinkedInConfig.clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tokens = LinkedInTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? _tokens!.refreshToken,
          expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        await _saveTokens(_tokens!);
        debugPrint('[LINKEDIN] Token refreshed successfully');
        return _tokens;
      } else {
        debugPrint('[LINKEDIN] Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[LINKEDIN] Token refresh error: $e');
      return null;
    }
  }

  Future<String?> getValidAccessToken() async {
    if (_tokens == null) {
      _tokens = await _loadTokens();
    }
    if (_tokens == null) return null;

    if (_tokens!.isExpired) {
      final refreshed = await refreshAccessToken();
      if (refreshed == null) return null;
      _tokens = refreshed;
    }

    return _tokens!.accessToken;
  }

  Future<bool> isAuthenticated() async {
    final token = await getValidAccessToken();
    return token != null;
  }

  Future<String?> getPersonUrn() async {
    final token = await getValidAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${LinkedInConfig.apiBaseUrl}/v2/userinfo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sub = data['sub'] as String;
        return 'urn:li:person:$sub';
      }
      return null;
    } catch (e) {
      debugPrint('[LINKEDIN] Failed to get person URN: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _tokens = null;
    await _storage.deleteSecure(AppConstants.linkedinTokensKey);
  }

  Future<void> _saveTokens(LinkedInTokens tokens) async {
    await _storage.saveSecure(
      AppConstants.linkedinTokensKey,
      json.encode(tokens.toJson()),
    );
  }

  Future<LinkedInTokens?> _loadTokens() async {
    final data = await _storage.readSecure(AppConstants.linkedinTokensKey);
    if (data == null) return null;
    try {
      return LinkedInTokens.fromJson(json.decode(data));
    } catch (e) {
      return null;
    }
  }
}
