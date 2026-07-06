// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_fiesta/app/app.dart';
import 'package:fortune_fiesta/app/modules/premium_home/views/widgets/slot_machine.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  testWidgets('Fortune Fiesta startup smoke test', (WidgetTester tester) async {
    // Initialize required local storage before booting app in test environment
    await GetStorage.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the core SlotMachine widget is present and app boots cleanly
    expect(find.byType(SlotMachine), findsOneWidget);
  });
}
