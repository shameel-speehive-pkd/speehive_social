import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formatted => DateFormat('MMM d, yyyy h:mm a').format(this);
  String get shortDate => DateFormat('MMM d').format(this);
  String get timeOnly => DateFormat('h:mm a').format(this);
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension StringCapitalization on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isWide => screenSize.width > 600;
}
