import 'package:flutter/foundation.dart';
import 'package:speehive_social/data/datasources/google/google_calendar_datasource.dart';
import 'package:speehive_social/data/datasources/outlook/outlook_calendar_datasource.dart';
import 'package:speehive_social/data/datasources/local/secure_storage_service.dart';

class EventCheckService {
  static const String _lastFetchKey = 'last_events_fetch_date';
  final GoogleCalendarDatasource? _googleCalendarDatasource;
  final OutlookCalendarDatasource? _outlookDatasource;
  final SecureStorageService _storage;

  EventCheckService({
    GoogleCalendarDatasource? googleCalendarDatasource,
    OutlookCalendarDatasource? outlookDatasource,
    required SecureStorageService storage,
  })  : _googleCalendarDatasource = googleCalendarDatasource,
        _outlookDatasource = outlookDatasource,
        _storage = storage;

  /// Check if today's events have been fetched
  /// Returns true if events are fresh, false if they need to be refreshed
  Future<bool> areTodayEventsFresh() async {
    try {
      final lastFetchStr = await _storage.readSecure(_lastFetchKey);
      if (lastFetchStr == null) return false;

      final lastFetch = DateTime.parse(lastFetchStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastFetchDate = DateTime(
        lastFetch.year,
        lastFetch.month,
        lastFetch.day,
      );

      // Events are fresh if fetched today
      return today.isAtSameMomentAs(lastFetchDate);
    } catch (e) {
      debugPrint('[EVENT_CHECK] Error checking freshness: $e');
      return false;
    }
  }

  /// Fetch today's events and mark as fresh
  Future<List<dynamic>> fetchAndMarkFresh() async {
    try {
      final events = await _fetchTodayEvents();
      await _markAsFresh();
      debugPrint('[EVENT_CHECK] Fetched ${events.length} events and marked as fresh');
      return events;
    } catch (e) {
      debugPrint('[EVENT_CHECK] Error fetching events: $e');
      rethrow;
    }
  }

  /// Force refresh events (ignore freshness check)
  Future<List<dynamic>> forceRefresh() async {
    final events = await _fetchTodayEvents();
    await _markAsFresh();
    return events;
  }

  Future<List<dynamic>> _fetchTodayEvents() async {
    // Try Google Calendar first, then Outlook
    final googleCalendar = _googleCalendarDatasource;
    final outlook = _outlookDatasource;

    if (googleCalendar != null) {
      try {
        return await googleCalendar.getTodayEvents();
      } catch (e) {
        debugPrint('[EVENT_CHECK] Google Calendar failed, trying Outlook: $e');
        if (outlook != null) {
          return await outlook.getTodayEvents();
        }
        rethrow;
      }
    } else if (outlook != null) {
      return await outlook.getTodayEvents();
    }
    throw Exception('No calendar datasource configured');
  }

  Future<void> _markAsFresh() async {
    await _storage.saveSecure(_lastFetchKey, DateTime.now().toIso8601String());
  }

  /// Get the last fetch time
  Future<DateTime?> getLastFetchTime() async {
    final lastFetchStr = await _storage.readSecure(_lastFetchKey);
    if (lastFetchStr == null) return null;
    try {
      return DateTime.parse(lastFetchStr);
    } catch (e) {
      return null;
    }
  }
}
