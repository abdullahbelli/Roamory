import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';

/// Roamory'nin mekan, ziyaret, seyahat ve sosyal gönderi doğrulama ve
/// normalizasyon kuralları.
///
/// İstemci tarafında veritabanına hatalı veri gitmesini ve Dijital Pasaport
/// sayaçlarında (`uniqueCountriesCount`, `uniqueCitiesCount`) aynı ülkenin/şehrin
/// farklı yazımları veya geçersiz ülke kodları nedeniyle mükerrer/yanlış sayaç
/// oluşmasını engeller.
abstract final class TravelValidators {
  /// Test veya rastgele tuşlama girdilerini engelleyen yasaklı yer tutucu kelimeler.
  static const Set<String> _disallowedPlaceholderWords = <String>{
    'test',
    'deneme',
    'asdf',
    'qwer',
    'qwerty',
    'abc',
    'abcd',
    'xxx',
    'zzz',
    'none',
    'null',
    'unknown',
    'bilinmiyor',
    'ülke',
    'ulke',
    'country',
    'şehir',
    'sehir',
    'city',
  };

  /// Resmi ISO 3166-1 alpha-2 ülke kodları kümesi.
  ///
  /// 2 harfli girdilerde yalnızca bu kümedeki gerçek ülke kodları (veya `UK`
  /// takma adı) kabul edilir; `XX`, `ZZ`, `AA` gibi geçersiz kodlar reddedilir.
  static const Set<String> validIsoCountryCodes = <String>{
    'AD',
    'AE',
    'AF',
    'AG',
    'AL',
    'AM',
    'AO',
    'AR',
    'AT',
    'AU',
    'AZ',
    'BA',
    'BB',
    'BD',
    'BE',
    'BF',
    'BG',
    'BH',
    'BI',
    'BJ',
    'BN',
    'BO',
    'BR',
    'BS',
    'BT',
    'BW',
    'BY',
    'BZ',
    'CA',
    'CD',
    'CF',
    'CG',
    'CH',
    'CI',
    'CL',
    'CM',
    'CN',
    'CO',
    'CR',
    'CU',
    'CV',
    'CY',
    'CZ',
    'DE',
    'DJ',
    'DK',
    'DM',
    'DO',
    'DZ',
    'EC',
    'EE',
    'EG',
    'ER',
    'ES',
    'ET',
    'FI',
    'FJ',
    'FM',
    'FR',
    'GA',
    'GB',
    'GD',
    'GE',
    'GH',
    'GM',
    'GN',
    'GQ',
    'GR',
    'GT',
    'GW',
    'GY',
    'HK',
    'HN',
    'HR',
    'HT',
    'HU',
    'ID',
    'IE',
    'IL',
    'IN',
    'IQ',
    'IR',
    'IS',
    'IT',
    'JM',
    'JO',
    'JP',
    'KE',
    'KG',
    'KH',
    'KI',
    'KM',
    'KN',
    'KP',
    'KR',
    'KW',
    'KZ',
    'LA',
    'LB',
    'LC',
    'LI',
    'LK',
    'LR',
    'LS',
    'LT',
    'LU',
    'LV',
    'LY',
    'MA',
    'MC',
    'MD',
    'ME',
    'MG',
    'MH',
    'MK',
    'ML',
    'MM',
    'MN',
    'MO',
    'MR',
    'MT',
    'MU',
    'MV',
    'MW',
    'MX',
    'MY',
    'MZ',
    'NA',
    'NE',
    'NG',
    'NI',
    'NL',
    'NO',
    'NP',
    'NR',
    'NZ',
    'OM',
    'PA',
    'PE',
    'PG',
    'PH',
    'PK',
    'PL',
    'PS',
    'PT',
    'PW',
    'PY',
    'QA',
    'RO',
    'RS',
    'RU',
    'RW',
    'SA',
    'SB',
    'SC',
    'SD',
    'SE',
    'SG',
    'SI',
    'SK',
    'SL',
    'SM',
    'SN',
    'SO',
    'SR',
    'SS',
    'ST',
    'SV',
    'SY',
    'SZ',
    'TD',
    'TG',
    'TH',
    'TJ',
    'TL',
    'TM',
    'TN',
    'TO',
    'TR',
    'TT',
    'TV',
    'TW',
    'TZ',
    'UA',
    'UG',
    'US',
    'UY',
    'UZ',
    'VA',
    'VC',
    'VE',
    'VN',
    'VU',
    'WS',
    'XK',
    'YE',
    'ZA',
    'ZM',
    'ZW',
  };

