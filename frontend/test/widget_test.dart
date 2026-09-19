import 'package:flutter_test/flutter_test.dart';
import 'package:agrivyn/main.dart';

void main() {
  testWidgets('AgriSync smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriSyncApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('AgriVyn'), findsWidgets);
  });
}
