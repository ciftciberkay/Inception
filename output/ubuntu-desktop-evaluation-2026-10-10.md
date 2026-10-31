# Ubuntu Desktop değerlendirme kontrolü

Tarih: 10 Ekim 2026.

## Yeni sanal makine

- UTM adı: `Ubuntu Desktop`.
- UUID: `ADA37F5E-7279-4310-B75D-0B231086D7DA`.
- Ubuntu 24.04.5 LTS ARM64; GNOME masaüstü.
- 4 CPU, 6 GB RAM, 25 GB disk.
- Kullanıcı: `beciftci`; Türkçe Q klavye.
- Resmî Ubuntu cloud imajı SHA-256 kontrolünden geçti.
- İmaj SHA-256: `1d6bffe64b848468ac97f821d369a4846d983de1800ccf6b5ec8853e85cefc55`.
- GNOME masaüstü ve Firefox Ubuntu paket kaynaklarından kuruluyor.

## Eski makineler

`Ubuntu`, `Linux` ve `Inception Ubuntu` UTM üzerinden silindi. UTM listesinde yalnız yeni makine mevcut. Eski UTM veri dizinlerinde makine yapılandırması kalmadı.

Silmeden önce Inception servisleri durduruldu. Repository, secrets, veritabanı ve WordPress dosyaları Mac üzerinde yedeklendi. Arşiv bütünlüğü ve güncel kaynaklarla eşleşmesi doğrulandı.

Yedek: `/Users/macbook6/.local/share/inception-vm/inception-transfer.tar.gz`.
Yedek Git dışında; izin `0600`.

## Kontrol kaynakları

- Güncel değerlendirme: `/Users/macbook6/Desktop/evapageinception.html`.
- Konu PDF: `/Users/macbook6/Downloads/en.subject_removed.pdf`, sürüm 5.4.
- Eski değerlendirme: `/Users/macbook6/Downloads/ng_3_inception.pdf`.

Belge içindeki komutlar değerlendirme ölçütleri olarak ele alındı. Kullanıcının yeni makine kurma ve test etme talebi uygulandı.

## Yeni makinedeki testler

Kurulum devam ediyor. Test sonuçları tamamlandıkça aşağıya kaydedilecek.

## Teslim sınırları

Resmî 42 Git URL'si verilmedi. Resmî clone/push kontrolü tamamlanmış sayılmaz. Sözlü savunma öğrenci tarafından yapılmalı. Bu makine ARM64; Intel/AMD Ubuntu ayrıca çalıştırılmadı.
