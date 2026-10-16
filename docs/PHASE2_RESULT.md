# Phase 2 — Interaction & Dialogue

Status: alur utama terverifikasi pada satu client Studio desktop, 16 Oktober 2026.
Tidak ada combat yang dikembangkan. Geometry, R6, movement, lighting, kamera,
dan source Phase 1 dipertahankan.

## Alur pemain

1. Dekati meja surat di kampung, dekat koordinat (21, 3.46, 64).
2. Tahan E selama 0.25 detik untuk mengambil surat.
3. Baca dialog; klik Lanjut/Selesai, Enter, atau X untuk menutupnya.
4. Datangi NPC di depan pos pejuang, sekitar (-20, 3.2, -147), lalu tahan E.
5. Server menerima surat dan mengangkat gerbang jalur pengungsian selama 1.8 detik.
6. Setelah animasi selesai, collision panel gerbang dinonaktifkan.

NPC menggunakan pos Phase 1 yang sudah ada. Phase 2 hanya menambahkan satu NPC
statis, meja/surat, gerbang, dan batas jalur yang mencegah bypass lewat halaman.
Dialog adalah narasi fiktif prototipe, bukan kutipan tokoh atau sumber sejarah.

## Arsitektur

| Source | Tanggung jawab |
| --- | --- |
| ServerScriptService/BARA/LetterProgress | Transisi Missing → Carrying → Delivered dan penolakan duplikat |
| ServerScriptService/BARA/InteractionRules | Validasi karakter hidup, prompt aktif di Workspace, dan jarak maksimum 10 stud |
| ServerScriptService/BARA/InteractionServer | State per pemain, dialog lock/token, ProximityPrompt, dan tween gerbang |
| ReplicatedStorage/BARA/DialogueCatalog | Nama pembicara dan dialog Bahasa Indonesia |
| ReplicatedStorage/BARA/DialogueView | Halaman dialog, tombol keluar, dan penutupan otomatis |
| StarterPlayerScripts/BARA/DialogueClient | Input UI, status tampilan surat lokal, dan event client |

Satu RemoteEvent di ReplicatedStorage.BARA_Network.DialogueEvent mengirim dialog.
Pesan client yang diterima hanya Ready dan Close dengan id dialog yang cocok;
pesan itu tidak memberi surat, menyerahkan surat, atau membuka gerbang.
Gameplay hanya berubah melalui ProximityPrompt yang divalidasi server. Tidak ada
permintaan client yang dipercaya untuk menentukan status surat.

State internal server adalah sumber kebenaran. Attribute pemain hanya memublikasikan
status untuk tampilan client. Interaksi ditolak selama dialog aktif atau cooldown
0.35 detik. Token dialog mencegah pesan Close lama menutup percakapan baru.

Surat disembunyikan lokal setelah diambil; objek/prompt global tetap tersedia untuk
pemain lain. Gerbang adalah satu objek bersama: penyerahan pertama yang sah membuka
gerbang untuk semua pemain. State surat tetap terpisah per pemain.

ScreenGui BARA_Dialogue berwarna cokelat gelap/krem, ResetOnSpawn=false, dengan
tombol Continue berlabel Lanjut/Selesai dan tombol X. Movement tidak dikunci saat
dialog. Client menutup dialog otomatis setelah 40 detik; server mengizinkan
interaksi lagi setelah lock kedaluwarsa 45 detik bila acknowledgement tidak datang.
Respawn menutup dialog tanpa menghapus progres surat.

## Pengujian aktual

