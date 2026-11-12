<p align="center">
  <img src="assets/images/roamory_logo.png" alt="Roamory Logo" width="120" />
</p>

<h1 align="center">Roamory — Kişisel Seyahat Atlası, Gezi Günlüğü & Keşif Platformu</h1>

<p align="center">
  Flutter, Clean Architecture, Riverpod, GoRouter, OpenStreetMap ve Supabase ile geliştirilmiş; gizlilik öncelikli kişisel seyahat günlüğü, harita, rota planlama ve topluluk uygulaması.
</p>

---

## 1. Projenin Amacı

**Roamory**, gezginlerin seyahat anılarını, harita pinlerini, ziyaret fotoğraflarını, günlük gezi planlarını ve hazırlık listelerini tek bir **Dijital Pasaport** altında toplaması için geliştirilmiştir.

Uygulamanın temel ilkeleri:
- **Özel Varsayılan Gizlilik:** Kullanıcının oluşturduğu ziyaretler (`visibility = 'private'`), özel mekanlar (`is_published = false`) ve ziyaret fotoğrafları (`visit-photos`) varsayılan olarak gizlidir; topluluk paylaşımı (`posts`) ayrı ve bilinçli bir aksiyondur. Ziyaretten gönderiye dönüştürmede (`C06 -> E02`) özel günlük notları ve özel fotoğraflar otomatik kopyalanmaz.
- **Gerçek Veri & Sıfır Mock Ekran:** Ana Sayfa Dijital Pasaport sayaçları, keşif listeleri, harita pinleri, seyahat planları, topluluk sayaçları ve bildirimler canlı Supabase veritabanından hesaplanır.
- **Kapsamlı Mobil Deneyim:** **34 ana ekran + 4 durum ekranı** (boş durum, yükleme iskeleti, ağ hatası, onay/çıkış diyaloğu) olmak üzere **38 ekran**, **TR/EN** anlık dil değişimi ve **Açık / Koyu** tema desteği içerir.

---

## 2. Temel Özellikler (Modüller)

| Modül | Ekran Kodları | Öne Çıkan İşlevler |
|---|---|---|
| **Kimlik Doğrulama & Kurulum** | `A01`–`A07` | Açılış ekranı (`assets/images/roamory_logo.png`), 3 adımlı onboarding, e-posta/şifre girişi, kayıt, şifre sıfırlama, e-posta doğrulama (`6–8` haneli OTP + bağlantı kontrolü), zorunlu profil kurulumu |
| **Ana Sayfa, Keşif & İstek Listesi** | `B01`–`B05` | Dijital Pasaport sayaçları (ülke/şehir/ziyaret/istek listesi), yaklaşan seyahat, kategori ve filtreli mekan arama, gizlilik kontrollü kapak görselleri, mekan detayı, notlu istek listesi CRUD |
| **Harita & Kişisel Gezi Günlüğü** | `C01`–`C06` | `flutter_map` + OpenStreetMap katmanı, Ziyaret (`#176B5B`) & İstek Listesi (`#D7A65C`) pinleri, Android GPS konum alma, katman/yıl/4+ yıldız filtreleri, 2 adımlı günlük editörü, `visit-photos` çoklu fotoğraf yükleme |
| **Seyahat Planlama & Kontrol Listesi** | `D01`–`D05` | `/trips` iç rotası, tarih aralığına göre otomatik `trip_days` üretimi, düzenleme modunda mevcut verileri koruma, `+ Gün Ekle`, katalog/istek/özel mekandan durak ekleme, sürükle-bırak `sort_order`, kategori & `%` ilerlemeli checklist |
| **Topluluk & Güvenlik** | `E01`–`E06` | Keşfet / Takip Edilenler akışı (`limit/offset` sayfalama), `draft`/`published` gönderi oluşturma, `post-photos` yükleme, beğeni, kaydetme, yorum ekleme/silme, gezgin profili, takipçi/takip edilenler, çift yönlü engelleme (`user_blocks`), şikayet (`content_reports`) |
| **Profil, Bildirim & Ayarlar** | `F01`–`F05` | Dijital Pasaport profili ve 4 sekme, `avatars` yüklemeli profil düzenleme, SQL trigger tabanlı bildirimler (Tümü / Okunmamış / Etkileşimler / Takip), TR/EN & Light/Dark/System ayarları, şifre güncelleme ve hesap verisi temizleme |
| **Ortak Durumlar** | `S01`–`S04` | Boş durum (`EmptyState`), yükleme iskeleti (`LoadingSkeleton`), yeniden dene (`ErrorState`), kaydedilmemiş çıkış/silme onayı (`PopScope` + `showAppConfirmSheet`) |

---

## 3. Mimari Yapı

Roamory, **Clean Architecture**, **SOLID** prensipleri ve **Feature-First** klasör düzeniyle geliştirilmiştir.

