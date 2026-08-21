import 'package:flutter_test/flutter_test.dart';

import 'package:brivora/app/app.dart';
import 'package:brivora/core/providers/locale_controller.dart';

void main() {
  testWidgets('Brivora app smoke test', (WidgetTester tester) async {
    final localeController = LocaleController();

    await tester.pumpWidget(BrivoraApp(localeController: localeController));

    await tester.pumpAndSettle();

    expect(find.byType(BrivoraApp), findsOneWidget);
  });
}
