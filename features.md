# Roamory — Ekran Bazlı Kabul Kriterleri

Ana kaynak `docs/screen_inventory.md` ve MCP ekran HTML/PNG. Bir ekranı `done` saymak için: route + görsel + gerçek işlev + loading/empty/error + l10n + widget/unit testi gerekli.

| Kod | İşlev / gereksinim | Backend |
|---|---|---|
| A01 | Splash: mevcut session ve onboarding tamamlanma kontrolü | auth |
| A02 | Üç onboarding adımı, skip/continue, yalnızca ilk açılış | yerel preferences |
| A03 | Email/şifre ve Google girişi, hata/unutma linki | Supabase Auth |
| A04 | Kayıt, parola doğrulama, koşul onayı | Auth |
| A05 | Reset e-posta isteği, rate limit/hata | Auth |
| A06 | Confirm email, yeniden gönderim, callback | Auth |
| A07 | Profil adı, unique username, ilgi, dil, fotoğraf | profiles + ilgi şeması inceleme |
| B01 | Gerçek özet, yaklaşan gezi, hızlı eylem ve son kayıtlar | trips/visits/posts |
| B02 | Mekan keşfi, kategori, kaydetme | places/categories/wishlist |
| B03 | Arama ve filtre, boş sonuç, debounce | places |
| B04 | Mekan detayı, harita, isteğe/seyahate/ziyarete ekle | places ve ilişkiler |
| B05 | Kullanıcının istek listesi, kaldır/planla | wishlist_items |
| C01 | Harita pinleri, filtre, marker bottom sheet, konum izni | visits/places/wishlist |
| C02 | Tarih/kategori/durum/ülke filtreleri | query filters |
| C03 | Ziyaret geçmişi, tarih grupları | visits |
| C04 | Konum seç, tarih, kategori, puan, kayıt başlat | places/visits |
| C05 | Günlük başlığı/not/fotoğraf, özel gizlilik, kaydet | visits/visit_photos/storage |
| C06 | Ziyaret detayı, düzenle/sil, paylaşım oluştur | visits |
| D01 | Planned/ongoing/completed listeler, empty | trips |
| D02 | Ad/tarih/hedef/kategori, validation | trips |
| D03 | Gün gün program, durak/ödev, durum | trips/trip_days |
| D04 | Durak ekle, yeniden sırala, saat/not | trip_stops |
| D05 | Liste ekle/işaretle/sil, kategori | trip_checklist_items |
| E01 | Discover/following feed, pagination, block filtre | posts/follows/blocks |
| E02 | Fotoğraf/caption/konum, açık yayınlama | posts/post_photos/storage |
| E03 | Detay/yorum/like/save/paylaş | posts/likes/saved |
| E04 | Yorum listesi/ekle/sil/rapor | comments/reports |
| E05 | Gezgin profili, takip/engelle/şikayet | profiles/follows/blocks |
| E06 | Takipçiler/takip edilenler, takip bırak | follows |
| F01 | Profil, gerçek sayaçlar, kendi içerik tabları | profiles + aggregates |
| F02 | Kullanıcı adı, bio, avatar, ilgi, kayıt | profiles |
| F03 | Bildirim görüntüle/okundu | notifications |
| F04 | TR/EN, light/dark/system, gizlilik ayarları | app preferences; schema inspect |
| F05 | Session, parola/çıkış, hesap silme talebi | Auth + privileged flow |
| S01 | Boş seyahat listesi | component |
| S02 | Feed skeleton yükleme | component |
| S03 | Bağlantı hatası/yeniden dene; offline iddiası yok | component |
| S04 | Form hatası, kaydedilmemiş değişiklikler dialogu | component |

## İnce iş kuralları
- `A07`: Kullanıcı ilgi alanları veri modeli yalnızca `categories` ise kullanıcı-profil ilgi bağı için güvenli migration gerekir; kategori tablosuna yetkisiz insert yapma.
- `B02/B03`: Katalog `places` boş olduğunda gerçek veri varmış gibi kart üretme; kategori id için gerçek lookup.
- `B04 -> D04`: `trip_stops` mevcut politikasında `is_published=true` koşulu private place'e engel olabilir; schema farkına ilişkin plan oluştur.
- `C04/C05`: Önce visit, sonra private bucket upload; hata durumunda rollback/cleanup UI.
- `D02`: Ortak seyahat daveti backend'de yok; UI'dan kaldır veya kapsam dışı olarak blokla.
- `E02`: `posts` şeması yalnız draft/published; takipçi ve bağlantı özel görünürlüğü geçerli değil. Kullanıcı onaysız yeni görünürlük modu ekleme.
- `E05`: Mesajlaşma V1 kapsamı dışında. Çalışmayan `Mesaj` butonu olmayacak.
- `F05`: 2FA/biometric/Apple Sign In/hesap veri aktarımı şemada hazır değil; gerçeğe aykırı UI saklama.
- Bildirim: DB'deki varlık, otomatik event trigger/push garantisi değildir; önce gerçek üretme yolunu kur/test et.
- Kullanıcının konumu ve ziyaret geçmişi özel veri; izinsiz paylaşım yapma.
