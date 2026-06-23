import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:speehive_social/core/constants/app_constants.dart';
import 'package:speehive_social/data/datasources/auth/outlook_oauth_service.dart';
import 'package:speehive_social/data/models/calendar_event_model.dart';
import 'package:speehive_social/domain/entities/calendar_event.dart';

class OutlookCalendarDatasource {
  final OutlookOAuthService _oauthService;

  OutlookCalendarDatasource(this._oauthService);

  Future<List<CalendarEvent>> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    final token = await _oauthService.getValidAccessToken();
    if (token == null) {
      throw Exception('Not authenticated with Outlook');
    }

    final startStr = start.toUtc().toIso8601String();
    final endStr = end.toUtc().toIso8601String();

    final uri = Uri.parse(
      '${OutlookConfig.graphBaseUrl}/me/calendar/calendarView',
    ).replace(
      queryParameters: {
        'startDateTime': startStr,
        'endDateTime': endStr,
        '\$select': 'subject,bodyPreview,organizer,attendees,start,end,location,isOnlineMeeting,onlineMeeting,webLink',
        '\$orderby': 'start/dateTime',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Prefer': 'outlook.timezone="UTC"',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final events = data['value'] as List<dynamic>;
      debugPrint('[OUTLOOK] Fetched ${events.length} events');

      return events
          .map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } else if (response.statusCode == 401) {
      final refreshed = await _oauthService.refreshAccessToken();
      if (refreshed != null) {
        return getEvents(start: start, end: end);
      }
      throw Exception('Authentication expired. Please reconnect Outlook.');
    } else {
      debugPrint('[OUTLOOK] Failed to fetch events: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch events: ${response.statusCode}');
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
}
