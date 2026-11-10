import 'package:flutter_test/flutter_test.dart';
import 'package:smartgas_flutter/main.dart';

void main() {
  testWidgets('Muestra la pantalla de inicio de sesion', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartGasApp());
    expect(find.text('Iniciar sesión'), findsWidgets);
  });
}
