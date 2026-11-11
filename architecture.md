# Roamory — Flutter Mimari Kararları

## Genel yaklaşım
**Feature-first Clean Architecture**: `presentation -> domain <- data`; bağımlılık tersine çevirme. Riverpod state management ve dependency injection, `go_router` navigasyon. Model (DTO) ile domain entity'yi ayır; yönetilebilir birimlerde pragmatik ol, katmanları boş sarmalayıcılarla çoğaltma.

```text
lib/
  main.dart
  app/
    app.dart
    router/app_router.dart
    theme/app_theme.dart
    theme/app_colors.dart
    theme/app_typography.dart
    theme/app_spacing.dart
    l10n/app_tr.arb
    l10n/app_en.arb
  core/
    config/supabase_config.dart
    errors/
    network/
    permissions/
    utils/
    widgets/
  features/
    auth/ onboarding/ home/ explore/ map/ visits/ journal/
    trips/ wishlist/ community/ profile/ notifications/ settings/
  shared/
    widgets/
    extensions/
```

Her feature gerektiği ölçüde:
```text
feature/
  domain/entities/
  domain/repositories/        # soyut sözleşmeler
  domain/usecases/
  data/models/                # JSON/DB DTO
  data/datasources/           # Supabase, map provider
  data/repositories/          # sözleşme implementasyonu
  presentation/providers/     # Riverpod async state
  presentation/screens/
  presentation/widgets/
```

## SOLID uygulaması
- S: Controller'da SQL, widget'ta business rule olmayacak.
- O: Repository/provider soyutlamalarıyla yeni veri kaynağı eklenecek.
- L: Fake repo ve gerçek repo aynı sözleşmeyi sağlayacak.
- I: İhtiyaca yönelik küçük repository arayüzleri.
- D: Domain Supabase SDK'ya değil soyut repository'ye bağımlı.

## Paket ve teknik tercih rehberi
- `supabase_flutter` güncel SDK API'si (`Supabase.initialize(url: ..., publishableKey: ...)` sürümde doğrulanmalı).
- `flutter_riverpod` / `riverpod_annotation` (gerekirse generated), `go_router`, `flutter_map`, `latlong2`, `flutter_localizations`, `intl`, `image_picker`, `cached_network_image`, `freezed`/`json_serializable` uygun sürümlerde.
- Sürüm pinlerini Flutter SDK ile doğrula, paket/pin uydurma. Test için `flutter_test`, fake repository; integration_test ihtiyaç kadar.

## Akış örneği
`VisitScreen -> VisitController(AsyncNotifier) -> CreateVisitUseCase -> VisitRepository -> SupabaseVisitRepository -> SupabaseClient`. Entity yalnızca domain alanlarını bilir; JSON map'i data katmanında dönüştürülür.

## Hata ve yüklenme yönetimi
- Async loading/success/empty/error/retry ayrımı.
- Supabase hata kodlarını kullanıcıya güvenli ve yerelleştirilmiş metne çevir; teknik ayrıntıyı yalnızca gizli olmayan debug log'a yaz.
- Form validation UI + domain katmanı; kaydet sırasında tekrar basmayı engelle; işlem sırasında disabled CTA.
- Ağ yoksa sağlıklı hata/fallback; çevrimdışı kayıt senkronizasyonunu V1 özelliği gibi gösterme.

## Navigasyon
Beş ana destinasyonda ortak shell; auth/onboarding/edition akışlarında ayrı route. Deep-link `io.roamory.app://login-callback/` (OAuth dönüşü), Android intent-filter/iOS URL scheme ile eşleşmeli. URL login callback ile password recovery route davranışını ayır.

## Performans ve erişilebilirlik
Liste sayfalama, arama debounce, görsel ölçekleme/cache, Flutter widget parçalama, dispose edilmiş referans kullanmama, erişilebilir hit-area, semantik etiketler. Konum iznini gerekince iste.

## Türkçe açıklayıcı kod
`AGENTS.md` içindeki DartDoc/yorum standardı zorunludur. Özellikle `Repository`, `UseCase`, `Provider`, `StateNotifier/AsyncNotifier`, Widget, `SupabaseClient` çağrısı, Storage path ve `try/catch` için amaç/neden yorumları yazılır; aşikar tüm satırlar tekrarlanmaz.
