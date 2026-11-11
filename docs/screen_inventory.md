# Roamory — Stitch Ekran Envanteri (MCP Doğrulanmış)

- Project: `projects/2591164501540002750`
- Toplam 38 ekran: 34 ana + 4 UI state.
- Her ekran öncesi MCP üzerinden HTML, screenshot ve bileşen bilgilerini tekrar oku. Kaynağın varlığını listelemek, görüntüsünü okumakla aynı şey değildir.
- Flutter ekran dosyalarının üzerine `/// Stitch referansı: A01` gibi yorum ekle; dosyalara dış link veya anahtar yerleştirme.

| Kod | Ekran | Stitch screen ID |
|---|---|---|
| A01 | Açılış Ekranı (Splash) | `005d8446c20848e08242aa2aa3369e6e` |
| A02 | Karşılama Turu (Onboarding) | `fb428783dd7e4d9683e8af822153cf19` |
| A03 | Giriş Yap (Login) | `e07198234a79470f84ab5d8a5b961915` |
| A04 | Kayıt Ol (Register) | `3fd6b8d90e964c2fbdc5a67f3abbc9ea` |
| A05 | Şifremi Unuttum (Forgot Password) | `67e49c01aa67496dbc0b32e2c8595619` |
| A06 | E-posta Doğrulama (Email Verification) | `4dbd7dec69c8413592f55aa51a7b6f04` |
| A07 | Profil Kurulumu (Profile Setup) | `7867ddd390aa4480b39cb78e08432b96` |
| B01 | Ana Sayfa (Home) | `f3d34ff9d41b4c21ada6da3016df99ed` |
| B02 | Keşfet (Explore) | `76e6753b2acb4052b3168cf459c9914a` |
| B03 | Arama ve Filtreler | `193e4b2a369842c18c26c32c48e89142` |
| B04 | Mekan Detayı (Place Details) | `5de6a72d74ef4f91b9a8cc8b9864b650` |
| B05 | İstek Listesi (Wishlist) | `cc1d396ee299461595e6faf0e0e18b12` |
| C01 | Haritam (My Map) | `d0d6efaae0fc48fea8d713056f5a8bd2` |
| C02 | Harita Filtreleri (Map Filters) | `3895b391baab46d0b52ab1f6d282b877` |
| C03 | Ziyaret Geçmişi (Visit History) | `b308dacea62d4c61955e00c145cf51ba` |
| C04 | Ziyaret Ekle (Add Visit) | `f5482f42ecf04aac98f6c1995b10ce89` |
| C05 | Seyahat Günlüğü Editörü (Journal Editor) | `2f12819fccda45c2aaf9534e720ec927` |
| C06 | Ziyaret Detayı (Visit Details) | `8b0cbcd9cdee41228d5febfde96e3249` |
| D01 | Seyahatlerim (My Trips) | `326e74e374f14a72a33bd82f6900279b` |
| D02 | Rota Oluştur (Create Trip) | `1123a5616c864c2894a8599e189228e6` |
| D03 | Seyahat Detayı (Trip Details) | `eaa6270a8a3d4d199df61c1c1e55e16f` |
| D04 | Günlük Rota Editörü (Itinerary Editor) | `cc44ec026ada4b7bb5b0f374831c10d8` |
| D05 | Seyahat Kontrol Listesi (Checklist) | `98ee3f26a6d24afbbacbfa1eaf77a2e9` |
| E01 | Topluluk Akışı (Community Feed) | `3264034a2de2418daacdedf1528a8f6f` |
| E02 | Gönderi Oluştur (Create Post) | `94c85959ec3f48608571d275ec67fe91` |
| E03 | Gönderi Detayı (Post Details) | `a26c05d0629d4c2fb46c5b58605eddf7` |
| E04 | Yorumlar (Comments) | `398fdefcd66c4c13bbae8ef6a1ef4cdb` |
| E05 | Gezgin Profili (Traveler Profile) | `c8c12a7bc9874efbbf7539b196012144` |
| E06 | Takipçiler ve Takip Edilenler | `24322a17804c48f2bb0759d023ff68ce` |
| F01 | Profilim (My Profile) | `3af660ab26094fc4bae9e492c4094846` |
| F02 | Profili Düzenle | `b8b80041477d48ecbec6aa8d8820454c` |
| F03 | Bildirimler | `c16d655f10c841cebae33bf68ca7d6f0` |
| F04 | Ayarlar | `1dfa9b5fcc0142b68b2e07fb62c0942f` |
| F05 | Hesap ve Güvenlik | `528fa05dc8ad4793aed27d80c42570d2` |
| S01 | Seyahatlerim (Boş Durum) | `2ce4b3a218084af5b3f87207b2c04959` |
| S02 | Topluluk Akışı (Yükleme İskeleti) | `de101723bb3641aebad0490183231ede` |
| S03 | Bağlantı Hatası ve Çevrimdışı Mod | `68770dfa76404282b86c008d4f179b86` |
| S04 | Form Hataları ve Çıkış Onayı | `191d19aed5734ea598ae755f9ffd716e` |

Her resource: `projects/2591164501540002750/screens/<screen-id>`; MCP aracını mevcut araç keşfine göre çağır.

## Eşleştirme
A = auth/onboarding; B = home/explore/wishlist; C = map/visits/journal; D = trips; E = community; F = profile/settings; S = states.

## Arayüz tutarlılığı sorunları
Stitch kaynakları arasında kimi sayfalarda İngilizce header bulunabilir. TR/EN l10n uygula. Trips alt tab değil nested route. Tasarımlarda desteklenmeyen özelliğe ait etkileşimsiz kontrol tutma.
