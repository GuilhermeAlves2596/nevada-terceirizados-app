// Smoke test: a aplicação inicia e monta a árvore de widgets.
//
// Nos testes o Firebase não é inicializado, então a tela inicial é a splash
// (a restauração de sessão falha silenciosamente e cairia no login em runtime).
// Verificamos a marca "Nevada", presente na splash e no login.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nevada_terceirizados/app/app.dart';

void main() {
  testWidgets('inicializa e renderiza a marca', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.pumpWidget(const ProviderScope(child: NevadaApp()));
    await tester.pump();

    expect(find.text('Nevada'), findsWidgets);
  });
}
