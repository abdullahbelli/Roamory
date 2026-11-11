# Roamory — Antigravity Agent Kuralları

> Bu dosyayı her görevden önce oku. Çalışma dizini **mevcut `roamory/` Flutter projesidir**. Yeni bir Flutter projesi oluşturma.

## Öncelik sırası
1. Kullanıcı talimatı ve güvenlik.
2. Bu dosya, `project.md`, `architecture.md`, `design.md`, `database.md`, `features.md`, `testing.md`.
3. `tasks.md` içindeki sıralı görevler.
4. Stitch MCP üzerinden alınan **gerçek** ekran HTML/PNG tasarımları.

## Değişmez kurallar
- Android + iOS; Flutter/Dart, Supabase, `flutter_map` + OpenStreetMap tabanlı sağlayıcı, Riverpod, `go_router`, `intl`/ARB. Kodları mevcut SDK ve paket sürümlerine uyumlu yaz; sürüm veya API uydurma.
- SOLID, Clean Architecture, feature-first. `domain` bağımsızdır; Supabase kodu `data` katmanında bulunur. UI doğrudan veri erişim kodu içermez.
- **Stitch MCP projesi:** `projects/2591164501540002750`. 34 ana + 4 durum ekranı. Ekranları kodlamadan önce ilgili HTML ve PNG'yi MCP ile oku ve `docs/screen_inventory.md` referansına bağla. MCP başarısız olursa tasarımı uydurma; sorunu raporla.
- `design.md` renk/tipografi tokenları tek kaynaktır. `lib/app/theme/app_theme.dart` merkezî tema; ekranda sabit hex kodları yok. TR/EN ARB; görünür sabit yazı yazma.
- Supabase **mevcut üretim projesini** kullan; 20 tabloyu, RLS ve Storage'ı yıkıcı biçimde değiştirme. Şema uyuşmazlığında önce incele, migration öner; onaysız üretim SQL'si çalıştırma.
- Flutter'a yalnızca Supabase URL ve **publishable key** gelir. Secret/service_role, SMTP, Stitch API key, OAuth secret, kişisel tokenlar kaynak koda, belgelere, loglara veya Git'e konmaz. İstemci RLS'yi geçemez.
- Önce erişilebilir, test edilebilir ve işlevsel uygulama; sonra görsel ince ayar. Sahte başarılı butonlar, sahte sosyal sayı ve gerçek veriymiş gibi mock data YASAK. Demo/fixture yalnızca test veya açıkça işaretli geliştirme modunda.
- Kullanıcı kaydı özel (private) varsayılan; yayınlama ayrı bilinçli aksiyondur. Engelleme, fotoğraf yetkisi, rapor ve bildirim güvenliğini koru.
- **Büyük tek seferlik görev bile alt aşamalara bölünür**; görev günlüğünü düzenli güncelle. Oturum/araç sınırında kaldığın yeri, test sonucunu, engeli ve bir sonraki eylemi `tasks.md`'ye yaz. Test etmeden `done` deme.

## Kod içi açıklama standardı — ZORUNLU
Tüm üretim Dart kodu **Türkçe ve öğretici yorumlar** içerecek. Kodun okunabilirliğini bozmayacak açıklamalar yaz; satırların her birini tekrar etme.
- Her public sınıf, repository sözleşmesi, use case, controller/provider ve karmaşık widget için `///` DartDoc: **ne yapar, hangi katmana aittir, gerekirse neden**.
- Her önemli metodun üzerinde `///`: parametreler, dönüş, hata/yan etki, veri kaynağı/erişim kuralı.
- `//` satır yorumları: `async/await`, state değişimi, hata işleme, form validasyonu, navigasyon, Supabase sorgusu, RLS varsayımı, Storage path, image upload, harita koordinat hesabı, stream aboneliği, dispose ve performans kararlarında **neden bu yaklaşım seçildiğini** anlatır.
- Karmaşık akışların içinde işlemleri kısa bölümlere ayıran Türkçe yorumlar kullan. `TODO(phase/id):` açıklamasız bırakılan gerçek eksikler için; yapıldı gibi gösterme.
- Aşikar kodu aynen tekrar eden yorum yazma (`// butona bas`), içeriği yanlış/eskimiş yorum bırakma. Güvenlik sırlarını veya kişisel bilgileri yorumlara koyma.
- Test kodlarında senaryonun amacı ve beklenen sonuç yorumla anlatılır.

