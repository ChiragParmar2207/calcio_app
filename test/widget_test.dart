import 'package:flutter_test/flutter_test.dart';
import 'package:calcio/main.dart';
import 'package:calcio/services/storage_service.dart';

void main() {
  testWidgets('Calcio app smoke test', (WidgetTester tester) async {
    final storage = StorageService();
    await storage.init();
    await tester.pumpWidget(CalcioApp(storage: storage));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('='), findsOneWidget);
  });
}
