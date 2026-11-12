# Roamory — Sunum Hazırlık ve Teknik Savunma Rehberi (`docs/SUNUM_HAZIRLIK.md`)

> **Amaç:** SoftIto Mobil Eğitim projesi sunumunda **12–15 slaytlık** (`docs/sunum/Roamory_Proje_Sunumu.pptx` ve `docs/sunum/Roamory_Proje_Sunumu.pdf`) akışı akıcı biçimde sunmak, kod tabanını savunmak ve jüri / eğitmen sorularına doğrudan gerçek dosya, sınıf ve satır düzeyinde yanıt verebilmek için hazırlanmıştır.
> **Güvenlik Hatırlatması:** Sunum sırasında canlı `.env` dosyasını, `SUPABASE_PUBLISHABLE_KEY` metnini veya kişisel hesap e-postasını ekrana yansıtmayın.

---

## 1. Sunum Dosyalarını Açma ve Çalıştırma
- **Düzenlenebilir PowerPoint:** `docs/sunum/Roamory_Proje_Sunumu.pptx` (Microsoft PowerPoint 16:9 widescreen, tüm metin kutuları ve görseller düzenlenebilir).
- **Yedek / Paylaşıma Hazır PDF:** `docs/sunum/Roamory_Proje_Sunumu.pdf` (PowerPoint olmayan bilgisayarlarda veya projektörde yazı tipi kayması olmaması için).
- **Sunum öncesi öneri:** Önce `.pptx` dosyasını PowerPoint'te açıp `F5` ile sunucu görünümünü test edin; projektörde sorun çıkarsa `.pdf` sürümünü tam ekran (`Ctrl+L`) açın.

---

## 2. Slayt Slayt Konuşmacı Notları (1–15)

### Slayt 1 — Kapak (Roamory: Kişisel Seyahat & Keşif Platformu)
- **Ne söyleyeceksin:** "Merhaba, ben [Adınız]. SoftIto Mobil Eğitim kapsamında geliştirdiğim **Roamory** uygulamasını sunacağım. Roamory; gezginlerin gittikleri yerleri haritada işaretleyebildiği, özel gezi günlüğü ve fotoğraf arşivi tutabildiği, seyahat planı yapabildiği ve isterlerse anılarını toplulukla paylaşabildiği Flutter + Supabase tabanlı bir mobil seyahat platformudur."
- **Vurgu:** "Özel hayat gizliliği varsayılandır; kullanıcı özellikle paylaşana kadar ziyaretler ve fotoğraflar gizli kalır."

### Slayt 2 — Proje Özeti, Problem ve Çözüm
- **Ne söyleyeceksin:** "Birçok gezgin harita pinlerini ayrı uygulamada, notlarını başka bir not uygulamasında, fotoğraflarını galeride, yapılacaklar listesini başka bir yerde tutuyor. Roamory bu dağınıklığı tek bir **Dijital Pasaport** ve **Kişisel Atlas** altında topluyor."
- **Vurgu:** "Gerçek verilerle çalışır: sahte sayaç, uydurma takipçi sayısı veya mockup ekran yoktur."

### Slayt 3 — Hedef Kitle ve Değer Önerisi
- **Ne söyleyeceksin:** "Üç ana değer önerimiz var: (1) Tek başına gezen veya düzenli arşiv tutmak isteyen kullanıcıya **özel günlük + fotoğraf kasası**, (2) Planlı gezginlere **günlük durak ve hazırlık listesi**, (3) İlham arayan gezginlere **güvenli ve moderasyonlu topluluk**."

### Slayt 4 — Temel Özellikler ve 38 Ekran Mimarisi (`A01`–`F05`, `S01`–`S04`)
- **Ne söyleyeceksin:** "Uygulama **34 ana ekran + 4 durum ekranı (boş, yükleme iskeleti, ağ hatası, doğrulama/çıkış onayı)** olmak üzere **38 ekrandan** oluşuyor. Alt gezinme çubuğu 5 sabit sekmeden oluşur: Ana Sayfa (`B01`), Keşfet (`B02`), Haritam (`C01`), Topluluk (`E01`) ve Profilim (`F01`). Seyahatlerim (`D01`–`D05`) 6. sekme açmadan `/trips` iç rotasıyla bağlanır."

### Slayt 5 — Tasarım Sistemi (`design.md`, `AppTheme`, `RoamoryColors`, Stitch MCP)
- **Ne söyleyeceksin:** "Görsel dilimiz *Earthy Modernist Journal*. Renklerimiz çam yeşili `#176B5B`, kum taşı altını `#D7A65C` ve kırık beyaz `#F7F8F5`. Ekranların hiçbirinde sabit hex renk kodu veya sabit metin yoktur; tüm renkler `RoamoryColors.of(context)` üzerinden, tüm yazılar TR/EN ARB dosyalarından (`lib/app/l10n/`) gelir. Açık ve koyu tema tam desteklidir."

