# Ubuntu değerlendirme doğrulaması

Test ortamı: UTM, Ubuntu 24.04.5 LTS ARM64, 4 CPU, 6 GB RAM, 25 GB disk.
Ubuntu hesabı: `beciftci`. Proje: `/home/beciftci/Inception`.
VM adresi: `192.168.64.4`.

## Doğrulanan kontroller

- Üç özel Dockerfile, `debian:12` tabanı; temiz Ubuntu üzerinde başarılı derleme.
- Üç hizmet sağlıklı; NGINX, PHP-FPM ve MariaDB kendi konteynerinde PID 1.
- Özel bridge ağı, `restart: always`; Docker başlangıçta etkin.
- Yalnız NGINX 443 yayımlanıyor; diğer hizmetlerin portları dışarıya açılmıyor.
- HTTPS yanıtı 200; TLS 1.2/1.3 çalışıyor; TLS 1.0/1.1 sunucu tarafından reddediliyor.
- İki yerel named volume; bind mount seçenekleri bulunmuyor.
- Volume yolları `/home/beciftci/data/docker/volumes/` altında.
- Tam iki WordPress kullanıcısı: yönetici `siteowner`, abone `reader`.
- İki hesabın HTTPS girişi başarılı; yönetici paneli erişilebilir.
- `reader` yorum ekledi; yönetici onayından sonra yorum görünür.
- Yönetici panelinin oturumu ve editör REST nonce değeriyle Sample Page güncellendi; değişiklik web sitesinde görüldü.
- MariaDB root girişi secret dosyasındaki parola ile doğrulandı; 12 WordPress tablosu mevcut.
- Veritabanı boş değil; `wp_users` mevcut; parolasız root girişi reddedildi.
- Konteynerler kaldırılıp yeniden oluşturuldu; sayfa ve yorum korundu.
- Ubuntu yeniden başlatıldı; boot ID değişti; Docker otomatik başladı; sayfa ve yorum korundu.
- MariaDB 3306 → 3307 değiştirildi; yeniden derleme ve başlatma sonrası site çalıştı. Varsayılan ayarlar geri yüklendi.
- NGINX 443 → 8443 değiştirildi; site ve kalıcı içerik doğrulandı. Varsayılan 443 geri yüklendi.
- PHP-FPM 9000 → 9001 değiştirildi; NGINX bağlantısı ve sağlık kontrolü güncellendi. Yeniden derleme sonrası site ve içerik doğrulandı; 9000 geri yüklendi.
- Türkçe Q konsol düzeni Ubuntu yeniden başlatıldıktan sonra doğrulandı.
- Cloud image yeniden açılışta `/etc/hosts` dosyasını oluşturuyor. `/etc/cloud/templates/hosts.debian.tmpl` dosyasına `127.0.0.1 beciftci.42.fr` eklendi; VM alan adı kaydı kalıcı şablona işlendi.

- Değerlendirme temizliği prova edildi: proje konteynerleri, imajları, ağı, volume'leri, build cache ve Docker veri kökü kaldırıldı. `make up` Docker dizinlerini yeniden oluşturdu ve sıfırdan derledi; `make verify` geçti.
- Temizlik öncesi alınan iki volume yedeği geri yüklendi; sayfa ve yorum korunmuş hâlde doğrulandı. Ardından yalnız geçici test sayfa eklemesi ve test yorumu kaldırıldı.
- Geri yükleme sonrası her iki hesabın HTTPS girişi ve yönetici paneli yeniden doğrulandı.
- Son yeniden başlatmada kalıcı alan adı kaydı korundu (boot ID: `930d8cf2-c5be-4670-b893-179a81d76de7`). `make up`, `make verify`, iki hesabın HTTPS girişi ve yönetici paneli tekrar geçti.
- Son durumda yalnız üç servis imajı var; üç konteyner sağlıklı; yayımlanan tek port 443.
- Mac ve Ubuntu Git takipli dosyalarının SHA-256 değerleri birebir eşleşti.
- VM diskinde yaklaşık 19 GB boş alan kaldı.

## Kod düzeltmeleri

- Linux veri yolu denetimi eklendi. Değerlendirme temizliği veri kökünü kaldırırsa Docker yeniden başlatılıyor.
- İlk kurulumda yetki nedeniyle yanlış çalışan dizin denetimi düzeltildi.
- Ubuntu kurulumuna doğrulama betiğinin gerektirdiği Python 3 eklendi.
- NGINX, standart dışı HTTPS portunu PHP-FPM'e doğru aktaracak şekilde düzeltildi; WordPress yönlendirme döngüsü giderildi.
- Sağlık, port eşlemesi, volume türü, kullanıcı sayısı, veritabanı ve eski TLS denetimleri güçlendirildi.
- Ubuntu kurulumu, yeniden başlatma ve servis port değişiklikleri belgelendi.
- Yerel raporlar ve PDF çıktıları Git dışında tutuldu.

## Sınırlar

- Mac `/etc/hosts` kaydı hâlâ `127.0.0.1`; tarayıcıyı VM'ye yönlendirmek için `192.168.64.4` kullanılmalı. Mac yönetici parolası gerekli; otomatik değiştirilemedi.
- Mac'ten VM'ye HTTPS erişimi `curl --resolve` ile doğrulandı.
- Intel/AMD Ubuntu üzerinde çalıştırılmadı. Dockerfile'larda mimariye özgü komut bulunmuyor.
- Sözlü savunma ve resmî teslim değerlendirmesi otomatik test kapsamına girmez.
- GitHub `origin` adresi henüz tanımlı değil; resmî teslim deposu adresi eklenmeli.
- Commit ve push yapılmadı. Parolalar, VM diski ve canlı veriler teslim deposuna eklenmedi.
