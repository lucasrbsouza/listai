import 'package:flutter_test/flutter_test.dart';
import 'package:listai/main.dart';

void main() {
  testWidgets('root widget renders without errors and displays Listaí', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ListaiApp());
    expect(find.text('Listaí'), findsOneWidget);
  });
}
