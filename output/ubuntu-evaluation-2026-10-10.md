# Inception - Ubuntu değerlendirme kontrolü

Tarih: 10 Ekim 2026. Yalnız zorunlu bölüm değerlendirildi.

## Kaynaklar

- [Güncel değerlendirme HTML](/Users/macbook6/Desktop/evapageinception.html)
- [Konu PDF, sürüm 5.4](/Users/macbook6/Downloads/en.subject_removed.pdf)
- [Eski değerlendirme PDF](/Users/macbook6/Downloads/ng_3_inception.pdf)
- [Debian resmî sürümleri](https://www.debian.org/releases/): güncel stable 13, oldstable 12. `debian:12` sondan bir önceki stable şartına uyuyor.

Eski değerlendirme PDF'si 2022 tarihli ve Debian Buster diyor. Güncel HTML ve konu 5.4 sondan bir önceki stable sürümü istiyor. Güncel gereksinimler esas alındı. Belgelerdeki temizlik komutları kullanıcı talimatı olarak alınmadı; testler yalnız bu projeye ayrılmış VM üzerinde yürütüldü; mevcut veriler önceden yedeklendi.

## Ortam

UTM VM: `Inception Ubuntu`, Ubuntu Server 24.04.5 LTS ARM64.
4 CPU, 6 GB RAM, 25 GB disk. Hesap `beciftci`.
Proje `/home/beciftci/Inception`. VM IP: `192.168.64.4`.
Mac `/etc/hosts` bu IP'yi `beciftci.42.fr` alan adına eşliyor.

## Değerlendirme sayfası

| Başlık | Sonuç | Kanıt / sınır |
|---|---|---|
| Preliminary tests | Kısmen tamamlandı | Git dosyaları ve geçmişinde secret dosyası, mevcut yerel parolalar veya özel anahtar bulunmadı. Resmî 42 depo adresi henüz verilmedi; resmî depodan clone ve teslim doğrulanamadı. |
| General instructions | Geçti | Root Makefile; yapılandırmalar `srcs`; üç Dockerfile; Compose ağ tanımı; host network, links, sonsuz loop, arka plan daemon hilesi bulunmuyor. |
| Activity overview | Belgeler tamam | Docker/Compose, image/container, VM/kernel ve dizin yapısı DEV_DOC/README'de açıklanıyor. Öğrencinin sözlü açıklaması otomatik değerlendirilemez. |
| README check | Geçti | İlk satır birebir doğru ve italik; İngilizce; Description, Instructions, Resources, AI kullanımı ve dört karşılaştırma mevcut. Eksik karşılaştırmalar genişletildi. |
| Documentation check | Geçti | USER_DOC ve DEV_DOC dolu. Kurulum, Makefile, yönetim, veri yolları, panel, credentials yönetimi belgelenmiş. |
| Simple setup | Geçti | Mac'ten gerçek alan adına HTTPS 200; kurulum ekranı yerine WordPress. Mac alan adı VM IP'sine yönleniyor. |
| Docker Basics | Geçti | Üç özel Dockerfile ve Compose build; `debian:12`; imaj adları `nginx:inception`, `wordpress:inception`, `mariadb:inception`; hazır servis imajı veya latest tag yok. |
| Docker Network | Geçti | `srcs_inception` bridge ağına tam üç servis bağlı; site PHP-FPM ve MariaDB üzerinden çalışıyor. |
| NGINX SSL/TLS | Geçti | Yalnız 443 yayımlanıyor. HTTP 80 bağlantısı reddediliyor. TLS 1.2/1.3 kabul, TLS 1.0/1.1 sunucu tarafından reddediliyor. |
| WordPress/PHP-FPM/volume | Geçti | WordPress container'ında NGINX/Apache yok. İki hesapla HTTPS login, okuyucuyla yorum, yönetici paneli ve editor REST nonce ile sayfa düzenleme doğrulandı. |
| MariaDB/volume | Geçti | Ayrı container; NGINX yok; DB boş değil; parolasız root reddediliyor. Uygulama DB bağlantısı site ve verify ile doğrulandı. Secret parolasıyla root girişi başarılı; 12 WordPress tablosu mevcut. |
| Persistence | Geçti | Restart ve container yeniden oluşturma sonrası içerik korundu. VM reboot sonrası boot ID değişti; edited page, comment, iki hesap ve DB korundu. |
| Configuration modification | Geçti | MariaDB 3306→3307, NGINX 443→8443, PHP-FPM 9000→9001 değiştirildi. Her biri yeniden build/start sonrası site ve test içeriğiyle doğrulandı. Her testten sonra varsayılanlar geri yüklendi; make verify geçti. |
| Bonus | Kapsam dışı | Kullanıcının isteğiyle bonus servis eklenmedi. |

## PDF'nin ek gereksinimleri

- Tam üç zorunlu servis, ayrı container'lar.
- İki native named volume; local driver; bind seçenekleri yok.
- `inception_db_data` ve `inception_wp_data` yolları `/home/beciftci/data/docker/volumes/` altında.
- Tam iki WordPress kullanıcısı; yönetici `siteowner`, ikinci kullanıcı `reader`. Yönetici adında `admin` bulunmuyor.
- Nonsecret environment değerleri `srcs/.env` içinde. Parolalar Docker secrets ile dosyadan yükleniyor; Git dışında.
- NGINX sertifikası SAN `DNS:beciftci.42.fr`; 1 Ekim 2027'ye kadar geçerli; self-signed olması konu tarafından kabul ediliyor.
- PID 1: NGINX `nginx`, WordPress `php-fpm8.2`, MariaDB `mariadbd`.
- Her container `restart: always`; VM'de Docker boot sırasında etkin.
- Üç servisin gerçek host PID 1 süreçleri ayrı ayrı SIGKILL ile sonlandırıldı. Üçü de Docker'ın restart policy'siyle otomatik, sağlıklı biçimde döndü.
- Makefile shutdown named volume'leri silmiyor.

VM reboot kanıtı: ilk boot ID `7b046999-7070-4597-8094-1962b209d796`, yeniden açılış `6a010af2-7b24-4cdd-a7ea-ed3f505c9b8f`. Docker boot sırasında otomatik başladı; alan adı hosts kaydı korundu.

## Temizlik ve son durum

- İki volume durdurulmuş servislerden yedeklendi: `/home/beciftci/inception-audit-2026-10-10/volumes`.
- Proje container, image, volume ve ağları kaldırıldı; build cache temizlendi; Docker veri kökü kaldırıldı.
- Makefile Docker dizinlerini yeniden oluşturdu; imajlar önbelleksiz derlendi; sıfırdan WordPress/MariaDB kuruldu; `make verify` geçti.
- Yedekler geri yüklendi; test sayfa içeriği ve yorum korundu; tekrar `make verify` geçti.
- Orijinal sayfa içeriği audit öncesi kayıttan birebir geri yüklendi. Yalnız bu turdaki test yorumu silindi.
- İki hesabın HTTPS login ve yönetici paneli geri yüklemeden sonra tekrar geçti.
- Parolasız root girişi hem socket (`localhost`) hem TCP (`127.0.0.1`) üzerinden reddedildi.
- Mac/Ubuntu takipli kaynakları SHA-256 ile eşleşti. VM secret dosyaları ve TLS key 0600; VM parolaları takipli dosyalarda bulunmuyor.
- Son durumda üç container sağlıklı; NGINX 443 tek yayımlanan port. Disk yaklaşık 5.1 GB kullanıyor, 19 GB boş.
- Ham temizlik logu VM'de `/home/beciftci/inception-audit-2026-10-10/cleanup.log`.

## Tarayıcı kontrolü

Codex dahili tarayıcısı self-signed sertifikayı reddetti. Güvenlik uyarısı agent tarafından geçilmedi. Kullanıcı Safari'de uyarıyı geçti. Safari accessibility ağacında gerçek `beciftci.42.fr` WordPress ana sayfası, Inception başlığı, Hello world ve Sample Page bağlantısı görüldü. Sample Page bağlantısına Safari üzerinden basıldı; düzenlenen sayfadaki `Ubuntu evaluation persistence marker` metni gerçek tarayıcıda görüldü.

Tema footer'ındaki About/FAQs gibi `#` bağlantıları WordPress varsayılan tema yer tutucularıdır. Ek sayfa oluşturmak zorunlu bölümde istenmediğinden bonus içerik eklenmedi.

Safari son kez yenilendi; orijinal Sample Page görüldü, geçici test metni kaldırılmıştı.

## Bu kontroldeki düzeltmeler

- README'de VM/Docker, secrets/environment, bridge/host ve volume/bind karşılaştırmaları açık hâle getirildi.
- USER_DOC'ye WordPress parola değiştirme, yerel credential dosyasını güncel tutma ve mevcut DB secret değişikliğinin sınırları eklendi.
- DEV_DOC: Ubuntu zorunlu iş akışı olarak açıklandı; macOS önizleme olarak ayrıldı; fresh VM için clone öncesi Git kurulumu eklendi.
- Makefile: Docker API erişilemezken yanlış veri kökü hatası yerine önce Docker başlatma hatası gösteriliyor. Çalışan engine ile pozitif kontrol ve geçersiz DOCKER_HOST ile hata yolu doğrulandı.
- Mac ve VM başlangıç kaynakları karşılaştırıldı; fark yalnız bu yeni belge düzeltmeleriydi. Belgeler VM'ye de aktarıldı.

## Teslim için kalanlar

Resmî 42 Git adresi gerekli. Resmî depodan boş dizine clone, depo aidiyeti, commit/push ve değerlendirmedeki öğrenci varlığı otomatik olarak tamamlanmış sayılmıyor. Şu an testler VM'nin yerel çalışma ağacını doğruluyor. Sözlü savunmayı öğrenci yapmalı.

Intel/AMD Ubuntu üzerinde bu tur çalıştırılmadı; test ortamı Ubuntu ARM64. Parolalar, canlı veriler ve VM diskleri Git dışında.
