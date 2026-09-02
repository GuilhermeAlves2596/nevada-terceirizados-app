import 'package:cloud_firestore/cloud_firestore.dart';

/// Helpers de conversão entre tipos do Firestore e Dart.

/// Converte um valor do Firestore (Timestamp/DateTime) em [DateTime].
DateTime fsDate(dynamic value, [DateTime? fallback]) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return fallback ?? DateTime.now();
}

/// [DateTime] → [Timestamp] para gravar no Firestore.
Timestamp fsTs(DateTime date) => Timestamp.fromDate(date);

/// Grava uma **data de calendário** (sem hora) de forma independente de fuso:
/// usa meio-dia UTC do dia informado. Assim a leitura em qualquer fuso das
/// Américas cai sempre no mesmo dia — evita que uma tarefa "de hoje" apareça
/// como "ontem" num aparelho com fuso diferente. A hora vem de campos próprios
/// (ex.: scheduledStartTime).
Timestamp dateOnlyTs(DateTime date) =>
    Timestamp.fromDate(DateTime.utc(date.year, date.month, date.day, 12));

/// Lê uma data de calendário e normaliza para meia-noite **local** (só a data
/// importa nas comparações de "hoje/ontem/atrasada").
DateTime fsDateOnly(dynamic value, [DateTime? fallback]) {
  final dt = fsDate(value, fallback);
  return DateTime(dt.year, dt.month, dt.day);
}
