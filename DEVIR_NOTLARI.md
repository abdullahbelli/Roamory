# Roamory — Ev / Ofis Antigravity Devir Notları

> **Bu belge her oturumun başında okunur ve sonunda güncellenir.** Anlık durumu gösterir; kronolojik geçmiş `YAPILANLAR.md`, görev kanıtı `tasks.md` içindedir. Doğrulanmamış işleri tamamlanmış sayma.

## Son durum
- Son güncelleme: 2026-11-11 15:51 (+03:00)
- Son çalışan ortam: Bilinmiyor (macOS)
- Git branch / HEAD: `main` @ `a7fecdd` (üzerinde `T01`, `T02`, `T04`–`T07` + `T08` unit/widget testleri uncommitted; `README.md` korundu)
- Aktif görev: `T08` (canlı Supabase E2E & SMTP doğrulaması kullanıcı kimlik/altyapı erişimi bekliyor) ve sıradaki fonksiyonel görev `T09` (`B01`–`B05` Keşif & Arama)
- Tamamlanan son görev: `T07` (`A01`–`A07` Auth/Onboarding Clean Architecture + router guard + deep link) ve `T08` unit/widget testleri (`23/23` pass)
- Devam etmek için ilk adım: `git status` ve `flutter analyze && flutter test` ile mevcut durumu doğrula. Canlı Supabase/SMTP/OAuth erişimi sağlanırsa `T03` ve `T08` canlı E2E testlerini çalıştır; sağlanmazsa `T09` (`B01`–`B05` Stitch HTML/PNG incelemesi ve Explore/Places implementasyonu) ile devam et.

## Açık engeller
- `T03` blocked: Bu cihazda `supabase` CLI kurulu değil ve canlı Supabase şema/RLS sorgusu için proje bağlantısı/yetkili erişim bulunmuyor (`profiles` dışı `categories` ilgi alanı ara tablosu şeması da doğrulanamadı).
- `T08` canlı E2E blocked: Çalışma alanında `--dart-define=SUPABASE_URL=...` ve `SUPABASE_PUBLISHABLE_KEY=...` değerleri ve özel SMTP sunucusu tanımlı değil; Supabase varsayılan SMTP hız sınırları üretim e-postaları için yetersiz.
- Google OAuth canlı test eksik: `io.roamory.app://login-callback/` manifest/plist içine eklendi ancak Android `applicationId` hâlâ `com.example.roamory`, Google Cloud OAuth istemci kimlikleri ve Supabase Dashboard Redirect URL allowlist ayarları doğrulanmadı; iOS simülatör/cihaz testi çalıştırılmadı.
- Bu cihazda Stitch MCP (`projects/2591164501540002750`) bağlantısı doğrulandı (38/38 ekran erişilebilir); diğer cihazda ayrıca yerel MCP doğrulaması gerekir.
- OSM servis seçimi gibi açık kararlar `tasks.md` içindedir.

## Yeni oturum açılış kontrolü (zorunlu)
1. Yerel kaynak kodun doğru Git deposu/branch olduğu doğrulansın; `git status` kontrol edilsin.
2. Git remote ve değişiklikler incelensin; **yerel değişiklikler korunmadan `pull --rebase`, `reset` veya force işlemi yapılmasın**. Gerekirse commit/stash, çakışmada dur ve kullanıcıya bildir.
3. İlgili branch'in güncel sürümü, yapılan pull/merge sonucu ve commit SHA kaydedilsin.
4. `AGENTS.md`, `tasks.md`, `YAPILANLAR.md`, `DEVIR_NOTLARI.md` okunsun, dosyalarla çelişki varsa gerçek kod esas alınarak durum uzlaştırılsın.
5. Stitch MCP `list_projects` ya da ilgili ekran okuma ile **bu cihazda** sınansın; bağlantı yoksa anahtarları sohbet/Git'e taşımadan yerel yapılandırma yapılması istensin.
6. Son doğrulanmış noktadan devam edilsin; tamamlanmış modüller yeniden yazılmasın.

## Oturum kapanışı (zorunlu)
- Görev durumunu ve gerçek test kanıtlarını `tasks.md` içine yaz.
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
