import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_food_and_macro_tracker/main.dart';

void main() {
  testWidgets('App smoke test - starts up and settles on Home with 0 initial stats', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AiFoodTrackerApp(),
      ),
    );

    // Initial frame shows splash
    expect(find.text('AI Food & Macro'), findsOneWidget);

    // Let timer tick and route transition complete to Home
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // After session check with default logged-in fake repo, it navigates to Home
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Today\'s meals'), findsOneWidget);
    // Verifies that for fresh day/user it starts from 0 with empty state
    expect(find.text('No meals logged today yet'), findsOneWidget);
    expect(find.text('Scan Meal'), findsOneWidget);
  });
}
