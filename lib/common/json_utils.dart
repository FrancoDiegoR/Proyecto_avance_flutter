// Ayudas para leer el JSON del backend, que a veces trae numeros como texto o campos con otro nombre.

double? toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? fallback;
}

String toText(dynamic value, [String fallback = '']) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? fallback : text;
}

DateTime? toDate(dynamic value) => value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

/// "10:42" si es de hoy, si no "13/05 07:30".
String formatShortDate(DateTime? date) {
  if (date == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  final now = DateTime.now();
  final time = '${two(date.hour)}:${two(date.minute)}';
  final sameDay = date.year == now.year && date.month == now.month && date.day == now.day;
  return sameDay ? time : '${two(date.day)}/${two(date.month)} $time';
}

/// 18.0 -> "18", 18.5 -> "18.5"
String formatNumber(double? value) {
  if (value == null) return '—';
  return value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}
