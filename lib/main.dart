import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check: garante que só o app legítimo acessa o backend (Firestore/
  // Storage/Functions). Em release usamos Play Integrity (Android) e App
  // Attest (iOS); em debug, o provedor de debug — registre o token impresso
  // no log no console do App Check. Fica em modo monitor até ligarmos o
  // enforcement por serviço no console.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: kReleaseMode
        ? const AppleAppAttestProvider()
        : const AppleDebugProvider(),
  );

  // Formatação de datas em português do Brasil.
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

  runApp(const ProviderScope(child: NevadaApp()));
}
