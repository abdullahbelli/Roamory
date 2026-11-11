# Roamory — Antigravity Geliştirme Dokümanları

Bu paket mevcut Flutter `roamory/` klasörünün köküne açılır. Flutter kaynak kodu içermez; ürün, tasarım, güvenlik, mimari ve görev talimatları içerir.

## Kullanım
1. ZIP dosyasını aç, içindeki dosyaları mevcut Flutter projesinin köküne kopyala (`AGENTS.md`, `project.md`, ... ve `docs/`).
2. Antigravity'de `roamory/` çalışma alanını açık tut; Stitch MCP bağlantısının çalıştığını doğrula.
3. `ANTIGRAVITY_MASTER_PROMPT.md` içindeki promptu agent'a **bir kez** gönder.
4. Agent önce belgeleri ve mevcut proje/şemayı inceler; sonra `tasks.md` görevlerine göre geliştirmeye başlar. Büyük işlerin tek oturumda biteceği garanti edilmez; görev durumu dosyada tutulur.
5. Supabase publishable key güvenli local config ile sağlanır, secret verilmez.

## Önemli
Görüşmedeki Supabase SQL işlemleri proje üzerinde daha önce çalıştırılmıştır. Agent onları körlemesine yeniden çalıştırmamalıdır. `docs/screen_inventory.md` gerçek Stitch MCP ekran ID'lerini içerir.

## Kod içi yorum zorunluluğu
Tüm önemli Dart sınıf/metotları Türkçe `///` DartDoc ve gerekli satır içi `//` yorumlarıyla açıklanacaktır. Bu kural `AGENTS.md`, `architecture.md`, `testing.md` ve ana promptta tekrarlanır.


## İki bilgisayarda çalışma (Ev / Ofis)
- `YAPILANLAR.md` ve `DEVIR_NOTLARI.md` dosyaları da proje kökünde olmalıdır. Bunlar Git üzerinden her iki cihazda eşitlenir.
- Bir oturumun BAŞINDA devir notlarını ve Git durumunu oku; SONUNDA işlem günlüğünü ve devir notlarını güncelle.
- Antigravity'nin yerel Stitch MCP konfigürasyonu bilgisayara özeldir; ofiste ayrıca yapılandırıp bağlantıyı doğrula. API key'i Git'e ekleme.
- Gerçek kaynak kod senkronizasyonu `git push`/`git pull` aracılığıyladır; Markdown yalnızca işlem ve bağlam devridir.
