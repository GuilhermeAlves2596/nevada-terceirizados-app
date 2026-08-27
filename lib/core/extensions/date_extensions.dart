import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  static final _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dayMonth = DateFormat('dd/MM', 'pt_BR');
  static final _time = DateFormat('HH:mm', 'pt_BR');
  static final _dateTime = DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR');

  String get ddMMyyyy => _date.format(this);
  String get ddMM => _dayMonth.format(this);
  String get hhmm => _time.format(this);
  String get fullDateTime => _dateTime.format(this);

  /// Rótulo relativo amigável: "Hoje", "Ontem", "Amanhã" ou a data.
  String get relativeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDay = DateTime(year, month, day);
    final diff = thisDay.difference(today).inDays;
    return switch (diff) {
      0 => 'Hoje',
      -1 => 'Ontem',
      1 => 'Amanhã',
      _ => ddMMyyyy,
    };
  }
}
