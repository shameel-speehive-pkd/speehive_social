import 'package:speehive_social/domain/entities/social_account.dart';
import 'package:speehive_social/domain/repositories/chat_repository.dart';

abstract class SocialRepository {
  Future<Result<List<SocialAccount>>> getConnectedAccounts();

  Future<Result<SocialAccount>> connectAccount(SocialPlatform platform);

  Future<Result<void>> disconnectAccount(String accountId);

  Future<Result<Map<String, dynamic>>> createPost({
    required String accountId,
    required String content,
    List<String>? mediaUrls,
    DateTime? scheduledAt,
  });

  Future<Result<Map<String, dynamic>>> getAnalytics({
    required String accountId,
    required DateTime from,
    required DateTime to,
  });
}