### Katman Sınırları
1. **Presentation Katmanı (`presentation/`):** Flutter ekranları, ortak widget'lar (`lib/shared/widgets/`), `go_router` rotaları (`lib/app/router/app_router.dart`) ve Riverpod `Notifier` denetleyicileri (`AuthController`, `ExploreController`, `VisitsController`, `TripsController`, `CommunityController`, `ProfileSettingsController`). UI katmanı doğrudan Supabase SDK veya ham veritabanı sorgusu içermez.
2. **Domain Katmanı (`domain/`):** Saf Dart entity'leri (`PlaceEntity`, `VisitEntity`, `TripEntity`, `TripChecklistItemEntity`, `PostEntity`, `AppNotificationEntity`, `UserProfile`), iş kuralı doğrulayıcıları (`TravelValidators`, `AuthValidators`) ve soyut repository sözleşmeleri (`AuthRepository`, `VisitsRepository`, `TripsRepository`, `ExploreRepository`, `WishlistRepository`, `CommunityRepository`, `ProfileSettingsRepository`). Supabase veya Flutter UI bağımlılığı içermez.
3. **Data Katmanı (`data/`):** Supabase repository implementasyonları, `SupabaseAuthDatasource`, model dönüşümleri ve merkezi hata eşleyici (`ErrorMapper`). Tüm PostgREST, Auth, Storage ve imza URL (`createSignedUrl`) çağrıları bu katmanda izoledir.

### Uçtan Uca Veri Akışı
```text
UI Ekranı (Screen)
  └─> Riverpod Controller (Notifier — state, loading, optimistik sıra geri alma)
        └─> Domain Repository Sözleşmesi (Soyut arayüz)
              └─> Data Repository / Datasource (Supabase SDK + Storage + ErrorMapper)
                    └─> Supabase (Auth • PostgreSQL 20 Tablo & RLS • 3 Storage Bucket • Trigger'lar)
```

### Klasör Yapısı (`lib/`)
```text
lib/
├── main.dart                         # .env yükleme + Supabase.initialize(PKCE) + ProviderScope
├── app/
│   ├── app.dart                      # RoamoryApp: tema, TR/EN l10n, router
│   ├── router/app_router.dart        # 38 ekran rotası, 5 sabit alt sekme kabuğu, auth redirect
│   ├── theme/                        # RoamoryColors, AppTheme (Light/Dark), AppSpacing, AppTypography
│   └── l10n/                         # app_tr.arb, app_en.arb ve üretilen AppLocalizations
├── core/
│   ├── config/supabase_config.dart   # .env + --dart-define çift desteği ve secret key koruması
│   ├── errors/                       # AppException türleri ve ErrorMapper
│   ├── providers/                    # AppPreferencesNotifier (kalıcı tema ve dil)
│   ├── services/location_service.dart# MethodChannel('io.roamory.app/location') GPS köprüsü
│   └── utils/                        # AppDateFormatter (intl), TravelValidators
├── shared/widgets/                   # AppBottomNavigation, RoamoryScaffold, AppNetworkImage, AppStateViews, AppConfirmSheet
└── features/
    ├── auth/                         # A01–A07 (domain / data / presentation)
    ├── home/                         # B01 Ana Sayfa
    ├── explore/ & wishlist/          # B02–B05 Keşif & İstek Listesi
    ├── map/ & visits/                # C01–C06 Harita & Gezi Günlüğü
    ├── trips/                        # D01–D05 Seyahat Planlama & Kontrol Listesi
    ├── community/                    # E01–E06 Topluluk, Yorum, Engelleme & Rapor
    └── profile/, notifications/, settings/ # F01–F05 Profil, Bildirimler & Ayarlar
```

---

## 4. Kullanılan Teknolojiler ve Paketler

### Çekirdek Yığın
- **Mobil Çatı:** Flutter `3.47.9` (stable) • Dart `3.13.7`
- **Durum Yönetimi:** `flutter_riverpod: ^3.5.0`
- **Yönlendirme & Deep Link:** `go_router: ^18.1.4` (`io.roamory.app://login-callback/`)
- **Backend (BaaS):** `supabase_flutter: ^2.18.3` (Auth, PostgREST, PostgreSQL RLS, SQL Trigger, Storage)
- **Harita & Konum:** `flutter_map: ^8.3.2`, `latlong2: ^0.10.1`, OpenStreetMap (`tile.openstreetmap.org`, `User-Agent: io.roamory.app`) ve Android native `MethodChannel('io.roamory.app/location')` (`MainActivity.kt`)
- **Yerelleştirme & Tarih:** `flutter_localizations`, `intl: ^0.20.3` (ARB tabanlı TR/EN)
- **Tipografi, Medya & Depolama:** `google_fonts: ^9.0.0`, `cached_network_image: ^4.0.6`, `image_picker: ^1.2.4`, `shared_preferences: ^2.5.6`, `flutter_dotenv: ^6.0.0`
- **Tasarım Sistemi Kaynağı:** Stitch MCP (`projects/2591164501540002750` — 38 ekran referansı) + `design.md` marka tokenları (`#176B5B` Çam Yeşili, `#D7A65C` Kum Taşı, `#F7F8F5` Kırık Beyaz)