### Slayt 6 — Teknik Mimari (Clean Architecture, SOLID, Feature-First)
- **Ne söyleyeceksin:** "Her özellik `domain`, `data` ve `presentation` alt katmanlarına ayrılmıştır. `domain` katmanı saf Dart kodudur; içinde `supabase_flutter` veya Flutter widget importu bulunmaz. `presentation` katmanı yalnızca Riverpod controller üzerinden `domain` sözleşmeleriyle konuşur; `Supabase` çağrılarının tamamı `data` katmanında izoledir."

### Slayt 7 — Veri Akışı (`UI -> Controller -> Repository -> Datasource -> Supabase`)
- **Ne söyleyeceksin:** "Örneğin bir kullanıcı kontrol listesine madde eklediğinde: `TripChecklistScreen` (`presentation`) -> `TripsController` (`Notifier`) -> `TripsRepository` arayüzü (`domain`) -> `SupabaseTripsRepository` (`data`) -> PostgreSQL (`trip_checklist_items`) sırasıyla ilerler. Bir hata oluşursa `ErrorMapper` teknik PostgREST veya Auth kodunu gizleyip güvenli yerelleştirilmiş `AppException` mesajına dönüştürür."

### Slayt 8 — Veritabanı, RLS ve Storage Güvenliği (20 Tablo, 3 Bucket)
- **Ne söyleyeceksin:** "Backend tarafında PostgreSQL üzerinde **20 tablo** ve sıkı **Row Level Security (RLS)** politikaları var. `avatars` (5 MB), `visit-photos` (private, 10 MB) ve `post-photos` (private, 10 MB) bucket'ları kullanılır. Özel fotoğraflar `createSignedUrl` ile geçici imzalı URL alır. Bildirimler istemciden yazılamaz; Supabase üzerinde `private.create_social_notification()` trigger fonksiyonuyla `follows`, `post_likes` ve `comments` tablolarından otomatik üretilir."

### Slayt 9 — Kimlik Doğrulama ve Güvenlik (`.env`, Auth, Profil Kurulumu, Deep Link)
- **Ne söyleyeceksin:** "İstemciye yalnızca `.env` (veya `--dart-define`) üzerinden `SUPABASE_URL` ve `SUPABASE_PUBLISHABLE_KEY` verilir; `SupabaseConfig` yanlışlıkla `service_role` / `secret` anahtar girilirse uygulamayı başlatmayı reddeder. Kayıt sonrası oturum, e-posta doğrulama (`A06`) ve profil kurulumu (`A07`) `app_router.dart` tarafından otomatik yönetilir."

### Slayt 10 — Harita, GPS ve Konum Özellikleri
- **Ne söyleyeceksin:** "Harita tarafında Google Maps anahtarı gerektirmeyen `flutter_map` + OpenStreetMap karo katmanı kullanılır (`User-Agent: io.roamory.app` ve zorunlu `© OpenStreetMap katkıda bulunanlar` atfı ile). Ziyaret edilen mekanlar çam yeşili pinle, istek listesi kum taşı pinle gösterilir. Konum izni için Android `MainActivity.kt` üzerinde `io.roamory.app/location` `MethodChannel` köprüsü yazıldı."

### Slayt 11 — Gezi Günlüğü, Fotoğraf Yükleme ve Özel/Genel Gizlilik Modeli
- **Ne söyleyeceksin:** "Ziyaret kaydı 2 adımlıdır (`C04` + `C05`). Kullanıcı katalogdan seçebilir veya kendi özel mekanını (`is_published = false`) ekleyebilir. `SupabaseVisitsRepository.upsertVisit`, fotoğraf yükledikten sonra DB kaydı başarısız olursa Storage'daki yüklenen dosyayı ve yeni oluşturulan mekan/ziyaret satırını otomatik geri alır (**orphan file rollback**)."

### Slayt 12 — Seyahat Planlama ve Kontrol Listesi (`D01`–`D05`)
- **Ne söyleyeceksin:** "Seyahat oluşturulduğunda tarih aralığı kadar `trip_days` otomatik açılır. Düzenleme modunda mevcut günler, duraklar ve checklist korunur; tarih uzatılırsa yalnız eksik günler eklenir. Durak sırası sürükle-bırak ile değişir ve DB başarısız olursa önceki sıra geri alınır. Checklist ise canlı PostgreSQL CHECK kısıtının (`documents`, `packing`, `bookings`, `other`) birebir karşılığıyla çalışır ve yüzde ilerleme gösterir."