  /// Türkçe ve İngilizce ülke yazımlarını standart 2 harfli ISO koduna eşler.
  static const Map<String, String> _countryAliasToIsoCode = <String, String>{
    'turkiye': 'TR',
    'turkiye cumhuriyeti': 'TR',
    'turkey': 'TR',
    'tr': 'TR',
    'tur': 'TR',
    'italya': 'IT',
    'italy': 'IT',
    'italia': 'IT',
    'it': 'IT',
    'japonya': 'JP',
    'japan': 'JP',
    'jp': 'JP',
    'fransa': 'FR',
    'france': 'FR',
    'fr': 'FR',
    'ispanya': 'ES',
    'spain': 'ES',
    'espana': 'ES',
    'es': 'ES',
    'almanya': 'DE',
    'germany': 'DE',
    'deutschland': 'DE',
    'de': 'DE',
    'yunanistan': 'GR',
    'greece': 'GR',
    'gr': 'GR',
    'ingiltere': 'GB',
    'birlesik krallik': 'GB',
    'united kingdom': 'GB',
    'great britain': 'GB',
    'england': 'GB',
    'uk': 'GB',
    'gb': 'GB',
    'abd': 'US',
    'amerika': 'US',
    'amerika birlesik devletleri': 'US',
    'united states': 'US',
    'united states of america': 'US',
    'usa': 'US',
    'us': 'US',
    'hollanda': 'NL',
    'netherlands': 'NL',
    'nl': 'NL',
    'avusturya': 'AT',
    'austria': 'AT',
    'at': 'AT',
    'isvicre': 'CH',
    'switzerland': 'CH',
    'ch': 'CH',
    'belcika': 'BE',
    'belgium': 'BE',
    'be': 'BE',
    'portekiz': 'PT',
    'portugal': 'PT',
    'pt': 'PT',
    'polonya': 'PL',
    'poland': 'PL',
    'pl': 'PL',
    'cekya': 'CZ',
    'cek cumhuriyeti': 'CZ',
    'czechia': 'CZ',
    'czech republic': 'CZ',
    'cz': 'CZ',
    'macaristan': 'HU',
    'hungary': 'HU',
    'hu': 'HU',
    'romanya': 'RO',
    'romania': 'RO',
    'ro': 'RO',
    'bulgaristan': 'BG',
    'bulgaria': 'BG',
    'bg': 'BG',
    'hirvatistan': 'HR',
    'croatia': 'HR',
    'hr': 'HR',
    'sirbistan': 'RS',
    'serbia': 'RS',
    'rs': 'RS',
    'bosna hersek': 'BA',
    'bosna-hersek': 'BA',
    'bosna': 'BA',
    'bosnia': 'BA',
    'bosnia and herzegovina': 'BA',
    'ba': 'BA',
    'arnavutluk': 'AL',
    'albania': 'AL',
    'al': 'AL',
    'kuzey makedonya': 'MK',
    'makedonya': 'MK',
    'north macedonia': 'MK',
    'macedonia': 'MK',
    'mk': 'MK',
    'karadag': 'ME',
    'montenegro': 'ME',
    'me': 'ME',
    'kosova': 'XK',
    'kosovo': 'XK',
    'xk': 'XK',
    'ukrayna': 'UA',
    'ukraine': 'UA',
    'ua': 'UA',
    'rusya': 'RU',
    'russia': 'RU',
    'ru': 'RU',
    'gurcistan': 'GE',
    'georgia': 'GE',
    'ge': 'GE',
    'azerbaycan': 'AZ',
    'azerbaijan': 'AZ',
    'az': 'AZ',
    'kibris': 'CY',
    'kktc': 'CY',
    'kuzey kibris': 'CY',
    'cyprus': 'CY',
    'cy': 'CY',
    'misir': 'EG',
    'egypt': 'EG',
    'eg': 'EG',
    'fas': 'MA',
    'morocco': 'MA',
    'ma': 'MA',
    'birlesik arap emirlikleri': 'AE',
    'bae': 'AE',
    'uae': 'AE',
    'united arab emirates': 'AE',
    'ae': 'AE',
    'katar': 'QA',
    'qatar': 'QA',
    'qa': 'QA',
    'suudi arabistan': 'SA',
    'saudi arabia': 'SA',
    'sa': 'SA',
    'guney kore': 'KR',
    'kore': 'KR',
    'south korea': 'KR',
    'korea': 'KR',
    'kr': 'KR',
    'cin': 'CN',
    'china': 'CN',
    'cn': 'CN',
    'tayland': 'TH',
    'thailand': 'TH',
    'th': 'TH',
    'endonezya': 'ID',
    'indonesia': 'ID',
    'id': 'ID',
    'malezya': 'MY',
    'malaysia': 'MY',
    'my': 'MY',
    'singapur': 'SG',
    'singapore': 'SG',
    'sg': 'SG',
    'hindistan': 'IN',
    'india': 'IN',
    'in': 'IN',
    'avustralya': 'AU',
    'australia': 'AU',
    'au': 'AU',
    'yeni zelanda': 'NZ',
    'new zealand': 'NZ',
    'nz': 'NZ',
    'kanada': 'CA',
    'canada': 'CA',
    'ca': 'CA',
    'meksika': 'MX',
    'mexico': 'MX',
    'mx': 'MX',
    'brezilya': 'BR',
    'brazil': 'BR',
    'br': 'BR',
    'arjantin': 'AR',
    'argentina': 'AR',
    'ar': 'AR',
    'isvec': 'SE',
    'sweden': 'SE',
    'se': 'SE',
    'norvec': 'NO',
    'norway': 'NO',
    'no': 'NO',
    'danimarka': 'DK',
    'denmark': 'DK',
    'dk': 'DK',
    'finlandiya': 'FI',
    'finland': 'FI',
    'fi': 'FI',
    'irlanda': 'IE',
    'ireland': 'IE',
    'ie': 'IE',
    'izlanda': 'IS',
    'iceland': 'IS',
    'is': 'IS',
  };

