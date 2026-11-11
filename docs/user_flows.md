# Roamory — Kullanıcı Akışları

## Kimlik doğrulama
İlk açılış -> A01 -> A02 -> A03/A04 -> e-posta doğrulaması gerekiyorsa A06 -> A07 (profil eksikse) -> B01. Mevcut session -> B01; geçersiz session -> A03. Google OAuth dönüşü hem Android hem iOS deep link ile yönetilir; callback duplicate navigasyon önlenir.

## Ziyaret
B01 veya C01 -> C04 -> B03/haritadan mekan seçimi -> tarih/kategori/puan -> C05 -> ziyaret verisini kaydet -> özel Storage upload -> C06 -> C01'de marker. Hata: yazılan metin kaybolmamalı. Silme onayı; storage cleanup.

## Keşfet -> İstek listesi -> Plan
B02 -> B04 -> B05'e kaydet -> D01 -> D02/D03 -> gün ekle -> D04 durak ekle -> D05 kontrol listesi. Kullanıcıya özel `places` koşulları için backend yetki gözden geçirilir.

## Sosyal paylaşım
C06 'Toplulukta paylaş' -> E02 üzerinde seçilen veriler (özel notlar otomatik değil) -> fotoğraf yükleme -> taslak -> açık "Yayınla" -> E01/E03. E04 yorum, beğeni/kaydet, raporlama, engelleme. Silinen/engellenen içerik erişimi yeniden sorgulanır.

## Profil/ayarlar
F01 -> F02 -> profil güncelle; F04 dil/tema seç -> anında görsel yansıtma; F05 logout / hesap silme güvenli onay. Başka gezginin profili E05.

## Temel hata akışları
S01 empty plan; S02 loading feed; S03 no network/retry; S04 validation/unsaved changes. İzin reddedilirse kullanıcı konumunu zorla isteme; manuel aramayla ilerletebil.
