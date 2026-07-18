import 'package:feppm_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the FEPPM dashboard', (tester) async {
    await tester.pumpWidget(const FeppmApp());

    expect(find.text('FEPPM'), findsOneWidget);
    expect(find.text('Maintenance dashboard'), findsOneWidget);
    expect(find.text('Compliance'), findsOneWidget);
  });
}