### Slayt 13 — Topluluk ve Bildirim Sistemi (`E01`–`E06`, `F03`)
- **Ne söyleyeceksin:** "Ziyareti topluluk gönderisine dönüştürürken (`C06 -> E02`) özel günlük notları ve özel ziyaret fotoğrafları otomatik kopyalanmaz; yalnızca kullanıcı isterse yeni yayın oluşturur. `user_blocks` çift yönlü filtre uygular. Bildirimler (`F03`) veritabanı trigger'larıyla üretilir; istemci sadece okur ve yalnızca `is_read` alanını günceller."

### Slayt 14 — Test, Kalite Kontrol ve Çözülen Gerçek Hatalar
- **Ne söyleyeceksin:** "Süreçte `42501 places` yetki hatası, `42501 trip_days` tarih aralığı hatası, `23514 trip_checklist_items_category_check` kategori uyuşmazlığı ve `D02` düzenleme parametre hatası logcat üzerinden kök nedenine inilerek çözüldü. Tüm proje güncel otomatik testlerle (`dart format`, `flutter analyze`, `flutter test`) doğrulanmıştır ve temel akışlar Android emülatöründe canlı Supabase ile test edilmiştir."

### Slayt 15 — APK Çıktısı, Şeffaf Sınırlamalar ve Gelecek Planı
- **Ne söyleyeceksin:** "Son olarak özel Roamory pusula/pin logomuzu (`assets/images/roamory_logo.png` ve Android adaptif ikonları) içeren kurulabilir Android APK çıktısı (`build/app/outputs/flutter-apk/app-release.apk`, `61.49 MB`) alındı ve Android emülatöründe (`emulator-5554`) kurulup canlı Supabase bağlantısıyla çalıştırıldı. Not olarak release APK şu an `android/app/build.gradle.kts` içinde debug imza yapılandırması kullanmaktadır; Play Store yayını için gerçek upload keystore gerekir. İki hesaplı canlı bildirim/sosyal senaryoları, e-posta link/OTP uçtan uca akışı ve fiziksel cihazda Google OAuth adımları şeffaf biçimde sonraki adım olarak ayrılmıştır. Teşekkür ederim, sorularınızı alabilirim."

---

## 3. Gerçek Klasör ve Clean Architecture Yapısı (`lib/`)

```text
lib/
├── main.dart                          # .env (SupabaseConfig.loadEnv) + Supabase.initialize + ProviderScope
├── app/
│   ├── app.dart                       # RoamoryApp: AppTheme (Light/Dark), TR/EN l10n, appRouterProvider
│   ├── router/app_router.dart         # AppRoutes (38 ekran rotası), 5 sekmeli shell, Auth yönlendirmeleri
│   ├── theme/                         # app_colors.dart (RoamoryColors), app_spacing.dart, app_typography.dart, app_theme.dart
│   └── l10n/                          # app_tr.arb, app_en.arb ve flutter gen-l10n çıktıları
├── core/
│   ├── config/supabase_config.dart    # .env + --dart-define okuma, publishable key & secret key koruma kontrolü
│   ├── errors/                        # app_exception.dart, error_mapper.dart (Postgrest/Auth/Storage güvenli dönüşüm)
│   ├── providers/app_preferences_provider.dart # Tema (Light/Dark/System) ve dil (TR/EN) kalıcı tercihi
│   ├── services/location_service.dart # MethodChannel('io.roamory.app/location') üzerinden GPS/izin yönetimi
│   └── utils/                         # app_date_formatter.dart, travel_validators.dart
├── shared/widgets/                    # app_bottom_navigation, app_buttons, app_confirm_sheet, app_network_image, app_state_views, app_text_field, roamory_scaffold
└── features/                          # Feature-first: her özellik domain / data / presentation katmanlı
    ├── auth/                          # A01–A07 (SupabaseAuthDatasource -> SupabaseAuthRepository -> AuthController)
    ├── home/                          # B01 Ana Sayfa (Dijital Pasaport + özet akış)
    ├── explore/ & wishlist/           # B02–B05 (SupabaseExploreRepository, SupabaseWishlistRepository, ExploreController)
    ├── map/ & visits/                 # C01–C06 (MyMapScreen, MapFilterSheet, SupabaseVisitsRepository, VisitsController)
    ├── trips/                         # D01–D05 (SupabaseTripsRepository, TripsController, TripChecklistScreen vb.)
    ├── community/                     # E01–E06 (SupabaseCommunityRepository, CommunityController, ReportContentSheet)
    └── profile/, notifications/, settings/ # F01–F05 (SupabaseProfileSettingsRepository, ProfileSettingsController)
```

---

