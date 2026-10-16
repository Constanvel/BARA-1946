# Script Sync

## Checkpoint manual sebelum sinkronisasi

Studio yang diperiksa membuka D:\bara-1946\Place1.rbxl, PlaceId 0.
Simpan melalui File > Save to File / Save As setelah folder dan modul uji dibuat.
Disarankan simpan sebagai D:\Projects\BARA-1946\backups\BARA-1946.rbxl.
Cadangan sebelum setup sudah dibuat dari file place yang ada di disk, bukan
snapshot perubahan Studio yang belum disimpan.

Di Explorer, klik kanan setiap Folder BARA berikut, pilih Sync to..., lalu arahkan
ke direktori tujuan. Periksa tujuan dialog agar file masuk ke subtree yang sesuai.
Jangan menyinkronkan service, ScreenGui, model, atau Part sebagai pengganti Folder.

| Folder di Studio | Direktori lokal |
| --- | --- |
| ServerScriptService.BARA | D:\Projects\BARA-1946\src\ServerScriptService |
| ReplicatedStorage.BARA | D:\Projects\BARA-1946\src\ReplicatedStorage |
| StarterPlayer.StarterPlayerScripts.BARA | D:\Projects\BARA-1946\src\StarterPlayerScripts |
| StarterGui.BARA | D:\Projects\BARA-1946\src\StarterGui |

Pemetaan di atas adalah direktori yang dipilih pada dialog Sync to.... Studio
membuat subfolder BARA di dalam masing-masing tujuan. Path source aktual adalah
src/<layanan>/BARA; keempat pemetaan sudah diperiksa lewat GetSyncedInstance.

Belum ada GUI pada pemeriksaan awal. Folder StarterGui.BARA hanya tempat script
GUI mendatang; ScreenGui dan elemen visual harus tetap dikelola di Studio.
LocalScript GUI yang berada di dalam ScreenGui nantinya perlu sync terpisah pada
script atau Folder yang didukung, tanpa memindah hierarki GUI yang berfungsi.

Jika terdapat dialog konflik, berhenti dan tinjau daftar perubahan; jangan pilih
Keep Studio atau Keep Disk secara otomatis.

## Prosedur pengujian

ModuleScript ReplicatedStorage.BARA.SyncConnectionTest dibuat hanya di Studio.
Marker awal studio-initial, version 1. Tidak ada Script yang require modul ini,
sehingga tidak menjalankan gameplay.

1. Setelah sync aktif, pastikan SyncConnectionTest.luau muncul otomatis di disk.
2. Ubah marker lokal menjadi local-roundtrip, simpan, lalu baca Source di MCP.
3. Ubah marker di Studio menjadi studio-roundtrip, lalu baca file dari terminal.
4. Verifikasi status InstanceFileSyncService bebas konflik untuk semua root.
5. Simpan place lagi dan pertahankan modul uji sampai koneksi stabil.
6. Setelah seluruh tes lulus, perbarui status, tinjau staged files, commit:
   chore: initialize BARA 1946 Roblox development environment
7. Push main dan cocokkan SHA lokal dengan GitHub.

Jangan membuat salinan modul secara manual di disk untuk mengklaim sync berhasil.

Hasil setup: langkah kemunculan otomatis, disk ke Studio, dan Studio ke disk lulus
pada SyncConnectionTest; marker akhir studio-roundtrip. Keempat root SyncedAsRoot.
Simpan place melalui File > Save to File agar perubahan terbaru di memori Studio
juga masuk ke file place; Git hanya menyimpan source code dan konfigurasi.

## Language server

Ekstensi VS Code: JohnnyMorganz.luau-lsp.
Plugin pendamping resmi pengembang ekstensi:
https://www.roblox.com/library/10913122509/Luau-Language-Server-Companion

Pasang plugin di Studio dan tekan Connect. Pengaturan workspace mengaktifkan
studioPlugin; tidak ada Rojo sourcemap. Plugin ini memberi konteks DataModel,
bukan mesin sinkronisasi file.

Referensi: https://create.roblox.com/docs/scripting/sync
