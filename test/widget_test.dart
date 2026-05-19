import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/main.dart';

void main() {
  testWidgets('App renders Listaí', (final WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ListaiApp()));
    expect(find.text('Listaí'), findsOneWidget);
  });
}