## 4. Temel Veri Akışları (Koddan Gerçek Örneklerle)

### 4.1 Uygulama Başlangıcı (`lib/main.dart` -> `RoamoryApp` -> `app_router.dart`)
1. `main()` içinde `WidgetsFlutterBinding.ensureInitialized()` çağrılır.
2. `SupabaseConfig.loadEnv()` kök dizindeki `.env` asset'ini `flutter_dotenv` ile yükler; yoksa `--dart-define` değerlerine bakar.
3. `SupabaseConfig.isConfigured` doğru ise `Supabase.initialize(url: ..., anonKey: ...)` çalıştırılır (`authFlowType: AuthFlowType.pkce`).
4. `runApp(const ProviderScope(child: RoamoryApp()))` çalıştırılır.
5. `AuthController.build()` içinde `authRepository.watchAuthChanges()` dinlenir ve `resolveInitialSession()` çalışır.
6. `appRouterProvider` içindeki `redirect` mantığı kullanıcının `AuthSessionState.status` değerine göre kullanıcıyı `/onboarding`, `/auth/login`, `/auth/verify-email`, `/auth/profile-setup` veya `/home` rotasına yönlendirir.

### 4.2 Ziyaret + Fotoğraf Yükleme (`AddVisitAndJournalScreen` -> `SupabaseVisitsRepository.upsertVisit`)
1. Kullanıcı `C04` (mekan/tarih/puan/GPS) ve `C05` (başlık/not/kategori/fotoğraf) formunu doldurup Kaydet'e basar.
2. `VisitsController` isteği `SupabaseVisitsRepository.upsertVisit(UpsertVisitRequest)` metoduna iletir.
3. İlk olarak `TravelValidators.validateVisitRequest(request)` koordinat, 1–5 puan ve `<= 10 MB` fotoğraf boyutunu doğrular.
4. `client.auth.currentUser?.id` ile `request.userId` eşleştirilir (`auth_uid_mismatch` / `auth_session_missing` koruması).
5. Özel mekan seçilmişse `places` tablosuna `is_published: false` ve `TravelValidators.normalizeCountryCode` / `normalizeCityName` ile kayıt açılır.
6. `visits` tablosuna `visibility: 'private'` olarak `.insert()` (veya düzenlemede `.update()`) atılır.
7. Fotoğraflar `visit-photos` Storage bucket'ına `userId/visitId/zaman_damgasi_dosya.ext` yoluna yüklenir ve `visit_photos` metadata satırları eklenir.
8. **Hata olursa:** `catch` bloğu yüklenen Storage dosyalarını, yeni oluşturulan `visit` satırını ve yeni özel `place` satırını ters sırayla temizler (**rollback**).

### 4.3 Seyahat ve Checklist (`TripChecklistScreen` -> `TripsController` -> `SupabaseTripsRepository`)
1. `TripChecklistScreen` (`D05`) açılışta `TripChecklistCategory.other` (`Genel Hazırlık`) varsayılanını seçer; kullanıcı `documents`, `packing`, `bookings`, `other` arasında ARB etiketli seçim yapar.
2. `TripsController.addChecklistItem` -> `SupabaseTripsRepository.addChecklistItem` çağrılır; geçersiz kategori kodu varsa repository güvenli biçimde `TripChecklistCategory.other` kullanır.
3. Yeni madde mevcut `sort_order` en büyük değerinin `max + 1` sırasıyla eklenir; DB satırı dönünce UI listesi ve tamamlanma yüzdesi (`%`) güncellenir.
4. DB kısıt (`23514`) veya RLS (`42501`) hatası gelirse `ErrorMapper.map` devreye girer ve ekranın altındaki `SnackBar` üzerinden yerelleştirilmiş hata gösterir.

---

## 5. Geliştirme Sırasında Çözülen Gerçek Hatalar (Örnek Savunma Hikayeleri)

