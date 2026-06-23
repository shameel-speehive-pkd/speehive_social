import 'package:speehive_social/domain/entities/calendar_event.dart';

class CalendarEventModel {
  final String id;
  final String subject;
  final String? bodyPreview;
  final String? organizerName;
  final String? organizerEmail;
  final List<AttendeeModel> attendees;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? locationDisplayName;
  final bool isOnlineMeeting;
  final String? onlineMeetingJoinUrl;
  final String? webLink;

  const CalendarEventModel({
    required this.id,
    required this.subject,
    this.bodyPreview,
    this.organizerName,
    this.organizerEmail,
    this.attendees = const [],
    required this.startDateTime,
    required this.endDateTime,
    this.locationDisplayName,
    this.isOnlineMeeting = false,
    this.onlineMeetingJoinUrl,
    this.webLink,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    final organizer = json['organizer'] as Map<String, dynamic>?;
    final emailAddress = organizer?['emailAddress'] as Map<String, dynamic>?;
    final attendeesList = json['attendees'] as List<dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;
    final onlineMeeting = json['onlineMeeting'] as Map<String, dynamic>?;
    final start = json['start'] as Map<String, dynamic>;
    final end = json['end'] as Map<String, dynamic>;

    return CalendarEventModel(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? 'No Subject',
      bodyPreview: json['bodyPreview'] as String?,
      organizerName: emailAddress?['name'] as String?,
      organizerEmail: emailAddress?['address'] as String?,
      attendees: attendeesList
              ?.map((a) => AttendeeModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      startDateTime: DateTime.parse(start['dateTime'] as String),
      endDateTime: DateTime.parse(end['dateTime'] as String),
      locationDisplayName: location?['displayName'] as String?,
      isOnlineMeeting: json['isOnlineMeeting'] as bool? ?? false,
      onlineMeetingJoinUrl: onlineMeeting?['joinUrl'] as String?,
      webLink: json['webLink'] as String?,
    );
  }

  CalendarEvent toEntity() {
    final attendeeNames = attendees
        .map((a) => a.name ?? a.email ?? 'Unknown')
        .toList();

    return CalendarEvent(
      id: id,
      subject: subject,
      bodyPreview: bodyPreview,
      organizer: organizerName ?? organizerEmail,
      attendees: attendeeNames,
      start: startDateTime,
      end: endDateTime,
      location: locationDisplayName,
      isOnlineMeeting: isOnlineMeeting,
      onlineMeetingUrl: onlineMeetingJoinUrl,
      webLink: webLink,
    );
  }
}

class AttendeeModel {
  final String? name;
  final String? email;
  final String? type;

  const AttendeeModel({
    this.name,
    this.email,
    this.type,
  });

  factory AttendeeModel.fromJson(Map<String, dynamic> json) {
    final emailAddress = json['emailAddress'] as Map<String, dynamic>?;
    return AttendeeModel(
      name: emailAddress?['name'] as String?,
      email: emailAddress?['address'] as String?,
      type: json['type'] as String?,
    );
  }
}
