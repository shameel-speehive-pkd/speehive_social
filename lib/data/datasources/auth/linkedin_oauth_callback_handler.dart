import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class LinkedInOAuthCallbackHandler {
  HttpServer? _server;
  final Completer<String?> _codeCompleter = Completer<String?>();

  Future<String?> startServerAndGetCode({int port = 34217}) async {
    try {
      _server = await HttpServer.bind('localhost', port);

      debugPrint('[LINKEDIN] Callback server started on port $port');

      _server!.listen((HttpRequest request) async {
        final uri = request.uri;
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          debugPrint('[LINKEDIN] OAuth error: $error');
          _sendResponse(request, 'Authentication failed: $error');
          if (!_codeCompleter.isCompleted) {
            _codeCompleter.complete(null);
          }
        } else if (code != null) {
          debugPrint('[LINKEDIN] Authorization code received');
          _sendResponse(request, 'Authentication successful! You can close this window.');
          if (!_codeCompleter.isCompleted) {
            _codeCompleter.complete(code);
          }
        } else {
          _sendResponse(request, 'Waiting for authentication...');
        }
      });

      return 'http://localhost:$port';
    } catch (e) {
      debugPrint('[LINKEDIN] Failed to start callback server: $e');
      return null;
    }
  }

  void _sendResponse(HttpRequest request, String message) {
    request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
    request.response.write('''
      <!DOCTYPE html>
      <html>
      <head>
        <title>LinkedIn Authentication</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f0f2f5; }
          .card { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
          h1 { color: #0077b5; margin-bottom: 20px; }
          p { color: #666; line-height: 1.6; }
          .success { color: #00a859; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>LinkedIn</h1>
          <p class="success">$message</p>
          <p>You can close this tab and return to the app.</p>
        </div>
      </body>
      </html>
    ''');
    request.response.close();
  }

  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
  }

  Future<String?> get authorizationCode => _codeCompleter.future;
}
