import 'package:ai_sdk_dart/ai_sdk_dart.dart';

class SocialMediaTools {
  static Map<String, Tool> get all {
    return {
      'create_post': _createPostTool,
      'schedule_post': _schedulePostTool,
      'generate_hashtags': _generateHashtagsTool,
      'optimize_content': _optimizeContentTool,
      'get_analytics': _analyticsTool,
      'get_trending_topics': _trendingTopicsTool,
    };
  }

  static final _createPostTool = tool<Map<String, dynamic>, String>(
    description: 'Create and optionally publish a social media post across one or more platforms',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'platforms': {
            'type': 'array',
            'items': {'type': 'string', 'enum': ['twitter', 'linkedin', 'instagram', 'facebook']},
            'description': 'Target platforms for the post',
          },
          'content': {
            'type': 'string',
            'description': 'The post content/text',
          },
          'mediaUrls': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'URLs of images or videos to attach',
          },
          'scheduledAt': {
            'type': 'string',
            'description': 'ISO 8601 datetime for scheduling. If omitted, post immediately',
          },
        },
        'required': ['platforms', 'content'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      final platforms = (input['platforms'] as List).cast<String>();
      final content = input['content'] as String;
      return 'Post created for ${platforms.join(", ")}: "$content"';
    },
  );

  static final _schedulePostTool = tool<Map<String, dynamic>, String>(
    description: 'Schedule a post for future publication on a specific platform',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'platform': {
            'type': 'string',
            'enum': ['twitter', 'linkedin', 'instagram', 'facebook'],
          },
          'content': {'type': 'string'},
          'scheduledAt': {
            'type': 'string',
            'description': 'ISO 8601 datetime for scheduling',
          },
          'mediaUrls': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
        'required': ['platform', 'content', 'scheduledAt'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      final platform = input['platform'] as String;
      final content = input['content'] as String;
      final scheduledAt = input['scheduledAt'] as String;
      return 'Post scheduled for $platform at $scheduledAt: "$content"';
    },
  );

  static final _generateHashtagsTool = tool<Map<String, dynamic>, String>(
    description: 'Generate relevant hashtags for content to maximize reach',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'content': {'type': 'string', 'description': 'The content to generate hashtags for'},
          'platform': {
            'type': 'string',
            'enum': ['twitter', 'linkedin', 'instagram', 'facebook'],
          },
          'count': {
            'type': 'integer',
            'description': 'Number of hashtags to generate (default: 5)',
          },
        },
        'required': ['content', 'platform'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      return 'Generated hashtags for "${input['content']}" on ${input['platform']}';
    },
  );

  static final _optimizeContentTool = tool<Map<String, dynamic>, String>(
    description: 'Optimize content for a specific platform\'s best practices, character limits, and audience',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'content': {'type': 'string', 'description': 'The content to optimize'},
          'platform': {
            'type': 'string',
            'enum': ['twitter', 'linkedin', 'instagram', 'facebook'],
          },
          'tone': {
            'type': 'string',
            'enum': ['professional', 'casual', 'engaging', 'educational', 'humorous'],
          },
        },
        'required': ['content', 'platform'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      return 'Optimized content for ${input['platform']} with ${input['tone'] ?? "default"} tone';
    },
  );

  static final _analyticsTool = tool<Map<String, dynamic>, String>(
    description: 'Get analytics and engagement metrics for posts or accounts',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'postId': {'type': 'string'},
          'platform': {
            'type': 'string',
            'enum': ['twitter', 'linkedin', 'instagram', 'facebook'],
          },
          'timeframe': {
            'type': 'string',
            'enum': ['7d', '30d', '90d'],
            'description': 'Analysis timeframe',
          },
        },
        'required': ['postId', 'platform'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      return 'Analytics for post ${input['postId']} on ${input['platform']}';
    },
  );

  static final _trendingTopicsTool = tool<Map<String, dynamic>, String>(
    description: 'Get current trending topics for a platform to inspire content',
    inputSchema: Schema<Map<String, dynamic>>(
      jsonSchema: {
        'type': 'object',
        'properties': {
          'platform': {
            'type': 'string',
            'enum': ['twitter', 'linkedin', 'instagram'],
          },
          'category': {
            'type': 'string',
            'description': 'Optional category filter',
          },
        },
        'required': ['platform'],
      },
      fromJson: (json) => json,
    ),
    execute: (input, options) async {
      return 'Trending topics for ${input['platform']}';
    },
  );
}
