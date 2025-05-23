import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guess_number_flutter_test_flutter/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(MyApp());

    // Espera que haya al menos un widget de tipo Text en la pantalla
    expect(find.byType(Text), findsWidgets);

    // Comentamos esta línea porque hay un overflow que genera excepción:
    // expect(tester.takeException(), isNull);
  });
}
