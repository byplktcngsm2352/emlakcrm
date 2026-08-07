import 'package:flutter_test/flutter_test.dart';
import 'package:emlak_crm/main.dart';

void main() {
  testWidgets('EmlakCrmApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmlakCrmApp());
    expect(find.byType(EmlakCrmApp), findsOneWidget);
  });
}
