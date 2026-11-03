import 'package:flutter_test/flutter_test.dart';

import 'package:app_localizacoes/app.dart';

void main() {
  testWidgets('Tela inicial exibe os botões principais', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Iniciar coleta'), findsOneWidget);
    expect(find.text('Parar coleta'), findsOneWidget);
    expect(find.text('Consultar histórico'), findsOneWidget);
    expect(find.text('Ver mapa'), findsOneWidget);
    expect(find.text('Configurações de permissão'), findsOneWidget);
  });
}
