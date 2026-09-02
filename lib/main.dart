import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';
import 'app/firestore_seeder.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Semeia os dados de demonstração no Firestore (só na primeira execução).
  try {
    await FirestoreSeeder(FirebaseFirestore.instance).seedIfNeeded();
  } catch (e) {
    debugPrint('Falha ao semear o Firestore (seguindo mesmo assim): $e');
  }

  // Formatação de datas em português do Brasil.
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

  runApp(const ProviderScope(child: NevadaApp()));
}