Örnek:
```dart
/// Kullanıcının yeni ziyaretini kaydeder.
/// İş kurallarını doğrular; kalıcı saklama işini repository'ye devreder.
class CreateVisitUseCase {
  const CreateVisitUseCase(this._repository);
  final VisitRepository _repository;

  /// [request] geçerliyse kaydı oluşturur; geçersiz puanda hata üretir.
  Future<Visit> call(CreateVisitRequest request) async {
    // Puanı veritabanına göndermeden önce domain katmanında doğruluyoruz.
    if (request.rating != null &&
        (request.rating! < 1 || request.rating! > 5)) {
      throw const InvalidVisitRatingException();
    }
    // Veri kaynağını bilmeyen sözleşme üzerinden işlemi gerçekleştiriyoruz.
    return _repository.createVisit(request);
  }
}
```

## Her alt görevde uygulanacak çalışma döngüsü
1. `tasks.md` durumunu ve ilgili dokümanı oku; gerçek mevcut dosyaları denetle.
2. İlgili Stitch ekran(lar)ını MCP ile getir, HTML/PNG ve akışı incele.
3. En küçük mimari değişikliği yap; kodu Türkçe açıklamalı yaz.
4. `dart format .`, `flutter analyze`, ilgili testler, mümkünse build çalıştır. Sonuçları `tasks.md`'ye yaz.
5. Kapsam dışı/erişilemeyen özellikleri gizlice simüle etme; `blocked` olarak kaydet.
6. Son aşamada tamamlanan ekran, Supabase işlem, test sonucu, kalan eksikler için somut özet üret.


## Ev / Ofis arasında zorunlu süreklilik ve işlem günlüğü
- Bu proje **iki ayrı Antigravity ortamında** (Ev ve Ofis) geliştiriliyor. Her yeni oturumun BAŞINDA `tasks.md`, `YAPILANLAR.md`, `DEVIR_NOTLARI.md` ve Git durumunu oku; gerçek kodu ve testleri kontrol ederek kaldığın yerden devam et. Sohbet hafızasına güvenme.
- **Her anlamlı işlemden HEMEN SONRA** `YAPILANLAR.md` içine tarihle, ortamla (biliniyorsa), görev ID'siyle, yapılan gerçek işlemle, dosya yollarıyla, test sonucu ve sıradaki eylemle bir kayıt EKLE. Eski kayıtları silme/yeniden yazma. Sadece nihai özet yeterli değildir.
- Her görev durumunu `tasks.md` içinde güncelle; `DEVIR_NOTLARI.md` dosyasını önemli kilometre taşlarında ve oturum sonunda güncel tut. Bir görevin bitişi ancak kod ve test kanıtı varsa `done` olur.
- Başlamadan `git status`, branch, HEAD ve remote kontrolü yap. Yerel değişiklikleri ezme; onaysız `git reset --hard`, force-push veya destructive migration yapma. Git pull öncesi güvenli commit/stash ve çakışma kontrolü yap. Senkronizasyon için Git kullan; MD dosyaları kodu taşımaz.
- Stitch MCP **cihaz bazında** yerel konfigürasyon gerektirir. Evde çalışması ofiste bağlantı olduğu anlamına gelmez; her makinede projeyi `projects/2591164501540002750` olarak doğrula. API anahtarlarını, yerel `mcp_config.json` ve gizli yapılandırmaları Git'e veya loglara alma.
- Oturum sonunda `DEVIR_NOTLARI.md` içinde bir sonraki cihazın tek başına ilerleyebilmesi için branch/commit, devam eden görev, açık dosyalar, başarısız testler, gerçek engeller ve ilk sonraki komutu kaydet.
