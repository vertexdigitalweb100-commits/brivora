import 'package:flutter_test/flutter_test.dart';

import 'package:brivora/app/app.dart';

void main() {
  testWidgets('Brivora app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrivoraApp());

    expect(find.text('Brivora'), findsOneWidget);
  });
}
