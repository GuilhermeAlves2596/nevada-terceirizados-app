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
