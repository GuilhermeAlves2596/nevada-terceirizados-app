// Smoke test: a aplicação inicia na tela de login.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nevada_terceirizados/app/app.dart';

void main() {
  testWidgets('abre na tela de login', (tester) async {
    // Evita chamadas de rede às fontes durante os testes.
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const ProviderScope(child: NevadaApp()));
    await tester.pump();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);
    expect(find.text('Funcionário'), findsOneWidget);
  });
}
