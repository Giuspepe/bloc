import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Should pass', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    setUpHotReload();
  });

  testWidgets('Should fail and does', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    /// onPressed of the button throws an exception
    await tester.tap(find.byIcon(Icons.flash_on));
    await tester.pump();

    setUpHotReload();
  });

  testWidgets('Should fail but does not', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pump();

    setUpHotReload();
  });
}

/// Call this at the end of every test so you can use hot reload
void setUpHotReload() {
  debugDefaultTargetPlatformOverride = null;
}
