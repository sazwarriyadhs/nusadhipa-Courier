import 'package:flutter_test/flutter_test.dart';
import 'package:courier_mobile/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const NusadhipaCourierApp());
    expect(find.byType(NusadhipaCourierApp), findsOneWidget);
  });
}