| # | Gerçek Hata (Logcat / Emülatör) | Kök Neden | Uygulanan Kalıcı Çözüm | İlgili Dosyalar |
|---|---|---|---|---|
| 1 | `PostgrestException(code: 42501, permission denied for table places)` | `places` tablosunda `authenticated` rolünün `INSERT` yetkisi ve bazı `wishlist_items`/`trip_stops` RLS politikaları eksikti. | Kullanıcıya SQL önerisi (`20260412000001_private_places_rls_proposal.sql`) sunularak canlı yetkiler açıldı; repository içine oturum ID doğrulaması ve tam rollback eklendi. | `supabase_visits_repository.dart`, `error_mapper.dart`, `20260412000001_private_places_rls_proposal.sql` |
| 2 | Keşfet/Ana Sayfa mekan kartlarında placeholder & özel fotoğraf sızıntı riski | Her mekanda `places.cover_image_url` yoktu; doğrudan `visit_photos` kullanılırsa özel fotoğraflar sızabilirdi. | `resolvePlaceCoverUrl` ile public mekanlarda yalnız `places.cover_image_url` veya yayınlı `post_photos`, özel mekanlarda yalnızca sahibinin `visit_photos` imzalı URL'si çözüldü. | `supabase_explore_repository.dart`, `place_entity.dart` |
| 3 | Seyahat Detayı `Düzenle` butonunun yeni seyahat ekranı açması | `AppRoutes.tripCreate` rotasına `?tripId=...` parametresi verilmiyordu. | `TripDetailsScreen` `?tripId=${trip.id}` geçirecek şekilde bağlandı; `CreateTripScreen` `_hydrateFromExisting` ile mevcut kaydı doldurup `UPDATE` yapar hale getirildi; tarih uzatılınca yalnız eksik günler eklendi. | `trip_details_screen.dart`, `create_trip_screen.dart`, `app_router.dart`, `supabase_trips_repository.dart` |
| 4 | `+ Gün Ekle` işleminde `42501` (`trip_days` RLS ihlali) | Canlı `trip_days` RLS politikası `day_date` değerinin `trips` `[start_date, end_date]` aralığında olmasını zorunlu kılıyordu. | `SupabaseTripsRepository.addTripDay`, yeni gün aralık dışındaysa önce `trips` tarih sınırını genişletir; insert başarısız olursa `trips` tarihini geri alır. | `supabase_trips_repository.dart` |
| 5 | Checklist eklemede `23514` (`trip_checklist_items_category_check`) | Uygulama `'general'`/`'docs'`/`'gear'`/`'hotel'` gönderirken canlı DB kısıtı yalnızca `'documents'`/`'packing'`/`'bookings'`/`'other'` kabul ediyordu. | Mevcut DB kısıtına dokunulmadan Flutter `TripChecklistCategory` değerleri ve ARB etiketleri birebir canlı 4 değere hizalandı; regresyon testleri eklendi. | `trip_entity.dart`, `trip_checklist_screen.dart`, `supabase_trips_repository.dart`, `app_tr.arb` |
| 6 | Topluluk & Bildirim filtre/çift dokunma ve `is_read` güvenliği | `NotificationFilter.interactions` yorumları kaçırıyordu; beğen/kaydet hızlı tıklamada yarışa girebiliyordu. | `interactions` hem `like` hem `comment` alacak şekilde düzeltildi; `isSubmitting` / işlem kilidi eklendi; DB trigger'larına geçildi ve `NotificationsScreen` yalnız okunmamışta `UPDATE (is_read)` atacak şekilde sıkılaştırıldı. | `settings_and_security_screens.dart`, `community_controller.dart`, `supabase_profile_settings_repository.dart` |

---

## 6. Sık Sorulabilecek Teknik Sorular ve Cevaplar (32 Soru)

### A. Mimari ve Flutter Temelleri
1. **Neden Clean Architecture + Feature-First kullandınız?**
   > Her modül (`auth`, `visits`, `trips`, `community` vb.) kendi `domain`, `data`, `presentation` klasörüne sahip. Böylece Supabase şeması veya paket değiştiğinde yalnızca `data` katmanı güncellenir; `domain` ve ekran widget'ları bozulmaz.
2. **Domain katmanının Supabase'den bağımsız olduğunu nasıl garanti ediyorsunuz?**
   > `lib/features/*/domain/` altındaki dosyalarda `package:supabase_flutter` importu yoktur. Tüm işlemler `VisitRepository`, `TripsRepository` gibi soyut sınıflar üzerinden tanımlanır.
3. **Neden Riverpod tercih ettiniz?**
   > Derleme zamanı güvenliği, `BuildContext`'e bağımlı olmadan provider paylaşımı, testlerde `ProviderContainer` / `ProviderScope(overrides: ...)` ile fake repository enjekte etme kolaylığı ve `Notifier` tabanlı öngörülebilir state yönetimi için kullandık.
4. **Testlerde gerçek Supabase'e bağlanmadan ekranları nasıl test ettiniz?**
   > `authRepositoryProvider`, `visitsControllerProvider`, `tripsControllerProvider` gibi Riverpod provider'larını testlerde fake/in-memory implementasyonlarla override ederek 46 otomatik birim/widget/akış testi koşturduk (`test/features/`).
