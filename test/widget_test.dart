import 'package:flutter_test/flutter_test.dart';
import 'package:speehive_social/core/themes/app_theme.dart';

void main() {
  testWidgets('App theme can be created', (WidgetTester tester) async {
    final theme = AppTheme.lightTheme;
    expect(theme.useMaterial3, isTrue);
  });
}
