# BARA 1946

Game sejarah Indonesia dengan visual retro PS1 low-poly, dibuat memakai Roblox
Studio dan Luau. Repository source code: https://github.com/Constanvel/BARA-1946.

## Development

Roblox Studio untuk map, model, environment, dan playtest. VS Code + Codex untuk
source code. Script Sync bawaan Studio menghubungkan source dan instance script.
Git dan GitHub menyimpan riwayat source; file place dicadangkan secara terpisah.

Buka BARA-1946.code-workspace di VS Code. Luau Language Server menyediakan
syntax highlighting dan language server. Dukungan hierarki DataModel memerlukan
plugin Luau Language Server Companion di Studio dan koneksi plugin ke VS Code.

## Struktur

```text
src/
  ServerScriptService/
  ReplicatedStorage/
  StarterPlayerScripts/
  StarterGui/
docs/
backups/                    cadangan lokal, tidak masuk Git
.vscode/
AGENTS.md
BARA-1946.code-workspace
```

Pemetaan dan langkah aktivasi ada di docs/SCRIPT_SYNC.md. Status pengujian nyata
ada di docs/SETUP_STATUS.md. Keempat Folder BARA sudah tersinkron ke subfolder
src/<layanan>/BARA. Tes dua arah lulus pada modul SyncConnectionTest di
ReplicatedStorage. File .gitkeep mempertahankan folder kosong di Git.

## Workflow harian

1. Buka place Roblox dan workspace VS Code yang sesuai.
2. Pastikan Script Sync aktif dan bebas konflik.
3. Minta Codex mengedit file src yang relevan di repository ini.
4. Verifikasi perubahan muncul di Studio, lalu lakukan playtest.
5. Simpan place dan buat backup lokal terpisah jika map berubah.
6. Tinjau git diff dan git status; stage hanya file yang telah ditinjau.
7. Buat commit, lalu git push origin main.

Selama sesi edit, gunakan file lokal sebagai sumber perubahan script. Hindari
mengedit script yang sama di Studio dan VS Code secara bersamaan. Studio tetap
menjadi sumber map dan model. Jangan pilih overwrite otomatis saat konflik.

Jangan menjalankan Rojo pada folder yang sama. Jangan simpan token atau password.

Referensi:
- https://create.roblox.com/docs/scripting/sync
- https://github.com/JohnnyMorganz/luau-lsp
