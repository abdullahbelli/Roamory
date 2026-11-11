# Roamory — Antigravity Görev Planı

> Agent için yürütme günlüğü. Her alt görevi başlamadan `in_progress`, başarı + test sonucu sonrası `[x]`, engelde `[!]` işaretle. **Başarılı sayılma ölçütü** `testing.md` ve `features.md`.

## P0 — İnceleme ve temel
- [x] T01 Mevcut Flutter SDK/Flutter projesi, git durumu, paketleri incele; kritik mevcut dosyaları silme. Çıktı: teknik keşif notu.
  - Kanıt: Flutter `3.47.9` (stable), Dart `3.13.7`. Branch `main` (`a7fecdd`), `README.md` modified + dokümanlar untracked. `android/app/build.gradle.kts` içinde `applicationId = "com.example.roamory"`; `AndroidManifest.xml` ve `Info.plist`'te `io.roamory.app://login-callback/` deep-link henüz tanımlı değil. `flutter analyze` (0 issue) ve `flutter test` (1/1 smoke test pass).
- [x] T02 Stitch MCP 38 HTML/PNG ekranını gerçek kaynaktan incele, `docs/screen_inventory.md` eşlemesini kontrol et; eksikleri işaretle.
  - Kanıt: `get_project` ve `list_screens` ile `projects/2591164501540002750` üzerinden 38/38 ekran doğrulandı (`Missing html: 0`, `Missing shot: 0`, `docs/screen_inventory.md` ile birebir eşleşme). `A01`, `A02`, `A03`, `B01` (+PNG), `B02`, `C01`, `D01`, `E01`, `E05`, `F01`, `F04`, `F05`, `S01`–`S04` HTML içerikleri doğrudan incelendi. Kalan modül ekranları kendi fazları (`P1`–`P5`) kodlanmadan hemen önce tekil olarak tekrar okunacaktır.
- [!] T03 Supabase gerçek kolon, grant, RLS, trigger ve Storage metadata şemasını kullanıcı güvenli erişimle incele; `database.md` ile diff çıkar. Gizli key isteme/gösterme.
  - Durum (`blocked`): Yerel makinede `supabase` CLI kurulu değil (`supabase not found`), `.env` veya `supabase/` dizini ve canlı proje bağlantı bilgisi (`SUPABASE_URL` / CLI erişimi) mevcut değil. Güvenli erişim sağlandığında şema diff'i çıkarılacak.
- [x] T04 `AGENTS.md`/mimari/tasarım/sözleşme dosyalarını oku ve sapma kaydı oluştur. Gerekliyse yalnızca gerekçeli güncelle.
  - Sapma kaydı: (1) `design.md` marka renkleri (`#176B5B` / `#F7F8F5`) Stitch otomatik Material 3 tokenlarından (`#005144` / `#EDFDF8`) otorite olarak üstündür. (2) `D01` ve `S01` Stitch HTML'lerinde alt çubukta 4. sekme `Seyahatlerim` olarak yer almış; `project.md` ve `design.md` uyarınca 5 sabit sekme (`Ana Sayfa`, `Keşfet`, `Haritam`, `Topluluk`, `Profil`) korunacak, `Trips` nested route olacaktır. (3) `C01` Stitch HTML nav etiketleri eksik; ortak `AppBottomNavigation` etiketli 5 sekmeyi standartlaştıracaktır. (4) `B01`, `B02`, `D01`, `E05`, `S04` ekranlarında İngilizce başlıklar (`Home`, `Explore`, `My Trips`, `Traveler Profile`, `Create Trip`) mevcut; tüm metinler TR/EN ARB üzerinden sağlanacaktır. (5) `E05` Stitch HTML'de geçen mesajlaşma öğesi V1 kapsamı dışındadır (`features.md`); ölü buton bırakılmayacaktır.
- [x] T05 `pubspec.yaml` bağımlılıkları, `--dart-define`, `go_router`, Riverpod, TR/EN l10n, tema altyapısı; analyze+smoke test.
  - Kanıt: `pubspec.yaml` (`flutter_riverpod: ^3.5.0`, `go_router: ^18.1.4`, `supabase_flutter: ^2.18.3`, `flutter_map: ^8.3.2`, `latlong2: ^0.10.1`, `intl: ^0.20.3`, `google_fonts: ^9.0.0`, `cached_network_image: ^4.0.6`, `image_picker: ^1.2.4`, `shared_preferences: ^2.5.6`, `flutter_localizations`), `l10n.yaml` + TR/EN ARB (`lib/app/l10n/`), merkezi açık/koyu tema (`lib/app/theme/`), `--dart-define` Supabase yapılandırması (`lib/core/config/supabase_config.dart`), 5 sabit sekmeli `go_router` (`lib/app/router/app_router.dart`) ve `AppPreferencesNotifier` (`lib/core/providers/app_preferences_provider.dart`) kuruldu.
- [x] T06 Temel ortak widget'lar, error handling, empty/loading/skeleton, image/cache, erişilebilirlik.
  - Kanıt: `ErrorMapper` + `AppException` (`lib/core/errors/`), `AppBottomNavigation`, `RoamoryScaffold`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `LoadingSkeleton`, `EmptyState`, `ErrorState`, `AppConfirmSheet`/`showAppConfirmSheet`, `AppNetworkImage` (`lib/shared/widgets/`). `dart format lib test`, `flutter analyze` (0 issue) ve `flutter test` (`13/13` test pass).