  /// ISO 3166-1 alpha-2 kodlarını kanonik Türkçe ülke adlarına eşler.
  static const Map<String, String> _isoCodeToCanonicalName = <String, String>{
    'TR': 'Türkiye',
    'IT': 'İtalya',
    'JP': 'Japonya',
    'FR': 'Fransa',
    'ES': 'İspanya',
    'DE': 'Almanya',
    'GR': 'Yunanistan',
    'GB': 'Birleşik Krallık',
    'US': 'ABD',
    'NL': 'Hollanda',
    'AT': 'Avusturya',
    'CH': 'İsviçre',
    'BE': 'Belçika',
    'PT': 'Portekiz',
    'PL': 'Polonya',
    'CZ': 'Çekya',
    'HU': 'Macaristan',
    'RO': 'Romanya',
    'BG': 'Bulgaristan',
    'HR': 'Hırvatistan',
    'RS': 'Sırbistan',
    'BA': 'Bosna-Hersek',
    'AL': 'Arnavutluk',
    'MK': 'Kuzey Makedonya',
    'ME': 'Karadağ',
    'XK': 'Kosova',
    'UA': 'Ukrayna',
    'RU': 'Rusya',
    'GE': 'Gürcistan',
    'AZ': 'Azerbaycan',
    'CY': 'Kıbrıs',
    'EG': 'Mısır',
    'MA': 'Fas',
    'AE': 'Birleşik Arap Emirlikleri',
    'QA': 'Katar',
    'SA': 'Suudi Arabistan',
    'KR': 'Güney Kore',
    'CN': 'Çin',
    'TH': 'Tayland',
    'ID': 'Endonezya',
    'MY': 'Malezya',
    'SG': 'Singapur',
    'IN': 'Hindistan',
    'AU': 'Avustralya',
    'NZ': 'Yeni Zelanda',
    'CA': 'Kanada',
    'MX': 'Meksika',
    'BR': 'Brezilya',
    'AR': 'Arjantin',
    'SE': 'İsveç',
    'NO': 'Norveç',
    'DK': 'Danimarka',
    'FI': 'Finlandiya',
    'IE': 'İrlanda',
    'IS': 'İzlanda',
  };

  /// Türkçe karakterleri ASCII karşılıklarına indirgeyerek karşılaştırma anahtarı üretir.
  static String foldTurkishAscii(String input) {
    return input
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'c')
        .replaceAll('ç', 'c')
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Girilen ülke adından veya kodundan bilinen 2 harfli ISO ülke kodunu çözümler.
  ///
  /// Geçerli bir ISO kodu veya bilinen ülke adı değilse `null` döner.
  static String? tryResolveIsoCountryCode(String rawCountry) {
    final trimmed = rawCountry.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final folded = foldTurkishAscii(trimmed);
    if (_disallowedPlaceholderWords.contains(folded)) {
      return null;
    }
    final byAlias = _countryAliasToIsoCode[folded];
    if (byAlias != null) {
      return byAlias;
    }
    if (trimmed.length == 2) {
      final upper = trimmed.toUpperCase();
      if (validIsoCountryCodes.contains(upper)) {
        return upper;
      }
      return null;
    }
    return null;
  }

