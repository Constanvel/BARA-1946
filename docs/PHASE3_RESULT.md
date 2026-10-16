# Phase 3 — Arcade Combat & Health

Status: alur utama terverifikasi pada satu client Studio desktop, 16 Oktober 2026.
Phase 1 dan Phase 2 dipertahankan. Tidak ada fase lanjutan yang dikembangkan.

## Cara bermain

1. Ambil surat dan serahkan ke pos pejuang untuk membuka jalur pengungsian.
2. Ikuti jalur ke utara menuju arena. Dekati papan sekitar (7, 2.2, -282), tahan E.
3. Bergerak memakai WASD/Space dan hadapkan karakter ke lawan. Tekan J untuk aksi.
4. Kalahkan kedua lawan, lalu lewati gerbang keluar untuk kembali menjelajah.
5. Jika HP habis, pilih Retry untuk memulai arena kembali atau Main Menu.
6. Main Menu menyediakan pilihan memulai arena atau kembali menjelajah map.

## Implementasi

- Aksi J memiliki cooldown server 0.5 detik, jangkauan 6 stud, dan pemeriksaan arah.
- Raycast terhadap rintangan statis mencegah aksi menembus cover.
- Pemain memakai Humanoid dengan MaxHealth 3; lawan memiliki state HP 1 pada model.
- Damage sah mengurangi satu HP. Invincibility pemain berlangsung 1.1 detik.
- Lawan blocky menggunakan state Idle, Detect, Chase, Action, dan Defeated.
- AI server berjalan 10 kali per detik, dibatasi arena, dengan Blockcast dan gerak
  geser sederhana. Tidak ada script AI yang disalin ke masing-masing model.
- Feedback berupa kilatan krem untuk aksi, telegraph outline lawan, dan flash amber
  ketika terkena damage. Tidak ada efek kekerasan grafis atau senjata realistis.
- Dua model lawan digunakan ulang pada Retry; tidak di-clone setiap ronde.
- Gerbang keluar dianimasikan selama 1.2 detik dan melepas collision setelah selesai.
- Token ronde dan pembatalan tween mencegah callback ronde lama membuka gerbang baru.
- Game Over bertahan sampai pemain memilih tombol. Retry memulihkan HP, posisi,
  dua lawan, dan gerbang; Main Menu mengembalikan pemain ke spawn map.

Arena berada setelah jalur pengungsian, dengan jembatan penghubung, tiga cover,
gerbang masuk/keluar, dan teras keluar. Tambahan Phase 3 berjumlah 32 BaseParts;
373 Parts Phase 1 dan 16 Parts Phase 2 tetap ada. Tidak mengambil model Toolbox.

Arena bersama hanya menerima satu pemain aktif. Pemain lain mendapat pemberitahuan
jika mencoba masuk. Ini pembatasan prototipe, bukan arena multiplayer per pemain.

## Source dan penyimpanan

| File | Tanggung jawab |
| --- | --- |
| src/ServerScriptService/BARA/CombatRules.luau | HP, cooldown, invincibility, arah/jarak aksi, batas arena |
| src/ServerScriptService/BARA/ArcadeEnemy.luau | State lawan, gerak, telegraph, reset dan defeat |
| src/ServerScriptService/BARA/CombatServer.server.luau | Validasi server, pemilik arena, damage, gerbang, lifecycle karakter |
| src/StarterPlayerScripts/BARA/CombatClient.local.luau | Input J, HUD, feedback dan tombol menu |
| tools/BuildPhase3.luau | Builder Edit sekali jalan untuk scene, UI, RemoteEvent, dan override Health |
| tools/TestPhase3Rules.luau | 16 assert aturan combat terisolasi |
| tools/TestPhase3Retry.luau | Assert kondisi sesudah Retry pada sesi Play |
| tools/VerifyPhase3.luau | Pemeriksaan struktur awal pada mode Edit |

Client hanya mengirim perintah; damage, target, HP, cooldown, pemilik, kondisi
karakter, jarak, dan rintangan ditentukan server. Payload tambahan ditolak.
CombatEvent ditempatkan dalam ReplicatedStorage.BARA_Network yang sudah ada.

Source dalam src menggunakan Script Sync yang sama. Model, GUI BARA_Combat,
RemoteEvent, serta Script kosong Health di StarterPlayer.StarterCharacterScripts
disimpan di place. Builder mempertahankan scene lama dan menolak overwrite arena.
Jangan memasang builder sebagai Script runtime.