## P1 — Authentication
- [x] T07 A01–A07 navigasyon ve Google/e-posta Supabase Auth; verified/profile setup, session & deep link.
  - Kanıt: Stitch MCP `projects/2591164501540002750` üzerinden A01–A07 HTML/PNG kaynakları tek tek incelendi; `lib/features/auth/` (`domain`, `data`, `presentation`) Clean Architecture ile kodlandı, `app_tr.arb`/`app_en.arb` ve `app_router.dart` oturum/e-posta doğrulama/profil kurulumu (`UserProfile.isSetupComplete`) yönlendirmeleri eklendi. Android (`AndroidManifest.xml`) ve iOS (`Info.plist`) için `io.roamory.app://login-callback/` deep link ve iOS galeri/kamera izin açıklamaları tanımlandı (`android/app/build.gradle.kts` `applicationId` hâlâ `com.example.roamory`). Canlı Supabase/Google Cloud kimlik bilgileri olmadığı için gerçek cihaz OAuth/SMTP akışı cihazda çalıştırılmadı.
- [!] T08 Auth unit/widget/gerçek entegrasyon testleri; mail SMTP sınırını raporla.
  - Durum (`unit/widget done`, `canlı entegrasyon blocked`): `test/features/auth/auth_unit_test.dart`, `test/features/auth/auth_screens_widget_test.dart` ve güncellenen `test/widget_test.dart` ile toplam `23/23` unit/widget testi geçti (`dart format lib test` → 44 dosya, `flutter analyze` → `No issues found!`, `flutter test` → `All tests passed!`). Gerçek Supabase Auth/Storage entegrasyon testleri `--dart-define` canlı kimlik bilgileri ve özel SMTP yapılandırması olmadığı için çalıştırılamadı; bu nedenle tamamlanmış işaretlenmedi. Varsayılan Supabase Auth SMTP hız sınırları ve iOS simülatör doğrulama eksikliği raporlandı.

## P2 — Keşif ve kişisel kayıtlar
- [ ] T09 B01–B05 keşif, arama, place detail, wishlist, gerçek özet.
- [ ] T10 C01–C06 harita, konum, kategori/filtre, ziyaret, günlük ve fotoğraflar.
- [ ] T11 Manuel private place'lerin wishlist/trip_stops RLS karşılığını incele; migration gerekirse önce onay al.
- [ ] T12 Bu modüllerin testleri ve UI ekran karşılaştırması.

## P3 — Seyahat
- [ ] T13 D01–D05 trip CRUD, günler, duraklar, checklist, filtre, empty state.
- [ ] T14 Tarih/iş akışı/RLS testleri, tasarıma sadakat QA.

## P4 — Topluluk
- [ ] T15 E01–E06 post upload/draft/publish, feed, like/comment/follow/save.
- [ ] T16 Block/report, followers visibility, fotoğraf erişimi ve notifications üretme stratejisi; şema dışı özellikleri raporla.
- [ ] T17 Social RLS/Storage negatif testleri ve UI QA.

## P5 — Profil ve ürün kalitesi
- [ ] T18 F01–F05, S01–S04, TR/EN, dark mode, güncelleme/hesap işlemleri.
- [ ] T19 38 ekran route ve işlev QA; keyboard/safe-area/overflow/izin testleri.
- [ ] T20 Genel `flutter analyze`/`flutter test`/Android build; gerçek test logları; eksik/blocked özeti.

## Gözlenen engeller / bekleyen kararlar
- [ ] SMTP/Resend/domain yok; gerçek kullanıcı e-postası production-ready değil.
- [ ] iOS test için macOS/Xcode gerekli.
- [ ] OSM tile/geocoding servis seçimi ve kullanım şartları.
- [ ] Private `places` -> wishlist/trip stop policy uyuşmazlığı.
- [ ] Ortak seyahat, takipçiye özel post, direkt mesaj, offline harita vb. Stitch görselinde var ama backend'e onaylı şekilde eklenmedi.

## Günlük
| Tarih | Görev | Durum | Test komutu/sonuç | Engeller / sıradaki |
|---|---|---|---|---|
| Başlangıç | Plan oluşturuldu | pending | — | T01'den başla |
| 2026-11-11 | T01, T02, T04 | done | `flutter analyze` (0 issue), `flutter test` (1/1 pass) | `T03` blocked (Supabase CLI/erişim yok) |
| 2026-11-11 | T03 | blocked | — | `supabase` CLI ve güvenli proje erişimi gerekli; T05'e geçiliyor |
| 2026-11-11 | T05, T06 | done | `dart format lib test`, `flutter analyze` (0 issue), `flutter test` (13/13 pass) | Sıradaki: `T07` (A01–A07 Auth & Onboarding) |
| 2026-11-11 | T07 | done | `dart format lib test`, `flutter analyze` (0 issue), `flutter test` (23/23 pass) | Cihazda canlı OAuth/SMTP denemesi yapılmadı; `T08` kısmi |
| 2026-11-11 | T08 | blocked (live E2E) | Unit + widget `flutter test` (23/23 pass); canlı Supabase E2E yok | `T03`/canlı kimlik & SMTP bekliyor; sonraki fonksiyonel faz: `T09` (B01–B05) |


## Ev / Ofis devir takibi
- [x] Çalışmaya başlamadan `DEVIR_NOTLARI.md`, `YAPILANLAR.md`, Git status/branch/HEAD kontrol edildi.
- [x] Bu cihazda Stitch MCP bağlantısı doğrulandı veya engel kaydedildi.
- [x] Her önemli değişiklik `YAPILANLAR.md`'ye tarih, dosyalar, test kanıtı ve Git referansıyla eklendi.
- [x] Oturum sonu `DEVIR_NOTLARI.md` güncellendi; sonraki net görev yazıldı.
- [x] Yerel gizli yapılandırmaların Git'e eklenmediği kontrol edildi.