  /// Kullanıcının girdiği ülke değerinin geçerli bir ülke adı veya ISO kodu olup
  /// olmadığını doğrular.
  static bool isValidCountry(String rawCountry) {
    final trimmed = rawCountry.trim();
    if (trimmed.length < 2) {
      return false;
    }
    final folded = foldTurkishAscii(trimmed);
    if (_disallowedPlaceholderWords.contains(folded)) {
      return false;
    }
    // Ülke adında rakam veya özel sembol bulunamaz.
    if (!RegExp(r"^[a-zA-ZçğıöşüÇĞİÖŞÜ\s\-\.']+$").hasMatch(trimmed)) {
      return false;
    }
    final iso = tryResolveIsoCountryCode(trimmed);
    if (iso != null) {
      return true;
    }
    // 2 veya 3 harfli olup bilinen ISO/alias listesinde yer almayan kısaltmalar
    // (ör. "XX", "ZZ", "AA", "XYZ") geçersiz ülke kodu olarak reddedilir.
    if (trimmed.length <= 3) {
      return false;
    }
    return true;
  }

  /// Kullanıcının girdiği şehir/bölge adının geçerli olup olmadığını doğrular.
  static bool isValidCity(String rawCity) {
    final trimmed = rawCity.trim();
    if (trimmed.length < 2) {
      return false;
    }
    final folded = foldTurkishAscii(trimmed);
    if (_disallowedPlaceholderWords.contains(folded)) {
      return false;
    }
    // Şehir adında rakam bulunamaz; yalnızca harf, boşluk, tire ve nokta olabilir.
    if (!RegExp(r"^[a-zA-ZçğıöşüÇĞİÖŞÜ\s\-\.']+$").hasMatch(trimmed)) {
      return false;
    }
    // Tekrarlayan tek harf ("aaa", "xxx") gibi anlamsız girdileri engelle.
    final uniqueChars = folded
        .replaceAll(RegExp(r'[^a-z]'), '')
        .split('')
        .toSet();
    if (folded.length >= 3 && uniqueChars.length <= 1) {
      return false;
    }
    return true;
  }

