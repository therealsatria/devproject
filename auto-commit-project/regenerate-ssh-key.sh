#!/bin/bash
# Periksa apakah file .env ada
if [ ! -f ".env" ]; then
  echo "File .env tidak ditemukan di direktori saat ini. Pastikan file .env sudah dibuat."
  exit 1
fi

# Muat variabel dari .env
set -a
source .env
set +a

# Gunakan direktori saat ini sebagai basis untuk folder ssh
PROJECT_DIR=$PWD

# Periksa apakah direktori ssh ada
if [ ! -d "ssh" ]; then
  echo "Direktori ssh tidak ditemukan. Membuat direktori..."
  mkdir -p ssh
fi

# Gunakan GIT_USER_EMAIL dari .env, fallback ke bot@example.com jika tidak ada
EMAIL=${GIT_USER_EMAIL:-bot@example.com}

# Hapus kunci SSH yang sudah ada
rm -f ssh/id_rsa ssh/id_rsa.pub

# Buat SSH key baru
ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f ssh/id_rsa -N ""

# Set izin yang benar untuk SSH key
chmod 600 ssh/id_rsa
chmod 644 ssh/id_rsa.pub

# Tampilkan public key untuk ditambahkan ke GitHub/GitLab
echo "Kunci publik baru untuk ditambahkan ke GitHub/GitLab:"
cat ssh/id_rsa.pub

# Catatan untuk pengguna
echo "Kunci SSH telah diregenerasi di $PROJECT_DIR/ssh."
echo "Tambahkan kunci publik di atas ke pengaturan SSH di GitHub/GitLab."
echo "Jika container sedang berjalan, restart dengan 'podman-compose down && podman-compose up -d' untuk menggunakan kunci baru."
