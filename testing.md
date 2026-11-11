# Roamory — Test ve Kalite Planı

## Zorunlu komutlar
- `dart format .`
- `flutter analyze`
- `flutter test`
- Android emülatör/cihazda `flutter run` ve kritik ekran akışları.
- iOS build/test için macOS + Xcode gereklidir; Windows üzerinde yapıldı iddiası YASAK.

## Unit testler
Domain validation (ratings, tarihler, title, route order, privacy), use case (fake repository ile başarılı/hata), DTO serialization, auth state mapping, locale/theme state.

## Widget testler
Onboarding, login invalid form, submit busy, home empty/skeleton, visit create form, trip day selection, social publish confirmation, protected journal, error/retry, locale toggle, bottom nav 5 sabit item, text overflow.

## Integration / E2E
- Email signup/confirm (SMTP sınırlaması not edilir), login/logout, Google OAuth redirect, session persistence.
- User A/B: visit/trips/wishlist private RLS; own INSERT/UPDATE/DELETE; draft vs published; blocked social; file uploads/downloads with real tokens.
- Storage: avatar 5MB public, visits/posts 10MB private; izinli/izinsiz list/read/upload/update/delete; signed URL expiry; orphan cleanup.
- Harita: attribution, izin reddi, pin/detay, manuel mekan, Geo coords, tile quota/geocoding failure.
- Topluluk: takip/beğeni/yorum/kaydet, engelle, rapor, bildirim read, yetkisiz owner update.
- Dil/tema: TR/EN ve light/dark/system; scroll/keyboard; font scaling; 320/393/430 genişlik.

## Güvenlik notu
SQL Editor'deki 'No errors detected' veya politika sayısı güvenlik kanıtı değildir. RLS ve Storage'ı **anon/authenticated mobil istemci oturumlarıyla** test et. Security definer ve privileged operations istemciye verilmez.

## Kabul kanıtı
Her modülün `tasks.md` satırına komut, sonuç, ekran ve test referansı ekle. Test çalıştırılamadıysa nedenini 'blocked' yaz. Kod içine öğretici Türkçe yorumlar eklenmiş olmalı; açıklamasız karmaşık metod kabul edilmez.
