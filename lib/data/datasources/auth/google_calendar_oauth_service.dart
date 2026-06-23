import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';

class GoogleCalendarOAuthService {
  final SecureStorageService _storage;
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;
  GoogleSignInClientAuthorization? _authorization;

  GoogleCalendarOAuthService(this._storage)
      : _googleSignIn = GoogleSignIn.instance;

  Future<void> initialize() async {
    await _googleSignIn.initialize(
      clientId: GoogleCalendarConfig.clientId.isNotEmpty
          ? GoogleCalendarConfig.clientId
          : null,
    );
    _googleSignIn.authenticationEvents.listen((event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn():
          _currentUser = event.user;
          break;
        case GoogleSignInAuthenticationEventSignOut():
          _currentUser = null;
          _authorization = null;
          break;
      }
    });
  }

  Future<bool> signIn() async {
    try {
      await initialize();
      final account = await _googleSignIn.authenticate();
      _currentUser = account;

      // Try to get existing authorization
      _authorization =
          await account.authorizationClient.authorizationForScopes(
        GoogleCalendarConfig.scopes,
      );

      // If not authorized, request authorization
      if (_authorization == null) {
        _authorization =
            await account.authorizationClient.authorizeScopes(
          GoogleCalendarConfig.scopes,
        );
      }

      if (_authorization != null) {
        await _saveTokens();
        debugPrint('[GOOGLE_CALENDAR] Signed in successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('[GOOGLE_CALENDAR] Sign in error: $e');
      return false;
    }
  }

  Future<auth.AuthClient?> getAuthenticatedClient() async {
    if (_currentUser == null) {
      await _loadTokens();
    }

    if (_currentUser == null) return null;

    // Try to get existing authorization
    _authorization =
        await _currentUser!.authorizationClient.authorizationForScopes(
      GoogleCalendarConfig.scopes,
    );

    if (_authorization == null) {
      // Need to authorize
      _authorization =
          await _currentUser!.authorizationClient.authorizeScopes(
        GoogleCalendarConfig.scopes,
      );
    }

    if (_authorization == null) return null;

    return _authorization!.authClient(
      scopes: GoogleCalendarConfig.scopes,
    );
  }

  Future<bool> isAuthenticated() async {
    if (_currentUser == null) {
      await _loadTokens();
    }
    return _currentUser != null;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authorization = null;
    await _googleSignIn.disconnect();
    await _storage.deleteSecure(AppConstants.googleTokensKey);
    debugPrint('[GOOGLE_CALENDAR] Signed out');
  }

  Future<void> _saveTokens() async {
    // Save a marker that user is authenticated
    // The actual tokens are managed by GoogleSignIn internally
    await _storage.saveSecure(
      AppConstants.googleTokensKey,
      _currentUser?.email ?? '',
    );
  }

  Future<void> _loadTokens() async {
    try {
      final email = await _storage.readSecure(AppConstants.googleTokensKey);
      if (email != null && email.isNotEmpty) {
        // Try lightweight authentication to restore session
        await initialize();
        final account = await _googleSignIn.attemptLightweightAuthentication();
        if (account != null) {
          _currentUser = account;
          _authorization =
              await account.authorizationClient.authorizationForScopes(
            GoogleCalendarConfig.scopes,
          );
        }
      }
    } catch (e) {
      debugPrint('[GOOGLE_CALENDAR] Error loading tokens: $e');
    }
  }
}
