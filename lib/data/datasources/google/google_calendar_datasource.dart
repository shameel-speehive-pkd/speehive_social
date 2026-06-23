import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:speehive_social/data/datasources/auth/google_calendar_oauth_service.dart';
import 'package:speehive_social/domain/entities/calendar_event.dart';

class GoogleCalendarDatasource {
  final GoogleCalendarOAuthService _oauthService;

  GoogleCalendarDatasource(this._oauthService);

  Future<List<CalendarEvent>> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    final client = await _oauthService.getAuthenticatedClient();
    if (client == null) {
      throw Exception('Not authenticated with Google Calendar');
    }

    try {
      final calendarApi = calendar.CalendarApi(client);
      final events = await calendarApi.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
        maxResults: 250,
      );

      debugPrint('[GOOGLE_CALENDAR] Fetched ${events.items?.length ?? 0} events');

      return (events.items ?? [])
          .map(_mapEventToEntity)
          .toList();
    } catch (e) {
      debugPrint('[GOOGLE_CALENDAR] Failed to fetch events: $e');
      throw Exception('Failed to fetch Google Calendar events: $e');
    }
  }

  Future<List<CalendarEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getEvents(start: startOfDay, end: endOfDay);
  }

  Future<List<CalendarEvent>> getUpcomingEvents({int days = 7}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfRange = startOfDay.add(Duration(days: days));
    return getEvents(start: startOfDay, end: endOfRange);
  }

  CalendarEvent _mapEventToEntity(calendar.Event event) {
    final attendees = event.attendees
            ?.map((a) => a.displayName ?? a.email ?? 'Unknown')
            .toList() ??
        [];

    final startDateTime = event.start?.dateTime ?? event.start?.date;
    final endDateTime = event.end?.dateTime ?? event.end?.date;

    return CalendarEvent(
      id: event.id ?? '',
      subject: event.summary ?? 'No Subject',
      bodyPreview: event.description,
      organizer: event.organizer?.displayName ?? event.organizer?.email,
      attendees: attendees,
      start: startDateTime ?? DateTime.now(),
      end: endDateTime ?? DateTime.now().add(const Duration(hours: 1)),
      location: event.location,
      isOnlineMeeting: event.hangoutLink != null || event.conferenceData != null,
      onlineMeetingUrl: event.hangoutLink,
      webLink: event.htmlLink,
    );
  }
}
