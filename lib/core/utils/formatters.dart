import 'package:flutter/services.dart';

String formatAge(String? birthDate) {
  if (birthDate == null || birthDate.isEmpty) return '0 anos';

  final birth = DateTime.tryParse(birthDate);
  if (birth == null) return '0 anos';

  final now = DateTime.now();
  if (birth.isAfter(now)) return '0 anos';

  final totalDays = now.difference(birth).inDays;

  if (totalDays < 30) {
    return totalDays == 1 ? '1 dia' : '$totalDays dias';
  }

  if (totalDays < 365) {
    final months = totalDays ~/ 30;
    return months == 1 ? '1 mês' : '$months meses';
  }

  var years = now.year - birth.year;
  final monthDiff = now.month - birth.month;
  if (monthDiff < 0 || (monthDiff == 0 && now.day < birth.day)) {
    years--;
  }

  return years == 1 ? '1 ano' : '$years anos';
}

String formatPhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 2) return '($digits';
  if (digits.length <= 7) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
  }
  final tail = digits.length > 11 ? digits.substring(0, 11) : digits;
  return '(${tail.substring(0, 2)}) ${tail.substring(2, 7)}-${tail.substring(7)}';
}

String formatCep(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 5) return digits;
  final tail = digits.length > 8 ? digits.substring(0, 8) : digits;
  return '${tail.substring(0, 5)}-${tail.substring(5)}';
}

String formatBirthDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

String toIsoDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

DateTime? parseIsoDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? toDateOnly(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  if (s.isEmpty) return null;
  return s.length >= 10 ? s.substring(0, 10) : s;
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatCep(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