5. **Navigasyonda neden `go_router` kullandınız ve alt sekme sayısı neden 5?**
   > `go_router` bildirimsel yönlendirme (`redirect`), parametre/query (`?tripId=`, `:visitId`), iç rota (`/trips`) ve deep link (`io.roamory.app://login-callback/`) desteği sunar. `project.md` ve `design.md` gereği ana kabuk 5 sabit sekmeden (`Ana Sayfa`, `Keşfet`, `Haritam`, `Topluluk`, `Profil`) oluşur; `D01` Seyahatlerim iç rota olarak bağlanmıştır.
6. **Tema ve renk yönetimini nasıl merkezileştirdiniz?**
   > `RoamoryColors` (`ThemeExtension`) ve `AppTheme.light` / `AppTheme.dark` (`lib/app/theme/`) tanımlandı. Ekranlarda sabit hex kodu yazılmaz; seçili chip kontrastı gibi detaylar bile `ChipThemeData` üzerinde `WidgetStateColor` ile çözülmüştür.
7. **TR/EN çoklu dil desteği nasıl çalışıyor?**
   > `lib/app/l10n/app_tr.arb` ve `app_en.arb` dosyalarından `flutter gen-l10n` ile üretilen `AppLocalizations` kullanılır. Tarihler de `AppDateFormatter` (`intl`) ile seçili dile göre (`12 Kasım 2026` / `Nov 12, 2026`) biçimlenir; `SettingsScreen` içinden yeniden başlatmadan anlık değiştirilebilir.
8. **Sayfadan kaydedilmeden çıkılınca veri kaybını nasıl önlüyorsunuz?**
   > `C04`, `C05`, `D02`, `E02`, `F02` formlarında `_isDirty` bayrağı ve Flutter `PopScope` + ortak `showAppConfirmSheet` (`S04`) alt sayfası kullanılarak kullanıcıdan onay alınır.

### B. Güvenlik, Supabase ve RLS
9. **Uygulama içinde neden `service_role` veya secret key yok?**
   > `service_role` RLS'yi tamamen baypas ettiği için mobil uygulamaya gömülmesi kritik güvenlik açığıdır. `SupabaseConfig` (`.env` ve `--dart-define`) sadece `SUPABASE_URL` ve `SUPABASE_PUBLISHABLE_KEY` kabul eder; gizli/servis anahtarı tespit ederse hata fırlatır.
10. **`.env` dosyasını nasıl güvende tutuyorsunuz?**
    > `.gitignore` içinde `.env` hariç tutulmuştur; repoda yalnızca örnek yer tutuculu `.env.example` bulunur. Hiçbir doküman veya log dosyasında gerçek URL/anahtar yazmaz.
11. **RLS (Row Level Security) nedir ve Roamory'de nasıl çalışır?**
    > PostgreSQL satır bazlı erişim denetimidir. `auth.uid() = user_id` kuralı sayesinde kötü niyetli bir istemci başka kullanıcının özel ziyaretini (`visibility = 'private'`), kontrol listesini veya taslak gönderisini doğrudan REST API ile bile çekemez.
12. **Bir kullanıcının özel ziyaret fotoğrafları başka kullanıcıya sızabilir mi?**
    > Hayır. `visit-photos` ve `post-photos` private bucket'tır. `visits` RLS sadece sahibine açıktır. Ayrıca `SupabaseExploreRepository.resolvePlaceCoverUrl`, genel mekan kapaklarında yalnızca `places.cover_image_url` veya yayınlanmış (`status = 'published'`) `post_photos` kullanır; özel mekanların fotoğrafını yalnızca oluşturan kullanıcıya signed URL ile verir.
13. **`createSignedUrl` nedir ve neden kullandınız?**
    > Private Storage bucket içindeki dosyalara kalıcı public link verilmez; bunun yerine süresi dolan (ör. 3600 saniyelik) geçici imzalı URL üretilir. Böylece link tahmin edilerek fotoğraflara erişilemez.
14. **Fotoğraf yükleme sırasında internet kopar veya DB hata verirse Storage'da çöp dosya kalıyor mu?**
    > Kalmaz. `SupabaseVisitsRepository.upsertVisit` ve `SupabaseCommunityRepository` içinde `uploadedPaths` listesi tutulur; sonraki DB adımı hata verirse `catch` bloğu yüklenen dosyaları `storage.from(...).remove(...)` ile geri temizler.
15. **Bildirimler neden Flutter uygulamasından INSERT edilmiyor?**
    > İstemcinin doğrudan başka kullanıcı adına bildirim satırı eklemesi sahte bildirim/spam riskine yol açar. Canlı Supabase üzerinde `notifications` tablosundan istemci `INSERT` ve `DELETE` yetkileri kaldırılmıştır; bildirimler yalnızca `follows`, `post_likes` ve `comments` üzerindeki `AFTER INSERT` SQL trigger'ları (`private.create_social_notification`) tarafından oluşturulur.
