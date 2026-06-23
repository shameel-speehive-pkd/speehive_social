import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/auth/linkedin_oauth_service.dart';

class LinkedInPostResult {
  final String? postId;
  final bool success;
  final String? error;

  const LinkedInPostResult({
    this.postId,
    this.success = false,
    this.error,
  });
}

class LinkedInPostDatasource {
  final LinkedInOAuthService _oauthService;

  LinkedInPostDatasource(this._oauthService);

  Future<LinkedInPostResult> createPost({
    required String content,
    String? authorUrn,
    String visibility = 'PUBLIC',
  }) async {
    final token = await _oauthService.getValidAccessToken();
    if (token == null) {
      return const LinkedInPostResult(
        success: false,
        error: 'Not authenticated with LinkedIn',
      );
    }

    final personUrn = authorUrn ?? await _oauthService.getPersonUrn();
    if (personUrn == null) {
      return const LinkedInPostResult(
        success: false,
        error: 'Could not retrieve LinkedIn person URN',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('${LinkedInConfig.apiBaseUrl}/rest/posts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'X-Restli-Protocol-Version': '2.0.0',
          'Linkedin-Version': '202401',
        },
        body: json.encode({
          'author': personUrn,
          'commentary': content,
          'visibility': visibility,
          'distribution': {
            'feedDistribution': 'MAIN_FEED',
            'targetEntities': [],
            'thirdPartyDistributionChannels': [],
          },
          'lifecycleState': 'PUBLISHED',
        }),
      );

      if (response.statusCode == 201) {
        final postId = response.headers['x-restli-id'];
        debugPrint('[LINKEDIN] Post created successfully: $postId');
        return LinkedInPostResult(
          postId: postId,
          success: true,
        );
      } else if (response.statusCode == 401) {
        final refreshed = await _oauthService.refreshAccessToken();
        if (refreshed != null) {
          return createPost(
            content: content,
            authorUrn: authorUrn,
            visibility: visibility,
          );
        }
        return const LinkedInPostResult(
          success: false,
          error: 'Authentication expired. Please reconnect LinkedIn.',
        );
      } else {
        debugPrint('[LINKEDIN] Post creation failed: ${response.statusCode} ${response.body}');
        return LinkedInPostResult(
          success: false,
          error: 'Failed to create post: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[LINKEDIN] Post creation error: $e');
      return LinkedInPostResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getRecentPosts({int count = 10}) async {
    final token = await _oauthService.getValidAccessToken();
    if (token == null) return [];

    final personUrn = await _oauthService.getPersonUrn();
    if (personUrn == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${LinkedInConfig.apiBaseUrl}/rest/posts')
            .replace(queryParameters: {
          'q': 'authors',
          'authors': 'List($personUrn)',
          'count': count.toString(),
          'sortBy': 'LAST_MODIFIED',
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'X-Restli-Protocol-Version': '2.0.0',
          'Linkedin-Version': '202401',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['elements'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('[LINKEDIN] Failed to get recent posts: $e');
      return [];
    }
  }
}
