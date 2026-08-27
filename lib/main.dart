import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formatação de datas em português do Brasil.
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

  runApp(const ProviderScope(child: NevadaApp()));
}