16. **Kullanıcı bildirimleri nasıl okundu işaretliyor?**
    > `authenticated` rolüne yalnızca `is_read` kolonunda `UPDATE` izni verilmiştir. `NotificationsScreen` ayrıca zaten okunmuş bildirimde (`if (!n.isRead)`) gereksiz `UPDATE` isteği atmaz.
17. **Engellenen kullanıcılar toplulukta tamamen gizleniyor mu?**
    > Evet. `user_blocks` üzerinden hem benim engellediklerim hem beni engellemiş olabilecek kayıtlar süzülür; kullanıcı engellendiğinde `CommunityController` akış ve yorum önbelleğinden ilgili yazarın içeriklerini anında temizler.
18. **`ErrorMapper` ne işe yarar?**
    > Alt katmandan gelen ham `PostgrestException`, `AuthException` veya `SocketException` ayrıntılarını kullanıcıya göstermeden güvenli `AppException` türlerine çevirir; teknik detay yalnızca `debugPrint` ile loglanır.

### C. Modüller, Harita, Ziyaret ve Seyahat
19. **Neden Google Maps yerine `flutter_map` + OpenStreetMap kullandınız?**
    > API anahtarı/faturalandırma zorunluluğu olmadan Android ve iOS'ta açık kaynak harita sunmak için seçildi. Zorunlu OpenStreetMap kullanım kuralı gereği `userAgentPackageName: 'io.roamory.app'` gönderilir ve `C01`, `B04`, `F04` ekranlarında `© OpenStreetMap katkıda bulunanlar` atfı görünür.
20. **Konum (GPS) iznini nasıl aldınız, neden ekstra eklenti yerine `MethodChannel` yazdınız?**
    > Gereksiz üçüncü parti konum eklentisi bağımlılığı ve sürüm çakışması yaratmamak için Android `MainActivity.kt` içinde `MethodChannel('io.roamory.app/location')` ile doğrudan Android `LocationManager` + çalışma zamanı `ACCESS_FINE_LOCATION` izni bağlandı.
21. **Pasaport sayaçlarında `İstanbul` ile `istanbul` veya `TR` ile `Türkiye` nasıl tek sayılıyor?**
    > `TravelValidators.normalizeCountryCode`, `normalizeCountryName` ve `normalizeCityName` hem özel mekan kaydında hem de sayaç hesaplamasında ülke ve şehir yazımlarını tek biçime normalleştirir.
22. **Ziyaret kaydı oluştururken `insert()` ve `update()` neden ayrı?**
    > Supabase `upsert()` bazı durumlarda hem INSERT hem UPDATE RLS politikasını tetikleyebilir. `SupabaseVisitsRepository` ve `SupabaseTripsRepository` yeni kayıtta `.insert()`, mevcut kayıtta `.update().eq('id', ...).eq('user_id', ...)` kullanarak RLS politikalarını net ayırır.
23. **`+ Gün Ekle` butonu neden `42501` hatası veriyordu ve nasıl çözdünüz?**
    > Canlı `trip_days` RLS politikası eklenen `day_date`'in üst `trips` kaydının `[start_date, end_date]` aralığında olmasını zorunlu tutuyordu. `SupabaseTripsRepository.addTripDay` önce `trips` tarih sınırını genişletip gün ekler; insert başarısız olursa eski `trips` tarihlerini geri alır.
24. **Checklist eklemedeki `23514` hatasını neden veritabanı constraint'ini değiştirerek çözmediniz?**
    > Proje kuralı gereği mevcut canlı veritabanı şemasına ve constraint'lerine yıkıcı müdahale yapılmadı. Canlı `trip_checklist_items_category_check` (`documents`, `packing`, `bookings`, `other`) doğrulandı ve Flutter tarafındaki `TripChecklistCategory` ile ARB etiketleri buna göre hizalandı.
25. **Durak sıralama (`D04`) sırasında ağ hatası olursa ne olur?**
    > `TripsController` iyimser (optimistic) UI sırasını hemen günceller ama `reorderDayStops` başarısız olursa önceki sıralama durumunu geri yükler ve hata bildirimi gösterir.
26. **Seyahat tarihini düzenleyince mevcut duraklar ve kontrol listesi siliniyor mu?**
    > Hayır. `updateTrip` içinde mevcut günler, duraklar ve checklist korunur; tarih aralığı uzatılırsa `buildMissingDaysForExtendedTrip` yalnız eksik yeni günleri ekler.
27. **Ziyareti topluluk gönderisine dönüştürürken (`C06 -> E02`) özel notlar neden kopyalanmıyor?**
    > Gizlilik prensibimiz gereği özel gezi günlüğü notları ve özel fotoğraflar yanlışlıkla topluluğa sızmamalıdır. Yalnızca mekan referansı aktarılır; kullanıcı başlık/açıklama ve yayın fotoğrafını bilinçli olarak seçer.

