import '../services/app_settings_service.dart';

/// Centralized bilingual date formatter for Nostra Notes (Indonesian & English).
class DateFormatter {
  DateFormatter._();

  static const List<String> monthNamesId = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> monthNamesEn = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static List<String> get monthNames =>
      AppSettingsService.instance.isEnglish ? monthNamesEn : monthNamesId;

  /// Formats date to user-friendly relative string:
  /// - ID: 'Hari ini, 14:30' | EN: 'Today, 14:30'
  /// - ID: 'Kemarin, 09:15' | EN: 'Yesterday, 09:15'
  /// - ID: '7 Nov, 12:00'   | EN: '7 Nov, 12:00'
  /// - ID: '7 Nov 2025'     | EN: '7 Nov 2025'
  static String formatRelative(DateTime? dateTime, [AppLanguage? language]) {
    final dt = dateTime ?? DateTime.now();
    final now = DateTime.now();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final isEn = (language ?? AppSettingsService.instance.currentLanguage) ==
        AppLanguage.en;
    final months = isEn ? monthNamesEn : monthNamesId;

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return isEn ? 'Today, $hour:$min' : 'Hari ini, $hour:$min';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return isEn ? 'Yesterday, $hour:$min' : 'Kemarin, $hour:$min';
    }

    if (dt.year == now.year) {
      return '${dt.day} ${months[dt.month]}, $hour:$min';
    }
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  /// Formats date to full detailed timestamp (e.g., '8 Nov 2026, 17:50')
  static String formatFull(DateTime? dateTime, [AppLanguage? language]) {
    final dt = dateTime ?? DateTime.now();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final isEn = (language ?? AppSettingsService.instance.currentLanguage) ==
        AppLanguage.en;
    final months = isEn ? monthNamesEn : monthNamesId;
    return '${dt.day} ${months[dt.month]} ${dt.year}, $hour:$min';
  }
}
