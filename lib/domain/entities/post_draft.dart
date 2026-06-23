import 'package:equatable/equatable.dart';

enum DraftStatus { pending, approved, rejected, published }

class PostDraft extends Equatable {
  final String id;
  final String content;
  final String? eventTitle;
  final String? eventDescription;
  final DateTime createdAt;
  final DraftStatus status;
  final String? linkedinPostId;
  final DateTime? publishedAt;

  const PostDraft({
    required this.id,
    required this.content,
    this.eventTitle,
    this.eventDescription,
    required this.createdAt,
    this.status = DraftStatus.pending,
    this.linkedinPostId,
    this.publishedAt,
  });

  PostDraft copyWith({
    String? id,
    String? content,
    String? eventTitle,
    String? eventDescription,
    DateTime? createdAt,
    DraftStatus? status,
    String? linkedinPostId,
    DateTime? publishedAt,
  }) {
    return PostDraft(
      id: id ?? this.id,
      content: content ?? this.content,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      linkedinPostId: linkedinPostId ?? this.linkedinPostId,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        eventTitle,
        eventDescription,
        createdAt,
        status,
        linkedinPostId,
        publishedAt,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'linkedinPostId': linkedinPostId,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  factory PostDraft.fromJson(Map<String, dynamic> json) {
    return PostDraft(
      id: json['id'] as String,
      content: json['content'] as String,
      eventTitle: json['eventTitle'] as String?,
      eventDescription: json['eventDescription'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: DraftStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DraftStatus.pending,
      ),
      linkedinPostId: json['linkedinPostId'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
    );
  }
}
