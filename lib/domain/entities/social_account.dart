import 'package:equatable/equatable.dart';

enum SocialPlatform { twitter, linkedin, instagram, facebook }

extension SocialPlatformExtension on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.twitter:
        return 'Twitter / X';
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
    }
  }

  String get key {
    switch (this) {
      case SocialPlatform.twitter:
        return 'twitter';
      case SocialPlatform.linkedin:
        return 'linkedin';
      case SocialPlatform.instagram:
        return 'instagram';
      case SocialPlatform.facebook:
        return 'facebook';
    }
  }
}

class SocialAccount extends Equatable {
  final String id;
  final SocialPlatform platform;
  final String displayName;
  final String? username;
  final String? profileImageUrl;
  final bool isConnected;
  final DateTime? lastSynced;

  const SocialAccount({
    required this.id,
    required this.platform,
    required this.displayName,
    this.username,
    this.profileImageUrl,
    this.isConnected = false,
    this.lastSynced,
  });

  SocialAccount copyWith({
    String? id,
    SocialPlatform? platform,
    String? displayName,
    String? username,
    String? profileImageUrl,
    bool? isConnected,
    DateTime? lastSynced,
  }) {
    return SocialAccount(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isConnected: isConnected ?? this.isConnected,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        platform,
        displayName,
        username,
        profileImageUrl,
        isConnected,
        lastSynced,
      ];
}
