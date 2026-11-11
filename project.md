# Roamory — Ürün Tanımı ve Kapsam (V1)

## Vizyon
Gezi keşfi, kişisel ziyaret/günlük kaydı, haritada anılar, tarih bazlı seyahat planlama ve fotoğraf odaklı sosyal topluluğu tek mobil uygulamada birleştirmek.

## Kesin kararlar
- İsim **Roamory**; Android + iOS; Türkçe ve İngilizce; Google + email/password Supabase Auth.
- Flutter frontend; Supabase PostgreSQL/Auth/Storage; OSM tabanlı harita; Stitch tasarımı, Antigravity geliştirmesi.
- V1'de sosyal akış, takip, beğeni, yorum, kaydetme, rapor ve engelleme bulunur.
- Beş sabit ana sekme: **Ana Sayfa, Keşfet, Haritam, Topluluk, Profil**. Seyahatlerim/günlük nested sayfadır; alt çubukta altıncı sekme oluşturma.
- Tüm ziyaret günlükleri **özel** başlar; topluluk paylaşımı ayrı işlem ve ayrı `posts` kaydıdır.

## V1 özellik sözleşmesi
1. Onboarding + e-posta doğrulama + oturum + profil tamamlatma.
2. Keşif/arama/filtre/mekan detayı; istek listesi ve haritadan kişisel mekan ekleme.
3. Harita üzerinde ziyaret/istek listesi işaretleri, ziyaret tarihleri ve kişisel günlük, puan, fotoğraf.
4. Seyahat oluşturma, günler, sıralı duraklar, kontrol listesi ve durum.
5. Topluluk akışı, taslak/yayın, fotoğraflar, yorum/beğeni, takip, kaydetme, engelleme/rapor.
6. Profil, basit seyahat istatistikleri, dil/tema, hesap çıkışı, hesap silme için güvenli iş akışı.
7. Empty/loading/error, form doğrulama, silme onayı, izin reddi ve tekrar dene durumları.

## Doğrulanmamış veya V1 dışında
- Stitch'te görünüyor diye otomatik eklenmeyecek: direkt mesaj, ortak seyahat/davet, biyometrik giriş, 2FA, Apple ile giriş, uçak/otel rezervasyonu, otomatik hava tahmini, çevrimdışı harita paketleri, PDF dışa aktarma, push bildirimleri ve rozet/gamification. Kullanıcı isteği ve teknik hazırlık olmadan bunlara sahte işlev yazma.
- iOS mağaza gerekliliklerine göre Apple giriş eşdeğeri ihtiyacı **yayın öncesi** değerlendirilecek.
- E-posta SMTP/domain henüz yapılandırılmadı; Supabase varsayılan mail sınırlamaları var. Yayına çıkış engelidir, geliştirmeyi engellemez.
- Veri kataloğu başlangıçta boş olabilir; boş ekranı doğru göster. Üçüncü taraf places/geocoding ve map tile sağlayıcısı seçiminde lisans, kota, attribution değerlendirilir.

## Temel kabul kriterleri
- Gerçek Supabase hesabıyla giriş, profil ve logout.
- A başka kullanıcının özel ziyaret, gezi, wishlist, taslak ve private Storage verisini okuyamaz/yazamaz.
- Kullanıcı keşfedilen/elle eklenen mekanı ziyaret ve plana ekler; kendi kayıtlarını haritada görür.
- Yayınlama açık rızayla; topluluk etkileşimleri gerçek backend'e yansır.
- İki dil ve sistem/açık/koyu temada ekran taşmaları yok.
- Stitch referanslarına görsel sadakat, açıklamalı kod, test ve format/analyze kontrolü.

## Kaynakların doğruluk sırası
Gerçek Supabase şeması > `database.md` özeti; Stitch MCP'deki güncel HTML/PNG > rapor ve özet; kullanıcı onaylı gereksinim > görseldeki süs öğeleri.
