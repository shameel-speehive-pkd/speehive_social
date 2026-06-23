import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  final String id;
  final String subject;
  final String? bodyPreview;
  final String? organizer;
  final List<String> attendees;
  final DateTime start;
  final DateTime end;
  final String? location;
  final bool isOnlineMeeting;
  final String? onlineMeetingUrl;
  final String? webLink;

  const CalendarEvent({
    required this.id,
    required this.subject,
    this.bodyPreview,
    this.organizer,
    this.attendees = const [],
    required this.start,
    required this.end,
    this.location,
    this.isOnlineMeeting = false,
    this.onlineMeetingUrl,
    this.webLink,
  });

  CalendarEvent copyWith({
    String? id,
    String? subject,
    String? bodyPreview,
    String? organizer,
    List<String>? attendees,
    DateTime? start,
    DateTime? end,
    String? location,
    bool? isOnlineMeeting,
    String? onlineMeetingUrl,
    String? webLink,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      organizer: organizer ?? this.organizer,
      attendees: attendees ?? this.attendees,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
      isOnlineMeeting: isOnlineMeeting ?? this.isOnlineMeeting,
      onlineMeetingUrl: onlineMeetingUrl ?? this.onlineMeetingUrl,
      webLink: webLink ?? this.webLink,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        bodyPreview,
        organizer,
        attendees,
        start,
        end,
        location,
        isOnlineMeeting,
        onlineMeetingUrl,
        webLink,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'bodyPreview': bodyPreview,
      'organizer': organizer,
      'attendees': attendees,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'location': location,
      'isOnlineMeeting': isOnlineMeeting,
      'onlineMeetingUrl': onlineMeetingUrl,
      'webLink': webLink,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? 'No Subject',
      bodyPreview: json['bodyPreview'] as String?,
      organizer: json['organizer'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      location: json['location'] as String?,
      isOnlineMeeting: json['isOnlineMeeting'] as bool? ?? false,
      onlineMeetingUrl: json['onlineMeetingUrl'] as String?,
      webLink: json['webLink'] as String?,
    );
  }
}
