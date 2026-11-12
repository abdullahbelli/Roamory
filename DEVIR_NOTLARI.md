# Roamory — Ev / Ofis Antigravity Devir Notları

> **Bu belge her oturumun başında okunur ve sonunda güncellenir.** Anlık durumu gösterir; kronolojik geçmiş `YAPILANLAR.md`, görev kanıtı `tasks.md`, ekran bazlı kalite matrisi `docs/QUALITY_CHECKLIST.md` içindedir. Doğrulanmamış işleri tamamlanmış sayma.

## Son durum
- Son güncelleme: 2026-11-12 09:47 (+03:00)
- Son çalışan ortam: Windows (`PowerShell`, Flutter `3.47.9`, Dart `3.13.7`, Android Emulator `Medium_Phone_API_36.1` API 36)
- Git branch / HEAD: `main` @ `5029151` (`T01`–`T20` kapsamındaki 38 ekran, `.env` + `flutter_dotenv`, checklist canlı DB hizalaması, `46/46` test, özel Roamory logosu & Android adaptif ikonları, Release APK `61.49 MB`, sunum `.pptx`/`.pdf` ve `docs/SUNUM_HAZIRLIK.md` çalışma alanında hazır; `.env` `.gitignore` ile hariç tutuldu)
- Aktif görev: Tüm planlı geliştirme, son kontrol, logo/ikon tasarımı, release APK derleme ve sunum hazırlığı tamamlandı; yalnızca çok kullanıcılı/fiziksel cihaz testleri (`NOT TESTED` / `DEFERRED`) kullanıcı ortamına bırakıldı.
- Tamamlanan son görev: Roamory için özel pusula/pin marka logosunun (`assets/images/roamory_logo.png`) oluşturulması, `SplashScreen` ve Android legacy `mipmap-*` + API 26+ adaptif ikonlarının (`mipmap-anydpi-v26/ic_launcher*.xml`, `drawable-nodpi/ic_launcher_foreground.png`, `values/colors.xml`) güncellenmesi, `flutter analyze` (`0 issue`) / `flutter test` (`46/46 pass`), yeni logolu Release APK (`build/app/outputs/flutter-apk/app-release.apk`, `64.472.337` byte / `61.49 MB`) derlenip `emulator-5554` üzerinde kurulup başlatılması ve sunum `.pptx`/`.pdf` dosyalarının güncellenmesi
- Devam etmek için ilk adım:
  1. Fiziksel telefona `build/app/outputs/flutter-apk/app-release.apk` (`61.49 MB`) dosyasını kurarak uygulama ikonunu/Splash logosunu, `+ Gün Ekle`, yeni checklist kategorileriyle (`documents`/`packing`/`bookings`/`other`) madde ekleme/tamamlama/silme/yeniden başlatma kalıcılığı ve Google OAuth (`DEFERRED`) testlerini yap.
  2. İki ayrı gerçek hesapla Topluluk (`E01`–`E06`) ve Bildirim (`F03`) tetikleyicilerini ile `A06` link/OTP doğrulamasını uçtan uca dene.
  3. Sunum için `docs/sunum/Roamory_Proje_Sunumu.pptx` (veya `.pdf`) ile `docs/SUNUM_HAZIRLIK.md` rehberini kullan.

## Açık engeller (`BLOCKED` / `NOT TESTED` / `DEFERRED`)
- **`+ Gün Ekle` & Checklist Canlı Cihaz Re-Test (`D04`, `D05` — `NOT TESTED`):** `trip_checklist_items_category_check` (`documents`, `packing`, `bookings`, `other`; varsayılan `other`) Flutter kodu ve ARB etiketleri canlı DB değerleriyle tam hizalandı (`46/46` test pass). Cihazda canlı checkbox/ekleme/silme/yeniden başlatma kontrolü bekliyor.
- **Topluluk İki Kullanıcılı Canlı Senaryolar (`E01`–`E06`) & Bildirimler (`F03` — `NOT TESTED`):** Canlı DB'de `private.create_social_notification` + `follows`/`post_likes`/`comments` trigger'ları ve `UPDATE (is_read)` uygulandı; 2 ayrı gerçek hesapla canlı cihaz testi bekliyor.
- **Release APK İmzalama (`android/app/build.gradle.kts`):** `build/app/outputs/flutter-apk/app-release.apk` Android debug keystore ile imzalıdır (fiziksel telefona kurulabilir; Google Play Store yayını için upload keystore yapılandırması gerekir).
- **Google OAuth (`A03` — `DEFERRED`):** Fiziksel telefon APK testine ertelendi; mevcut OAuth/deep-link yapılandırmasına dokunulmadı.
- **E-posta Doğrulama (`A06`) Bağlantı / OTP Uçtan Uca Doğrulaması (`NOT TESTED`):** Canlı Supabase üzerinde `mailer_autoconfirm: false` aktiftir ve güvenlik gereği kapatılmamıştır; gerçek gelen kutusundan bağlantı/OTP uçtan uca akışı henüz ayrıca doğrulanmamıştır.
- **Supabase Varsayılan E-posta / SMTP Sınırları (`T08`):** Özel SMTP/domain kapsam dışıdır (`rate limit` / `HTTP 429`).
- **iOS Simülatör / Fiziksel iOS Cihaz (`BLOCKED`):** Windows ortamında macOS/Xcode bulunmadığı için iOS derleme ve simülatör testi yapılamaz.

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
