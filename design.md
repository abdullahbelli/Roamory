# Roamory — Stitch Kaynaklı Tasarım Sistemi

## Kaynak
- Stitch proje: **Roamory Travel App UI System**, `projects/2591164501540002750`.
- Tasarım sistemi: **Earthy Modernist Journal**, resource `assets/0c1b672082e24d4e990c7d6b510f4764`.
- 34 ana + 4 durum ekranı; referans ve Screen ID listesi `docs/screen_inventory.md`.
- Kodlamadan önce **her** ekranın MCP HTML + PNG kaynağını al. HTML görsel ölçü için yardımcıdır, doğrudan Flutter'a HTML gömme. Tasarımı Flutter widget ağacıyla uygula.

## Tek otoriter marka renkleri
| Token | HEX | Kullanım |
|---|---|---|
| primary | `#176B5B` | CTA/aktif nav/ziyaret pini |
| primaryContainer | `#E0F2ED` | chip/rozet |
| accent | `#D7A65C` | wishlist/yıldız/dönüm noktası |
| accentContainer | `#FBF3E6` | sıcak vurgu |
| tertiary | `#4A90E2` | topluluk pini |
| background | `#F7F8F5` | ana zemin |
| surface | `#FFFFFF` | kart/modal |
| surfaceVariant | `#EEF2EE` | giriş/segmented |
| outline | `#D9E2DF` | sınır |
| textPrimary | `#1F2D2A` | ana metin |
| textSecondary | `#596D68` | açıklama |
| error | `#D34538` | hata |
| warning | `#E68A1B` | uyarı |
| success | `#2E8B57` | başarı |

**Çakışma kararı:** Stitch raporundaki otomatik Material 3 tokenları (`primary #005144`, `background #EDFDF8`) farklı. Marka tablosu otoritedir; ondan uyumlu ThemeData/ColorScheme üret, istemsiz yeniden renklendirme yapma.

## Tipografi
- Başlıklar **Plus Jakarta Sans**; body/label **Inter**; lisanslı Google Fonts erişimi veya uygun paket kullanılabilir; hiçbir font dosyası repoya izinsiz eklenmesin.
- display 30/38 mobil 700; headline 26/32 700, 22/28 600, 18/24 600; title 16/22 600; body 16/24 veya 14/20; label 14/18, 12/16, 10/14.
- Türkçe `ç ğ ı ö ş ü İ` doğrula. TR/EN çeviri Flutter ARB ile; yazılar widget'ta hardcode edilmez.

## Yerleşim
- Ana viewport referansı 393×852; 8pt grid (4pt alt-grid).
- margin 20, gutter 16; spacing 4/8/16/24/32; radius 4/8/12/16/24/pill.
- Primary button yaklaşık 52 yüksek, 14 radius; input 48 yüksek/12 radius; chip 36 yüksek pill; card 16 radius, hafif outline/shadow.
- Photo hero 4:3 / 16:9; fotoğraf placeholder yalnızca empty state olarak; gerçek veride kaynak lisansları kontrol.
- Bottom pill nav: yatay 20 margin, 64 yükseklik, cihaz safe-area üstünde 16 boşluk, pill; 5 sekme sabit: Ana Sayfa, Keşfet, Haritam, Topluluk, Profil.
- Map marker: visited green/check, wishlist gold/star, community blue/pin. Harita attribution görünür; tile/geocoding politikası korunur.
- `app_theme.dart`, `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`; dark mode için ayrı semantik tokenlar geliştir ve görsel QA yap.

## Bileşen kütüphanesi
`RoamoryScaffold`, `AppBottomNavigation`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `DestinationCard`, `VisitCard`, `TripCard`, `PostCard`, `TravelChip`, `LoadingSkeleton`, `EmptyState`, `ErrorState`, `AppConfirmSheet`, `MapPlaceSheet`, `Avatar`, `PhotoCarousel`. Yeniden kullanım gerçekse shared'e taşı; sırf dosya sayısı artsın diye abstraksiyon ekleme.

## Özel durumlar ve tutarlılık
- S01 empty trip, S02 social skeleton, S03 network/error, S04 form/unsaved dialog.
- Aile içi sayfalarda İngilizce placeholder başlıklar Stitch'te kalmış olabilir; UI metinleri TR/EN çeviri anahtarlarından gelecek.
- D01 ve S01 bazı tasarımlarda “Seyahatlerim” alt sekme olmuş; **doğrusu 5 sabit sekme**, Trips nested route.
- Fotoğraf/rozet/“premium passport” gibi süsler gerçek veri ve işlev olmadan istatistik taklidi olarak gösterilmez.
- Stitch'te görülen ama backend'de olmayan direkt mesaj, ortak rota, offline harita, 2FA gibi kontroller ya kapsama alınan migration+işlev ile yapılır ya da gizlenir; ölü buton bırakılmaz.

## Görsel kabul
Ekran bazında screenshot/golden karşılaştırması, 320/393/430 px genişlikte overflow kontrolü, accessibility/contrast, light-dark, TR-EN ve large text ile kontrol; farkları `tasks.md`'ye yaz.