### Backend Mimarisi (Supabase)
- **20 Canlı PostgreSQL Tablosu:**
  - *Kimlik & Güvenlik:* `profiles`, `user_blocks`, `content_reports`
  - *Keşif & İstek Listesi:* `categories`, `places`, `wishlist_items`
  - *Ziyaret & Günlük:* `visits`, `visit_photos`, `visit_categories`
  - *Seyahat Planlama:* `trips`, `trip_days`, `trip_stops`, `trip_checklist_items` (`category` CHECK kısıtı: `documents`, `packing`, `bookings`, `other`)
  - *Topluluk & Bildirimler:* `posts`, `post_photos`, `post_likes`, `saved_posts`, `comments`, `follows`, `notifications`
- **3 Storage Bucket:**
  - `avatars` (`<= 5 MB`)
  - `visit-photos` (private bucket, `<= 10 MB`, `createSignedUrl` ile geçici imzalı URL ve hata anında yetim dosya rollback temizliği)
  - `post-photos` (private bucket, `<= 10 MB`, `createSignedUrl` + rollback koruması)
- **Güvenli Bildirim Trigger Mimarisi:** `authenticated` kullanıcıların `notifications` tablosunda `INSERT`/`DELETE` yetkisi yoktur; bildirimler yalnızca `follows`, `post_likes` ve `comments` tabloları üzerindeki `AFTER INSERT` SQL trigger'ları (`private.create_social_notification()`) tarafından oluşturulur. İstemci yalnızca `SELECT` ve `is_read` kolonu üzerinde `UPDATE` yapabilir.

---

## 5. Kurulum ve Çalıştırma

### Ön Koşullar
- Flutter SDK (`3.47+`) ve Dart SDK (`3.13+`)
- Android Studio / Android SDK (Android derleme ve emülatör için)
- Etkin bir Supabase projesi (URL + **Publishable Key**)

### Adımlar
1. **Bağımlılıkları yükleyin ve l10n dosyalarını üretin:**
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
2. **Ortam değişkenlerini yapılandırın (`.env`):**
   Proje kökündeki `.env.example` dosyasını `.env` olarak kopyalayıp kendi Supabase bilgilerinizi girin:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_key_here
   ```
   > **Güvenlik Uyarısı:** `.env` dosyası `.gitignore` ile hariç tutulmuştur. İstemci tarafında **asla** `service_role` veya secret key kullanmayın; `SupabaseConfig` bu tür anahtarları algıladığında çalışmayı reddeder. Alternatif olarak `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...` ile de çalıştırabilirsiniz.

3. **Kod analizi ve otomatik testleri çalıştırın:**
   ```bash
   dart format lib test
   flutter analyze
   flutter test
   ```
   *Doğrulanan son sonuç:* `flutter analyze` (`No issues found!`), `flutter test` (`46/46` test başarılı).

4. **Uygulamayı çalıştırın veya Release APK üretin:**
   ```bash
   flutter run
   flutter build apk --release
   ```
   *Üretilen APK:* `build/app/outputs/flutter-apk/app-release.apk` (`61.49 MB` / Android `debug` imza yapılandırmalı; Play Store yayını için gerçek upload keystore gerekir).

---

## 6. Proje Belgeleri ve Sunum Kaynakları

- [docs/sunum/Roamory_Proje_Sunumu.pptx](docs/sunum/Roamory_Proje_Sunumu.pptx) & [PDF](docs/sunum/Roamory_Proje_Sunumu.pdf) — 15 slaytlık proje sunumu
- [docs/SUNUM_HAZIRLIK.md](docs/SUNUM_HAZIRLIK.md) — Slayt slayt konuşmacı notları, mimari anlatım, çözülen gerçek hatalar, 32 teknik soru-cevap ve canlı demo akışı
- [docs/QUALITY_CHECKLIST.md](docs/QUALITY_CHECKLIST.md) — 38 ekran ve modüllerin doğrulama matrisi
- [database.md](database.md) — 20 tablo, RLS politikaları, Storage ve SQL trigger sözleşmesi
- [tasks.md](tasks.md), [YAPILANLAR.md](YAPILANLAR.md), [DEVIR_NOTLARI.md](DEVIR_NOTLARI.md) — Görev takibi ve oturum devir günlükleri