  /// Ülke girdisini 2 harfli standart ISO ülke koduna dönüştürür (`places.country_code`).
  static String normalizeCountryCode(String rawCountry) {
    final resolved = tryResolveIsoCountryCode(rawCountry);
    if (resolved != null) {
      return resolved;
    }
    final asciiLetters = foldTurkishAscii(rawCountry)
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z]'), '');
    if (asciiLetters.length >= 2) {
      final candidate = asciiLetters.substring(0, 2);
      if (validIsoCountryCodes.contains(candidate)) {
        return candidate;
      }
    }
    return 'TR';
  }

  /// Ülke girdisini kanonik ülke adına dönüştürür (`places.country_name`).
  ///
  /// Örneğin `"tr"`, `"TR"`, `"Turkey"`, `"turkiye"` ve `"TÜRKİYE"` girdilerinin
  /// tamamı `"Türkiye"` olarak standartlaştırılır.
  static String normalizeCountryName(String rawCountry) {
    final trimmed = rawCountry.trim();
    if (trimmed.isEmpty) {
      return 'Türkiye';
    }
    final iso = tryResolveIsoCountryCode(trimmed);
    if (iso != null) {
      return _isoCodeToCanonicalName[iso] ?? iso;
    }
    return _toTurkishTitleCase(trimmed);
  }

  /// Şehir adını Türkçe büyük/küçük harf kurallarına göre standartlaştırır (`places.city`).
  ///
  /// Örneğin `"istanbul"`, `"ISTANBUL"`, `"İSTANBUL"` -> `"İstanbul"`.
  static String normalizeCityName(String rawCity) {
    final trimmed = rawCity.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final folded = foldTurkishAscii(trimmed);
    const knownTurkishCities = <String, String>{
      'istanbul': 'İstanbul',
      'izmir': 'İzmir',
      'izmit': 'İzmit',
      'isparta': 'Isparta',
      'igdir': 'Iğdır',
      'ankara': 'Ankara',
      'antalya': 'Antalya',
      'mugla': 'Muğla',
      'nevsehir': 'Nevşehir',
      'canakkale': 'Çanakkale',
      'eskisehir': 'Eskişehir',
      'diyarbakir': 'Diyarbakır',
      'sanliurfa': 'Şanlıurfa',
      'gaziantep': 'Gaziantep',
    };
    if (knownTurkishCities.containsKey(folded)) {
      return knownTurkishCities[folded]!;
    }
    return _toTurkishTitleCase(trimmed);
  }

  /// Dijital Pasaport ülke sayacı için tekil anahtar üretir (`uniqueCountriesCount`).
  ///
  /// `"TR"`, `"Türkiye"`, `"turkiye"` ve `"Turkey"` aynı `'TR'` anahtarına indirgenir.
  static String canonicalCountryKey(String? rawCountry) {
    if (rawCountry == null || rawCountry.trim().isEmpty) {
      return '';
    }
    final trimmed = rawCountry.trim();
    final folded = foldTurkishAscii(trimmed);
    if (_disallowedPlaceholderWords.contains(folded)) {
      return '';
    }
    final iso = tryResolveIsoCountryCode(trimmed);
    if (iso != null) {
      return iso;
    }
    return folded;
  }

  /// Dijital Pasaport şehir sayacı için tekil anahtar üretir (`uniqueCitiesCount`).
  static String canonicalCityKey(String? rawCity, {String? country}) {
    if (rawCity == null || rawCity.trim().isEmpty) {
      return '';
    }
    final foldedCity = foldTurkishAscii(rawCity);
    if (_disallowedPlaceholderWords.contains(foldedCity)) {
      return '';
    }
    final countryKey = canonicalCountryKey(country);
    return countryKey.isEmpty ? foldedCity : '$countryKey:$foldedCity';
  }

  static String _toTurkishTitleCase(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    return words
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          final first = word[0];
          final upperFirst = switch (first) {
            'i' => 'İ',
            'ı' => 'I',
            _ => first.toUpperCase(),
          };
          final rest = word
              .substring(1)
              .replaceAll('İ', 'i')
              .replaceAll('I', 'ı')
              .toLowerCase();
          return '$upperFirst$rest';
        })
        .join(' ');
  }

  /// Enlem ve boylamın geçerli coğrafi sınırlar içinde olup olmadığını kontrol eder.
  static bool isValidCoordinates(double latitude, double longitude) {
    if (latitude.isNaN || longitude.isNaN) {
      return false;
    }
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  /// Özel mekan oluşturma isteğini doğrular; hata varsa [ValidationAppException] fırlatır.
  static void validatePrivatePlace(CreatePrivatePlaceRequest request) {
    if (request.name.trim().isEmpty ||
        request.country.trim().isEmpty ||
        request.city.trim().isEmpty) {
      throw const ValidationAppException(code: 'place_fields_required');
    }
    if (!isValidCountry(request.country)) {
      throw const ValidationAppException(code: 'invalid_country');
    }
    if (!isValidCity(request.city)) {
      throw const ValidationAppException(code: 'invalid_city');
    }
    if (!isValidCoordinates(request.latitude, request.longitude)) {
      throw const ValidationAppException(code: 'invalid_coordinates');
    }
  }

  /// Ziyaret kaydetme isteğini (`UpsertVisitRequest`) doğrular.
  static void validateVisitRequest(UpsertVisitRequest request) {
    final hasExistingPlace =
        request.placeId != null && request.placeId!.trim().isNotEmpty;
    if (!hasExistingPlace && request.customPlace == null) {
      throw const ValidationAppException(code: 'visit_place_required');
    }
    if (request.customPlace != null) {
      validatePrivatePlace(request.customPlace!);
    }
    if (request.rating != null &&
        (request.rating! < 1 || request.rating! > 5)) {
      throw const ValidationAppException(code: 'invalid_visit_rating');
    }
    for (final photo in request.newPhotos) {
      if (photo.bytes.lengthInBytes > 10 * 1024 * 1024) {
        throw const ValidationAppException(code: 'visit_photo_too_large');
      }
    }
  }

  /// Seyahat oluşturma/güncelleme isteğini (`UpsertTripRequest`) doğrular.
  static void validateTripRequest(UpsertTripRequest request) {
    if (request.title.trim().isEmpty) {
      throw const ValidationAppException(code: 'trip_title_required');
    }
    // Bitiş tarihi başlangıç tarihinden önce olamaz (T13 iş kuralı).
    if (request.startDate != null &&
        request.endDate != null &&
        request.endDate!.isBefore(request.startDate!)) {
      throw const ValidationAppException(code: 'trip_invalid_date_order');
    }
  }

  /// Başlangıç ve bitiş tarihine göre oluşturulacak gün numaralarını (`1..N`) hesaplar.
  static List<DateTime?> generateTripDayDates(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
      return const [null];
    }
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final count = normalizedEnd.difference(normalizedStart).inDays + 1;
    // Aşırı uzun tarih aralıklarında güvenli üst sınır (maksimum 60 gün).
    final safeCount = count.clamp(1, 60);
    return List<DateTime?>.generate(
      safeCount,
      (index) => normalizedStart.add(Duration(days: index)),
    );
  }
}
