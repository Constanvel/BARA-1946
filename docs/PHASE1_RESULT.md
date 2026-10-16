# Phase 1 — 3D Foundation & Environment

Status: playable dan terverifikasi pada satu client Studio desktop, 16 Oktober 2026.
Pekerjaan berhenti di Phase 1. Belum ada sistem interaksi, dialog, misi, atau combat.

## Implementasi

- Movement, animasi, input WASD/Space, dan controller kamera bawaan Roblox dipertahankan.
- Rig blocky R6 berasal dari generator rig Roblox, tanpa model Toolbox.
- FoundationCamera hanya memberi offset fokus 1,5 stud dan framing awal saat spawn.
  Kamera tetap Custom/Classic dengan zoom 10–26 stud dan occlusion bawaan.
- Workspace.BARA_Phase1 berisi 373 Parts, seluruhnya anchored, dalam area modular.
- Area01_Kampung: empat rumah warga, atap genteng, pagar, pohon, dan peti.
- Area02_Kolonial: dua gedung berpilar, dua rumah toko, simpang, dan tiang lampu.
- Area03_PosPejuang: pos, bendera, peti, perlindungan sederhana, dan jalur pengungsian.
- GroundAndRoads menyambungkan area; PerimeterAndBackdrop memberi batas dan pendar oranye.
- Warna desaturated, grade sepia, senja 17.5, atmosfer ringan, dan material sederhana.
- Empat PointLight tanpa shadow; tidak ada generator yang berjalan saat gameplay.
- SpawnLocation dan Baseplate lama dipertahankan, lalu disesuaikan untuk map.
- Modul SyncConnectionTest tetap ada; source lama tidak ditimpa.

Layout ini interpretasi lingkungan untuk prototipe, bukan rekonstruksi geografis
Bandung 1946. Bangunan pada fase ini dieksplorasi dari luar; interior belum dibuat.

## Pengujian aktual

| Pemeriksaan | Hasil |
| --- | --- |
| Test sebelum implementasi | VerifyPhase1 gagal karena environment belum dibangun |
| Struktur akhir | LULUS: tiga area, tanah/jalan, dan properti ada |
| Anchor / budget | LULUS: 373 Parts anchored, di bawah budget 850 |
| Jalur utama | LULUS: 55 sampel bebas collider pada koridor selebar 8 stud dan memiliki tanah |
| Spawn | LULUS: R6 spawn di sekitar (0, 4.2, 72), health 100 |
| WASD | Input keyboard nyata bergerak; 180 frame menempuh sekitar 48 stud |
| Space | LULUS: karakter naik menjadi sekitar Y=10 lalu kembali ke tanah |
| Tiga area | LULUS: berjalan dari kampung melalui kota hingga Z=-197.23 tanpa teleport |
| Collision rumah | LULUS: dari X=20, tombol D dua detik berhenti pada X=31.50 di dinding rumah |
| Kamera | LULUS: subject Humanoid, offset (0,1.5,0), LookVector.Y sekitar -0.518 |
| Kamera berjalan | Langkah kamera maksimum sekitar 0.4 stud pada sampel gerak |
| Respawn | LULUS: R6, spawn, health, dan offset kamera kembali benar |
| Visual | Screenshot overview dan view pemain diperiksa; lighting awal yang terlalu gelap diperbaiki |
| Performa desktop | 180 frame / 2.999 detik: rata-rata 60.02 FPS; p95 17.84 ms |
| Source sync | FoundationCamera.local.luau muncul sebagai LocalScript di Studio |
| Backup model | LULUS: file disk cocok byte, deserialize menghasilkan map 373 Parts dan rig |
| Akhir pengujian | Studio kembali Edit; tidak melanjutkan fase berikutnya |

Log playtest memuat warning internal CorePackages/UIBlox FoundationProvider.
Tidak ditemukan error runtime dari FoundationCamera pada pengujian ini.
Assert gagal sebelum implementasi adalah bagian dari pengujian, bukan error akhir.

## File dan pemulihan

- src/StarterPlayerScripts/BARA/FoundationCamera.local.luau: source tersinkron.
- tools/BuildPhase1.luau: pembangun geometry, lighting, spawn, dan setting kamera.
- tools/ConfigureR6.luau: pembuat StarterCharacter R6.
- tools/VerifyPhase1.luau: pemeriksaan struktur dan koridor tanpa mengubah scene.

Jalankan tools melalui execute_luau pada mode Edit, bukan sebagai Script gameplay.
Builder sengaja berhenti jika BARA_Phase1 sudah ada agar hasil edit tidak tertimpa.
Untuk pemulihan dari place kosong yang memiliki Baseplate dan SpawnLocation:
aktifkan kembali Script Sync, jalankan BuildPhase1 lalu ConfigureR6, kemudian VerifyPhase1.
Jangan menjalankan pembangun lagi pada map yang sudah diedit.

Place tersimpan oleh pengguna di D:\bara-1946\Place1.rbxl pada 09:33:31 WIB,
ukuran 106137 byte. Salinan lengkap lokal:
D:\Projects\BARA-1946\backups\BARA-Phase1-verified.rbxl.
SHA256 keduanya:
E8C2733EB68C521D4571555082AC5A619A9E3F09CEEF9106970B4AEF9135EDF6.

Backup model tambahan: backups/BARA-Phase1-scene-and-rig.rbxm, 34349 byte.
SHA256: 40DFAFBD431BEC2C968A2110B2DA80F73CCF8E40A59620E721D2C654DCD965AB.
Model berisi BARA_Phase1 dan StarterCharacter; bukan pengganti backup seluruh place.
Seluruh backups tetap lokal dan di-ignore Git.

## Batas verifikasi

Belum diuji pada HP fisik, multiplayer, jaringan lambat, atau server published.
FPS adalah sampel singkat Studio di komputer saat ini, bukan jaminan perangkat lain.
Orbit mouse/zoom ekstrem dan collision setiap sudut properti belum diuji menyeluruh.
Fondasi berikutnya harus tetap menjaga movement dan jalur yang sudah lulus ini.