| Kasus | Hasil |
| --- | --- |
| Test-first progres | Gagal saat modul belum ada, lalu 9 assert lulus setelah implementasi |
| NPC tanpa surat | E membuka dialog petunjuk; state Missing dan gerbang Closed |
| Di luar jangkauan | Aturan server menolak prompt surat dari spawn |
| Pesan gameplay palsu | Deliver/Collect dari client diabaikan; tidak memberi surat atau membuka gerbang |
| Token Close salah | Ditolak saat dialog baru aktif |
| Ambil surat | E mengubah state menjadi Carrying dan membuka dialog penemuan |
| Ambil ulang | Tiga percobaan ulang setelah prompt diaktifkan lokal tidak memberi dialog/progres tambahan |
| Ketersediaan pemain lain | Prompt surat di server tetap Enabled setelah satu pemain mengambil |
| Continue | Tombol mouse menutup halaman akhir; Enter melanjutkan halaman dialog |
| Tombol X | Menutup dialog dan melepas lock server; surat yang sudah diambil tetap ada |
| Timeout dialog | Dialog yang dibiarkan terbuka menutup otomatis dan lock server terlepas |
| Respawn membawa surat | Carrying tetap ada; dialog tertutup, surat tetap tersembunyi, R6/kamera tetap benar |
| Serahkan surat | State Delivered, dialog penerimaan, dan animasi gerbang dimulai server |
| Collision animasi | Aktif selama Opening; nonaktif setelah State Open dan panel Y=15.3 |
| Gerbang tertutup | Gerak W tertahan pada Z sekitar -176 |
| Jalur samping | Gerak W pada X=30 juga tertahan setelah batas jalur ditambahkan |
| Gerbang terbuka | Pemain berjalan melewati gerbang hingga Z sekitar -195.59 |
| Serahkan ulang | Dialog AlreadyDelivered; panel tidak bergerak lebih tinggi |
| Respawn setelah menyerahkan | Delivered tetap ada, GUI tidak terduplikasi, NPC masih bisa diajak bicara |
| UI sempit | Speaker, isi, nomor halaman, dan tombol diperiksa pada panel lebar 280 piksel |
| NPC statis | Pivot diperbaiki; telapak kaki di Y=0.2 sesuai permukaan tanah |
| Regresi Phase 1 | VerifyPhase1 lulus: 373 Parts anchored dan 55 sampel jalur |
| Sinkronisasi source | Seluruh 8 file Luau tersinkron cocok antara disk dan Studio |

Sesi tes pertama tidak dimulai dari progres kosong; tes diulang pada sesi bersih.
Assert NPC tenggelam dan bypass samping sempat gagal, kemudian keduanya diperbaiki
dan diuji ulang. Pemeriksaan awal tombol dilakukan terlalu cepat sebelum satu
frame UI selesai; pemeriksaan setelah frame berjalan membuktikan tombol berfungsi.
Log sesi final hanya menunjukkan warning internal Roblox UIBlox/FoundationProvider,
tanpa error runtime dari script Phase 2.

## Checkpoint dan pemulihan

tools/BuildPhase2.luau membangun tambahan scene, GUI, dan network pada mode Edit.
Builder menolak overwrite bila instance Phase 2 sudah ada. Jangan memasangnya
sebagai Script gameplay. tools/TestPhase2Progress.luau menguji tabel progres
terisolasi; tools/VerifyPhase2.luau memeriksa struktur awal tanpa mengubah scene.

Objek non-script ditempatkan di luar root Script Sync. Source tetap di src; GUI,
NPC, surat, gerbang, dan RemoteEvent disimpan dalam place. Backup lengkap lokal:
D:\Projects\BARA-1946\backups\BARA-Phase2-verified.rbxl.
Place disimpan pengguna pada 09:53:40 WIB, ukuran 123017 byte. Hash SHA256 place
asal dan backup sama:
C14A27EAFB8691E3BDFEB036AFE99602F02EF26903B638242EC8312D6D5F2BAC.
Backup tidak masuk Git. Studio selesai dalam mode Edit dengan gerbang awal Closed.

## Batas

Progres bertahan setelah respawn selama pemain berada di server yang sama.
Belum ada DataStore: keluar/rejoin atau server baru memulai progres baru.
Isolasi dua pemain diuji melalui tabel progres terpisah; sesi multiplayer nyata
belum dijalankan. HP fisik, touch, gamepad, dan server published belum diuji.
Panel sempit adalah pengujian ukuran UI di desktop, bukan verifikasi perangkat HP.