Override Health mencegah regenerasi bawaan Roblox mengubah HP arcade; penempatan
Script kosong bernama Health mengikuti [dokumentasi Humanoid Roblox](https://create.roblox.com/docs/reference/engine/classes/Humanoid).
Runtime memakai CharacterAutoLoads=false untuk mempertahankan layar Game Over.
Respawn eksplorasi tetap dijalankan server setelah waktu respawn normal.

## Pengujian aktual

| Kasus | Hasil |
| --- | --- |
| Aturan combat | 16 assert lulus, mencakup batas cooldown, HP, invincibility, arah dan jarak |
| Masuk arena | E memulai ronde, memindahkan pemain ke titik awal, HP 3 |
| Input J | Aksi diterima dan feedback terlihat |
| Spam cooldown | 12 permintaan beruntun menghasilkan satu Swing; setelah 0.55 detik, burst berikut menghasilkan satu Swing tambahan |
| Payload palsu | Damage 999 dan payload target/damage tambahan ditolak |
| Perintah menu tidak sah | Retry/Main Menu saat ronde aktif diabaikan |
| Cover | Target dalam jangkauan tetap HP 1 jika terhalang rintangan |
| Orientasi | Target di belakang tidak terkena; setelah pemain menghadap target, target menjadi Defeated |
| State AI | Idle, Detect, Chase, Action dan Defeated diamati dalam Play |
| HP dan invincibility | HP turun 3 → 2 → 1 → 0; dua telegraph bersamaan hanya mengurangi satu HP |
| Regenerasi | Setelah HP 2, dijauhkan dari lawan dan ditunggu 6.2 detik; HP atribut dan Humanoid tetap 2 |
| Game Over | Humanoid benar-benar 0, panel tampil, tidak auto-respawn setelah 5.5 detik |
| Retry | Tombol nyata memulihkan HP 3, karakter tidak anchored, dua lawan HP 1, gerbang terkunci, dan kepemilikan ronde benar |
| Main Menu | Tombol nyata mengembalikan ke spawn map, HP 3, panel menu tampil |
| Pilihan menu | Jelajah mengembalikan mode Explore; Mulai memulai arena baru |
| Objective arena | Lawan pertama menyisakan satu; lawan kedua membuat Completed dan sisa nol |
| Gerbang | Collision tetap aktif selama animasi, nonaktif setelah selesai; pemain berjalan sampai Z sekitar -400.08 |
| Keluar arena | Kepemilikan dilepas dan mode Explore dipulihkan |
| Duplikasi | Setelah beberapa ronde/menu, tetap dua model lawan, satu CombatEvent dan satu GUI combat |
| Regresi surat/respawn | Carrying bertahan setelah kematian di luar arena; setelah respawn surat bisa diserahkan |
| Regresi kamera | Offset kamera (0, 1.5, 0) tetap terpasang pada karakter baru |
| Regresi struktur | VerifyPhase1, VerifyPhase2, dan VerifyPhase3 lulus pada Edit setelah tes Play |
| Sinkronisasi | Seluruh 12 file Luau dalam src cocok dengan source Studio |
| Log final | Tidak ada error runtime script proyek; warning internal UIBlox/FoundationProvider masih terlihat |

Bug yang ditemukan dan diperbaiki:

- Retry awal melepaskan pemilik arena karena CharacterAdded dan LoadCharacterAsync
  selesai pada urutan berbeda. Penanda pendingLoad dikonsumsi sebelum callback
  melakukan yield; AI menunggu konfigurasi karakter selesai. Tes Retry yang semula
  gagal kemudian lulus pada sesi Play baru dengan source final.
- Override Health awal diletakkan dalam template karakter; script regenerasi bawaan
  masih masuk pada runtime. Dipindahkan ke StarterCharacterScripts dan diverifikasi
  pada karakter baru; tes HP 2 setelah 6.2 detik lulus.

## Checkpoint place

Pengguna menyimpan place setelah sesi Play dihentikan. Studio akhir dalam mode Edit.

- Place: D:\bara-1946\Place1.rbxl
- Waktu simpan: 16 Oktober 2026, 10:18:15 WIB
- Ukuran: 131291 byte
- Backup: D:\Projects\BARA-1946\backups\BARA-Phase3-verified.rbxl
- SHA256 asal dan backup: CC26F679A159D90FAEED4BF5C6E58BD82E2B16C5D2D50076935F8444A32122B7

Backup diabaikan Git. Commit menyimpan source, builder, tes, dan laporan;
map lengkap harus dipulihkan dari file place/backup lokal.

## Batas pengujian

Pengujian menggunakan satu client desktop dan keyboard/mouse di Studio. Multiplayer
nyata, perangkat mobile/gamepad, server published, serta profil FPS Phase 3 belum
diuji. Arena hanya satu pemain aktif; status combat tidak memakai DataStore.

AI menghindari cover melalui gerak geser sederhana dan dapat tertahan pada susunan
rintangan tertentu. Gunakan pathfinding jika desain arena kelak menuntut navigasi
lebih rumit. Tidak ada combo, persenjataan realistis, atau sistem fase berikutnya.