### D. Supabase Auth, PostgREST ve Canlı Süreçler
28. **E-posta doğrulama (`A06`) canlıda nasıl çalışıyor?**
    > Canlı Supabase'de `mailer_autoconfirm: false` aktiftir. Kullanıcı kayıt olduğunda veya doğrulanmamış hesapla giriş yaptığında (`email_not_confirmed`) `AuthController` kullanıcıyı `A06` ekranına yönlendirir. Kullanıcı e-postadaki bağlantıya tıkladıktan sonra "Doğrulamayı Kontrol Et" (`refreshVerificationStatus`) ile veya 6–8 haneli OTP kodu girerek doğrulamayı tamamlar.
29. **Supabase varsayılan e-posta servisinin sınırı nedir?**
    > Özel SMTP/domain kurulmadığında Supabase dahili e-posta servisi saatlik gönderim hız sınırına (rate limit / `HTTP 429`) tabidir. `ErrorMapper` `429` kodunu yakalayıp kullanıcıya bilgilendirme mesajı gösterir.
30. **`posts` sorgusunda `profiles!posts_user_id_fkey` yazımını neden kullandınız?**
    > `posts` ile `profiles` arasında hem yazar ilişkisi (`user_id`) hem de `post_likes`/`saved_posts` üzerinden dolaylı ilişkiler bulunduğundan PostgREST `PGRST201` (belirsiz ilişki) hatası verebiliyordu. Açık foreign key adıyla belirsizlik giderildi.
31. **Stitch MCP'de görünen ama backend'de olmayan özellikleri (DM, Stories) ne yaptınız?**
    > Uygulama kalitesi ve dürüstlük kuralı gereği sahte veya tıklanınca hiçbir şey yapmayan ölü butonlar eklenmedi; kapsam dışı öğeler `docs/screen_inventory.md` ve `docs/QUALITY_CHECKLIST.md` içinde sapma kaydı olarak belgelendi.
32. **Bu sürüm Google Play Store'a yüklenmeye hazır mı?**
    > Teknik olarak release APK derlendi ve kurulabilir durumda, ancak `android/app/build.gradle.kts` içinde şimdilik Android debug keystore ile imzalıdır. Store yayını için gerçek upload keystore, Google OAuth fiziksel cihaz doğrulaması ve özel SMTP alan adı yapılandırması gerekir.

---

## 7. Canlı Demo Senaryosu (5–7 Dakika)

1. **Dakika 0:00–1:00 — Giriş ve Dijital Pasaport (`A01` / `A03` -> `B01`):**
   - Uygulamayı aç, daha önce doğrulanmış test hesabıyla giriş yap.
   - `B01` Ana Sayfa üzerinde gerçek Dijital Pasaport sayaçlarını (Ülke, Şehir, Ziyaret), Türkçe tarih biçimini ve yaklaşan seyahati göster.
2. **Dakika 1:00–2:30 — Keşif, Mekan Detayı ve İstek Listesi (`B02`, `B04`, `B05`):**
   - Keşfet'te kategori filtresi seç (açık/koyu tema chip kontrastını vurgula).
   - Bir mekan detayını aç, mini OSM haritasını göster ve İstek Listeme ekle/not güncelle.
3. **Dakika 2:30–4:00 — Kişisel Harita, GPS ve Gezi Günlüğü (`C01`, `C04`, `C05`, `C06`):**
   - `Haritam` sekmesinde ziyaret ve istek listesi pinlerini göster; OpenStreetMap atfına işaret et.
   - Yeni özel mekan veya mevcut mekandan `C04 -> C05` ziyaret günlüğü + fotoğraf yüklemesini göster; `C06` detayında görüntülendiğini göster.
4. **Dakika 4:00–5:30 — Seyahat Planlama ve Kontrol Listesi (`D01`–`D05`):**
   - `Seyahatlerim` içinden bir seyahate gir -> `Günlük Plan` üzerinde durak ekle/sırala -> `Kontrol Listesi` üzerinde `Rezervasyonlar` (`bookings`) veya `Genel Hazırlık` (`other`) kategorisinde madde ekle, tamamla ve `%` ilerlemesini göster.
5. **Dakika 5:30–6:30 — Topluluk, Bildirim ve Ayarlar (`E01`, `E03`, `F01`, `F03`, `F04`):**
   - Topluluk akışında gönderi aç, profil sayfasına geç, `Ayarlar` içinden anlık `TR/EN` dil ve `Koyu/Açık` tema değişimini canlı göstererek demo kapanışını yap.
