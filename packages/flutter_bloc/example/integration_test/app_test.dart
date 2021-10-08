import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Should fail and does', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    /// onPressed of the button throws an exception
    await tester.tap(
        find.text('Throw exception in onPressed of button (not inside bloc)'));
    await tester.pump();

    setUpHotReload();
  });

  testWidgets('Should succeed', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Load data and succeed (no exception thrown)'));
    await tester.pumpAndSettle();
    expect(find.byType(StaticSuccessWidget), findsOneWidget);

    setUpHotReload();
  });

  testWidgets(
      'Should fail immediately when bloc throws exception, but times out after 10 minutes',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    await tester
        .tap(find.text('Load data and fail (exception thrown in bloc)'));
    await tester.pumpAndSettle();
    expect(find.byType(StaticSuccessWidget), findsOneWidget);

    setUpHotReload();
  });
}

/// Call this at the end of every test so you can use hot reload
void setUpHotReload() {
  debugDefaultTargetPlatformOverride = null;
}
