import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';

class OutlookTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const OutlookTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory OutlookTokens.fromJson(Map<String, dynamic> json) {
    return OutlookTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class OutlookOAuthService {
  final SecureStorageService _storage;
  OutlookTokens? _tokens;

  OutlookOAuthService(this._storage);

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (_) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  Uri getAuthorizationUrl() {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    final params = {
      'client_id': OutlookConfig.clientId,
      'response_type': 'code',
      'redirect_uri': OutlookConfig.redirectUri,
      'scope': OutlookConfig.scopes.join(' '),
      'response_mode': 'query',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': codeVerifier,
    };

    final uri = Uri.parse(OutlookConfig.authorizationEndpoint)
        .replace(queryParameters: params);
    return uri;
  }

  Future<OutlookTokens?> exchangeCodeForTokens(String code, String state) async {
    try {
      final response = await http.post(
        Uri.parse(OutlookConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': OutlookConfig.clientId,
          'client_secret': OutlookConfig.clientSecret,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': OutlookConfig.redirectUri,
          'scope': OutlookConfig.scopes.join(' '),
          'code_verifier': state,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tokens = OutlookTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        await _saveTokens(_tokens!);
        debugPrint('[OUTLOOK] OAuth tokens obtained successfully');
        return _tokens;
      } else {
        debugPrint('[OUTLOOK] Token exchange failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[OUTLOOK] Token exchange error: $e');
      return null;
    }
  }

  Future<OutlookTokens?> refreshAccessToken() async {
    if (_tokens == null) {
      _tokens = await _loadTokens();
    }
    if (_tokens == null) return null;

    try {
      final response = await http.post(
        Uri.parse(OutlookConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': OutlookConfig.clientId,
          'client_secret': OutlookConfig.clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': _tokens!.refreshToken,
          'scope': OutlookConfig.scopes.join(' '),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tokens = OutlookTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? _tokens!.refreshToken,
          expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'])),
        );
        await _saveTokens(_tokens!);
        debugPrint('[OUTLOOK] Token refreshed successfully');
        return _tokens;
      } else {
        debugPrint('[OUTLOOK] Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[OUTLOOK] Token refresh error: $e');
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

  Future<void> logout() async {
    _tokens = null;
    await _storage.deleteSecure(AppConstants.outlookTokensKey);
  }

  Future<void> _saveTokens(OutlookTokens tokens) async {
    await _storage.saveSecure(
      AppConstants.outlookTokensKey,
      json.encode(tokens.toJson()),
    );
  }

  Future<OutlookTokens?> _loadTokens() async {
    final data = await _storage.readSecure(AppConstants.outlookTokensKey);
    if (data == null) return null;
    try {
      return OutlookTokens.fromJson(json.decode(data));
    } catch (e) {
      return null;
    }
  }
}
