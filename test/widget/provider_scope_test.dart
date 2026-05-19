import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/main.dart';

void main() {
  testWidgets('ProviderScope wraps the widget tree', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ListaiApp()));
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
