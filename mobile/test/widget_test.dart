import 'package:flutter_test/flutter_test.dart';
import 'package:syncbox/main.dart';

void main() {
  testWidgets('renders the Hello SyncBox screen', (tester) async {
    await tester.pumpWidget(const SyncBoxApp(autoCheckHealth: false));
    expect(find.text('Hello SyncBox'), findsOneWidget);
    expect(find.text('Recheck health'), findsOneWidget);
  });
}
