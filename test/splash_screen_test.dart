import 'package:flutter_test/flutter_test.dart';
import 'package:afetnet/main.dart';

void main() {
  testWidgets('SplashScreen renders title, subtitle, and status text', (WidgetTester tester) async {
    await tester.pumpWidget(const AfetNetApp());

    expect(find.text('AfetNet'), findsOneWidget);
    expect(find.text('Canlı Kriz Yönetimi Ağı'), findsOneWidget);
    expect(find.text('AfetNet protokolü hazır.'), findsOneWidget);
  });
}

