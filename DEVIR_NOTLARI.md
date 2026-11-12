# Roamory — Ev / Ofis Antigravity Devir Notları

> **Bu belge her oturumun başında okunur ve sonunda güncellenir.** Anlık durumu gösterir; kronolojik geçmiş `YAPILANLAR.md`, görev kanıtı `tasks.md`, ekran bazlı kalite matrisi `docs/QUALITY_CHECKLIST.md` içindedir. Doğrulanmamış işleri tamamlanmış sayma.

## Son durum
- Son güncelleme: 2026-11-12 07:45 (+03:00)
- Son çalışan ortam: Windows (`PowerShell`, Flutter `3.47.9`, Dart `3.13.7`, Android Emulator `sdk gphone64 x86 64` / `emulator-5554` API 36)
- Git branch / HEAD: `main` @ `93a8eb1` (`T01`–`T20` kapsamındaki 38 ekran, `.env` + `flutter_dotenv`, seyahat `+ Gün Ekle` tarih genişletme/rollback ve checklist kanonik kod/`sort_order`/`%` ilerleme/filtre düzeltmeleri, Topluluk `E01`–`E06` denetim/düzeltmeleri, Bildirim `F03` etkileşim filtresi + trigger SQL önerileri ve `46/46` test çalışma alanında hazır; `.env` `.gitignore` ile hariç tutuldu)
- Aktif görev: Kullanıcı tarafından `supabase/migrations/20260412000003_trips_and_checklist_proposal.sql` (`trip_checklist_items_category_check` & `trip_days` RLS) ve `supabase/migrations/20260412000002_notifications_triggers_proposal.sql` (`follows`/`post_likes`/`comments` bildirim trigger'ları) SQL önerilerinin incelenip Supabase SQL Editor'de onaylanması; ardından emülatörde (`emulator-5554`) `+ Gün Ekle`, Checklist CRUD + yeniden başlatmada kalıcılık, seyahat tarih değişikliğinde alt veri koruma ve 2 ayrı hesapla Topluluk/Bildirim canlı cihaz doğrulamalarının tamamlanması (`Google OAuth` gerçek cihaz APK aşamasına `DEFERRED`)
- Tamamlanan son görev: Kullanıcının yeni emülatör `DEVICE TESTED` onaylarının (`D02` Düzenle prefill & tekrarsız UPDATE, `D04` özel mekan durağı + 2. durak + durak sıralama, önceki Ziyaret/Fotoğraf/Harita/Wishlist) belgelenmesi; canlı logcat `+ Gün Ekle` (`42501`, `trip_days` tarih aralığı) ve Checklist (`23514`, `trip_checklist_items_category_check`) kök nedenlerinin düzeltilmesi; Topluluk (`E01`–`E06`) ve Bildirimler (`F03` — `like`+`comment` Etkileşimler filtresi, rozet, avatar, pull-to-refresh, `actor_id`/`post_id` trigger önerisi) denetim ve iyileştirmelerinin tamamlanıp `dart format lib test` (`0 changed`), `flutter analyze` (`0 issue`), `flutter test` (`46/46 All tests passed!`) ve `flutter run -d emulator-5554 --no-resident` (`exit code 0`) ile doğrulanması
- Devam etmek için ilk adım:
  1. `supabase/migrations/20260412000003_trips_and_checklist_proposal.sql` içindeki Adım 1 inceleme sorgusunu Supabase SQL Editor'de çalıştırıp `trip_checklist_items_category_check` ve `trip_days` politikalarını kontrol et; onaylarsan Adım 2'yi uygula.
  2. Emülatörde (`emulator-5554`) çalışan güncel debug uygulamasında `+ Gün Ekle`, kontrol listesine madde ekleme / tamamlama / silme, uygulamayı kapatıp açınca gün/durak/checklist kalıcılığı ve seyahat tarih aralığı düzenlendiğinde alt verilerin korunmasını test et.
  3. İsteğe bağlı olarak `supabase/migrations/20260412000002_notifications_triggers_proposal.sql` dosyasını onaylayıp 2 ayrı hesapla Topluluk (`E01`–`E06`) ve Bildirim (`F03`) akışlarını canlı doğrula; kullanıcı onayından önce **final APK oluşturma (`flutter build apk`) veya sunum hazırlama başlatma**.

## Açık engeller (`BLOCKED` / `NOT TESTED` / `DEFERRED`)
- **`+ Gün Ekle` & Checklist Canlı Cihaz Doğrulaması (`D04`, `D05` — `NOT TESTED` / SQL İnceleme Bekliyor):** Uygulama düzeltmeleri (`trips.end_date`/`start_date` uzatma + rollback, `TripChecklistCategory` kanonik kodları + `sort_order` + `23514` hata eşleme + `%` ilerleme) `46/46` testle doğrulandı. Canlı DB'de `'general'` kategorisinin engellenmemesi için `20260412000003_trips_and_checklist_proposal.sql` inceleme/onayı ve ardından `+ Gün Ekle`, Checklist CRUD ve yeniden başlatma kalıcılığı cihaz testi bekleniyor.
- **Topluluk İki Kullanıcılı Canlı Senaryolar (`E01`–`E06`) & Bildirim Trigger Onayı (`F03` — `NOT TESTED`):** `E01`–`E06` sayfalama, çift-dokunma kilitleri, yorum silmede sayaç eşitleme, kendini takip/engelle kaldırma, engelleme temizliği ve `F03` (`like`+`comment`) birim/widget testlerinden geçti. İki ayrı gerçek hesapla takip/beğeni/yorum/engelleme/şikayet ve trigger SQL önerisi (`20260412000002_notifications_triggers_proposal.sql`) onayı henüz canlıda test edilmedi.
- **Google OAuth (`A03` — `DEFERRED`):** Google ile giriş cihaz testi gerçek cihaz APK aşamasına ertelendi; mevcut OAuth/deep-link yapılandırmasına dokunulmadı.
- **E-posta Doğrulama (`A06`) Bağlantı / OTP Uçtan Uca Doğrulaması (`NOT TESTED` / `BLOCKED`):** Canlı Supabase üzerinde `mailer_autoconfirm: false` aktiftir ve güvenlik gereği kapatılmamıştır. `A06` ekranı 6–8 haneli OTP ve bağlantı onayından sonra "Doğrulamayı Kontrol Et" (`refreshVerificationStatus`) ile oturum açacak şekilde güncellenmiştir; ancak gerçek gelen kutusundan bağlantı/OTP ile uçtan uca akış henüz ayrıca doğrulanmadığı için tamamlanmış olarak işaretlenmemiştir.
- **Supabase Varsayılan E-posta / SMTP Sınırları (`T08`):** Özel SMTP/domain kurulumu ertelendiği için Supabase yerleşik e-posta servisi saatlik gönderim kotasına (rate limit / `HTTP 429`) tabidir. Kota aşıldığında uygulama `forgotSmtpNotice` uyarısını gösterir.
- **iOS Simülatör / Fiziksel iOS Cihaz (`BLOCKED`):** Windows ortamında macOS/Xcode bulunmadığı için iOS derleme ve simülatör testi yapılamaz (`ios/Runner/Info.plist` konum, kamera/galeri ve deep-link tanımları hazırdır).

## Yeni oturum açılış kontrolü (zorunlu)
1. Yerel kaynak kodun doğru Git deposu/branch olduğu doğrulansın; `git status` kontrol edilsin.
2. Git remote ve değişiklikler incelensin; **yerel değişiklikler korunmadan `pull --rebase`, `reset` veya force işlemi yapılmasın**. Gerekirse commit/stash, çakışmada dur ve kullanıcıya bildir.
3. İlgili branch'in güncel sürümü, yapılan pull/merge sonucu ve commit SHA kaydedilsin.
4. `AGENTS.md`, `tasks.md`, `YAPILANLAR.md`, `DEVIR_NOTLARI.md` ve `docs/QUALITY_CHECKLIST.md` okunsun, dosyalarla çelişki varsa gerçek kod esas alınarak durum uzlaştırılsın.
5. Stitch MCP `list_projects` ya da ilgili ekran okuma ile **bu cihazda** sınansın; bağlantı yoksa anahtarları sohbet/Git'e taşımadan yerel yapılandırma yapılması istensin.
6. Son doğrulanmış noktadan devam edilsin; tamamlanmış modüller yeniden yazılmasın.

## Oturum kapanışı (zorunlu)
- Görev durumunu ve gerçek test kanıtlarını `tasks.md` ve `docs/QUALITY_CHECKLIST.md` içine yaz.
- İşlem geçmişini `YAPILANLAR.md` içine ekle.
- Bu belgenin son durum, branch/commit, açık dosyalar, kırık testler, engeller ve sıradaki net eylem alanlarını güncelle.
- Değişiklikler derlenebilir olmalı; değilse dürüstçe WIP olarak etiketle.
- Git commit/push **yalnızca izin ve güvenli remote kontrolüyle**; diğer cihazda pull yapılmadan geliştirme devam etmesin.
- Her oturum sonunda secrets ve `.gitignore` denetimi yap.

## Çalışma kuralları
- İki cihaz aynı anda aynı branch'te çatışmalı değişiklik yapmasın.
- MCP sunucu ve API anahtarı gibi kullanıcı makinesi yapılandırmaları Git ile paylaşılmaz.
- Antigravity sohbet geçmişi otomatik senkronize kabul edilmez; kalıcı kaynak repo dosyalarıdır.
- Dosya aktarımı yalnızca Markdown ile değil Git ile yapılır.
