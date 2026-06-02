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
