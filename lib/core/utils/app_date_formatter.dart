import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Roamory uygulamasının TR / EN yerel ayarlarına (`Locale`) duyarlı merkezi tarih
/// biçimlendiricisi.
///
/// `DateFormat` doğrudan parametresiz çağrıldığında `Intl.defaultLocale` (`en_US`)
/// kullandığı için Türkçe arayüzde "November 12, 2026" veya "Nov 12, 2026" gibi
/// İngilizce tarihler görünmesini engeller.
/// - Türkçe (`tr`): `"12 Kasım 2026"` (gün + tam Türkçe ay adı + yıl)
/// - İngilizce (`en`): `"Nov 12, 2026"` (kart/liste) veya `"November 12, 2026"` (detay)
abstract final class AppDateFormatter {
  static const List<String> _trMonthsLong = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> _enMonthsShort = <String>[
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

  static const List<String> _enMonthsLong = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// [context] içindeki aktif dil koduna göre tarihi biçimlendirir.
  ///
  /// Türkçe'de her zaman `"12 Kasım 2026"`, İngilizce'de [longMonth] `true` ise
  /// `"November 12, 2026"`, `false` ise `"Nov 12, 2026"` döndürür.
  static String format(
    BuildContext context,
    DateTime date, {
    bool longMonth = false,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return formatForLanguage(date, languageCode, longMonth: longMonth);
  }

  /// Dil koduna (`'tr'` veya `'en'`) göre tarihi güvenli biçimde biçimlendirir.
  ///
  /// `intl` yerel verisi henüz başlatılmamış birim testi ortamlarında dahi hata
  /// fırlatmadan deterministik Türkçe/İngilizce çıktı üretir.
  static String formatForLanguage(
    DateTime date,
    String languageCode, {
    bool longMonth = false,
  }) {
    final normalizedLang = languageCode.trim().toLowerCase();
    final monthIndex = (date.month - 1).clamp(0, 11);

    if (normalizedLang.startsWith('tr')) {
      return '${date.day} ${_trMonthsLong[monthIndex]} ${date.year}';
    }

    try {
      return longMonth
          ? DateFormat.yMMMMd('en').format(date)
          : DateFormat.yMMMd('en').format(date);
    } catch (_) {
      final monthName = longMonth
          ? _enMonthsLong[monthIndex]
          : _enMonthsShort[monthIndex];
      return '$monthName ${date.day}, ${date.year}';
    }
  }

  /// Yıl olmadan yalnızca gün ve ay bilgisini biçimlendirir (ör. rota gün kartları).
  ///
  /// Türkçe'de `"12 Kasım"`, İngilizce'de `"Nov 12"` döndürür.
  static String formatMonthDay(BuildContext context, DateTime date) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final monthIndex = (date.month - 1).clamp(0, 11);

    if (languageCode.toLowerCase().startsWith('tr')) {
      return '${date.day} ${_trMonthsLong[monthIndex]}';
    }
    try {
      return DateFormat.MMMd('en').format(date);
    } catch (_) {
      return '${_enMonthsShort[monthIndex]} ${date.day}';
    }
  }

  /// İki tarih arasındaki aralığı aktif dile göre biçimlendirir.
  static String formatRange(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
  ) {
    return '${format(context, startDate)} - ${format(context, endDate)}';
  }
}
