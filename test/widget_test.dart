import 'package:flutter_test/flutter_test.dart';
import 'package:gmu_doulos/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GMUDoulosApp());
    await tester.pump();
    expect(find.text('GMU Doulos'), findsWidgets);
  });
}
